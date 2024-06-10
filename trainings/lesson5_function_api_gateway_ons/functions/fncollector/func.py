import io
import json
import logging
import os
from fdk import response

def handler(ctx, data: io.BytesIO = None):
    # Initialize logging
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    DEBUG_MODE = os.getenv("DEBUG_MODE") is not None

    if DEBUG_MODE:
        logger.info('Starting fncollector handler...')

    # Read the incoming data
    raw_data = data.getvalue().decode('utf-8')  # Decode bytes to string

    if DEBUG_MODE:
        logger.info(f'fncollector: Received message: {raw_data}')

    # Respond with success
    return response.Response(
        ctx, response_data=json.dumps(
            {"status": "fncollector: Message processed"}),
        headers={"Content-Type": "application/json"}
    )

if __name__ == "__main__":
    from fdk import handle
    handle(handler)
