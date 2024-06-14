import io
import os
import json
import logging
from fdk import response


def handler(ctx, data: io.BytesIO=None):

    if os.getenv("FN_CUSTOM_MESSAGE") != None:
        fn_custom_message = os.getenv("FN_CUSTOM_MESSAGE")
    else:
        _='Missing configuration key FN_CUSTOM_MESSAGE'
        logging.getLogger().error(_)
        return None, _

    logging.getLogger().info(f'Starting function with message: {fn_custom_message}')

    return response.Response(
        ctx, response_data=json.dumps(
            {"message": fn_custom_message}),
        headers={"Content-Type": "application/json"}
    )

