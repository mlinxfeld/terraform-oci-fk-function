import io
import json
import logging
import oci
from fdk import response

def handler(ctx, data: io.BytesIO = None):
    try:
        body = json.loads(data.getvalue())
    except (Exception, ValueError) as ex:
        logging.getLogger().info('error parsing json payload: ' + str(ex))
        raise

    logging.getLogger().info("Received message: " + json.dumps(body))

    message = body.get("message")
    if message:
        logging.getLogger().info("Processing message: " + message)

    return response.Response(
        ctx, response_data=json.dumps(
            {"status": "Message processed"}),
        headers={"Content-Type": "application/json"}
    )
