import io
import os
import json
import cx_Oracle
from fdk import response


def handler(ctx, data: io.BytesIO=None):
    resp = dbaccess(data)

    return response.Response(
        ctx, response_data=json.dumps(
            {"message": resp}),
        headers={"Content-Type": "application/json"}
    )

def dbaccess(data):
    
    try: 
        adb_admin_user = "admin"
        adb_admin_password = os.getenv('ADB_ADMIN_PASSWORD')
        adb_app_user_name = os.getenv('ADB_APP_USER_NAME')
        adb_app_user_password = os.getenv('ADB_APP_USER_PASSWORD')
        adb_sqlnet_alias = os.getenv('ADB_SQLNET_ALIAS')

        ## Connecting as ATP ADMIN User, creation of user for iot_data table

        connection = cx_Oracle.connect(adb_admin_user, adb_admin_password, adb_sqlnet_alias)
        cursor = connection.cursor()

        rs = cursor.execute("create user {} identified by {}".format(adb_app_user_name,adb_app_user_password))
        rs = cursor.execute("grant create session to {}".format(adb_app_user_name))
        rs = cursor.execute("grant create table to {}".format(adb_app_user_name))
        rs = cursor.execute("grant create sequence to {}".format(adb_app_user_name))
        rs = cursor.execute("grant unlimited tablespace to {}".format(adb_app_user_name))

        cursor.close()
        connection.close()

        ## Connecting as ADB User, creation of customers table with three iot_data records.

        connection2 = cx_Oracle.connect(adb_app_user_name, adb_app_user_password, adb_sqlnet_alias)
        cursor2 = connection2.cursor()
        
        rs = cursor2.execute('''create table iot_data (id number, iot_key varchar2(1000), iot_data varchar2(1000), CONSTRAINT iot_data_pk PRIMARY KEY (id))''')
        rs = cursor2.execute('''insert into iot_data values (1,'machine1','1234567890')''')
        rs = cursor2.execute('''insert into iot_data values (2,'machine2','2345678901')''')
        rs = cursor2.execute('''insert into iot_data values (3,'machine3','3456789012')''')
        rs = cursor2.execute('COMMIT')

        rs = cursor2.execute("create sequence iot_data_seq start with 3 increment by 1 nocache nocycle")
        rs = cursor2.execute("select iot_data_seq.nextval from DUAL")

        cursor2.close()
        connection2.close()

    except Exception as e:
        return {"Result": "Not connected to ADB! Exception: {}".format(str(e)),}

    return {"Result": "Success! User with privileges created, table iot_data populated.", }
 