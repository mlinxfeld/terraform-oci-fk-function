import io
import os
import json
from fdk import response


def handler(ctx, data: io.BytesIO=None):

    return response.Response(
        ctx, response_data=json.dumps(
            {"message": "Hello World!"}),
        headers={"Content-Type": "application/json"}
    )

