# NGINX SSL — تقرير فحص سريع

## الملخّص التنفيذي

- الشهادة الموجودة في `nginx/ssl/cert.pem` صالحة من **2026-03-22** حتى **2027-03-22**.
- المفتاح الموجود في `nginx/ssl/key.pem` غير مُشفّر ويطابق الشهادة (تحقق: MATCH).
- تم تعديل `docker-compose.yml` لربط المجلد المحلي `./nginx/ssl` إلى `/etc/nginx/ssl` داخل حاوية Nginx.

## الفحوصات المنفّذة

- قراءة محتوى الشهادة وفحص تواريخ الصلاحية باستخدام Node (`crypto.X509Certificate`).
- التحقق من تطابق المفتاح العام المشتق من `key.pem` مع المفتاح الموجود في الشهادة.
- مراجعة `nginx/nginx.conf` و`docker-compose.yml` للتأكد من المسارات والإعدادات الأساسية.

## الإجراءات المُنفّذة

- تعديل `docker-compose.yml` لربط الشهادات داخل الحاوية بدلاً من استخدام volume فارغ.

## التوصيات الفورية

- ضبط أذونات المفتاح على المضيف:

```bash
chmod 600 ./nginx/ssl/key.pem
```

- اختبار تكوين Nginx وتشغيل الحاويات:

```bash
docker-compose up -d
docker-compose run --rm nginx nginx -t -c /etc/nginx/nginx.conf
```

- توليد DH parameters (يُحسّن أمان التشفير):

```bash
openssl dhparam -out ./nginx/ssl/dhparam.pem 2048
```

ثم أضف داخل قسم SSL في `nginx.conf`:

```
ssl_dhparam /etc/nginx/ssl/dhparam.pem;
```

- OCSP stapling: تأكد من وجود `resolver` صالح في `nginx.conf` (DNS قابل للوصول من داخل الحاوية) وابقَ `ssl_stapling on;` و`ssl_stapling_verify on;`. ملاحظة: عمل OCSP يتطلب CA يدعم الـ OCSP.

- للإنتاج: استخدم شهادة مُصدَّقة (مثلاً Let's Encrypt) بدلاً من self-signed قبل انتهاء الصلاحية، وتهيئ التجديد التلقائي (`certbot` أو `acme.sh`).

- حماية المفتاح: للنشر الآمن، ضع المفاتيح كـ Docker secrets أو داخل مخزن آمن (KMS). تجنّب وضع المفاتيح في سِجلات غير مشفرة أو نسخ احتياطية غير مؤمنة.

## خطوات مقترحة قادمة (اختر خياراً)

1. توليد `dhparam` الآن وإدراجه في `./nginx/ssl` (يحسّن الأمان).  
2. تهيئة Let's Encrypt وتجديد تلقائي عبر `certbot` أو `acme.sh`.  
3. نقل الشهادات إلى Docker secrets أو بناء صورة Nginx مخصّصة مع ضبط الصلاحيات آلياً.

## مراجع سريعة

- تقرير هذا الفحص محفوظ في هذا الملف: [NGINX_SSL_REPORT.md](NGINX_SSL_REPORT.md)
- ملفات التكوين ذات الصلة: [nginx/nginx.conf](nginx/nginx.conf) و[ docker-compose.yml](docker-compose.yml)

---
تقرير مُختصر أُنشئ آلياً — أخبرني أي خيار تفضّل للخطوة التالية (توليد `dhparam` الآن، تهيئة Let's Encrypt، أو نقل الشهادات إلى Docker secrets). 
