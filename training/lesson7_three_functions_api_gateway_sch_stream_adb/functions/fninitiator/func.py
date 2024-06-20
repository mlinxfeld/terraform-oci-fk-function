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

# Setting environment
DEBUG_MODE = os.getenv("DEBUG_MODE") is not None

stream_ocid = os.getenv("STREAM_OCID")
stream_endpoint = os.getenv("STREAM_ENDPOINT")

if not stream_ocid or not stream_endpoint:
    error_message = 'Missing configuration key STREAM_OCID or STREAM_ENDPOINT'
    logging.getLogger().error(error_message)

if DEBUG_MODE:
    logging.getLogger().info(f'Getting signer using instance principals...')
signer = oci.auth.signers.get_resource_principals_signer()
if DEBUG_MODE:
    logging.getLogger().info(f'Got signer ok')

streamClient = setup_oci_client('streaming', signer,str("https://" + stream_endpoint))

def handler(ctx, data: io.BytesIO = None):

    if DEBUG_MODE:
        logging.getLogger().info('Starting fninitiator handler...')
        
# --- Connect to Stream and push the message 

    try:
        body = json.loads(data.getvalue())
        device_id = str(body.get("device_id"))
        device_data = body.get("device_data", {})
        device_data_str = json.dumps(device_data)

        stream_message_entry = oci.streaming.models.PutMessagesDetailsEntry()
        stream_message_entry.key = b64encode(bytes(str(device_id), 'utf-8')).decode('utf-8')
        stream_message_entry.value = b64encode(bytes(device_data_str, 'utf-8')).decode('utf-8')
        
        stream_messages = oci.streaming.models.PutMessagesDetails()
        stream_messages.messages = [stream_message_entry]
        streamClient.put_messages(stream_ocid, stream_messages)
        if DEBUG_MODE:
            logging.getLogger().info(f'Message sent to stream: key={stream_message_entry.key}, value={stream_message_entry.value}')

    except Exception as ex:
        logging.getLogger().error(f'Error pushing data to Stream: {ex}')
        logging.getLogger().info(f'Leaving handler w/errors')

        return response.Response(
            ctx,
            response_data=json.dumps({'status'     : 1
                                    ,'step'       : 'Connect to Stream and push the message'
                                    ,'exception'  : str(ex)}, indent=2),
            headers={"Content-Type": "application/json"}
        )

    return response.Response(
        ctx,
        response_data=json.dumps({'status'     : 0
                                ,'fninitiator' : 'Finished'}, indent=2),
        headers={"Content-Type": "application/json"}
    )