import io
import json
import logging
import os
from base64 import b64encode
from urllib.parse import parse_qs, urlparse

import oci
from fdk import response


def setup_oci_client(client_type, signer, stream_endpoint):
    try:
        if DEBUG_MODE:
            logging.getLogger().info(f"Trying to get {client_type} Client using resource principals.")

        if client_type == "streaming":
            oci_client = oci.streaming.StreamClient(
                config={},
                signer=signer,
                service_endpoint=stream_endpoint,
            )
        else:
            raise ValueError(f"Invalid Client type {client_type}")

        if DEBUG_MODE:
            logging.getLogger().info(f"Got {client_type} Client ok")

        return oci_client

    except Exception as exc:
        logging.getLogger().info(f"Raised exception: {exc} attempting to initialize {client_type} Client")
        raise


def normalize_stream_records(body):
    base_device_id = body.get("device_id")
    device_data = body.get("device_data", {})

    if isinstance(device_data, list):
        records = []
        for index, item in enumerate(device_data, start=1):
            record_device_id = item.get("device_id", base_device_id)
            if record_device_id is None:
                raise ValueError(f"Missing device_id for record {index}.")

            records.append({
                "device_id": str(record_device_id),
                "payload": item,
            })
        return records

    if base_device_id is None:
        raise ValueError("device_id must be provided for single-record payloads.")

    return [{
        "device_id": str(base_device_id),
        "payload": device_data,
    }]


def parse_request_body(data):
    if data is None:
        return None

    raw_body = data.getvalue()
    if raw_body is None:
        return None

    if isinstance(raw_body, bytes):
        raw_body = raw_body.decode("utf-8")

    if not str(raw_body).strip():
        return None

    return json.loads(raw_body)


def get_first_value(mapping, key):
    if key not in mapping:
        return None

    value = mapping.get(key)
    if isinstance(value, list):
        return value[0] if value else None

    return value


def build_body_from_request(ctx):
    request_url = ctx.RequestURL() or ""
    query_params = parse_qs(urlparse(request_url).query)
    headers = {str(k).lower(): v for k, v in ctx.HTTPHeaders().items()}

    device_id = (
        get_first_value(query_params, "device_id")
        or headers.get("x-device-id")
        or headers.get("device_id")
    )
    temperature = (
        get_first_value(query_params, "temperature")
        or headers.get("x-temperature")
        or headers.get("temperature")
    )
    humidity = (
        get_first_value(query_params, "humidity")
        or headers.get("x-humidity")
        or headers.get("humidity")
    )

    if not device_id:
        raise ValueError("Request body is empty and device_id was not provided in query params or headers.")

    if temperature is None or humidity is None:
        raise ValueError("Request body is empty and temperature/humidity were not provided in query params or headers.")

    return {
        "device_id": device_id,
        "device_data": {
            "temperature": str(temperature),
            "humidity": str(humidity),
        },
    }


DEBUG_MODE = os.getenv("DEBUG_MODE") is not None

stream_ocid = os.getenv("STREAM_OCID")
stream_endpoint = os.getenv("STREAM_ENDPOINT")

if not stream_ocid or not stream_endpoint:
    logging.getLogger().error("Missing configuration key STREAM_OCID or STREAM_ENDPOINT")

if DEBUG_MODE:
    logging.getLogger().info("Getting signer using resource principals...")
signer = oci.auth.signers.get_resource_principals_signer()
if DEBUG_MODE:
    logging.getLogger().info("Got signer ok")

stream_client = setup_oci_client("streaming", signer, f"https://{stream_endpoint}")


def handler(ctx, data: io.BytesIO = None):
    if DEBUG_MODE:
        logging.getLogger().info("Starting fninitiator handler...")

    try:
        body = parse_request_body(data)
        if body is None:
            if DEBUG_MODE:
                logging.getLogger().info("Request body is empty. Falling back to query params / headers.")
            body = build_body_from_request(ctx)

        records = normalize_stream_records(body)

        if DEBUG_MODE:
            logging.getLogger().info(f"Preparing asynchronous processing for {len(records)} record(s).")

        stream_messages = oci.streaming.models.PutMessagesDetails()
        stream_messages.messages = []

        for record in records:
            stream_message_entry = oci.streaming.models.PutMessagesDetailsEntry()
            stream_message_entry.key = b64encode(record["device_id"].encode("utf-8")).decode("utf-8")
            stream_message_entry.value = b64encode(
                json.dumps(record["payload"]).encode("utf-8")
            ).decode("utf-8")
            stream_messages.messages.append(stream_message_entry)

        stream_client.put_messages(stream_ocid, stream_messages)

        if DEBUG_MODE:
            logging.getLogger().info(f"Sent {len(stream_messages.messages)} message(s) to stream.")

    except Exception as exc:
        logging.getLogger().error(f"Error pushing data to Stream: {exc}")
        logging.getLogger().info("Leaving handler w/errors")

        return response.Response(
            ctx,
            response_data=json.dumps(
                {
                    "status": 1,
                    "step": "Connect to Stream and push the message",
                    "exception": str(exc),
                },
                indent=2,
            ),
            headers={"Content-Type": "application/json"},
        )

    return response.Response(
        ctx,
        response_data=json.dumps(
            {
                "status": 0,
                "fninitiator": "Finished",
                "record_count": len(records),
                "device_id": records[0]["device_id"] if records else None,
            },
            indent=2,
        ),
        headers={"Content-Type": "application/json"},
    )
