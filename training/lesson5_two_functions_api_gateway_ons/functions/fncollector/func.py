import io
import json
import logging
import os
from fdk import response

def handler(ctx, data: io.BytesIO = None):
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)

    DEBUG_MODE = os.getenv("DEBUG_MODE") is not None

    if DEBUG_MODE:
        logger.info('Starting fncollector handler...')

    raw_data = data.getvalue().decode('utf-8')
    correlation_id = None
    message = raw_data

    try:
        payload = json.loads(raw_data)
        correlation_id = payload.get("correlation_id")
        message = payload.get("message", raw_data)
    except json.JSONDecodeError:
        payload = {"message": raw_data}

    if DEBUG_MODE:
        if correlation_id is not None:
            logger.info(
                f'fncollector: Received correlation_id={correlation_id} message={message}'
            )
        else:
            logger.info(f'fncollector: Received message: {raw_data}')

    return response.Response(
        ctx, response_data=json.dumps(
            {
                "status": "fncollector: Message processed",
                "correlation_id": correlation_id,
                "message": message
            }
        ),
        headers={"Content-Type": "application/json"}
    )

if __name__ == "__main__":
    from fdk import handle
    handle(handler)
