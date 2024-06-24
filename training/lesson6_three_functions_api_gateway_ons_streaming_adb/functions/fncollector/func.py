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
import random
import subprocess
import oracledb
from fdk import response
from zipfile import ZipFile
from base64 import b64decode, b64encode

# ----------------------------------------------------------------------------------------------------------------------

def setup_oci_client(client_type, signer, stream_endpoint):
    try:
        if DEBUG_MODE:
            logging.getLogger().info(f'Trying to get {client_type} Client using instance principals....')

        if client_type == 'adb':
            oci_client = oci.database.DatabaseClient(config={}, signer=signer)
        elif client_type == 'streaming':
            oci_client = oci.streaming.StreamClient(config={}, signer=signer, service_endpoint=stream_endpoint)
        elif client_type == 'ons':
            oci_client = oci.ons.NotificationDataPlaneClient(config={}, signer=signer)
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

def generate_random_string(length=8):
    letters = string.ascii_lowercase + string.digits
    return ''.join(random.choice(letters) for i in range(length))

# ----------------------------------------------------------------------------------------------------------------------


# Setting environment
DEBUG_MODE = os.getenv("DEBUG_MODE") is not None

stream_ocid = os.getenv("STREAM_OCID")
stream_endpoint = os.getenv("STREAM_ENDPOINT")

if not stream_ocid or not stream_endpoint:
    error_message = 'Missing configuration key STREAM_OCID or STREAM_ENDPOINT'
    logging.getLogger().error(error_message)

# Database configuration
adb_ocid = os.getenv('ADB_OCID')
oracle_home = os.getenv('ORACLE_HOME')
adb_app_user_name = os.getenv('ADB_APP_USER_NAME')
adb_app_user_password = os.getenv('ADB_APP_USER_PASSWORD')
adb_sqlnet_alias = os.getenv('ADB_SQLNET_ALIAS')
adb_wallet_dir = '/tmp'     

if not adb_ocid or not oracle_home or not adb_app_user_name or not adb_app_user_password or not adb_sqlnet_alias or not adb_wallet_dir:
    error_message = 'Missing database configuration keys'
    logging.getLogger().error(error_message)

if DEBUG_MODE:
    logging.getLogger().info(f'Getting signer using instance principals...')
signer = oci.auth.signers.get_resource_principals_signer()
if DEBUG_MODE:
    logging.getLogger().info(f'Got signer ok')

adbClient = setup_oci_client('adb', signer,'')
streamClient = setup_oci_client('streaming', signer, str("https://" + stream_endpoint))

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

def handler(ctx, data: io.BytesIO = None):

    if DEBUG_MODE:
        logging.getLogger().info('Starting fncollector handler...')

# --- Connect to Stream and obtain message response

    group_name = "iot_consumer_group"
    instance_name = "iot_consumer_instance_" + generate_random_string()

    try:
        # Get messages from the stream

        cursor_details = oci.streaming.models.CreateGroupCursorDetails(
            group_name=group_name,
            instance_name=instance_name,
            type=oci.streaming.models.CreateGroupCursorDetails.TYPE_LATEST,
            commit_on_get=False
        )
        cursor_response = streamClient.create_group_cursor(stream_ocid, cursor_details)    
        stream_cursor = cursor_response.data.value
gi
        get_messages_response = streamClient.get_messages(stream_ocid, stream_cursor, limit=10)

        if DEBUG_MODE:
            logging.getLogger().info(f'Fetched messages from stream: {get_messages_response.data}')

    except Exception as ex:
        logging.getLogger().error(f'Error obtaining data from Stream: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                    ,'step'       : 'Connect to Stream and obtain message response'
                                    ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

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


# --- Update iot_data table with Stream message response

    if len(get_messages_response.data):    
        try:
            for message in get_messages_response.data:
                cursor_result = adb_cursor.execute("select iot_data_seq.nextval from dual")
                rows = cursor_result.fetchone()
                new_id = str(rows).replace(',','')
                new_device = str(b64decode(message.key).decode('utf-8'))
                new_device_data_str = b64decode(message.value).decode('utf-8')
                new_device_data = json.loads(new_device_data_str)
                new_temperature = new_device_data.get('temperature')
                new_humidity = new_device_data.get('humidity')
                iot_record = "insert into iot_data values ({},'{}',{},{},SYSDATE)".format(new_id, new_device, new_temperature, new_humidity)
                adb_cursor.execute(iot_record)
                adb_connection.commit()
                if DEBUG_MODE:
                    logging.getLogger().info(f'IOT_DATA table inserted: ({iot_record}).')

        except Exception as ex:
            logging.getLogger().error(f'Error inserting data into IOT_DATA table: {ex}')
            logging.getLogger().info(f'Leaving handler w/errors')

            return response.Response(
                ctx,
                response_data=json.dumps({'status'     : 1
                                        ,'step'       : 'Update iot_data table with Stream message response'
                                        ,'exception'  : str(ex)}, indent=2),
                headers={"Content-Type": "application/json"}
            )

# --- Closing stream cursor manually

    try:   
        consumer_commit_response = streamClient.consumer_commit(stream_ocid, stream_cursor)    

        if DEBUG_MODE:
            logging.getLogger().info(f'Closing stream cursor manually: {consumer_commit_response.data}.')

    except Exception as ex:
        logging.getLogger().error(f'Error closing stream cursor manually: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                    ,'step'       : 'Closing stream cursor manually'
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
                                  ,'fncollector' : 'Finished'}, indent=2),
        headers={"Content-Type": "application/json"}
    )



# ----------------------------------------------------------------------------------------------------------------------

