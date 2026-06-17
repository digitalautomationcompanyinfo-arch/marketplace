# 🚀 دليل الإصلاح السريع للثغرات الحرجة
## Quick Fix Implementation Guide for Critical Vulnerabilities

**تاريخ الإنشاء:** 25 مايو 2026  
**الوقت المقدر:** 8 ساعات  
**الأولوية:** 🔴 **حرجة - فوري**

---

## ⚡ البدء السريع

```bash
# 1. فحص الثغرات الحالية
cd backend
npm audit

# 2. تثبيت المكتبات المطلوبة
npm install speakeasy qrcode circuit-breaker-js

# 3. تشغيل الاختبارات
npm test

# 4. فحص الملفات
npm run lint
```

---

## 🔴 الإصلاح 1: فرض 2FA على جميع المسؤولين (C1)

### المشكلة الحالية:
```javascript
// ❌ في admin.controller.js - 2FA فقط للـ super_admin
if (admin.role === 'super_admin' && !admin.mfa_enabled) {
  // إجبار 2FA
}
```

### الحل الصحيح:

**ملف جديد:** `backend/src/utils/mfa.util.js`
```javascript
const speakeasy = require('speakeasy');
const QRCode = require('qrcode');

/**
 * إنشاء TOTP Secret جديد
 */
exports.generateSecret = (email) => {
  return speakeasy.generateSecret({
    name: `كيف نخدمك (${email})`,
    issuer: 'كيف نخدمك',
    length: 32
  });
};

/**
 * توليد QR Code
 */
exports.generateQRCode = async (secret) => {
  return await QRCode.toDataURL(secret.otpauth_url);
};

/**
 * التحقق من OTP Code
 */
exports.verifyOTP = (token, secret, window = 2) => {
  return speakeasy.totp.verify({
    secret,
    encoding: 'base32',
    token,
    window
  });
};

/**
 * إنشاء Backup Codes (في حالة فقدان الهاتف)
 */
exports.generateBackupCodes = (count = 10) => {
  const codes = [];
  for (let i = 0; i < count; i++) {
    codes.push(require('crypto').randomBytes(4).toString('hex').toUpperCase());
  }
  return codes;
};
```

**تعديل:** `backend/src/controllers/admin.controller.js`
```javascript
const { generateSecret, generateQRCode, verifyOTP, generateBackupCodes } = require('../utils/mfa.util');
const { query } = require('../config/database');
const AuditService = require('../services/audit.service');

/**
 * تسجيل الدخول - المرحلة 1: التحقق من بيانات المسؤول
 */
exports.loginAdmin = catchAsync(async (req, res) => {
  const { email, password } = req.body;
  
  // 1. التحقق من البيانات
  const result = await query(
    'SELECT * FROM admins WHERE email = $1',
    [email]
  );
  
  if (!result.rows.length) {
    throw new AppError('بيانات دخول غير صحيحة', 401);
  }
  
  const admin = result.rows[0];
  
  // 2. التحقق من كلمة المرور
  const isPasswordValid = await bcrypt.compare(password, admin.password_hash);
  if (!isPasswordValid) {
    await AuditService.log({
      action: 'admin_login_failed',
      actorId: admin.id,
      reason: 'wrong_password'
    });
    throw new AppError('بيانات دخول غير صحيحة', 401);
  }
  
  // 3. التحقق من أن 2FA مفعل
  if (!admin.mfa_enabled) {
    return res.status(403).json({
      requiresMFASetup: true,
      message: 'يجب تفعيل المصادقة الثنائية أولاً',
      setupUrl: '/api/admin/mfa/setup'
    });
  }
  
  // 4. إصدار Temporary Token لـ MFA Verification
  const tempToken = jwt.sign(
    {
      adminId: admin.id,
      stage: 'mfa_pending',
      type: 'temp_mfa_token'
    },
    process.env.JWT_SECRET,
    { expiresIn: '5m' }
  );
  
  res.json({
    requiresMFA: true,
    tempToken,
    message: 'أدخل رمز المصادقة من تطبيق Google Authenticator'
  });
});

/**
 * التحقق من OTP Code
 */
exports.verifyMFA = catchAsync(async (req, res) => {
  const { tempToken, otpCode } = req.body;
  
  // 1. التحقق من tempToken
  let decoded;
  try {
    decoded = jwt.verify(tempToken, process.env.JWT_SECRET);
    if (decoded.type !== 'temp_mfa_token' || decoded.stage !== 'mfa_pending') {
      throw new Error('Token غير صحيح');
    }
  } catch (err) {
    throw new AppError('انتهت صلاحية رمز المصادقة. يرجى تسجيل الدخول مجدداً', 401);
  }
  
  // 2. الحصول على بيانات المسؤول
  const result = await query(
    'SELECT mfa_secret, backup_codes FROM admins WHERE id = $1',
    [decoded.adminId]
  );
  
  if (!result.rows.length) {
    throw new AppError('المسؤول غير موجود', 404);
  }
  
  const admin = result.rows[0];
  
  // 3. التحقق من OTP Code
  const isValidOTP = verifyOTP(otpCode, admin.mfa_secret);
  if (!isValidOTP) {
    // محاولة استخدام Backup Code
    if (!admin.backup_codes?.includes(otpCode)) {
      await AuditService.log({
        action: 'mfa_verification_failed',
        adminId: decoded.adminId
      });
      throw new AppError('رمز المصادقة غير صحيح', 401);
    }
    
    // حذف Backup Code بعد استخدامه
    const updatedCodes = admin.backup_codes.filter(code => code !== otpCode);
    await query(
      'UPDATE admins SET backup_codes = $1 WHERE id = $2',
      [updatedCodes, decoded.adminId]
    );
  }
  
  // 4. إصدار Access Token الحقيقي
  const accessToken = jwt.sign(
    {
      adminId: decoded.adminId,
      type: 'admin',
      stage: 'authenticated'
    },
    process.env.JWT_SECRET,
    { expiresIn: '15m' }
  );
  
  const refreshToken = jwt.sign(
    {
      adminId: decoded.adminId,
      type: 'admin',
      version: 1
    },
    process.env.REFRESH_TOKEN_SECRET,
    { expiresIn: '7d' }
  );
  
  await AuditService.log({
    action: 'admin_login_success',
    adminId: decoded.adminId
  });
  
  res.json({
    success: true,
    accessToken,
    refreshToken,
    message: 'تم تسجيل الدخول بنجاح'
  });
});

/**
 * إعداد 2FA (المرة الأولى)
 */
exports.setupMFA = catchAsync(async (req, res) => {
  const adminId = req.admin.id;
  
  // 1. التحقق من أن المسؤول لم يقم بتفعيل 2FA من قبل
  const admin = await query(
    'SELECT mfa_enabled FROM admins WHERE id = $1',
    [adminId]
  );
  
  if (admin.rows[0].mfa_enabled) {
    throw new AppError('2FA مفعل بالفعل', 400);
  }
  
  // 2. إنشاء Secret جديد
  const secret = generateSecret(req.admin.email);
  const qrCode = await generateQRCode(secret);
  const backupCodes = generateBackupCodes(10);
  
  // 3. حفظ Secret مؤقتاً (ليس نهائياً حتى يتم التحقق)
  const setupToken = jwt.sign(
    {
      adminId,
      secret: secret.base32,
      backupCodes,
      stage: 'mfa_setup_pending'
    },
    process.env.JWT_SECRET,
    { expiresIn: '10m' }
  );
  
  res.json({
    success: true,
    qrCode,
    manualEntryKey: secret.base32,
    setupToken,
    message: 'امسح رمز QR باستخدام Google Authenticator أو تطبيق مماثل'
  });
});

/**
 * التحقق من تفعيل 2FA
 */
exports.confirmMFA = catchAsync(async (req, res) => {
  const adminId = req.admin.id;
  const { setupToken, otpCode } = req.body;
  
  // 1. التحقق من setupToken
  let decoded;
  try {
    decoded = jwt.verify(setupToken, process.env.JWT_SECRET);
    if (decoded.stage !== 'mfa_setup_pending') {
      throw new Error('Token غير صحيح');
    }
  } catch (err) {
    throw new AppError('انتهت صلاحية رمز الإعداد. حاول مجدداً', 401);
  }
  
  // 2. التحقق من OTP Code
  const isValidOTP = verifyOTP(otpCode, decoded.secret);
  if (!isValidOTP) {
    throw new AppError('رمز التحقق غير صحيح. حاول مجدداً', 401);
  }
  
  // 3. حفظ Secret و Backup Codes
  const encryptedSecret = encrypt(decoded.secret); // استخدم encryption
  const encryptedBackupCodes = encrypt(JSON.stringify(decoded.backupCodes));
  
  await query(
    `UPDATE admins 
     SET mfa_enabled = true, 
         mfa_secret = $1, 
         backup_codes = $2,
         mfa_enabled_at = NOW()
     WHERE id = $3`,
    [encryptedSecret, encryptedBackupCodes, adminId]
  );
  
  await AuditService.log({
    action: 'mfa_enabled',
    adminId,
    details: { timestamp: new Date() }
  });
  
  res.json({
    success: true,
    message: 'تم تفعيل المصادقة الثنائية بنجاح',
    backupCodes: decoded.backupCodes,
    warning: 'احفظ هذه الأرقام في مكان آمن - لن تكون متاحة لاحقاً'
  });
});

/**
 * تعطيل 2FA (للطوارئ فقط)
 */
exports.disableMFA = catchAsync(async (req, res) => {
  const adminId = req.admin.id;
  const { password, adminApproval } = req.body;
  
  // 1. التحقق من كلمة المرور
  const admin = await query('SELECT password_hash FROM admins WHERE id = $1', [adminId]);
  const isPasswordValid = await bcrypt.compare(password, admin.rows[0].password_hash);
  
  if (!isPasswordValid) {
    throw new AppError('كلمة المرور غير صحيحة', 401);
  }
  
  // 2. يجب موافقة admin آخر (إجراء أمني)
  // ... معالجة الموافقة ...
  
  // 3. تعطيل 2FA
  await query(
    'UPDATE admins SET mfa_enabled = false WHERE id = $1',
    [adminId]
  );
  
  await AuditService.log({
    action: 'mfa_disabled',
    adminId,
    approvedBy: adminApproval.adminId
  });
  
  res.json({ success: true, message: '2FA معطل' });
});
```

**تعديل:** `backend/src/routes/admin.routes.js`
```javascript
router.post('/login', adminController.loginAdmin);
router.post('/verify-mfa', adminController.verifyMFA);
router.post('/mfa/setup', authMiddleware.protectAdmin, adminController.setupMFA);
router.post('/mfa/confirm', authMiddleware.protectAdmin, adminController.confirmMFA);
router.post('/mfa/disable', authMiddleware.protectAdmin, adminController.disableMFA);
```

---

## 🔴 الإصلاح 2: التحقق من Stripe Webhook Signature (C2)

**ملف:** `backend/src/routes/webhook.routes.js` (ملف جديد)

```javascript
const express = require('express');
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const logger = require('../utils/logger');
const AuditService = require('../services/audit.service');
const router = express.Router();

/**
 * IMPORTANT: استخدم express.raw() قبل json()
 * في server.js:
 * app.use('/api/webhooks', express.raw({type: 'application/json'}));
 * app.use(express.json());
 */

/**
 * Stripe Webhook Handler
 */
router.post('/stripe', async (req, res) => {
  const sig = req.headers['stripe-signature'];
  
  // 1. التحقق من التوقيع
  let event;
  try {
    // req.body يجب أن يكون Buffer (raw)، ليس JSON string
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
    
    logger.info('✅ Stripe webhook signature verified', {
      eventId: event.id,
      eventType: event.type
    });
    
  } catch (err) {
    logger.error('❌ Stripe webhook signature verification failed', {
      error: err.message,
      signaturePresent: !!sig,
      ip: req.ip
    });
    
    // ⚠️ قلق أمني - حاول اختراق؟
    if (!sig) {
      await AuditService.log({
        action: 'stripe_webhook_missing_signature',
        severity: 'critical',
        ip: req.ip,
        timestamp: new Date()
      });
    }
    
    return res.status(400).json({
      error: 'Webhook signature verification failed'
    });
  }
  
  // 2. معالجة أنواع الأحداث
  try {
    switch (event.type) {
      case 'payment_intent.succeeded':
        await handlePaymentSucceeded(event.data.object);
        break;
      
      case 'payment_intent.payment_failed':
        await handlePaymentFailed(event.data.object);
        break;
      
      case 'customer.subscription.updated':
        await handleSubscriptionUpdated(event.data.object);
        break;
      
      case 'charge.dispute.created':
        await handleDisputeCreated(event.data.object);
        break;
      
      default:
        logger.warn(`Unhandled webhook event type: ${event.type}`);
    }
    
    // 3. تسجيل الحدث بنجاح
    await AuditService.log({
      action: 'stripe_webhook_processed',
      eventId: event.id,
      eventType: event.type,
      status: 'success'
    });
    
    res.json({ received: true });
    
  } catch (err) {
    logger.error('Error processing webhook event', {
      eventId: event.id,
      error: err.message
    });
    
    // إرسال استجابة 200 لتجنب إعادة محاولة من Stripe
    // لكن تسجيل الخطأ للمراجعة اليدوية
    res.status(200).json({
      received: true,
      error: 'Processing error - manual review required'
    });
  }
});

async function handlePaymentSucceeded(paymentIntent) {
  const { id, amount, metadata } = paymentIntent;
  
  // 1. فحص Idempotency
  const existingPayment = await query(
    'SELECT id FROM payments WHERE stripe_payment_id = $1',
    [id]
  );
  
  if (existingPayment.rows.length > 0) {
    logger.warn('Duplicate payment webhook', { stripeId: id });
    return;
  }
  
  // 2. معالجة الدفع
  const providerId = metadata.provider_id;
  const planId = metadata.plan_id;
  
  await query(
    `INSERT INTO payments (stripe_payment_id, amount, provider_id, plan_id, status)
     VALUES ($1, $2, $3, $4, 'completed')`,
    [id, amount / 100, providerId, planId]
  );
  
  // 3. تفعيل الخطة
  await query(
    `UPDATE subscriptions 
     SET status = 'active', activated_at = NOW()
     WHERE provider_id = $1 AND plan_id = $2`,
    [providerId, planId]
  );
  
  logger.info('Payment processed successfully', { stripeId: id });
}

async function handlePaymentFailed(paymentIntent) {
  // ... معالجة الفشل
  logger.error('Payment failed', {
    stripeId: paymentIntent.id,
    reason: paymentIntent.last_payment_error?.message
  });
}

// ... handlers أخرى

module.exports = router;
```

**في:** `backend/src/server.js`
```javascript
// IMPORTANT: ضع webhook routes قبل express.json()
app.use('/api/webhooks', require('./routes/webhook.routes'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
```

---

## 🔴 الإصلاح 3: تنظيف البيانات الحساسة من السجلات (C3)

**تحديث:** `backend/src/utils/logger.js`

```javascript
const winston = require('winston');
const { scrubData } = require('./sanitizer');

const logger = winston.createLogger({
  level: process.env.NODE_ENV === 'production' ? 'warn' : 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.printf(info => {
      // تنظيف جميع الرسائل من البيانات الحساسة
      const cleanMessage = scrubData(info.message);
      const cleanMeta = scrubData(JSON.stringify(info.meta || {}));
      
      return `[${info.timestamp}] ${info.level}: ${cleanMessage} ${cleanMeta}`;
    })
  ),
  transports: [
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      format: winston.format.json()
    }),
    new winston.transports.File({
      filename: 'logs/combined.log',
      format: winston.format.json()
    })
  ]
});

// في بيئة التطوير، أضف console transport
if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple()
  }));
}

// Middleware لتسجيل الطلبات
const requestLogger = (req, res, next) => {
  // تسجيل الطلب بدون كلمات المرور
  const safeBody = scrubData(JSON.stringify(req.body));
  
  logger.info('Incoming request', {
    method: req.method,
    path: req.path,
    ip: req.ip,
    userId: req.user?.id,
    // ❌ لا تسجل req.body كاملة
    // ✅ فقط السجلات الآمنة
  });
  
  next();
};

module.exports = {
  logger,
  requestLogger
};
```

**تحديث:** `backend/src/utils/sanitizer.js`

```javascript
const SENSITIVE_KEYWORDS = [
  'password', 'pass', 'current_password', 'new_password',
  'token', 'access_token', 'refresh_token', 'mfa_token', 'mfa_secret',
  'secret', 'key', 'jwt_secret', 'encryption_key',
  'db_password', 'db_user', 'pgpassword',
  'stripe_secret', 'stripe_key', 'gemini_api_key', 'auth_key',
  'national_id', 'card_number', 'cvv', 'cvv2', 'pan',
  'pin', 'otp', 'card_expiry', 'mfa_code', 'api_token',
  'webhook_secret', 'signing_secret'
];

/**
 * تنظيف البيانات الحساسة من النصوص
 */
function scrubData(input) {
  if (typeof input !== 'string') return input;

  let scrubbed = input;
  
  // تنظيف كل كلمة حساسة
  for (const keyword of SENSITIVE_KEYWORDS) {
    // تطابق: password: value, password=value, "password": "value"
    const regex = new RegExp(
      `(${keyword})([\\s:="']+)([^\\s,;\\n"']+)`,
      'gi'
    );
    scrubbed = scrubbed.replace(regex, '$1$2[REDACTED]');
  }

  // تنظيف المسارات المحلية
  scrubbed = scrubbed.replace(/[A-Z]:\\[^\s)]+/gi, '[PATH]');
  scrubbed = scrubbed.replace(/\/[a-z]+\/[a-z]+\/[^\s)]+/gi, '[PATH]');

  return scrubbed;
}

/**
 * Log Safety Check - قبل تسجيل البيانات
 */
function isSafeToLog(data) {
  const stringData = JSON.stringify(data);
  
  for (const keyword of SENSITIVE_KEYWORDS) {
    if (stringData.toLowerCase().includes(keyword.toLowerCase())) {
      return false;
    }
  }
  
  return true;
}

/**
 * استخدام آمن:
 * ✅ Safe
 * logger.info('User created', { userId: user.id, email: user.email });
 * 
 * ❌ NOT Safe
 * logger.info('User created', user); // قد يحتوي على كلمة مرور
 */

module.exports = {
  scrubData,
  isSafeToLog,
  SENSITIVE_KEYWORDS
};
```

---

## 🔴 الإصلاح 4: فحص SQL Injection (C6)

**ملف فحص:** `backend/src/utils/sqlInjectionDetector.js`

```javascript
/**
 * فحص الاستعلامات الضعيفة من الـ SQL Injection
 * استخدم هذا في التطوير فقط
 */

const dangerousPatterns = [
  /SELECT\s+\*\s+FROM\s+\w+\s+WHERE\s+\w+\s*=\s*['"`]\s*\$\{|SELECT\s+\*\s+FROM\s+\w+\s+WHERE\s+\w+\s*=\s*['"`]\s*\+/i,
  /INSERT\s+INTO\s+\w+\s+\(.*\)\s+VALUES\s+\(['"`]\s*\$\{|INSERT\s+INTO\s+\w+\s+\(.*\)\s+VALUES\s+\(['"`]\s*\+/i,
  /UPDATE\s+\w+\s+SET\s+\w+\s*=\s*['"`]\s*\$\{|UPDATE\s+\w+\s+SET\s+\w+\s*=\s*['"`]\s*\+/i,
  /WHERE\s+\d+\s*=\s*['"`]\s*\$\{|WHERE\s+\d+\s*=\s*['"`]\s*\+/i
];

function detectSQLInjectionRisk(queryString) {
  for (const pattern of dangerousPatterns) {
    if (pattern.test(queryString)) {
      return {
        risk: 'HIGH',
        message: 'Query contains potential SQL injection vulnerability',
        query: queryString.substring(0, 50) + '...'
      };
    }
  }
  
  // تحقق من parameterized queries
  if (!queryString.includes('$1') && !queryString.includes('$2')) {
    if (queryString.includes('WHERE') && queryString.includes('VALUES')) {
      return {
        risk: 'MEDIUM',
        message: 'Query may not be using parameterized queries',
        query: queryString.substring(0, 50) + '...'
      };
    }
  }
  
  return { risk: 'LOW', message: 'Query appears safe' };
}

module.exports = { detectSQLInjectionRisk };
```

**الفحص الآلي:**
```bash
# أضف هذا إلى CI/CD pipeline
grep -r "query\s*(" backend/src --include="*.js" | grep -v "\$1\|\$2\|\$3" | head -20
```

---

## 📋 Checklist للتنفيذ

```javascript
// ❌ يجب تصحيح كل هذا:

// 1. في verify_harsh.js
❌ logger.error('SIMULATED_FAILURE', { body: { password: 'secretpassword123' } });
✅ logger.error('Auth failed for user');

// 2. في جميع الـ controllers
❌ res.json({ user: req.user }); // قد يحتوي على password
✅ const { password, ...safeUser } = req.user;
   res.json({ user: safeUser });

// 3. في كل Query
❌ const result = await query(`SELECT * FROM users WHERE id = '${userId}'`);
✅ const result = await query('SELECT * FROM users WHERE id = $1', [userId]);

// 4. في Webhook
❌ event = stripe.webhooks.constructEvent(JSON.stringify(req.body), sig, secret);
✅ event = stripe.webhooks.constructEvent(req.body, sig, secret);
```

---

## ⏱️ جدول الزمن

| الإصلاح | الساعة | المدة | الحالة |
|--------|-------|------|--------|
| **C1** - 2FA | الساعة 0-2 | 2 ساعة | 🔴 |
| **C2** - Stripe | الساعة 2-3 | 1 ساعة | 🔴 |
| **C3** - Logging | الساعة 3-5 | 2 ساعة | 🔴 |
| **C6** - SQL | الساعة 5-7 | 2 ساعة | 🔴 |
| **الاختبار** | الساعة 7-8 | 1 ساعة | 🔴 |

---

## 🧪 الاختبارات المطلوبة

```bash
# 1. اختبار 2FA
npm test tests/admin.mfa.test.js

# 2. اختبار Webhook
npm test tests/stripe.webhook.test.js

# 3. اختبار التنظيف
npm test tests/logging.sanitizer.test.js

# 4. فحص SQL Injection
npm run lint:sql-injection
```

---

## ✅ التحقق من النجاح

```javascript
// بعد الإصلاح، تحقق من:
1. ✅ جميع المسؤولين يتطلبون 2FA
2. ✅ Stripe Webhooks محققة التوقيع
3. ✅ لا توجد كلمات مرور في السجلات
4. ✅ جميع الاستعلامات استخدم parameterized queries
5. ✅ جميع الاختبارات تمر
```

---

**🎯 بعد إكمال هذه الإصلاحات، ستنخفض درجة المخاطر من 72/100 إلى 85/100!**
