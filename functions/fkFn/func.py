import io
import os
import json
import logging
from fdk import response


def handler(ctx, data: io.BytesIO = None):
    if os.getenv("FN_CUSTOM_MESSAGE") is not None:
        fn_custom_message = os.getenv("FN_CUSTOM_MESSAGE")
    else:
        missing = "Missing configuration key FN_CUSTOM_MESSAGE"
        logging.getLogger().error(missing)
        return None, missing

    logging.getLogger().info(f"Starting function with message: {fn_custom_message}")

    return response.Response(
        ctx,
        response_data=json.dumps({"message": fn_custom_message}),
        headers={"Content-Type": "application/json"},
    )
