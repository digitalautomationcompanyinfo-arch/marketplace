import React, { useState } from 'react';
import { useMutation } from '@tanstack/react-query';
import { Send, Bell, Users, Store, MapPin } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../services/api';

const targets = [
  { value: 'all_users',     label: 'جميع المستخدمين',   icon: <Users size={18} />,  color: '#2980B9' },
  { value: 'all_providers', label: 'جميع مزودي الخدمة', icon: <Store size={18} />,  color: '#27AE60' },
  { value: 'region',        label: 'منطقة محددة',        icon: <MapPin size={18} />, color: '#8E44AD' },
];

export default function NotificationsPage() {
  const [form, setForm] = useState({ title: '', body: '', target: 'all_users', region_id: '' });
  const [history] = useState([
    { title: 'عروض رمضان 🌙', target: 'جميع المستخدمين', sent: 4280, date: 'أمس' },
    { title: 'مزودون جدد في الرياض', target: 'منطقة الرياض', sent: 1240, date: 'منذ يومين' },
    { title: 'تجديد اشتراكك', target: 'جميع مزودي الخدمة', sent: 892, date: 'منذ أسبوع' },
  ]);

  const sendMutation = useMutation({
    mutationFn: () => api.post('/admin/notifications/send', form),
    onSuccess: (res) => {
      toast.success(`✅ تم الإرسال بنجاح`);
      setForm({ title: '', body: '', target: 'all_users', region_id: '' });
    },
    onError: () => toast.error('فشل الإرسال'),
  });

  const charCount = form.body.length;

  return (
    <div style={{ fontFamily: 'Cairo, Arial, sans-serif' }}>
      <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A3C5E', marginBottom: 4 }}>إرسال إشعارات</h1>
      <p style={{ color: '#7F8C8D', fontSize: 14, marginBottom: 24 }}>أرسل إشعارات push لجميع مستخدمي المنصة أو لشريحة محددة</p>

      <div style={{ display: 'grid', gridTemplateColumns: '1.2fr 0.8fr', gap: 20 }}>

        {/* ─── نموذج الإرسال ────────────────────────────── */}
        <div style={cardStyle}>
          <h3 style={{ margin: '0 0 20px', color: '#1A3C5E', fontSize: 16 }}>إنشاء إشعار جديد</h3>

          {/* اختيار الجمهور */}
          <label style={labelStyle}>الجمهور المستهدف</label>
          <div style={{ display: 'flex', gap: 10, marginBottom: 20 }}>
            {targets.map(t => (
              <button key={t.value}
                onClick={() => setForm(f => ({ ...f, target: t.value }))}
                style={{
                  flex: 1, padding: '10px 8px', border: 'none', borderRadius: 10, cursor: 'pointer',
                  display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4,
                  background: form.target === t.value ? t.color : '#F5F6FA',
                  color: form.target === t.value ? 'white' : '#566573',
                  fontFamily: 'Cairo', fontSize: 12, fontWeight: 600,
                  transition: 'all 0.2s',
                }}>
                {t.icon}
                {t.label}
              </button>
            ))}
          </div>

          {/* عنوان الإشعار */}
          <label style={labelStyle}>عنوان الإشعار *</label>
          <input
            value={form.title}
            onChange={e => setForm(f => ({ ...f, title: e.target.value }))}
            placeholder="مثال: عروض حصرية لك اليوم! 🎉"
            style={inputStyle}
          />

          {/* نص الإشعار */}
          <label style={{ ...labelStyle, marginTop: 16 }}>نص الإشعار *</label>
          <div style={{ position: 'relative' }}>
            <textarea
              value={form.body}
              onChange={e => setForm(f => ({ ...f, body: e.target.value }))}
              placeholder="اكتب تفاصيل الإشعار هنا..."
              maxLength={250}
              rows={4}
              style={{ ...inputStyle, resize: 'none' }}
            />
            <span style={{ position: 'absolute', bottom: 8, left: 8, fontSize: 11, color: charCount > 200 ? '#E74C3C' : '#95A5A6' }}>
              {charCount}/250
            </span>
          </div>

          {/* معاينة */}
          {(form.title || form.body) && (
            <div style={{ marginTop: 20, padding: 16, background: '#F8F9FA', borderRadius: 12, border: '1px solid #E9ECEF' }}>
              <div style={{ fontSize: 12, color: '#7F8C8D', marginBottom: 8 }}>👁️ معاينة الإشعار</div>
              <div style={{ display: 'flex', gap: 10 }}>
                <div style={{ width: 36, height: 36, background: '#1A3C5E', borderRadius: 8, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <Bell size={20} color="white" />
                </div>
                <div>
                  <div style={{ fontWeight: 700, fontSize: 14 }}>{form.title || 'عنوان الإشعار'}</div>
                  <div style={{ fontSize: 13, color: '#566573', marginTop: 2 }}>{form.body || 'نص الإشعار...'}</div>
                </div>
              </div>
            </div>
          )}

          <button
            onClick={() => sendMutation.mutate()}
            disabled={!form.title.trim() || !form.body.trim() || sendMutation.isPending}
            style={{
              width: '100%', padding: 14, marginTop: 20,
              background: !form.title.trim() || !form.body.trim() ? '#BDC3C7' : '#1A3C5E',
              color: 'white', border: 'none', borderRadius: 12, cursor: 'pointer',
              fontFamily: 'Cairo', fontWeight: 700, fontSize: 15,
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
            }}>
            <Send size={18} />
            {sendMutation.isPending ? 'جاري الإرسال...' : 'إرسال الإشعار'}
          </button>
        </div>

        {/* ─── سجل الإشعارات ──────────────────────────── */}
        <div style={cardStyle}>
          <h3 style={{ margin: '0 0 20px', color: '#1A3C5E', fontSize: 16 }}>آخر الإشعارات المرسلة</h3>
          {history.map((n, i) => (
            <div key={i} style={{ padding: '14px 0', borderBottom: i < history.length - 1 ? '1px solid #F5F6FA' : 'none' }}>
              <div style={{ fontWeight: 600, fontSize: 14, marginBottom: 4 }}>{n.title}</div>
              <div style={{ fontSize: 12, color: '#7F8C8D', display: 'flex', justifyContent: 'space-between' }}>
                <span>📤 {n.target}</span>
                <span>✅ {n.sent.toLocaleString()} جهاز</span>
              </div>
              <div style={{ fontSize: 11, color: '#95A5A6', marginTop: 4 }}>🕐 {n.date}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

const cardStyle = { background: 'white', borderRadius: 16, padding: 24, boxShadow: '0 2px 12px rgba(0,0,0,0.06)' };
const labelStyle = { display: 'block', fontSize: 13, fontWeight: 600, color: '#2C3E50', marginBottom: 8 };
const inputStyle = { width: '100%', padding: '10px 14px', border: '1px solid #E0E0E0', borderRadius: 10, fontFamily: 'Cairo', fontSize: 14, direction: 'rtl', boxSizing: 'border-box', outline: 'none' };

