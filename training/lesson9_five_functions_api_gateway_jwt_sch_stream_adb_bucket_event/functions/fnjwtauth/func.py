import io
import json
import logging
import datetime

from datetime import timedelta
from fdk import response

def handler(ctx, data: io.BytesIO = None):
    auth_token = "invalid"
    token = "invalid"
    fnJwtToken = "invalid"
    expiresAt = (datetime.datetime.utcnow() + timedelta(seconds=60)).replace(tzinfo=datetime.timezone.utc).astimezone().replace(microsecond=0).isoformat()
    
    try:
        auth_token = json.loads(data.getvalue())
        token = auth_token.get("token")
        
        app_context = dict(ctx.Config())
        fnJwtToken = app_context['FN_JWT_TOKEN']
        
        if token == fnJwtToken:
            return response.Response(
                ctx, 
                status_code=200, 
                response_data=json.dumps({"active": True, "principal": "foo", "scope": "bar", "clientId": "1234", "expiresAt": expiresAt, "context": {"username": "wally"}})
            )
    
    except (Exception, ValueError) as ex:
        logging.getLogger().info('error parsing json payload: ' + str(ex))
        pass
    
    return response.Response(
        ctx, 
        status_code=401, 
        response_data=json.dumps({"active": False, "wwwAuthenticate": "API-key"})
    )