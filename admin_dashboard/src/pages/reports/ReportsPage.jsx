import React, { useState } from 'react';
import { AlertTriangle, CheckCircle, XCircle, Eye } from 'lucide-react';
import toast from 'react-hot-toast';

import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../services/api';

export default function ReportsPage() {
  const qc = useQueryClient();
  const [filter, setFilter] = useState('pending');
  const [selected, setSelected] = useState(null);
  const [action, setAction] = useState('');
  const [note, setNote] = useState('');

  const { data: reportsData = { data: [] } } = useQuery({
    queryKey: ['reports-admin', filter],
    queryFn: () => api.get(`/admin/reports?status=${filter}`).then(r => r.data),
    placeholderData: { data: [] },
  });

  const resolveMutation = useMutation({
    mutationFn: ({ id, payload }) => api.post(`/admin/reports/${id}/resolve`, payload),
    onSuccess: () => {
      toast.success('تم معالجة البلاغ');
      qc.invalidateQueries(['reports-admin']);
      setSelected(null);
      setAction('');
      setNote('');
    }
  });

  const resolve = (id, _action = 'dismiss') => {
    resolveMutation.mutate({ id, payload: { action: _action, note } });
  };

  const filtered = reportsData.data || [];

  return (
    <div style={{ fontFamily: 'Cairo, Arial, sans-serif' }}>
      <div style={{ marginBottom: 24 }}>
        <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A3C5E', margin: 0 }}>البلاغات والشكاوى</h1>
        <p style={{ color: '#7F8C8D', fontSize: 14, marginTop: 4 }}>إدارة ومعالجة البلاغات</p>
      </div>

      <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
        {['pending','resolved','all'].map(f => (
          <button key={f} onClick={() => setFilter(f)}
            style={{ padding: '8px 16px', border: 'none', borderRadius: 10, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 600,
              background: filter === f ? '#1A3C5E' : '#F5F6FA', color: filter === f ? 'white' : '#566573' }}>
            {f === 'pending' ? 'بانتظار المعالجة' : f === 'resolved' ? 'تمت المعالجة' : 'الكل'}
          </button>
        ))}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: selected ? '1fr 1fr' : '1fr', gap: 20 }}>
        <div>
          {filtered.map(r => (
            <div key={r.id} onClick={() => setSelected(r)}
              style={{ background: 'white', borderRadius: 14, padding: 18, marginBottom: 12, cursor: 'pointer',
                border: selected?.id === r.id ? '2px solid #2980B9' : '2px solid transparent',
                boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <AlertTriangle size={18} color={r.status === 'pending' ? '#E74C3C' : '#95A5A6'} />
                  <span style={{ fontWeight: 700, fontSize: 15 }}>{r.reported}</span>
                </div>
                <span style={{ padding: '3px 12px', borderRadius: 20, fontSize: 12, fontWeight: 600,
                  background: r.status === 'pending' ? '#FADBD8' : '#D5F5E3',
                  color: r.status === 'pending' ? '#E74C3C' : '#27AE60' }}>
                  {r.status === 'pending' ? 'انتظار' : 'معالج'}
                </span>
              </div>
              <div style={{ fontSize: 13, color: '#566573' }}>📌 السبب: {r.reason}</div>
              <div style={{ fontSize: 13, color: '#566573', marginTop: 4 }}>👤 المُبلِّغ: {r.reporter_type === 'user' ? 'مستخدم' : 'مزود'} (ID: {r.reporter_id})</div>
              <div style={{ fontSize: 13, color: '#2980B9', marginTop: 4 }}>🎯 الهدف: {r.reported_type} (ID: {r.reported_id})</div>
              <div style={{ fontSize: 12, color: '#95A5A6', marginTop: 6 }}>{new Date(r.created_at).toLocaleString('ar-SD')}</div>

              {r.status === 'pending' && (
                <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
                  <button onClick={e => { e.stopPropagation(); resolve(r.id, 'dismiss'); }}
                    disabled={resolveMutation.isPending}
                    style={{ flex: 1, padding: '8px', background: '#D5F5E3', color: '#27AE60', border: 'none', borderRadius: 8, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 4 }}>
                    <CheckCircle size={16} /> تجاهل
                  </button>
                  <button onClick={e => { e.stopPropagation(); setSelected(r); }}
                    style={{ flex: 1, padding: '8px', background: '#FADBD8', color: '#E74C3C', border: 'none', borderRadius: 8, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 4 }}>
                    <XCircle size={16} /> إجراء
                  </button>
                </div>
              )}
            </div>
          ))}
          {filtered.length === 0 && (
            <div style={{ textAlign: 'center', padding: 60, color: '#95A5A6' }}>
              <CheckCircle size={48} color="#27AE60" style={{ marginBottom: 12 }} />
              <p>لا توجد بلاغات في هذا القسم</p>
            </div>
          )}
        </div>

        {/* تفاصيل البلاغ */}
        {selected && selected.status === 'pending' && (
          <div style={{ background: 'white', borderRadius: 16, padding: 24, boxShadow: '0 2px 12px rgba(0,0,0,0.08)', alignSelf: 'start' }}>
            <h3 style={{ margin: '0 0 20px', color: '#1A3C5E' }}>معالجة البلاغ</h3>
            <div style={{ marginBottom: 16, fontSize: 14, lineHeight: 1.8 }}>
              <strong>الجهة المُبلَّغ عنها:</strong> {selected.reported}<br />
              <strong>سبب البلاغ:</strong> {selected.reason}<br />
              <strong>المُبلِّغ:</strong> {selected.reporter}
            </div>
            <label style={{ fontSize: 13, fontWeight: 600, display: 'block', marginBottom: 8 }}>الإجراء</label>
            <select value={action} onChange={e => setAction(e.target.value)}
              style={{ width: '100%', padding: '10px', border: '1px solid #E0E0E0', borderRadius: 10, fontFamily: 'Cairo', marginBottom: 12 }}>
              <option value="">اختر الإجراء</option>
              <option value="warn">تحذير</option>
              <option value="suspend">إيقاف مؤقت</option>
              <option value="delete">حذف الحساب</option>
              <option value="dismiss">تجاهل البلاغ</option>
              {selected.reported_type === 'order' && (
                <>
                  <option value="release_payout">تحرير المبلغ للمزود (Release Payout)</option>
                  <option value="refund_user">استرداد المبلغ للمستخدم (Refund User)</option>
                </>
              )}
            </select>
            <textarea value={note} onChange={e => setNote(e.target.value)}
              placeholder="ملاحظات إضافية..." rows={3}
              style={{ width: '100%', padding: 10, border: '1px solid #E0E0E0', borderRadius: 10, fontFamily: 'Cairo', resize: 'none', direction: 'rtl', boxSizing: 'border-box', marginBottom: 16 }} />
            <button onClick={() => resolve(selected.id, action)} disabled={!action || resolveMutation.isPending}
              style={{ width: '100%', padding: 12, background: action ? '#1A3C5E' : '#BDC3C7', color: 'white', border: 'none', borderRadius: 10, cursor: action ? 'pointer' : 'default', fontFamily: 'Cairo', fontWeight: 700 }}>
              تأكيد الإجراء
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

