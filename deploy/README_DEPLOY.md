نشر تجريبي (سريع) باستخدام صور الحاويات على GitHub Container Registry (GHCR)
=====================================================================

ملف العمل هذا يشرح خطوات نشر تجريبي على منصات مجانية باستخدام الصور المبنية تلقائياً إلى GHCR بواسطة GitHub Actions.

ما الذي نفّعله هنا
- عند كل دفع (`push`) على الفرع `main` يقوم workflow `.github/workflows/build_and_publish_images.yml` ببناء صور `backend` و`admin` ودفعها إلى `ghcr.io/<owner>/marketplace-backend:latest` و`ghcr.io/<owner>/marketplace-admin:latest`.

لماذا هذا مفيد
- يتيح لك هذا نشر الحاويات إلى منصات استضافة تدعم سحب صورة من سجل الحاويات (Fly.io, Render, Railway, Render).
- تحتاج إلى أقل قدر من الأسرار (عادة اسم التطبيق/رمز الوصول على المنصة) أو يمكن الربط اليدوي عبر واجهة الويب.

خطوات سريعة لنشر الخلفية إلى Fly.io (مثال)
1. أنشئ حساباً في https://fly.io
2. أنشئ تطبيقاً جديداً باسم `your-fly-app-name` (أو استخدم `flyctl apps create your-fly-app-name` محلياً).
3. في Fly.io استخدم خيار "Deploy via image" أو شغّل محلياً (مع `flyctl`) الأمر:

```bash
# من جهازك المحلي (تتطلب تثبيت flyctl ووجود صورة GHCR مرفوعة)
flyctl deploy --image ghcr.io/<GITHUB_OWNER>/marketplace-backend:latest --app your-fly-app-name
```

خطوات سريعة للنشر على Render (مثال)
1. أنشئ حساباً في https://render.com
2. أنشئ خدمة جديدة من نوع "Web Service" واختر "Docker" أو "Private Image".
3. إذا اخترت "Private Image" أدخل مسار الصورة `ghcr.io/<GITHUB_OWNER>/marketplace-backend:latest` وأضف مفتاح وصول (يمكنك إنشاء GitHub Personal Access Token مع صلاحية `read:packages` وتخزينه كسر في Render).

نشر الواجهة الإدارية
- يمكنك نشر الواجهة (`admin_dashboard`) مباشرة على Vercel من GitHub (توصي Vercel بربط المستودع)، أو استخدام الصورة `ghcr.io/<GITHUB_OWNER>/marketplace-admin:latest` بنفس طريقة Render أو Fly.

قاعدة البيانات وRedis
- لبيئة تجريبية مجانية:
  - PostgreSQL: استخدم Supabase (خطة مجانية) أو خدمة Render Databases.
  - Redis: استخدم Upstash (خطة مجانية تُتيح Redis عبر واجهة REST/URL).

ملاحظات للتهيئة وتفعيل النشر الآلي
- تأكد أن المستودع في GitHub وworkflow يعمل على الفرع `main`.
- لا يلزم أي سر إضافي لبناء ودفع الصور إلى GHCR لأن `GITHUB_TOKEN` متوفر تلقائياً في Actions.
- بعد أن تُرفع الصور، استخدم لوحة Fly/Render/Vercel لربط الصورة أو اتّبع الأوامر الموضّحة أعلاه.

أمثلة أوامر محلية مفيدة
```bash
# بناء ورفع يدوي (محلي) إلى GHCR
docker build -t ghcr.io/<GITHUB_OWNER>/marketplace-backend:latest -f backend/Dockerfile backend
docker push ghcr.io/<GITHUB_OWNER>/marketplace-backend:latest

# نشر إلى Fly (محلي)
flyctl deploy --image ghcr.io/<GITHUB_OWNER>/marketplace-backend:latest --app your-fly-app-name
```

الخطوات التالية التي أستطيع تنفيذها لك
- أ) أهيئ ونشِر تلقائياً إلى Fly.io (أحتاج `FLY_API_TOKEN` واسم التطبيق).
- ب) أهيئ ربط Vercel للوحة الإدارة (أحتاج صلاحية Vercel أو توجيهك لربط المشروع).
- ج) أهيئ Supabase وقاعدة البيانات (أحتاج صلاحيات لإنشاء مشروع أو سأزوّد ملف `pg:restore` وإرشادات).

أخبرني أي خيار تفضّل (أقوم تلقائياً بإعداد ما أستطيع ومرشدك لباقي الأسرار)، أو اختَر أن أجرّب نشرًا تلقائيًا إلى منصة محددة الآن.
