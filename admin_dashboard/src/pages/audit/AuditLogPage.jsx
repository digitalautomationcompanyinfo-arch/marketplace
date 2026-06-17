import React, { useState } from 'react';
import { ClipboardList, User, Store, Tag, Bell, Shield } from 'lucide-react';

const actionIcons = {
  approve_provider:   { icon: <Store size={15} />,       color: '#27AE60', bg: '#D5F5E3' },
  reject_provider:    { icon: <Store size={15} />,       color: '#E74C3C', bg: '#FADBD8' },
  deactivate_user:    { icon: <User size={15} />,        color: '#E74C3C', bg: '#FADBD8' },
  soft_delete_user:   { icon: <User size={15} />,        color: '#922B21', bg: '#FADBD8' },
  activate_user:      { icon: <User size={15} />,        color: '#27AE60', bg: '#D5F5E3' },
  delete_user:        { icon: <Trash2 size={15} />,      color: '#922B21', bg: '#FADBD8' },
  send_notification:  { icon: <Bell size={15} />,        color: '#2980B9', bg: '#D6EAF8' },
  resolve_report:     { icon: <Shield size={15} />,      color: '#8E44AD', bg: '#F4ECF7' },
  create_category:    { icon: <Tag size={15} />,         color: '#D4A017', bg: '#FEF9E7' },
  update_category:    { icon: <Tag size={15} />,         color: '#D4A017', bg: '#FEF9E7' },
  admin_login:        { icon: <Shield size={15} />,      color: '#1A3C5E', bg: '#EBF5FB' },
  failed_login_admin: { icon: <Shield size={15} />,      color: '#E74C3C', bg: '#FADBD8' },
  system_auto_deactivate: { icon: <Store size={15} />,   color: '#7F8C8D', bg: '#F5F6FA' },
};

const actionLabels = {
  approve_provider:  'موافقة على مزود',
  reject_provider:   'رفض مزود',
  deactivate_user:   'تعطيل مستخدم',
  soft_delete_user:  'حذف ناعم للمستخدم',
  activate_user:     'تفعيل مستخدم',
  delete_user:       'حذف مستخدم',
  send_notification: 'إرسال إشعار',
  resolve_report:    'معالجة بلاغ',
  create_category:   'إضافة فئة',
  update_category:   'تعديل فئة',
  admin_login:       'تسجيل دخول مسؤول',
  failed_login_admin: 'محاولة دخول فاشلة',
  system_auto_deactivate: 'تعطيل تلقائي (النظام)',
  admin_login_2fa_success: 'تحقق ثنائي ناجح',
  failed_2fa: 'فشل التحقق الثنائي',
  adjust_user_wallet: 'تعديل رصيد المحفظة',
};

import { useQuery } from '@tanstack/react-query';
import api from '../../services/api';
import { Trash2 } from 'lucide-react';

function timeAgo(dateStr) {
  const diff = Date.now() - new Date(dateStr).getTime();
  const mins = Math.floor(diff / 60000);
  if (mins < 1)  return 'الآن';
  if (mins < 60) return `قبل ${mins} دقيقة`;
  const hrs = Math.floor(mins / 60);
  if (hrs < 24)  return `قبل ${hrs} ساعة`;
  return `قبل ${Math.floor(hrs / 24)} يوم`;
}

export default function AuditLogPage() {
  const [search, setSearch] = useState('');
  const [adminFilter, setAdminFilter] = useState('all');
  const [page, setPage] = useState(1);

  const { data: logsData = { data: [], pagination: { total: 0, pages: 1 } } } = useQuery({
    queryKey: ['audit-admin', page],
    queryFn: () => api.get('/admin/audit-log', { params: { page, limit: 50 } }).then(r => r.data),
    placeholderData: { data: [] },
  });

  const sourceLogs = logsData.data || [];
  const pagination = logsData.pagination || { total: 0, pages: 1 };

  const admins = [...new Set(sourceLogs.map(l => l.admin_name || (l.actor_type === 'system' ? 'النظام' : 'مجهول')))];
  const logs = sourceLogs.filter(l => {
    const actorName = l.admin_name || (l.actor_type === 'system' ? 'النظام' : 'مجهول');
    return (!search || actionLabels[l.action]?.includes(search) || actorName.includes(search)) &&
           (adminFilter === 'all' || actorName === adminFilter);
  });

  return (
    <div style={{ fontFamily: 'Cairo, Arial, sans-serif', paddingBottom: 50 }}>
      <div style={{ marginBottom: 24 }}>
        <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A3C5E', margin: 0 }}>سجل الأنشطة والرقابة</h1>
        <p style={{ color: '#7F8C8D', fontSize: 14, marginTop: 4 }}>تتبع كافة التحركات الإدارية وعمليات النظام التلقائية ({pagination.total} سجل)</p>
      </div>

      {/* إحصاء سريع (مبني على الصفحة الحالية) */}
      <div style={{ display: 'flex', gap: 12, marginBottom: 24, overflowX: 'auto', paddingBottom: 10 }}>
        {Object.entries(
          sourceLogs.reduce((acc, l) => { acc[l.action] = (acc[l.action] || 0) + 1; return acc; }, {})
        ).slice(0, 5).map(([action, count]) => {
          const cfg = actionIcons[action] || { icon: <ClipboardList size={15} />, color: '#566573', bg: '#F5F6FA' };
          return (
            <div key={action} style={{ background: 'white', borderRadius: 12, padding: '12px 16px', display: 'flex', alignItems: 'center', gap: 10, boxShadow: '0 2px 8px rgba(0,0,0,0.06)', minWidth: 160 }}>
              <div style={{ width: 32, height: 32, borderRadius: 8, background: cfg.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', color: cfg.color }}>
                {cfg.icon}
              </div>
              <div>
                <div style={{ fontWeight: 700, fontSize: 18, color: cfg.color }}>{count}</div>
                <div style={{ fontSize: 11, color: '#95A5A5', whiteSpace: 'nowrap' }}>{actionLabels[action] || action}</div>
              </div>
            </div>
          );
        })}
      </div>

      {/* فلاتر */}
      <div style={{ display: 'flex', gap: 12, marginBottom: 20 }}>
        <input value={search} onChange={e => { setSearch(e.target.value); setPage(1); }} placeholder="بحث في السجل (إجراء، مسؤول...)"
          style={{ flex: 1, padding: '10px 14px', border: '1px solid #E0E0E0', borderRadius: 10, fontFamily: 'Cairo', fontSize: 14, direction: 'rtl' }} />
        <select value={adminFilter} onChange={e => { setAdminFilter(e.target.value); setPage(1); }}
          style={{ padding: '10px 14px', border: '1px solid #E0E0E0', borderRadius: 10, fontFamily: 'Cairo', fontSize: 14 }}>
          <option value="all">الكل (مسؤولون ونظام)</option>
          {admins.map(a => <option key={a} value={a}>{a}</option>)}
        </select>
      </div>

      {/* السجل */}
      <div style={{ background: 'white', borderRadius: 16, overflow: 'hidden', boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
        {logs.map((log, i) => {
          const cfg = actionIcons[log.action] || { icon: <ClipboardList size={15} />, color: '#566573', bg: '#F5F6FA' };
          const actorName = log.admin_name || (log.actor_type === 'system' ? 'النظام' : 'مجهول');
          const isSystem = log.actor_type === 'system';
          
          return (
            <div key={log.id} style={{ display: 'flex', alignItems: 'flex-start', gap: 14, padding: '16px 20px', borderBottom: i < logs.length - 1 ? '1px solid #F5F6FA' : 'none', transition: 'background 0.15s' }}
              onMouseEnter={e => e.currentTarget.style.background = '#FAFCFF'}
              onMouseLeave={e => e.currentTarget.style.background = 'white'}>

              {/* أيقونة الإجراء */}
              <div style={{ width: 38, height: 38, borderRadius: 10, background: cfg.bg, display: 'flex', alignItems: 'center', justifyContent: 'center', color: cfg.color, flexShrink: 0 }}>
                {isSystem ? <div style={{ fontSize: 10, fontWeight: 900 }}>SYS</div> : cfg.icon}
              </div>

              {/* التفاصيل */}
              <div style={{ flex: 1 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
                   <span style={{ fontWeight: 700, fontSize: 14, color: isSystem ? '#7F8C8D' : '#2C3E50' }}>{actorName}</span>
                  <span style={{ color: '#7F8C8D', fontSize: 13 }}>قام بـ</span>
                  <span style={{ padding: '2px 10px', borderRadius: 20, fontSize: 12, fontWeight: 600, background: cfg.bg, color: cfg.color }}>
                    {actionLabels[log.action] || log.action}
                  </span>
                </div>

                {/* بيانات الإجراء */}
                <div style={{ fontSize: 13, color: '#566573', display: 'flex', gap: 12, flexWrap: 'wrap' }}>
                  {Object.entries(log.details).map(([k, v]) => (
                    <span key={k} style={{ background: '#F8F9FA', padding: '2px 8px', borderRadius: 6 }}>
                      {k}: <strong>{String(v)}</strong>
                    </span>
                  ))}
                </div>
              </div>

              {/* الوقت وIP */}
              <div style={{ textAlign: 'left', flexShrink: 0 }}>
                <div style={{ fontSize: 13, fontWeight: 600, color: '#2C3E50' }}>{timeAgo(log.created_at)}</div>
                <div style={{ fontSize: 11, color: '#BDC3C7', marginTop: 2, fontFamily: 'monospace' }}>{log.ip_address}</div>
              </div>
            </div>
          );
        })}
        {logs.length === 0 && <div style={{padding: '40px', textAlign: 'center', color: '#7F8C8D'}}>لا يوجد سجلات مطابقة</div>}
      </div>

      {/* أزرار التقسيم الصفحي - FIX Phase 18: Scientific Scalability */}
      {pagination.pages > 1 && (
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', gap: 20, marginTop: 24, padding: '10px 0' }}>
          <button 
            disabled={page === 1}
            onClick={() => setPage(p => p - 1)}
            style={{ padding: '8px 20px', borderRadius: 10, background: page === 1 ? '#F5F6FA' : '#1A3C5E', color: page === 1 ? '#BDC3C7' : 'white', border: 'none', cursor: page === 1 ? 'default' : 'pointer', fontWeight: 700, transition: 'all 0.2s' }}>
            السابق
          </button>
          
          <span style={{ fontWeight: 700, color: '#1A3C5E', fontSize: 14 }}>
            صفحة {page} من {pagination.pages}
          </span>

          <button 
            disabled={page === pagination.pages}
            onClick={() => setPage(p => p + 1)}
            style={{ padding: '8px 20px', borderRadius: 10, background: page === pagination.pages ? '#F5F6FA' : '#1A3C5E', color: page === pagination.pages ? '#BDC3C7' : 'white', border: 'none', cursor: page === pagination.pages ? 'default' : 'pointer', fontWeight: 700, transition: 'all 0.2s' }}>
            التالي
          </button>
        </div>
      )}
    </div>
  );
}

