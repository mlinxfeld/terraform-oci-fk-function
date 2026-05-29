import datetime
import io
import json
import logging
from datetime import timedelta

from fdk import response


def get_token_from_payload(payload):
    if not isinstance(payload, dict):
        return None

    if payload.get("token"):
        return payload.get("token")

    headers = payload.get("headers", {})
    if isinstance(headers, dict):
        return headers.get("token") or headers.get("Token")

    return None


def handler(ctx, data: io.BytesIO = None):
    logger = logging.getLogger()
    expires_at = (
        datetime.datetime.utcnow() + timedelta(seconds=60)
    ).replace(tzinfo=datetime.timezone.utc).astimezone().replace(microsecond=0).isoformat()

    try:
        payload = json.loads(data.getvalue()) if data else {}
    except (TypeError, ValueError) as ex:
        logger.info("error parsing json payload: %s", ex)
        payload = {}

    token = get_token_from_payload(payload)
    expected_token = dict(ctx.Config()).get("FN_JWT_TOKEN")

    if token and token == expected_token:
        return response.Response(
            ctx,
            status_code=200,
            response_data=json.dumps(
                {
                    "active": True,
                    "principal": "foggykitchen-user",
                    "scope": "iot:write",
                    "clientId": "fk-jwt-client",
                    "expiresAt": expires_at,
                    "context": {"username": "wally"},
                }
            ),
        )

    return response.Response(
        ctx,
        status_code=401,
        response_data=json.dumps({"active": False, "wwwAuthenticate": "API-key"}),
    )
