import { createCipheriv, createDecipheriv, randomBytes } from 'crypto';
import { S3Client, PutObjectCommand, GetObjectCommand } from '@aws-sdk/client-s3';
import { Readable } from 'stream';
import fs from 'fs';

const algo = 'aes-256-gcm';

function getKey() {
  const hex = process.env.CSE_KEY_HEX;
  if (!hex) throw new Error('CSE_KEY_HEX not set');
  const key = Buffer.from(hex, 'hex');
  if (key.length !== 32) throw new Error('CSE_KEY_HEX must be 32 bytes (hex)');
  return key;
}

function encrypt(plaintext) {
  const key = getKey();
  const nonce = randomBytes(12);
  const cipher = createCipheriv(algo, key, nonce);
  const ciphertext = Buffer.concat([cipher.update(plaintext), cipher.final()]);
  const tag = cipher.getAuthTag();
  return { nonce, ciphertext, tag };
}

function decrypt(nonce, ciphertext, tag) {
  const key = getKey();
  const decipher = createDecipheriv(algo, key, nonce);
  decipher.setAuthTag(tag);
  const plaintext = Buffer.concat([decipher.update(ciphertext), decipher.final()]);
  return plaintext;
}

async function upload(bucket, key, nonce, tag, ciphertext) {
  const s3 = new S3Client({});
  const meta = {
    'cse-alg': 'AES256-GCM',
    'cse-nonce-b64': Buffer.from(nonce).toString('base64'),
    'cse-tag-b64': Buffer.from(tag).toString('base64')
  };
  await s3.send(new PutObjectCommand({ Bucket: bucket, Key: key, Body: ciphertext, Metadata: meta }));
  console.log(`Uploaded ciphertext to s3://${bucket}/${key}`);
}

async function download(bucket, key) {
  const s3 = new S3Client({});
  const resp = await s3.send(new GetObjectCommand({ Bucket: bucket, Key: key }));
  const chunks = [];
  await new Promise((resolve, reject) => {
    resp.Body.on('data', (c) => chunks.push(c));
    resp.Body.on('end', resolve);
    resp.Body.on('error', reject);
  });
  const body = Buffer.concat(chunks);
  const meta = resp.Metadata || {};
  return { body, meta };
}

async function main() {
  const [cmd, bucket, key, path] = process.argv.slice(2);
  if (!cmd || !bucket || !key) {
    console.error('Usage: node index.js <encrypt-upload|download-decrypt> <bucket> <key> [path]');
    process.exit(1);
  }
  if (cmd === 'encrypt-upload') {
    if (!path) { console.error('Missing plaintext path'); process.exit(1); }
    const plaintext = fs.readFileSync(path);
    const { nonce, ciphertext, tag } = encrypt(plaintext);
    await upload(bucket, key, nonce, tag, ciphertext);
  } else if (cmd === 'download-decrypt') {
    if (!path) { console.error('Missing output path'); process.exit(1); }
    const { body, meta } = await download(bucket, key);
    const nonceB64 = meta['cse-nonce-b64'];
    const tagB64 = meta['cse-tag-b64'];
    if (!nonceB64 || !tagB64) {
      console.error('Missing CSE metadata; cannot decrypt');
      process.exit(1);
    }
    const nonce = Buffer.from(nonceB64, 'base64');
    const tag = Buffer.from(tagB64, 'base64');
    const plaintext = decrypt(nonce, body, tag);
    fs.writeFileSync(path, plaintext);
    console.log(`Wrote decrypted content to ${path}`);
  } else {
    console.error('Unknown command');
    process.exit(1);
  }
}

main().catch((e) => { console.error(e); process.exit(1); });
