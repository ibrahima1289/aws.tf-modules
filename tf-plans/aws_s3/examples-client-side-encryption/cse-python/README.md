# Client-Side Encryption (Python)

This example encrypts data locally using AES-256-GCM, then uploads the ciphertext to S3. It also shows how to download and decrypt.

Notes:
- Keys are managed by you (env var or file). Rotate keys as needed.
- S3 cannot enforce client-side encryption via bucket policy. This happens in your application.
- Store non-sensitive metadata (e.g., algorithm, nonce) on the object to aid decryption.

## Setup
1. Create or choose a 32-byte key (256-bit). Export as hex:
   - Windows PowerShell:
     ```powershell
     $key = -join ((1..32) | ForEach-Object { [char](Get-Random -Minimum 0 -Maximum 256) })
     # Use a proper key generator; example below uses cryptography lib to generate.
     ```
   Prefer:
   ```powershell
   python - <<'PY'
   import os, binascii
   print(binascii.hexlify(os.urandom(32)).decode())
   PY
   ```
   Set env var `CSE_KEY_HEX` to the generated value.

2. Install deps:
   ```bash
   python -m venv .venv
   .venv/Scripts/activate
   pip install -r requirements.txt
   ```

3. Configure AWS creds (set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and optionally `AWS_SESSION_TOKEN`).

## Usage
- Encrypt and upload:
  ```bash
  python encrypt_upload.py --bucket my-bucket --key app/data.bin --in plaintext.bin
  ```
- Download and decrypt:
  ```bash
  python encrypt_upload.py --bucket my-bucket --key app/data.bin --out decrypted.bin --decrypt
  ```

## Security Considerations
- Protect `CSE_KEY_HEX` and avoid storing it in plaintext.
- Consider using AWS KMS to encrypt your client-side key and store the encrypted blob alongside config.
- Use distinct nonces per object; never reuse a nonce with the same key.
