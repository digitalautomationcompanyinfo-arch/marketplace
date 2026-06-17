# 🚀 كيف نخدمك للخدمات المتكاملة

## هيكل المشروع

```
marketplace/
├── backend/                    Node.js + Express API
│   ├── src/
│   │   ├── server.js           نقطة الدخول الرئيسية
│   │   ├── config/
│   │   │   ├── database.js     PostgreSQL Pool
│   │   │   ├── redis.js        Redis Cache
│   │   │   ├── firebase.js     Firebase Admin
│   │   │   ├── socket.js       WebSocket / رسائل فورية
│   │   │   └── schema.sql      20 جدول كامل
│   │   ├── controllers/
│   │   │   ├── auth.controller.js          تسجيل + OTP + JWT
│   │   │   ├── provider.controller.js      مزودو الخدمة
│   │   │   ├── product.controller.js       المنتجات + باركود
│   │   │   ├── search.controller.js        بحث نصي + جغرافي
│   │   │   ├── subscription.controller.js  Stripe + اشتراكات
│   │   │   └── admin.controller.js         لوحة التحكم الكاملة
│   │   ├── middleware/
│   │   │   ├── auth.middleware.js   JWT لـ 3 أنواع مستخدمين
│   │   │   ├── errorHandler.js      معالجة مركزية للأخطاء
│   │   │   ├── validate.js          التحقق من المدخلات
│   │   │   └── upload.middleware.js رفع الملفات
│   │   ├── services/
│   │   │   ├── notification.service.js  Firebase Push
│   │   │   ├── upload.service.js        Cloudinary
│   │   │   ├── sms.service.js           Twilio OTP
│   │   │   └── email.service.js         Nodemailer
│   │   └── routes/             جميع نقاط الـ API
│   └── Dockerfile
│
├── flutter_customer/           تطبيق المستخدم
│   └── lib/
│       ├── main.dart           Firebase + RTL + Riverpod
│       ├── core/router/        GoRouter
│       └── features/
│           ├── home/           الشاشة الرئيسية
│           └── messages/       الدردشة الفورية
│
├── flutter_provider/           تطبيق مزود الخدمة
│   └── lib/
│       └── features/
│           ├── dashboard/      لوحة التحكم + رسوم بيانية
│           ├── products/       إدارة المنتجات + باركود
│           └── stats/          الإحصاءات التفصيلية
│
├── admin_dashboard/            React.js Admin Panel
│   └── src/
│       ├── App.jsx
│       ├── components/layout/  AdminLayout + Sidebar
│       ├── pages/
│       │   ├── dashboard/      KPIs + Charts
│       │   ├── providers/      PendingPage + ProvidersPage
│       │   └── notifications/  إرسال إشعارات
│       ├── services/api.js     Axios + JWT
│       └── store/authStore.js  Zustand
│
├── docker-compose.yml          تشغيل كل شيء
└── start.sh                    سكريبت التشغيل
```

## متطلبات التشغيل

- Docker + Docker Compose
- أو: Node.js 20+ و PostgreSQL 15+ و Redis 7+

## التشغيل السريع بـ Docker

```bash
# 1. نسخ المشروع
git clone <repo-url> && cd marketplace

# 2. إعداد البيئة
cp backend/.env.example backend/.env
# عدّل backend/.env بقيمك الحقيقية

# 3. تشغيل كل شيء
chmod +x start.sh && ./start.sh
```

## التشغيل بدون Docker

```bash
# Backend
cd backend
npm install
npm run migrate    # تطبيق schema.sql
npm run dev        # http://localhost:5001

# Admin Dashboard
cd admin_dashboard
npm install
npm start          # http://localhost:3000

# Flutter
cd flutter_customer
flutter pub get
flutter run

cd flutter_provider
flutter pub get
flutter run
```

## متغيرات البيئة الإلزامية

| المتغير | الوصف |
|---------|-------|
| `JWT_SECRET` | مفتاح سري طويل (32+ حرف) |
| `DB_PASSWORD` | كلمة مرور PostgreSQL |
| `FIREBASE_*` | بيانات Firebase للإشعارات |
| `TWILIO_*` | بيانات Twilio للـ OTP |
| `STRIPE_SECRET_KEY` | مفتاح Stripe للمدفوعات |
| `CLOUDINARY_*` | بيانات Cloudinary للصور |

## نقاط API الرئيسية

| النهاية | الوصف |
|---------|-------|
| `POST /api/v1/auth/register` | تسجيل مستخدم |
| `POST /api/v1/auth/login` | تسجيل الدخول |
| `GET /api/v1/providers/nearby?lat=&lng=` | المزودون القريبون |
| `GET /api/v1/search?q=&category_id=` | البحث الشامل |
| `GET /api/v1/search/autocomplete?q=` | اقتراحات فورية |
| `POST /api/v1/subscriptions/pay` | الدفع والاشتراك |
| `WS /socket.io` | الرسائل الفورية |

## التقنيات المستخدمة

- **Backend**: Node.js + Express + PostgreSQL + Redis + Socket.io
- **Mobile**: Flutter (iOS + Android)
- **Admin**: React.js + Recharts + Zustand
- **الإشعارات**: Firebase FCM
- **الصور**: Cloudinary
- **المدفوعات**: Stripe + STC Pay + Mada
- **OTP**: Twilio
- **البحث الجغرافي**: PostGIS
