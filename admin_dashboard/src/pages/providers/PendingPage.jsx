import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { CheckCircle, XCircle, Eye, FileText, Phone, MapPin, Clock } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../services/api';



export default function PendingPage() {
  const qc = useQueryClient();
  const [selected, setSelected] = useState(null);
  const [rejectReason, setRejectReason] = useState('');
  const [showRejectModal, setShowRejectModal] = useState(false);

  const { data = [], isLoading } = useQuery({
    queryKey: ['pending-providers'],
    queryFn: () => api.get('/admin/providers/pending').then(r => r.data.data || []),
    placeholderData: [],
  });

  const reviewMutation = useMutation({
    mutationFn: ({ id, action, reason }) =>
      api.post(`/admin/providers/${id}/review`, { action, reason }),
    onSuccess: (_, vars) => {
      toast.success(vars.action === 'approve' ? '✅ تمت الموافقة وإشعار المزود' : '❌ تم الرفض وإشعار المزود');
      qc.invalidateQueries(['pending-providers']);
      setSelected(null);
      setShowRejectModal(false);
    },
    onError: () => toast.error('حدث خطأ، يرجى المحاولة مجدداً'),
  });

  const docLabels = { national_id: 'الهوية الوطنية', commercial_reg: 'السجل التجاري', license: 'الرخصة', logo: 'الشعار' };

  return (
    <div style={{ fontFamily: 'Cairo, Arial, sans-serif' }}>
      <div style={{ marginBottom: 24 }}>
        <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A3C5E', margin: 0 }}>طلبات التسجيل</h1>
        <p style={{ color: '#7F8C8D', marginTop: 4, fontSize: 14 }}>{data.length} طلب بانتظار المراجعة</p>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: selected ? '1fr 1fr' : '1fr', gap: 20 }}>

        {/* ─── قائمة الطلبات ──────────────────────────── */}
        <div>
          {data.map(provider => (
            <div key={provider.id}
              onClick={() => setSelected(provider)}
              style={{
                background: 'white', borderRadius: 16, padding: 20, marginBottom: 12,
                cursor: 'pointer', transition: 'all 0.2s',
                border: selected?.id === provider.id ? '2px solid #2980B9' : '2px solid transparent',
                boxShadow: '0 2px 8px rgba(0,0,0,0.06)',
              }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                <div>
                  <h3 style={{ margin: '0 0 6px', fontSize: 16, color: '#1A3C5E' }}>{provider.business_name}</h3>
                  <div style={{ color: '#566573', fontSize: 13, display: 'flex', flexDirection: 'column', gap: 4 }}>
                    <span>👤 {provider.owner_name}</span>
                    <span>📞 {provider.phone}</span>
                    <span>🏷️ {provider.category_name} · 📍 {provider.region_name}</span>
                  </div>
                </div>
                <div style={{ textAlign: 'center' }}>
                  <div style={{ background: '#FEF9E7', color: '#D4A017', padding: '4px 12px', borderRadius: 20, fontSize: 12, fontWeight: 600, marginBottom: 8 }}>
                    انتظار
                  </div>
                  <div style={{ color: '#95A5A6', fontSize: 11, display: 'flex', alignItems: 'center', gap: 4 }}>
                    <Clock size={12} />
                    {new Date(provider.created_at).toLocaleDateString('ar-SD')}
                  </div>
                </div>
              </div>

              {/* الوثائق */}
              <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
                {provider.documents?.map((doc, i) => (
                  <a key={i} href={doc.file_url} target="_blank" rel="noreferrer"
                    style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '4px 10px', background: '#EBF5FB', borderRadius: 8, fontSize: 12, color: '#2980B9', textDecoration: 'none' }}
                    onClick={e => e.stopPropagation()}>
                    <FileText size={14} />
                    {docLabels[doc.doc_type] || doc.doc_type}
                  </a>
                ))}
              </div>

              {/* أزرار الإجراء */}
              <div style={{ display: 'flex', gap: 10, marginTop: 14 }}>
                <button
                  onClick={e => { e.stopPropagation(); reviewMutation.mutate({ id: provider.id, action: 'approve' }); }}
                  style={{ flex: 1, padding: '10px', background: '#27AE60', color: 'white', border: 'none', borderRadius: 10, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}>
                  <CheckCircle size={18} /> موافقة
                </button>
                <button
                  onClick={e => { e.stopPropagation(); setSelected(provider); setShowRejectModal(true); }}
                  style={{ flex: 1, padding: '10px', background: '#E74C3C', color: 'white', border: 'none', borderRadius: 10, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}>
                  <XCircle size={18} /> رفض
                </button>
              </div>
            </div>
          ))}

          {data.length === 0 && (
            <div style={{ textAlign: 'center', padding: 60, color: '#95A5A6' }}>
              <CheckCircle size={48} style={{ marginBottom: 12, color: '#27AE60' }} />
              <p style={{ fontSize: 16, fontWeight: 600 }}>لا توجد طلبات انتظار</p>
              <p style={{ fontSize: 14 }}>تم مراجعة جميع الطلبات</p>
            </div>
          )}
        </div>

        {/* ─── تفاصيل المزود المختار ──────────────────── */}
        {selected && !showRejectModal && (
          <div style={{ background: 'white', borderRadius: 16, padding: 24, boxShadow: '0 2px 12px rgba(0,0,0,0.08)', alignSelf: 'start' }}>
            <h3 style={{ margin: '0 0 20px', color: '#1A3C5E' }}>تفاصيل الطلب</h3>
            {[
              ['اسم النشاط', selected.business_name],
              ['اسم المالك', selected.owner_name],
              ['رقم الهاتف', selected.phone],
              ['رقم الهوية الوطنية', selected.national_id || 'غير متوفر'],
              ['الفئة', selected.category_name],
              ['المنطقة', selected.region_name],
            ].map(([k, v]) => (
              <div key={k} style={{ display: 'flex', justifyContent: 'space-between', padding: '10px 0', borderBottom: '1px solid #F5F6FA' }}>
                <span style={{ color: '#7F8C8D', fontSize: 13 }}>{k}</span>
                <span style={{ fontWeight: 600, fontSize: 13 }}>{v}</span>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* ─── Modal الرفض ────────────────────────────────── */}
      {showRejectModal && selected && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
          <div style={{ background: 'white', borderRadius: 20, padding: 32, width: 480, boxShadow: '0 20px 60px rgba(0,0,0,0.3)' }}>
            <h3 style={{ margin: '0 0 8px', color: '#1A3C5E', fontSize: 20 }}>سبب الرفض</h3>
            <p style={{ color: '#7F8C8D', fontSize: 14, marginBottom: 20 }}>سيتم إرسال هذا السبب للمزود عبر الإشعارات</p>
            <textarea
              value={rejectReason}
              onChange={e => setRejectReason(e.target.value)}
              placeholder="مثال: البيانات المدخلة غير مكتملة، يرجى إرفاق السجل التجاري..."
              rows={4}
              style={{ width: '100%', padding: 12, borderRadius: 10, border: '1px solid #DDD', fontFamily: 'Cairo', fontSize: 14, resize: 'none', boxSizing: 'border-box', direction: 'rtl' }}
            />
            <div style={{ display: 'flex', gap: 12, marginTop: 20 }}>
              <button
                onClick={() => reviewMutation.mutate({ id: selected.id, action: 'reject', reason: rejectReason })}
                disabled={!rejectReason.trim()}
                style={{ flex: 1, padding: 12, background: '#E74C3C', color: 'white', border: 'none', borderRadius: 10, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 700, fontSize: 15, opacity: !rejectReason.trim() ? 0.5 : 1 }}>
                تأكيد الرفض
              </button>
              <button onClick={() => setShowRejectModal(false)}
                style={{ flex: 1, padding: 12, background: '#F5F6FA', color: '#566573', border: 'none', borderRadius: 10, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 600, fontSize: 15 }}>
                إلغاء
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

