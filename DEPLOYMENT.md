# 🚀 دليل النشر على الإنتاج (Production Deployment)

## الخيار 1: نشر سريع بـ Docker (موصى به)

### المتطلبات
- VPS بـ Ubuntu 22.04 (2GB RAM على الأقل)
- Docker + Docker Compose
- اسم نطاق (domain)

### الخطوات

```bash
# 1. نسخ المشروع على السيرفر
git clone <your-repo> && cd marketplace

# 2. إعداد البيئة
cp backend/.env.example backend/.env
nano backend/.env  # عدّل جميع القيم

# 3. SSL Certificate (مجاني)
apt install certbot
certbot certonly --standalone -d api.yourdomain.com -d admin.yourdomain.com

# 4. تشغيل كل شيء
chmod +x start.sh && ./start.sh

# 5. التحقق
curl https://api.yourdomain.com/health
```

---

## الخيار 2: نشر على Railway (أسرع للتجربة)

### Backend
```bash
# ثبّت Railway CLI
npm install -g @railway/cli

# سجل دخول
railway login

# أنشئ مشروع جديد
cd backend
railway init

# أضف PostgreSQL و Redis
railway add postgresql
railway add redis

# نشر
railway up
```

### Admin Dashboard
```bash
cd admin_dashboard
railway init
railway up
```

---

## الخيار 3: نشر على Render

### Backend
1. ارفع الكود على GitHub
2. اذهب إلى render.com
3. **New → Web Service**
4. اختر الـ repository
5. **Build Command**: `npm install`
6. **Start Command**: `node src/server.js`
7. أضف متغيرات البيئة من `.env.example`
8. أضف **PostgreSQL** و **Redis** من قائمة الخدمات

### Admin Dashboard
1. **New → Static Site**
2. **Build Command**: `npm run build`
3. **Publish Directory**: `build`
4. أضف: `REACT_APP_API_URL=https://your-backend.onrender.com/api/v1`

---

## الخيار 4: نشر على DigitalOcean App Platform

```yaml
# .do/app.yaml
name: marketplace
services:
  - name: backend
    source_dir: backend
    environment_slug: node-js
    run_command: node src/server.js
    envs:
      - key: NODE_ENV
        value: production

  - name: admin
    source_dir: admin_dashboard
    environment_slug: node-js
    build_command: npm run build
    output_dir: build

databases:
  - name: marketplace-db
    engine: PG
    version: "15"
  - name: marketplace-redis
    engine: REDIS
```

---

## الخيار 5: نشر تطبيق Flutter

### Android (Google Play)
```bash
# بناء APK للإنتاج
flutter build apk --release

# بناء App Bundle (للـ Play Store)
flutter build appbundle --release

# الملف في: build/app/outputs/bundle/release/app-release.aab
```

### iOS (App Store)
```bash
# يتطلب Mac + Xcode
flutter build ios --release

# ثم افتح Xcode وارفع من Product → Archive
```

---

## قائمة التحقق قبل الإطالق

### الأمان 🔒
- [ ] `JWT_SECRET` طويل وعشوائي (استخدم: `openssl rand -base64 64`)
- [ ] HTTPS مُفعّل على جميع النطاقات
- [ ] Rate Limiting مُفعّل
- [ ] Firewall: افتح فقط المنافذ 80 و 443
- [ ] قاعدة البيانات غير متاحة للعالم الخارجي
- [ ] CORS مُقيّد لنطاقات محددة فقط

### الأداء ⚡
- [ ] Redis مُفعّل للـ Caching
- [ ] CDN مُفعّل للصور (Cloudinary)
- [ ] Database Indexes مُطبّقة (في schema.sql)
- [ ] Gzip مُفعّل في Nginx

### المراقبة 📊
- [ ] Logging مُعدّ (Winston → ملفات)
- [ ] Error tracking (Sentry)
- [ ] Uptime monitoring (UptimeRobot)
- [ ] Database backups تلقائية

### الاختبار ✅
- [ ] اختبار API كامل (Postman Collection)
- [ ] اختبار الدفع في بيئة Test ثم Live
- [ ] اختبار الإشعارات على iOS و Android
- [ ] اختبار الأداء تحت حمل (k6)

---

## أوامر مفيدة للـ Production

```bash
# مشاهدة logs البيرفور
docker-compose logs -f backend

# إعادة تشغيل Backend فقط
docker-compose restart backend

# backup قاعدة البيانات
docker exec marketplace_db pg_dump -U postgres marketplace_db > backup_$(date +%Y%m%d).sql

# استعادة backup
docker exec -i marketplace_db psql -U postgres marketplace_db < backup_20240101.sql

# مشاهدة استهلاك الموارد
docker stats

# تحديث الكود
git pull && docker-compose build backend && docker-compose up -d backend
```

---

## تكاليف الاستضافة التقديرية

| المزود | المواصفات | السعر/شهر |
|--------|-----------|-----------|
| DigitalOcean Droplet | 2GB RAM, 50GB SSD | $12 |
| Railway Basic | مناسب للبداية | $5-20 |
| Render Starter | مناسب للبداية | مجاني → $7 |
| AWS EC2 t3.small | 2GB RAM | $15 |

**نصيحة**: ابدأ بـ Railway أو Render للتوفير في الوقت، وانتقل لـ DigitalOcean عند الحاجة لتحكم أكبر.
