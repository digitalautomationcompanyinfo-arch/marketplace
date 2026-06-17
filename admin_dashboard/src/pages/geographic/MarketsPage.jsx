import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Plus, Edit2, Trash2, MapPin, CheckCircle, XCircle, Search, Filter } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../services/api';

export default function MarketsPage() {
  const qc = useQueryClient();
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing]     = useState(null);
  const [selectedState, setSelectedState] = useState('');
  const [form, setForm] = useState({ state_id: '', code: '', name: '', name_en: '', latitude: '', longitude: '', delivery_fee: 0, is_active: true });

  const { data: states = [] } = useQuery({
    queryKey: ['states-list'],
    queryFn: () => api.get('/admin/states').then(r => r.data.data || []),
  });

  const { data: markets = [], isLoading } = useQuery({
    queryKey: ['markets-admin', selectedState],
    queryFn: () => api.get('/admin/markets', { params: { state_id: selectedState } }).then(r => r.data.data || []),
  });

  const saveMutation = useMutation({
    mutationFn: (data) => data.id ? api.put(`/admin/markets/${data.id}`, data) : api.post('/admin/markets', data),
    onSuccess: () => {
      toast.success('تم الحفظ بنجاح');
      qc.invalidateQueries(['markets-admin']);
      setShowModal(false);
    },
    onError: (err) => toast.error(err.response?.data?.message || 'خطأ في الحفظ')
  });

  const deleteMutation = useMutation({
    mutationFn: (id) => api.delete(`/admin/markets/${id}`),
    onSuccess: () => {
      toast.success('تم الحذف بنجاح');
      qc.invalidateQueries(['markets-admin']);
    }
  });

  const openAdd = () => {
    setEditing(null);
    setForm({ state_id: selectedState || '', code: '', name: '', name_en: '', latitude: '', longitude: '', delivery_fee: 0, is_active: true });
    setShowModal(true);
  };

  const openEdit = (mkt) => {
    setEditing(mkt);
    setForm({ ...mkt });
    setShowModal(true);
  };

  const handleDelete = (id) => {
    if (window.confirm('هل أنت متأكد من حذف هذا السوق؟')) {
      deleteMutation.mutate(id);
    }
  };

  return (
    <div className="fade-in">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A3C5E', margin: 0 }}>إدارة الأسواق المحلية</h1>
          <p style={{ color: '#7F8C8D', fontSize: 14, marginTop: 4 }}>
            تنظيم الأسواق وتوزيعها الجغرافي داخل الولايات لسهولة البحث والربط
          </p>
        </div>
        <button onClick={openAdd}
          style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '10px 18px', background: '#27AE60', color: 'white', border: 'none', borderRadius: 10, cursor: 'pointer', fontWeight: 600 }}>
          <Plus size={18} /> إضافة سوق جديد
        </button>
      </div>

      {/* الفلترة */}
      <div className="card" style={{ marginBottom: 20, padding: '12px 20px', display: 'flex', alignItems: 'center', gap: 16 }}>
        <Filter size={18} color="#7F8C8D" />
        <span style={{ fontSize: 14, fontWeight: 600 }}>تصفية حسب الولاية:</span>
        <select value={selectedState} onChange={e => setSelectedState(e.target.value)}
          style={{ padding: '8px 12px', borderRadius: 8, border: '1px solid #DDD', background: 'white', fontFamily: 'Cairo', outline: 'none' }}>
          <option value="">كل الولايات</option>
          {states.map(s => <option key={s.id} value={s.id}>{s.name} ({s.code})</option>)}
        </select>
        
        <div style={{ flex: 1 }} />
        <div style={{ color: '#95A5A6', fontSize: 13 }}>توجد {markets.length} نتيجة</div>
      </div>

      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'right' }}>
          <thead style={{ background: '#F8F9FA', borderBottom: '1px solid #E0E0E0' }}>
            <tr>
              <th style={{ padding: '16px 20px', fontSize: 13, color: '#566573' }}>الرمز</th>
              <th style={{ padding: '16px 20px', fontSize: 13, color: '#566573' }}>اسم السوق</th>
              <th style={{ padding: '16px 20px', fontSize: 13, color: '#566573' }}>الولاية</th>
               <th style={{ padding: '16px 20px', fontSize: 13, color: '#566573' }}>الإحداثيات</th>
              <th style={{ padding: '16px 20px', fontSize: 13, color: '#566573' }}>رسوم التوصيل</th>
              <th style={{ padding: '16px 20px', fontSize: 13, color: '#566573' }}>الحالة</th>
              <th style={{ padding: '16px 20px', fontSize: 13, color: '#566573' }}>الإجراءات</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan="7" style={{ padding: 40, textAlign: 'center', color: '#BDC3C7' }}>جاري التحميل...</td></tr>
            ) : markets.length === 0 ? (
              <tr><td colSpan="7" style={{ padding: 40, textAlign: 'center', color: '#BDC3C7' }}>لا توجد أسواق مضافة</td></tr>
            ) : markets.map(mkt => (
              <tr key={mkt.id} style={{ borderBottom: '1px solid #F0F0F0' }}>
                <td style={{ padding: '16px 20px' }}>
                  <code style={{ background: '#E9F7EF', padding: '4px 8px', borderRadius: 6, color: '#27AE60', fontWeight: 700 }}>{mkt.code}</code>
                </td>
                <td style={{ padding: '16px 20px', fontWeight: 600 }}>{mkt.name}</td>
                <td style={{ padding: '16px 20px' }}><span className="badge">{mkt.state_name}</span></td>
                <td style={{ padding: '16px 20px', fontSize: 11, color: '#7F8C8D' }}>
                   {mkt.latitude}, {mkt.longitude}
                </td>
                <td style={{ padding: '16px 20px', fontWeight: 700, color: '#2980B9' }}>
                  {mkt.delivery_fee} ج.س
                </td>
                <td style={{ padding: '16px 20px' }}>
                  {mkt.is_active ? 
                    <span style={{ color: '#27AE60', display: 'flex', alignItems: 'center', gap: 4, fontSize: 13 }}><CheckCircle size={14}/> نشط</span> :
                    <span style={{ color: '#E74C3C', display: 'flex', alignItems: 'center', gap: 4, fontSize: 13 }}><XCircle size={14}/> معطل</span>
                  }
                </td>
                <td style={{ padding: '16px 20px' }}>
                  <div style={{ display: 'flex', gap: 8 }}>
                    <button onClick={() => openEdit(mkt)} style={{ padding: 6, background: '#F4F6F7', border: 'none', borderRadius: 6, cursor: 'pointer', color: '#2980B9' }}><Edit2 size={16}/></button>
                    <button onClick={() => handleDelete(mkt.id)} style={{ padding: 6, background: '#F4F6F7', border: 'none', borderRadius: 6, cursor: 'pointer', color: '#E74C3C' }}><Trash2 size={16}/></button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="card" style={{ width: 480, padding: 30 }}>
            <h3 style={{ margin: '0 0 20px' }}>{editing ? 'تعديل السوق' : 'إضافة سوق جديد'}</h3>
            
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 16 }}>
              <div>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>الولاية *</label>
                <select value={form.state_id} onChange={e => setForm({...form, state_id: e.target.value})}
                  style={{ width: '100%', padding: '10px', borderRadius: 8, border: '1px solid #DDD', fontFamily: 'Cairo' }}>
                  <option value="">اختر الولاية...</option>
                  {states.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}
                </select>
              </div>
              <div>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>الرمز الفريد (Code) *</label>
                <input type="text" value={form.code} onChange={e => setForm({...form, code: e.target.value.toUpperCase()})} placeholder="مثلاً: OMD-LIBY" 
                  style={{ width: '100%', padding: '10px', border: '1px solid #DDD', borderRadius: 8, fontFamily: 'Cairo' }} />
              </div>
            </div>

            <div style={{ marginBottom: 16 }}>
              <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>اسم السوق بالعربية *</label>
              <input type="text" value={form.name} onChange={e => setForm({...form, name: e.target.value})} placeholder="مثلاً: سوق ليبيا" 
                style={{ width: '100%', padding: '10px', border: '1px solid #DDD', borderRadius: 8, fontFamily: 'Cairo' }} />
            </div>

            <div style={{ marginBottom: 16 }}>
              <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>الاسم بالإنجليزية</label>
              <input type="text" value={form.name_en} onChange={e => setForm({...form, name_en: e.target.value})} placeholder="Libya Market" 
                style={{ width: '100%', padding: '10px', border: '1px solid #DDD', borderRadius: 8, fontFamily: 'Cairo' }} />
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 24 }}>
              <div>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>خط العرض (Lat)</label>
                <input type="text" value={form.latitude} onChange={e => setForm({...form, latitude: e.target.value})} placeholder="15.588" 
                  style={{ width: '100%', padding: '10px', border: '1px solid #DDD', borderRadius: 8, fontFamily: 'Cairo' }} />
              </div>
              <div>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>خط الطول (Lng)</label>
                <input type="text" value={form.longitude} onChange={e => setForm({...form, longitude: e.target.value})} placeholder="32.534" 
                  style={{ width: '100%', padding: '10px', border: '1px solid #DDD', borderRadius: 8, fontFamily: 'Cairo' }} />
              </div>
            </div>

            <div style={{ marginBottom: 24 }}>
              <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>رسوم التوصيل الافتراضية (ج.س) *</label>
              <input type="number" value={form.delivery_fee} onChange={e => setForm({...form, delivery_fee: e.target.value})} 
                style={{ width: '100%', padding: '10px', border: '1px solid #DDD', borderRadius: 8, fontFamily: 'Cairo' }} />
            </div>

            <div style={{ marginBottom: 24, display: 'flex', alignItems: 'center', gap: 10 }}>
              <input type="checkbox" checked={form.is_active} onChange={e => setForm({...form, is_active: e.target.checked})} id="active-market" />
              <label htmlFor="active-market" style={{ fontSize: 14 }}>هذا السوق نشط ويظهر للمستخدمين</label>
            </div>

            <div style={{ display: 'flex', gap: 12 }}>
              <button onClick={() => saveMutation.mutate(form)} disabled={saveMutation.isLoading}
                style={{ flex: 1, padding: 12, background: '#27AE60', color: 'white', border: 'none', borderRadius: 8, cursor: 'pointer', fontWeight: 700 }}>
                {saveMutation.isLoading ? 'جاري الحفظ...' : 'حفظ'}
              </button>
              <button onClick={() => setShowModal(false)}
                style={{ flex: 1, padding: 12, background: '#F4F6F7', color: '#566573', border: 'none', borderRadius: 8, cursor: 'pointer', fontWeight: 600 }}>
                إلغاء
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
