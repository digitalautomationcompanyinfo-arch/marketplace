# دليل تشغيل كيف نخدمك 🚀

هذا الدليل يلخص خطوات تشغيل جميع مكونات النظام بعد عملية الإعداد والتجهيز.

## 1. الخلفية (Backend)
الخلفية تعمل على المنفذ **5001**.
- انتقل للمجلد: `cd backend`
- التشغيل: `node src/server.js`
- للتحقق: [http://localhost:5001/health](http://localhost:5001/health)

## 2. لوحة تحكم المسؤول (Admin Dashboard)
تعمل على المنفذ **3000**.
- انتقل للمجلد: `cd admin_dashboard`
- التشغيل: `npm start`
- الرابط: [http://localhost:3000](http://localhost:3000)

## 3. تطبيق العميل (Flutter Customer)
- انتقل للمجلد: `cd flutter_customer`
- تحميل المكتبات: `flutter pub get`
- التشغيل: `flutter run`

## 4. تطبيق المزود (Flutter Provider)
- انتقل للمجلد: `cd flutter_provider`
- تحميل المكتبات: `flutter pub get`
- التشغيل: `flutter run`

---

### ملاحظات هامة:
- تم توحيد جميع الاتصالات لتتم عبر المنفذ **5001**.
- تأكد من تشغيل السيرفر أولاً قبل تشغيل التطبيقات.
- في حال واجهت مشكلة في الصلاحيات عند تشغيل `npm` على Windows، استخدم `node` مباشرة أو تأكد من `Execution Policy`.
