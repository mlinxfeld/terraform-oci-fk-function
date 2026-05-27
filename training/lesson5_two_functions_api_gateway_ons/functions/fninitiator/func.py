import io
import json
import logging
import oci
import os
import uuid
from fdk import response

def handler(ctx, data: io.BytesIO = None):

    if os.getenv("TOPIC_OCID") != None:
        topic_ocid = os.getenv("TOPIC_OCID")
    else:
        _='Missing configuration key TOPIC_OCID'
        logging.getLogger().error(_)
        return None, _

    if os.getenv("DEBUG_MODE") != None:
        DEBUG_MODE = True
    else:
        DEBUG_MODE = False

    if DEBUG_MODE:
        logging.getLogger().info(f'Starting fninitiator handler...')

    if DEBUG_MODE:
        logging.getLogger().info(f'fninitiator: Getting signer using resource principals...')
    signer = oci.auth.signers.get_resource_principals_signer()
    
    if DEBUG_MODE:
        logging.getLogger().info(f'fninitiator: Starting ons_client...')    
    ons_client = oci.ons.NotificationDataPlaneClient(config={}, signer=signer)

    correlation_id = str(uuid.uuid4())
    message = {
        "title": "ONS Notification",
        "body": json.dumps(
            {
                "correlation_id": correlation_id,
                "message": "This is a message from fninitiator to fncollector"
            }
        )
    }
    try:
        message_details = oci.ons.models.MessageDetails(
            title=message["title"],
            body=message["body"]
        )
        if DEBUG_MODE:
            logging.getLogger().info(
                f'fninitiator: Publishing correlation_id={correlation_id} via ons_client to topic {topic_ocid}'
            )
        ons_response = ons_client.publish_message(
            topic_id=topic_ocid,
            message_details=message_details
        )
        logging.getLogger().info("fninitiator: Message published successfully: " + str(ons_response.data))
        return response.Response(
            ctx, response_data=json.dumps(
                {
                    "status": "fninitiator: Message published successfully",
                    "correlation_id": correlation_id,
                    "ons_response": str(ons_response.data)
                }
            ),
            headers={"Content-Type": "application/json"}
        )
    except Exception as e:
        logging.getLogger().error("fninitiator: Failed to publish message: " + str(e))
        return response.Response(
            ctx, response_data=json.dumps(
                {
                    "status": "fninitiator: Failed to publish message",
                    "correlation_id": correlation_id,
                    "error": str(e)
                }
            ),
            headers={"Content-Type": "application/json"}
        )
