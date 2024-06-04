import io
import os
import json
from fdk import response


def handler(ctx, data: io.BytesIO=None):

    return response.Response(
        ctx, response_data=json.dumps(
            {"message": "HelloWorld!"}),
        headers={"Content-Type": "application/json"}
    )

