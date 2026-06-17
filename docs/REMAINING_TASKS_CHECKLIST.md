# قائمة المهام المتبقية - Remaining Tasks Checklist
## منصة المتجر - 25 مايو 2026

---

## 📊 ملخص الحالة

**التقدم الإجمالي**: 60% ✅
- ✅ **مكتملة**: 8 مهام أساسية + 2 تكامل
- 🔴 **المتبقية**: 5 مهام

---

## 📋 المهام الفورية (هذه الأسبوع)

### 1️⃣ تشغيل اختبارات Admin Auth (أولوية عالية جداً) ⭐⭐⭐
```
الملف: backend/tests/admin.auth.test.js
الحالة: 🔴 لم يتم الاختبار بعد
الوقت المتوقع: 30-60 دقيقة
الخطوات:
  [ ] cd backend
  [ ] npm install --save-dev jest supertest
  [ ] npm test -- admin.auth.test.js
المتوقع: جميع الاختبارات تمر (50+ tests)
```

### 2️⃣ نشر Firebase Security Rules (أولوية عالية) ⭐⭐⭐
```
الملف: backend/config/firebase-rules.json
الحالة: 🔴 لم يتم النشر بعد
الوقت المتوقع: 30 دقيقة
الخطوات:
  [ ] npm install -g firebase-tools
  [ ] firebase login
  [ ] firebase deploy --only database:rules
  [ ] firebase deploy --only storage
المتوقع: جميع الـ rules تنشر بدون أخطاء
```

### 3️⃣ اختبار Payment Service Circuit Breaker (أولوية عالية) ⭐⭐
```
الملف: backend/src/services/payment.service.js
الحالة: 🔴 لم يتم الاختبار الشامل بعد
الوقت المتوقع: 1-2 ساعة
المتطلب:
  [ ] إنشاء tests/payment.service.test.js
  [ ] اختبار createPaymentIntent()
  [ ] اختبار fallback scenarios
  [ ] اختبار retry logic
المتوقع: > 80% test coverage
```

### 4️⃣ اختبار Firebase Service Circuit Breaker (أولوية متوسطة) ⭐⭐
```
الملف: backend/src/services/firebase.service.js
الحالة: 🔴 لم يتم الاختبار الشامل بعد
الوقت المتوقع: 1-2 ساعة
المتطلب:
  [ ] إنشاء tests/firebase.service.test.js
  [ ] اختبار getUserFCMToken()
  [ ] اختبار sendMessageToUser()
  [ ] اختبار fallback scenarios
المتوقع: > 80% test coverage
```

### 5️⃣ اختبار التكامل الكامل (أولوية متوسطة) ⭐⭐
```
الملفات: subscription.controller.js + payment.service.js
الحالة: 🔴 لم يتم الاختبار بعد
الوقت المتوقع: 2-3 ساعات
المتطلب:
  [ ] إنشاء tests/subscription.integration.test.js
  [ ] اختبار createPaymentIntent() endpoint
  [ ] اختبار confirmSubscription() endpoint
  [ ] اختبار stripeWebhook() endpoint
  [ ] اختبار fallback scenarios عند فشل Stripe
المتوقع: النظام يعمل بدون توقف عند فشل Stripe
```

---

## 🎯 خطة التنفيذ (الجدول الزمني)

### اليوم / غداً (24 ساعة)
- [ ] تشغيل admin.auth.test.js ← **المهمة 1**
- [ ] نشر Firebase Rules ← **المهمة 2**

### أسبوع 1 (أيام 1-5)
- [ ] اختبار Payment Service ← **المهمة 3**
- [ ] اختبار Firebase Service ← **المهمة 4**
- [ ] اختبار التكامل ← **المهمة 5**

### أسبوع 2-3 (اختياري لكن موصى به)
- [ ] تحسين Database Queries
- [ ] بدء TypeScript Migration
- [ ] إضافة Performance Monitoring

---

## 📝 الأوامر الجاهزة (Copy & Paste)

### Task 1: Admin Auth Tests
```bash
cd backend
npm install --save-dev jest supertest
npm test -- admin.auth.test.js
```

### Task 2: Firebase Deployment
```bash
npm install -g firebase-tools
firebase login
firebase deploy --only database:rules
firebase deploy --only storage
```

### Task 3: Payment Service Test
```bash
cd backend
cat > tests/payment.service.test.js << 'EOF'
const paymentService = require('../src/services/payment.service');
describe('Payment Service', () => {
  it('should create payment intent', async () => {
    const intent = await paymentService.createPaymentIntent(50, 'usd', {
      provider_id: '123', plan_id: '456'
    });
    expect(intent).toBeDefined();
    expect(intent.client_secret).toBeDefined();
  });
});
EOF
npm test -- payment.service.test.js
```

### Task 4: Firebase Service Test
```bash
cd backend
cat > tests/firebase.service.test.js << 'EOF'
const firebaseService = require('../src/services/firebase.service');
describe('Firebase Service', () => {
  it('should get FCM token', async () => {
    const token = await firebaseService.getUserFCMToken(123);
    // Token can be null if not set, which is fine
    expect(typeof token === 'string' || token === null).toBe(true);
  });
});
EOF
npm test -- firebase.service.test.js
```

### Task 5: Integration Test
```bash
cd backend
cat > tests/subscription.integration.test.js << 'EOF'
const request = require('supertest');
const app = require('../src/server');
describe('Subscription Integration', () => {
  it('should create payment via API', async () => {
    const res = await request(app)
      .post('/api/v1/subscriptions/create-payment-intent')
      .send({ plan_id: '1', payment_method: 'stripe' });
    expect(res.status).toBe(200);
  });
});
EOF
npm test -- subscription.integration.test.js
```

---

## ✅ معايير النجاح

### Task 1: Admin Auth Tests ✅
- [ ] عدد الاختبارات: 50+
- [ ] نسبة النجاح: 100%
- [ ] الوقت المستغرق: < 10 ثواني

### Task 2: Firebase Rules ✅
- [ ] جميع الـ rules منشورة بدون أخطاء
- [ ] يمكن الوصول من Firebase Console
- [ ] الأمان محسّن (CORS محدود، Authorization مطبق)

### Task 3-5: خدمات واختبارات ✅
- [ ] جميع الاختبارات تمر
- [ ] Circuit Breaker يعمل كما هو متوقع
- [ ] Fallback يعمل عند الفشل
- [ ] Retry logic يعيد المحاولة بنجاح

---

## 📊 مؤشرات الأداء المطلوبة

| المقياس | الحالي | الهدف | الملاحظات |
|--------|--------|--------|----------|
| Test Coverage | ~30% | 70%+ | بعد إكمال Task 3-5 |
| Payment Success Rate | ? | 99%+ | يجب اختباره تحت الضغط |
| Firebase Availability | ? | 99.9% | مع Circuit Breaker |
| API Response Time | ? | <200ms | بعد optimization |
| Error Recovery Time | ? | <10s | Circuit Breaker timeout |

---

## 🚨 الملاحظات المهمة

1. **Database**: تأكد أن PostgreSQL و Redis يعملان قبل الاختبار
2. **Environment**: تأكد أن جميع متغيرات البيئة معرفة في `.env`
3. **Firebase**: اختبر في بيئة تطوير أولاً قبل الإنتاج
4. **Tests**: استخدم `npm test -- --verbose` إذا احتجت تفاصيل أكثر

---

## 🎯 الخطوة التالية

**الآن**: ابدأ بـ Task 1 (Admin Auth Tests)
```bash
cd backend
npm install --save-dev jest supertest
npm test -- admin.auth.test.js
```

**ثم**: Task 2 (Firebase Deployment)
```bash
firebase deploy --only database:rules
```

---

## 📞 الدعم والمساعدة

| المشكلة | الحل |
|--------|------|
| Test لا يعمل | `npm test -- --verbose` لرؤية التفاصيل |
| Firebase deployment فشل | `firebase login` ثم `firebase init` |
| Database errors | تحقق من `npm run migrate` وقيم `.env` |
| Stripe errors | تأكد من `STRIPE_SECRET_KEY` في `.env` |
| Redis timeout | تأكد من تشغيل Redis: `redis-cli ping` |

---

**التاريخ**: 25 مايو 2026
**الحالة**: ✅ 60% مكتملة - جاهز للاختبار الفوري
**الوقت المتوقع**: 1-2 أسبوع لإكمال كل شيء
**الأولوية**: Task 1 و Task 2 فوراً
