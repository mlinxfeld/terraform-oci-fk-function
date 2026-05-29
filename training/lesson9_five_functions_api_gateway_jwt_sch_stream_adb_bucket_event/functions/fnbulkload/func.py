import io
import json
import logging
import os
from base64 import b64encode

import oci
from fdk import response


def setup_oci_client(client_type, signer, stream_endpoint=None):
    if client_type == "streaming":
        return oci.streaming.StreamClient(
            config={},
            signer=signer,
            service_endpoint=f"https://{stream_endpoint}",
        )
    if client_type == "oss":
        return oci.object_storage.ObjectStorageClient(config={}, signer=signer)

    raise ValueError(f"Unsupported client_type: {client_type}")


def publish_to_stream(stream_client, stream_ocid, device_id, device_data):
    stream_message_entry = oci.streaming.models.PutMessagesDetailsEntry()
    stream_message_entry.key = b64encode(device_id.encode("utf-8")).decode("utf-8")
    stream_message_entry.value = b64encode(json.dumps(device_data).encode("utf-8")).decode("utf-8")

    stream_messages = oci.streaming.models.PutMessagesDetails()
    stream_messages.messages = [stream_message_entry]
    stream_client.put_messages(stream_ocid, stream_messages)


DEBUG_MODE = os.getenv("DEBUG_MODE") is not None
STREAM_OCID = os.getenv("STREAM_OCID")
STREAM_ENDPOINT = os.getenv("STREAM_ENDPOINT")

if not STREAM_OCID or not STREAM_ENDPOINT:
  raise RuntimeError("Missing configuration key STREAM_OCID or STREAM_ENDPOINT")

if DEBUG_MODE:
    logging.getLogger().info("Getting signer using resource principals...")
signer = oci.auth.signers.get_resource_principals_signer()
if DEBUG_MODE:
    logging.getLogger().info("Got signer ok")

stream_client = setup_oci_client("streaming", signer, STREAM_ENDPOINT)
oss_client = setup_oci_client("oss", signer)


def handler(ctx, data: io.BytesIO = None):
    logger = logging.getLogger()

    if DEBUG_MODE:
        logger.info("Starting fnbulkload handler...")

    try:
        body = json.loads(data.getvalue()) if data else {}
        bucket_name = body["data"]["additionalDetails"]["bucketName"]
        object_name = body["data"]["resourceName"]

        if DEBUG_MODE:
            logger.info("Function invoked for bucket upload: %s", bucket_name)

    except (TypeError, ValueError, KeyError) as ex:
        logger.error("Error parsing JSON payload: %s", ex)
        return response.Response(
            ctx,
            response_data=json.dumps(
                {
                    "status": 1,
                    "step": "Parsing JSON payload from OCI Events",
                    "exception": str(ex),
                },
                indent=2,
            ),
            headers={"Content-Type": "application/json"},
        )

    try:
        namespace = oss_client.get_namespace().data
        obj = oss_client.get_object(namespace, bucket_name, object_name)
        object_payload = json.loads(obj.data.content.decode("utf-8"))

        if not isinstance(object_payload, list):
            raise ValueError("Uploaded JSON payload must be an array of device records.")

        processed_count = 0
        for device in object_payload:
            device_id = str(device.get("device_id"))
            device_data = device.get("device_data", {})

            if not device_id:
                raise ValueError("Each device record must define device_id.")

            publish_to_stream(stream_client, STREAM_OCID, device_id, device_data)
            processed_count += 1

            if DEBUG_MODE:
                logger.info("Published device_id=%s to stream", device_id)

    except Exception as ex:
        logger.error("Error processing uploaded object or pushing to Stream: %s", ex)
        return response.Response(
            ctx,
            response_data=json.dumps(
                {
                    "status": 1,
                    "step": "Reading uploaded JSON and pushing records to Streaming",
                    "exception": str(ex),
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
                "fnbulkload": "Finished",
                "bucket_name": bucket_name,
                "object_name": object_name,
                "record_count": processed_count,
            },
            indent=2,
        ),
        headers={"Content-Type": "application/json"},
    )
