import io
import json
import logging
import oci
import os
from fdk import response

def handler(ctx, data: io.BytesIO = None):

    if os.getenv("TOPIC_OCID") != None:
        topic_ocid = os.getenv("TOPIC_OCID")
    else:
        _='Missing configuration key TOPIC_OCID'
        logging.getLogger().error(_)
        return None, _

    signer = oci.auth.signers.get_resource_principals_signer()
    ons_client = oci.ons.NotificationDataPlaneClient(config={}, signer=signer)
    
    message = {
        "title": "Sample Notification",
        "body": "This is a test message from OCI Function"
    }

    try:
        message_details = oci.ons.models.MessageDetails(
            title=message["title"],
            body=message["body"]
        )
        response = ons_client.publish_message(
            topic_id=topic_ocid,
            message_details=message_details
        )
        logging.getLogger().info("Message published successfully: " + str(response.data))
        return response.Response(
            ctx, response_data=json.dumps(
                {"status": "Message published successfully", "response": str(response.data)}),
            headers={"Content-Type": "application/json"}
        )
    except Exception as e:
        logging.getLogger().error("Failed to publish message: " + str(e))
        return response.Response(
            ctx, response_data=json.dumps(
                {"status": "Failed to publish message", "error": str(e)}),
            headers={"Content-Type": "application/json"}
        )
