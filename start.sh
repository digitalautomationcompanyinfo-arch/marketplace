#!/bin/bash
# ============================================
# كيف نخدمك - سكريبت الإعداد والتشغيل
# ============================================

set -e
echo "🚀 بدء إعداد المنصة..."

# التحقق من المتطلبات
command -v docker >/dev/null 2>&1 || { echo "❌ Docker غير مثبت"; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "❌ Docker Compose غير مثبت"; exit 1; }

# إعداد ملف البيئة
if [ ! -f backend/.env ]; then
  echo "📝 إنشاء ملف البيئة..."
  cp backend/.env.example backend/.env
  echo "⚠️  يرجى تعديل backend/.env قبل المتابعة"
fi

# بناء وتشغيل الخدمات
echo "🏗️  بناء الخدمات..."
docker-compose build

echo "▶️  تشغيل قاعدة البيانات أولاً..."
docker-compose up -d postgres redis
sleep 8

echo "▶️  تشغيل باقي الخدمات..."
docker-compose up -d backend admin nginx

echo ""
echo "✅ تم التشغيل بنجاح!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📡 API:        http://localhost:5001/api/v1"
echo "🖥️  Admin:      http://localhost:3000"
echo "📊 Health:     http://localhost:5001/health"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
