# Client-Side Encryption (Node.js)

Encrypt locally with AES-256-GCM via Node's crypto and upload to S3.

## Setup
```bash
npm install
```

Export a 32-byte key as hex in `CSE_KEY_HEX`.

## Usage
```bash
node index.js encrypt-upload my-bucket app/data.bin ./plaintext.bin
node index.js download-decrypt my-bucket app/data.bin ./decrypted.bin
```
