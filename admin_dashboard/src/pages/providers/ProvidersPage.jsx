import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Search, Star, ToggleLeft, ToggleRight, Award, Eye, QrCode as QrIcon } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../services/api';



export default function ProvidersPage() {
  const qc = useQueryClient();
  const [search, setSearch]   = useState('');
  const [catFilter, setCat]   = useState('');
  const [statusFilter, setSt] = useState('all');
  const [activeQr, setQr]         = useState(null);
  const [selectedProv, setSel]    = useState(null);

  const { data = { data: [] } } = useQuery({
    queryKey: ['providers-admin', search, catFilter, statusFilter],
    queryFn: () => api.get(`/admin/providers?search=${search}&status=${statusFilter}`).then(r => r.data),
    placeholderData: { data: [] },
  });

  const toggleMutation = useMutation({
    mutationFn: ({ id, is_active }) => api.put(`/admin/providers/${id}`, { is_active }),
    onSuccess: () => { toast.success('تم التحديث'); qc.invalidateQueries(['providers-admin']); },
  });

  const featuredMutation = useMutation({
    mutationFn: (id) => api.post(`/admin/providers/${id}/featured`),
    onSuccess: () => { toast.success('تم تحديث التمييز'); qc.invalidateQueries(['providers-admin']); },
  });

  const deleteMutation = useMutation({
    mutationFn: (id) => api.delete(`/admin/providers/${id}`),
    onSuccess: () => { toast.success('تم حذف المزود'); qc.invalidateQueries(['providers-admin']); },
  });

  const providers = (data.data || []).filter(p =>
    (!search || p.business_name?.includes(search) || p.phone?.includes(search)) &&
    (statusFilter === 'all' || (statusFilter === 'active' ? p.is_active : !p.is_active))
  );

  const statusColor = (p) => {
    if (p.verification_status === 'pending') return { bg: '#FEF9E7', color: '#D4A017', label: 'انتظار' };
    if (!p.is_active) return { bg: '#F5F6FA', color: '#95A5A6', label: 'معطل' };
    const daysLeft = Math.floor((new Date(p.subscription_expires) - new Date()) / 86400000);
    if (daysLeft < 0) return { bg: '#FADBD8', color: '#E74C3C', label: 'منتهي' };
    if (daysLeft < 7) return { bg: '#FEF9E7', color: '#D4A017', label: `${daysLeft}ي` };
    return { bg: '#D5F5E3', color: '#27AE60', label: 'نشط' };
  };

  return (
    <div style={{ fontFamily: 'Cairo, Arial, sans-serif' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A3C5E', margin: 0 }}>مزودو الخدمة</h1>
          <p style={{ color: '#7F8C8D', fontSize: 14, marginTop: 4 }}>{providers.length} مزود</p>
        </div>
        <a href="/providers/pending" style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '10px 16px', background: '#FEF9E7', color: '#D4A017', borderRadius: 10, textDecoration: 'none', fontWeight: 600, fontSize: 13 }}>
          ⏳ طلبات الانتظار
        </a>
      </div>

      {/* فلاتر */}
      <div style={{ display: 'flex', gap: 12, marginBottom: 20 }}>
        <div style={{ flex: 1, position: 'relative' }}>
          <Search size={16} style={{ position: 'absolute', right: 12, top: 11, color: '#95A5A6' }} />
          <input value={search} onChange={e => setSearch(e.target.value)} placeholder="بحث بالاسم أو الهاتف..."
            style={{ width: '100%', padding: '10px 36px 10px 12px', border: '1px solid #E0E0E0', borderRadius: 10, fontFamily: 'Cairo', fontSize: 14, direction: 'rtl', boxSizing: 'border-box' }} />
        </div>
        {['all','active','inactive'].map(s => (
          <button key={s} onClick={() => setSt(s)}
            style={{ padding: '10px 16px', border: 'none', borderRadius: 10, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 600, fontSize: 13,
              background: statusFilter === s ? '#1A3C5E' : '#F5F6FA', color: statusFilter === s ? 'white' : '#566573' }}>
            {s === 'all' ? 'الكل' : s === 'active' ? 'نشط' : 'معطل'}
          </button>
        ))}
      </div>

      {/* الجدول */}
      <div style={{ background: 'white', borderRadius: 16, overflow: 'hidden', boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontFamily: 'Cairo' }}>
          <thead>
            <tr style={{ background: '#F8F9FA' }}>
              {['النشاط التجاري','الفئة','المنطقة','التقييم','المشاهدات','الاشتراك','مميز','إجراءات'].map(h => (
                <th key={h} style={{ padding: '12px 14px', textAlign: 'right', fontSize: 12, color: '#566573', fontWeight: 600, borderBottom: '1px solid #F0F0F0', whiteSpace: 'nowrap' }}>{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {providers.map((p, i) => {
              const st = statusColor(p);
              return (
                <tr key={p.id} style={{ borderBottom: '1px solid #F5F6FA', background: i % 2 === 0 ? 'white' : '#FAFAFA' }}>
                  {/* الاسم */}
                  <td style={{ padding: '12px 14px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <div style={{ width: 38, height: 38, borderRadius: 10, background: '#D6EAF8', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18 }}>🏪</div>
                      <div>
                        <div style={{ fontWeight: 700, fontSize: 14, display: 'flex', alignItems: 'center', gap: 6 }}>
                          {p.business_name}
                          {p.is_featured && <span style={{ fontSize: 11, background: '#FEF9E7', color: '#D4A017', padding: '1px 6px', borderRadius: 4 }}>مميز</span>}
                          <QrIcon size={14} style={{ cursor: 'pointer', color: '#3498DB' }} onClick={() => setQr(p)} />
                        </div>
                        <div style={{ fontSize: 12, color: '#95A5A6' }}>{p.phone}</div>
                      </div>
                    </div>
                  </td>
                  <td style={{ padding: '12px 14px', fontSize: 13 }}>{p.category_name}</td>
                  <td style={{ padding: '12px 14px', fontSize: 13 }}>{p.region_name}</td>
                  {/* التقييم */}
                  <td style={{ padding: '12px 14px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 4 }}>
                      <Star size={13} color="#F1C40F" fill="#F1C40F" />
                      <span style={{ fontWeight: 700, fontSize: 14 }}>{p.rating_avg}</span>
                      <span style={{ fontSize: 12, color: '#95A5A6' }}>({p.rating_count})</span>
                    </div>
                  </td>
                  <td style={{ padding: '12px 14px', fontSize: 14, fontWeight: 600 }}>{p.views_count?.toLocaleString() || 0}</td>
                  {/* حالة الاشتراك */}
                  <td style={{ padding: '12px 14px' }}>
                    <span style={{ padding: '4px 10px', borderRadius: 20, fontSize: 12, fontWeight: 700, background: st.bg, color: st.color }}>{st.label}</span>
                  </td>
                  {/* مميز */}
                  <td style={{ padding: '12px 14px' }}>
                    <button onClick={() => featuredMutation.mutate(p.id)}
                      style={{ background: 'none', border: 'none', cursor: 'pointer', color: p.is_featured ? '#D4A017' : '#BDC3C7' }}>
                      <Award size={22} fill={p.is_featured ? '#D4A017' : 'none'} />
                    </button>
                  </td>
                  {/* إجراءات */}
                  <td style={{ padding: '12px 14px' }}>
                    <div style={{ display: 'flex', gap: 6 }}>
                      <button title={p.is_active ? 'تعطيل' : 'تفعيل'}
                        onClick={() => toggleMutation.mutate({ id: p.id, is_active: !p.is_active })}
                        style={{ padding: '6px 10px', border: 'none', borderRadius: 8, cursor: 'pointer',
                          background: p.is_active ? '#FADBD8' : '#D5F5E3', color: p.is_active ? '#E74C3C' : '#27AE60' }}>
                        {p.is_active ? <ToggleRight size={18} /> : <ToggleLeft size={18} />}
                      </button>
                       <button title="عرض التفاصيل"
                        onClick={() => setSel(p)}
                        style={{ padding: '6px 10px', border: 'none', borderRadius: 8, cursor: 'pointer', background: '#EBF5FB', color: '#2980B9' }}>
                        <Eye size={16} />
                      </button>
                      <button title="حذف"
                        onClick={() => window.confirm('هل أنت متأكد من حذف هذا المزود؟') && deleteMutation.mutate(p.id)}
                        style={{ padding: '6px 10px', border: 'none', borderRadius: 8, cursor: 'pointer', background: '#FDEDEC', color: '#CB4335' }}>
                        🗑️
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

       {activeQr && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }} onClick={() => setQr(null)}>
          <div style={{ background: 'white', padding: 32, borderRadius: 20, textAlign: 'center', maxWidth: 350 }} onClick={e => e.stopPropagation()}>
            <h3 style={{ margin: '0 0 16px' }}>{activeQr.business_name}</h3>
            <img src={activeQr.qr_code_url} alt="QR" style={{ width: 250, height: 250, borderRadius: 10 }} />
            <p style={{ color: '#7F8C8D', fontSize: 13, marginTop: 16 }}>امسح الكود لزيارة الملف الشخصي</p>
            <button onClick={() => setQr(null)} style={{ marginTop: 16, padding: '8px 24px', background: '#1A3C5E', color: 'white', border: 'none', borderRadius: 8, cursor: 'pointer' }}>إغلاق</button>
          </div>
        </div>
      )}

      {selectedProv && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }} onClick={() => setSel(null)}>
          <div style={{ background: 'white', padding: 32, borderRadius: 20, width: '100%', maxWidth: 450 }} onClick={e => e.stopPropagation()}>
            <h3 style={{ margin: '0 0 24px', color: '#1A3C5E', textAlign: 'center' }}>تفاصيل المزود</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              {[
                ['اسم النشاط', selectedProv.business_name],
                ['اسم المالك', selectedProv.owner_name],
                ['رقم الهاتف', selectedProv.phone],
                ['رقم الهوية الوطنية', selectedProv.national_id || 'غير متوفر'],
                ['الفئة', selectedProv.category_name],
                ['المنطقة', selectedProv.region_name || 'عام'],
                ['حالة التحقق', selectedProv.verification_status === 'approved' ? '✅ معتمد' : '⏳ معلق'],
                ['تاريخ الانضمام', new Date(selectedProv.created_at).toLocaleDateString('ar-SD')],
              ].map(([k, v]) => (
                <div key={k} style={{ display: 'flex', justifyContent: 'space-between', padding: '10px 0', borderBottom: '1px solid #F5F6FA' }}>
                  <span style={{ color: '#7F8C8D', fontSize: 13 }}>{k}:</span>
                  <span style={{ fontWeight: 600, fontSize: 13, textAlign: 'left' }}>{v}</span>
                </div>
              ))}
            </div>
            <button onClick={() => setSel(null)} style={{ marginTop: 24, width: '100%', padding: '12px', background: '#1A3C5E', color: 'white', border: 'none', borderRadius: 10, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 600 }}>إغلاق</button>
          </div>
        </div>
      )}
    </div>
  );
}

