#!/bin/bash
# ============================================================
# init-ssl.sh — إعداد شهادة SSL تلقائياً بـ Let's Encrypt
# الاستخدام: sudo bash scripts/init-ssl.sh yourdomain.com admin@yourdomain.com
# ============================================================

set -euo pipefail

DOMAIN="${1:-}"
EMAIL="${2:-}"

if [[ -z "$DOMAIN" || -z "$EMAIL" ]]; then
  echo "❌ الاستخدام: sudo bash scripts/init-ssl.sh <domain> <email>"
  echo "   مثال: sudo bash scripts/init-ssl.sh api.marketplace.com admin@marketplace.com"
  exit 1
fi

SSL_DIR="./nginx/ssl"
COMPOSE_FILE="./docker-compose.yml"

echo "🔒 إعداد SSL لـ: $DOMAIN"

# ─── 1. تثبيت certbot إذا لم يكن موجوداً ─────────────────────
if ! command -v certbot &>/dev/null; then
  echo "📦 تثبيت certbot..."
  apt-get update -qq && apt-get install -y certbot
fi

# ─── 2. إنشاء مجلد SSL ────────────────────────────────────────
mkdir -p "$SSL_DIR"

# ─── 3. إيقاف Nginx مؤقتاً للحصول على الشهادة ────────────────
echo "⏸  إيقاف Nginx مؤقتاً..."
docker compose -f "$COMPOSE_FILE" stop nginx 2>/dev/null || true

# ─── 4. الحصول على الشهادة ────────────────────────────────────
echo "🌐 الحصول على شهادة Let's Encrypt..."
certbot certonly \
  --standalone \
  --non-interactive \
  --agree-tos \
  --email "$EMAIL" \
  -d "$DOMAIN"

# ─── 5. نسخ الشهادات إلى مجلد nginx ──────────────────────────
echo "📂 نسخ الشهادات..."
cp /etc/letsencrypt/live/"$DOMAIN"/fullchain.pem "$SSL_DIR/cert.pem"
cp /etc/letsencrypt/live/"$DOMAIN"/privkey.pem   "$SSL_DIR/key.pem"
chmod 600 "$SSL_DIR/key.pem"
chmod 644 "$SSL_DIR/cert.pem"

# ─── 6. إعادة تشغيل Nginx ────────────────────────────────────
echo "▶️  إعادة تشغيل Nginx..."
docker compose -f "$COMPOSE_FILE" start nginx

# ─── 7. إعداد التجديد التلقائي (cron) ────────────────────────
CRON_JOB="0 3 * * * certbot renew --quiet && cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem $PWD/$SSL_DIR/cert.pem && cp /etc/letsencrypt/live/$DOMAIN/privkey.pem $PWD/$SSL_DIR/key.pem && docker compose -f $PWD/$COMPOSE_FILE exec nginx nginx -s reload"

if ! crontab -l 2>/dev/null | grep -q "certbot renew"; then
  (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  echo "✅ تم ضبط التجديد التلقائي (يومياً 3:00 صباحاً)"
fi

echo ""
echo "✅ تم إعداد SSL بنجاح!"
echo "   الشهادة: $SSL_DIR/cert.pem"
echo "   المفتاح: $SSL_DIR/key.pem"
echo "   صلاحية: 90 يوم (تجديد تلقائي)"
