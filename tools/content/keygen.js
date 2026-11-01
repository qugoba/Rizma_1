const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '../..');

function publicKeyBase64(privateKey) {
  const jwk = crypto.createPublicKey(privateKey).export({ format: 'jwk' });
  return Buffer.from(jwk.x, 'base64url').toString('base64');
}

function main(args) {
  if (args[0] === '--public' && args[1]) {
    const key = crypto.createPrivateKey(fs.readFileSync(args[1]));
    console.log(publicKeyBase64(key));
    return 0;
  }
  const out = args[0];
  if (!out) {
    console.error('الاستعمال: node tools/content/keygen.js <مسار ملف المفتاح الخاص>');
    return 2;
  }
  const target = path.resolve(out);
  const rel = path.relative(repoRoot, target);
  if (!rel.startsWith('..') && !path.isAbsolute(rel)) {
    console.error('ممنوع: المفتاح الخاص لا يُحفظ داخل المستودع. اختر مسارًا خارجه.');
    return 2;
  }
  if (fs.existsSync(target)) {
    console.error('يوجد ملف بهذا الاسم؛ لن يُستبدل مفتاح موجود.');
    return 2;
  }
  const { privateKey } = crypto.generateKeyPairSync('ed25519');
  fs.mkdirSync(path.dirname(target), { recursive: true });
  fs.writeFileSync(target, privateKey.export({ format: 'pem', type: 'pkcs8' }), {
    mode: 0o600,
  });
  console.log(`المفتاح الخاص: ${target}`);
  console.log('المفتاح العام (يوضع في ContentConfig.publishedKeys):');
  console.log(publicKeyBase64(privateKey));
  return 0;
}

module.exports = { publicKeyBase64 };
if (require.main === module) process.exit(main(process.argv.slice(2)));
