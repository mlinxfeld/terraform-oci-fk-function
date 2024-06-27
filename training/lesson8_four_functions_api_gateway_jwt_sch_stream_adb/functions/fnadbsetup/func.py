import base64
import datetime
import io
import json
import logging
import oci
import os
import re
import secrets
import string
import subprocess
import oracledb
from fdk import response
from zipfile import ZipFile

def setup_oci_client(client_type, signer, stream_endpoint):
    try:
        if DEBUG_MODE:
            logging.getLogger().info(f'Trying to get {client_type} Client using instance principals....')

        if client_type == 'adb':
            oci_client = oci.database.DatabaseClient(config={}, signer=signer)
        elif client_type == 'streaming':
            oci_client = oci.streaming.StreamClient(config={}, signer=signer, service_endpoint=stream_endpoint)
        elif client_type == 'ons':
            ons_client = oci.ons.NotificationDataPlaneClient(config={}, signer=signer)
        else:
            logging.getLogger().info(f'Invalid Client type {client_type}')
            quit()

        if DEBUG_MODE:
            logging.getLogger().info(f'Got {client_type} Client ok')

        return oci_client

    except Exception as fc:
        logging.getLogger().info(f'Raised exception: {str(fc)} attempting to initialize {client_type} Client')
        quit()

# ----------------------------------------------------------------------------------------------------------------------

def valid_pw(password):
    if not any(c.isdigit() for c in password):
        return False
    return True

# ----------------------------------------------------------------------------------------------------------------------

def read_and_log_file_content(file_path):
    try:
        with open(file_path, 'r') as file:
            content = file.read()
        logging.getLogger().info(f"Content of {file_path}:\n{content}")
    except FileNotFoundError:
        logging.getLogger().error(f"The file {file_path} does not exist.")
    except IOError:
        logging.getLogger().error(f"An error occurred while reading the file {file_path}.")

# ----------------------------------------------------------------------------------------------------------------------

def get_wallet_from_adb(adb_client, adb_ocid, wallet_dir):
    os.makedirs(wallet_dir, exist_ok=True)

    if DEBUG_MODE:
        logging.getLogger().info(f'Trying to get wallet for ADB: {adb_ocid}')

    adb_wallet_pwd = ''
    while not valid_pw(adb_wallet_pwd):
        adb_wallet_pwd = ''.join(secrets.choice(string.ascii_uppercase + string.digits) for i in range(15)) # random string
        
    adb_wallet_details = oci.database.models.GenerateAutonomousDatabaseWalletDetails(password=adb_wallet_pwd)

    if DEBUG_MODE:
        logging.getLogger().info(f'Wallet details: {adb_wallet_details}')

    wallet_data = adb_client.generate_autonomous_database_wallet(adb_ocid, adb_wallet_details)

    if DEBUG_MODE:
        logging.getLogger().info(f'Storing the wallet: {wallet_dir}{os.sep}dbwallet.zip')

    with open(wallet_dir + os.sep + 'dbwallet.zip', 'w+b') as f:
        for chunk in wallet_data.data.raw.stream(1024 * 1024, decode_content=False):
            f.write(chunk)

    if DEBUG_MODE:
        logging.getLogger().info(f'Unziping the wallet to directory {wallet_dir}')

    with ZipFile(wallet_dir + os.sep + 'dbwallet.zip', 'r') as zipObj:
            zipObj.extractall(wallet_dir)

    # Check if extraction was successful and list files
    if os.path.exists(wallet_dir):
        extracted_files = os.listdir(wallet_dir)
        if DEBUG_MODE:
            logging.getLogger().info(f'Extracted files: {extracted_files}')
    else:
        logging.getLogger().error('Extraction failed: directory does not exist')

    # Define the file paths
    tnsnames_file = os.path.join(wallet_dir, 'tnsnames.ora')
    sqlnet_file = os.path.join(wallet_dir, 'sqlnet.ora')

    # Read and log the content of tnsnames.ora
    if DEBUG_MODE:
        read_and_log_file_content(tnsnames_file)

    if DEBUG_MODE:
    # Read and log the content of sqlnet.ora
        read_and_log_file_content(sqlnet_file)  

# ----------------------------------------------------------------------------------------------------------------------

# Setting environment
DEBUG_MODE = os.getenv("DEBUG_MODE") is not None
adb_ocid = os.getenv('ADB_OCID')
oracle_home = os.getenv('ORACLE_HOME')
adb_admin_user = "admin"
adb_admin_password = os.getenv('ADB_ADMIN_PASSWORD')
adb_app_user_name = os.getenv('ADB_APP_USER_NAME')
adb_app_user_password = os.getenv('ADB_APP_USER_PASSWORD')
adb_sqlnet_alias = os.getenv('ADB_SQLNET_ALIAS')
adb_wallet_dir = '/tmp'

if DEBUG_MODE:
    logging.getLogger().info(f'Getting signer using instance principals...')
signer = oci.auth.signers.get_resource_principals_signer()
if DEBUG_MODE:
    logging.getLogger().info(f'Got signer ok')

adbClient = setup_oci_client('adb', signer,'')

# Download the DB Wallet
try:
    if DEBUG_MODE:
        logging.getLogger().info(f'Retrieving wallet from ADB: {adb_ocid}.')
    get_wallet_from_adb(adbClient, adb_ocid, adb_wallet_dir)
    if DEBUG_MODE:
        logging.getLogger().info(f'DB wallet dir content = {os.listdir(adb_wallet_dir)}')
        logging.getLogger().info(f'ORACLE_HOME content = {os.listdir(oracle_home)}')
except Exception as w:
    logging.getLogger().error(f'Error retrieving DB wallet from ADB: {w}')

# Update SQLNET.ORA
try:
    if DEBUG_MODE:
        logging.getLogger().info(f'Updating sqlnet.ora.')
    with open(adb_wallet_dir + '/sqlnet.ora') as sqlnet_ora_orig:
        newText=sqlnet_ora_orig.read().replace('DIRECTORY=\"?/network/admin\"', 'DIRECTORY=\"{}\"'.format(adb_wallet_dir))
    with open(adb_wallet_dir + '/sqlnet.ora', "w") as sqlnet_ora_new:
        sqlnet_ora_new.write(newText)
except Exception as s:
    logging.getLogger().error("Error updating sqlnet.ora: {s}")

# ----------------------------------------------------------------------------------------------------------------------

def handler(ctx, data: io.BytesIO=None):

# --- DB client initialization

    try:
        oracledb.init_oracle_client(lib_dir=oracle_home)
        if DEBUG_MODE:
            logging.getLogger().info(f'DB client initialized.')
    except Exception as ex:
        logging.getLogger().error(f'Error initializing the DB client: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors.')

        return response.Response(
            ctx,
            response_data=json.dumps({'status' : 1
                                      ,'step' : 'DB client initialization'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- DB Connection for ADMIN User

    try:
        if DEBUG_MODE:
            logging.getLogger().info(f'oracledb.connect(user={adb_admin_user}, password={adb_admin_password}, dsn={adb_sqlnet_alias}, config_dir={adb_wallet_dir}, wallet_location={adb_wallet_dir})')        
        adb_connection = oracledb.connect(user=adb_admin_user, password=adb_admin_password, dsn=adb_sqlnet_alias, config_dir=adb_wallet_dir, wallet_location=adb_wallet_dir)
        if DEBUG_MODE:
            logging.getLogger().info(f'DB connection acquired for ADMIN User (dsn={adb_sqlnet_alias}).')
    except Exception as ex:
        logging.getLogger().error(f'Error getting DB connection for ADMIN User (dsn={adb_sqlnet_alias}): {ex}.')
        logging.getLogger().info(f'Leaving handler w/errors.')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'DB Connection for ADMIN User'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- Cursor creation for ADMIN User

    try:
        adb_cursor = adb_connection.cursor()

        if DEBUG_MODE:
            logging.getLogger().info(f'DB cursor created for ADMIN User.')
    except Exception as ex:
        logging.getLogger().error(f'Error creating DB cursor for ADMIN User: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors.')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'DB cursor creation for ADMIN User.'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- App User Creation

    try:
        adb_cursor.execute("create user {} identified by {}".format(adb_app_user_name,adb_app_user_password))
        if DEBUG_MODE:
            logging.getLogger().info(f'User {adb_app_user_name} created.')
    except Exception as ex:
        logging.getLogger().error(f'Error creating {adb_app_user_name} user: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'App User Creation'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- Create session to App User

    try:
        adb_cursor.execute("grant create session to {}".format(adb_app_user_name))
        if DEBUG_MODE:
            logging.getLogger().info(f'Create session granted to {adb_app_user_name} user.')
    except Exception as ex:
        logging.getLogger().error(f'Error granting create session to {adb_app_user_name} user: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'Grant create session'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- Create table to App User

    try:
        adb_cursor.execute("grant create table to {}".format(adb_app_user_name))
        if DEBUG_MODE:
            logging.getLogger().info(f'Create table granted to {adb_app_user_name} user.')
    except Exception as ex:
        logging.getLogger().error(f'Error granting create table to {adb_app_user_name} user: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'Grant create table'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- Create sequence to App User

    try:
        adb_cursor.execute("grant create sequence to {}".format(adb_app_user_name))
        if DEBUG_MODE:
            logging.getLogger().info(f'Create sequence granted to {adb_app_user_name} user.')
    except Exception as ex:
        logging.getLogger().error(f'Error granting create sequence to {adb_app_user_name} user: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'Grant create sequence'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- Unlimited tablespace to App User

    try:
        adb_cursor.execute("grant unlimited tablespace to {}".format(adb_app_user_name))
        if DEBUG_MODE:
            logging.getLogger().info(f'Unlimited tablespace granted to {adb_app_user_name} user.')
    except Exception as ex:
        logging.getLogger().error(f'Error granting unlimited tablespace to {adb_app_user_name} user: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'Grant unlimited tablespace'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- Closing cursor for ADMIN User

    try:
        adb_cursor.close()
        if DEBUG_MODE:
            logging.getLogger().info(f'Closed cursor for ADMIN User.')
    except Exception as ex:
        logging.getLogger().error(f'Error closing cursor for ADMIN User: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'Closing cursor for ADMIN User'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- Closing connection for ADMIN User

    try:
        adb_connection.close()
        if DEBUG_MODE:
            logging.getLogger().info(f'Connection closed for ADMIN User.')
    except Exception as ex:
        logging.getLogger().error(f'Error closing connection for ADMIN User: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'Closing connection for ADMIN User'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- DB Connection for APPUSER

    try:
        if DEBUG_MODE:
            logging.getLogger().info(f'oracledb.connect(user={adb_app_user_name}, password={adb_app_user_password}, dsn={adb_sqlnet_alias}, config_dir={adb_wallet_dir}, wallet_location={adb_wallet_dir})')        
        adb_connection = oracledb.connect(user=adb_app_user_name, password=adb_app_user_password, dsn=adb_sqlnet_alias, config_dir=adb_wallet_dir, wallet_location=adb_wallet_dir)
        if DEBUG_MODE:
            logging.getLogger().info(f'DB connection acquired for APPUSER User (dsn={adb_sqlnet_alias}).')
    except Exception as ex:
        logging.getLogger().error(f'Error getting DB connection for APPUSER User (dsn={adb_sqlnet_alias}): {ex}.')
        logging.getLogger().info(f'Leaving handler w/errors.')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'DB Connection for APPUSER'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- Cursor creation for APPUSER 

    try:
        adb_cursor = adb_connection.cursor()

        if DEBUG_MODE:
            logging.getLogger().info(f'DB cursor created for APPUSER.')
    except Exception as ex:
        logging.getLogger().error(f'Error creating DB cursor for APPUSER: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors.')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'DB cursor creation for APPUSER.'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- Create table iot_data

    try:
        adb_cursor.execute('''CREATE TABLE iot_data(id NUMBER, device_id VARCHAR2(1000), temperature NUMBER(5, 2), humidity NUMBER(5, 2), time_stamp TIMESTAMP, CONSTRAINT iot_data_pk PRIMARY KEY (id))''')
        if DEBUG_MODE:
            logging.getLogger().info(f'IOT_DATA table created.')
    except Exception as ex:
        logging.getLogger().error(f'Error creating IOT_DATA table: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'Create table iot_data'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- Inserts into iot_data

    try:
        adb_cursor.execute('''insert into iot_data values (1, 'device1', 89.1, 2.2, TO_TIMESTAMP('2024-06-11 10:00:00', 'YYYY-MM-DD HH24:MI:SS'))''')
        adb_cursor.execute('''insert into iot_data values (2, 'device2', 54.2, 10.5, TO_TIMESTAMP('2024-06-11 10:01:00', 'YYYY-MM-DD HH24:MI:SS'))''')
        adb_cursor.execute('''insert into iot_data values (3, 'device3', 12.5, 11.7, TO_TIMESTAMP('2024-06-11 10:02:00', 'YYYY-MM-DD HH24:MI:SS'))''')
        adb_connection.commit()
        if DEBUG_MODE:
            logging.getLogger().info(f'IOT_DATA table with 3 inserts.')
    except Exception as ex:
        logging.getLogger().error(f'Error inserting into IOT_DATA table: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'Inserts into iot_data'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )


# --- Create sequence iot_data_seq

    try:
        adb_cursor.execute("create sequence iot_data_seq start with 3 increment by 1 nocache nocycle")
        adb_cursor.execute("select iot_data_seq.nextval from DUAL")
        
        if DEBUG_MODE:
            logging.getLogger().info(f'IOT_DATA_SEQ sequence created.')
    except Exception as ex:
        logging.getLogger().error(f'Error creating IOT_DATA_SEQ sequence: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'Create sequence iot_data_seq'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- Closing cursor for APPUSER

    try:
        adb_cursor.close()
        if DEBUG_MODE:
            logging.getLogger().info(f'Closed cursor for APPUSER.')
    except Exception as ex:
        logging.getLogger().error(f'Error closing cursor for APPUSER: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'Closing cursor for APPUSER'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# --- Closing connection for APPUSER

    try:
        adb_connection.close()
        if DEBUG_MODE:
            logging.getLogger().info(f'Connection closed for APPUSER.')
    except Exception as ex:
        logging.getLogger().error(f'Error closing connection for APPUSER: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                      ,'step'       : 'Closing connection for APPUSER'
                                      ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 0
                                      ,'fnadbsetup' : 'Finished'}, indent=2),
            headers={"Content-Type": "application/json"}
        )

# ----------------------------------------------------------------------------------------------------------------------
