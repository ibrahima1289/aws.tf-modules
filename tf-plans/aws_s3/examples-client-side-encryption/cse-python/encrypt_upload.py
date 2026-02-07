import os
import sys
import argparse
import base64
import binascii
from typing import Tuple

from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import boto3


def get_key_from_env() -> bytes:
    key_hex = os.getenv("CSE_KEY_HEX")
    if not key_hex:
        print("CSE_KEY_HEX not set; generate a 32-byte key and export as hex.")
        sys.exit(1)
    try:
        key = binascii.unhexlify(key_hex)
    except Exception:
        print("Invalid CSE_KEY_HEX; must be hex-encoded 32 bytes.")
        sys.exit(1)
    if len(key) != 32:
        print(f"CSE_KEY_HEX length is {len(key)} bytes; must be 32.")
        sys.exit(1)
    return key


def encrypt(plaintext: bytes, key: bytes) -> Tuple[bytes, bytes]:
    aesgcm = AESGCM(key)
    nonce = os.urandom(12)  # 96-bit nonce for AES-GCM
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)
    return nonce, ciphertext


def decrypt(nonce: bytes, ciphertext: bytes, key: bytes) -> bytes:
    aesgcm = AESGCM(key)
    return aesgcm.decrypt(nonce, ciphertext, None)


def upload_s3(bucket: str, key: str, nonce: bytes, ciphertext: bytes, region: str = None):
    session = boto3.session.Session(region_name=region)
    s3 = session.client("s3")
    s3.put_object(
        Bucket=bucket,
        Key=key,
        Body=ciphertext,
        Metadata={
            "cse-alg": "AES256-GCM",
            "cse-nonce-b64": base64.b64encode(nonce).decode(),
        },
    )
    print(f"Uploaded ciphertext to s3://{bucket}/{key}")


def download_s3(bucket: str, key: str, region: str = None) -> Tuple[bytes, dict]:
    session = boto3.session.Session(region_name=region)
    s3 = session.client("s3")
    resp = s3.get_object(Bucket=bucket, Key=key)
    body = resp["Body"].read()
    meta = resp.get("Metadata", {})
    return body, meta


def main():
    p = argparse.ArgumentParser(description="Client-side encrypt/decrypt and upload/download S3")
    p.add_argument("--bucket", required=True)
    p.add_argument("--key", required=True, help="S3 object key path")
    p.add_argument("--region", default=None)
    p.add_argument("--in", dest="in_path", help="Plaintext input file for encrypt+upload")
    p.add_argument("--out", dest="out_path", help="Output file for decrypted content")
    p.add_argument("--decrypt", action="store_true", help="Download and decrypt instead of encrypt+upload")
    args = p.parse_args()

    key = get_key_from_env()

    if args.decrypt:
        ciphertext, meta = download_s3(args.bucket, args.key, args.region)
        nonce_b64 = meta.get("cse-nonce-b64")
        if not nonce_b64:
            print("Missing cse-nonce-b64 metadata; cannot decrypt.")
            sys.exit(1)
        nonce = base64.b64decode(nonce_b64)
        plaintext = decrypt(nonce, ciphertext, key)
        if args.out_path:
            with open(args.out_path, "wb") as f:
                f.write(plaintext)
            print(f"Wrote decrypted content to {args.out_path}")
        else:
            sys.stdout.buffer.write(plaintext)
        return

    if not args.in_path:
        print("--in is required for encrypt+upload")
        sys.exit(1)

    with open(args.in_path, "rb") as f:
        plaintext = f.read()

    nonce, ciphertext = encrypt(plaintext, key)
    upload_s3(args.bucket, args.key, nonce, ciphertext, args.region)


if __name__ == "__main__":
    main()
