import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Plus, Edit2, Trash2, Globe, CheckCircle, XCircle } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../services/api';

export default function StatesPage() {
  const qc = useQueryClient();
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing]     = useState(null);
  const [form, setForm] = useState({ code: '', name: '', name_en: '', country: 'SD', is_active: true });

  const { data: states = [], isLoading } = useQuery({
    queryKey: ['states-admin'],
    queryFn: () => api.get('/admin/states').then(r => r.data.data || []),
  });

  const saveMutation = useMutation({
    mutationFn: (data) => data.id ? api.put(`/admin/states/${data.id}`, data) : api.post('/admin/states', data),
    onSuccess: () => {
      toast.success('تم الحفظ بنجاح');
      qc.invalidateQueries(['states-admin']);
      setShowModal(false);
    },
    onError: (err) => toast.error(err.response?.data?.message || 'خطأ في الحفظ')
  });

  const deleteMutation = useMutation({
    mutationFn: (id) => api.delete(`/admin/states/${id}`),
    onSuccess: () => {
      toast.success('تم الحذف بنجاح');
      qc.invalidateQueries(['states-admin']);
    }
  });

  const openAdd = () => {
    setEditing(null);
    setForm({ code: '', name: '', name_en: '', country: 'SD', is_active: true });
    setShowModal(true);
  };

  const openEdit = (state) => {
    setEditing(state);
    setForm({ ...state });
    setShowModal(true);
  };

  const handleDelete = (id) => {
    if (window.confirm('هل أنت متأكد من حذف هذه الولاية؟ سيؤدي ذلك لحذف كافة الأسواق المرتبطة بها.')) {
      deleteMutation.mutate(id);
    }
  };

  return (
    <div className="fade-in">
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A3C5E', margin: 0 }}>إدارة الولايات</h1>
          <p style={{ color: '#7F8C8D', fontSize: 14, marginTop: 4 }}>
            التحكم في الولايات والرموز البرمجية للربط المنظم
          </p>
        </div>
        <button onClick={openAdd}
          style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '10px 18px', background: '#2980B9', color: 'white', border: 'none', borderRadius: 10, cursor: 'pointer', fontWeight: 600 }}>
          <Plus size={18} /> إضافة ولاية جديدة
        </button>
      </div>

      <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'right' }}>
          <thead style={{ background: '#F8F9FA', borderBottom: '1px solid #E0E0E0' }}>
            <tr>
              <th style={{ padding: '16px 20px', fontSize: 13, color: '#566573' }}>الرمز (Code)</th>
              <th style={{ padding: '16px 20px', fontSize: 13, color: '#566573' }}>الاسم بالعربية</th>
              <th style={{ padding: '16px 20px', fontSize: 13, color: '#566573' }}>الاسم بالإنجليزية</th>
              <th style={{ padding: '16px 20px', fontSize: 13, color: '#566573' }}>الحالة</th>
              <th style={{ padding: '16px 20px', fontSize: 13, color: '#566573' }}>الإجراءات</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan="5" style={{ padding: 40, textAlign: 'center', color: '#BDC3C7' }}>جاري التحميل...</td></tr>
            ) : states.map(state => (
              <tr key={state.id} style={{ borderBottom: '1px solid #F0F0F0' }}>
                <td style={{ padding: '16px 20px', fontWeight: 700, color: '#2980B9' }}>
                  <code style={{ background: '#EBF5FB', padding: '4px 8px', borderRadius: 6 }}>{state.code}</code>
                </td>
                <td style={{ padding: '16px 20px', fontWeight: 600 }}>{state.name}</td>
                <td style={{ padding: '16px 20px', color: '#7F8C8D' }}>{state.name_en}</td>
                <td style={{ padding: '16px 20px' }}>
                  {state.is_active ? 
                    <span style={{ color: '#27AE60', display: 'flex', alignItems: 'center', gap: 4, fontSize: 13 }}><CheckCircle size={14}/> نشط</span> :
                    <span style={{ color: '#E74C3C', display: 'flex', alignItems: 'center', gap: 4, fontSize: 13 }}><XCircle size={14}/> معطل</span>
                  }
                </td>
                <td style={{ padding: '16px 20px' }}>
                  <div style={{ display: 'flex', gap: 8 }}>
                    <button onClick={() => openEdit(state)} style={{ padding: 6, background: '#F4F6F7', border: 'none', borderRadius: 6, cursor: 'pointer', color: '#2980B9' }}><Edit2 size={16}/></button>
                    <button onClick={() => handleDelete(state.id)} style={{ padding: 6, background: '#F4F6F7', border: 'none', borderRadius: 6, cursor: 'pointer', color: '#E74C3C' }}><Trash2 size={16}/></button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 }}>
          <div className="card" style={{ width: 450, padding: 30 }}>
            <h3 style={{ margin: '0 0 20px' }}>{editing ? 'تعديل ولاية' : 'إضافة ولاية جديدة'}</h3>
            
            <div style={{ marginBottom: 16 }}>
              <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>الرمز الفريد (Code) *</label>
              <input type="text" value={form.code} onChange={e => setForm({...form, code: e.target.value.toUpperCase()})} placeholder="مثلاً: KH" 
                style={{ width: '100%', padding: '10px 12px', border: '1px solid #DDD', borderRadius: 8, fontFamily: 'Cairo' }} />
            </div>

            <div style={{ marginBottom: 16 }}>
              <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>الاسم بالعربية *</label>
              <input type="text" value={form.name} onChange={e => setForm({...form, name: e.target.value})} placeholder="ولاية الخرطوم" 
                style={{ width: '100%', padding: '10px 12px', border: '1px solid #DDD', borderRadius: 8, fontFamily: 'Cairo' }} />
            </div>

            <div style={{ marginBottom: 16 }}>
              <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>الاسم بالإنجليزية</label>
              <input type="text" value={form.name_en} onChange={e => setForm({...form, name_en: e.target.value})} placeholder="Khartoum" 
                style={{ width: '100%', padding: '10px 12px', border: '1px solid #DDD', borderRadius: 8, fontFamily: 'Cairo' }} />
            </div>

            <div style={{ marginBottom: 24, display: 'flex', alignItems: 'center', gap: 10 }}>
              <input type="checkbox" checked={form.is_active} onChange={e => setForm({...form, is_active: e.target.checked})} id="active-state" />
              <label htmlFor="active-state" style={{ fontSize: 14 }}>هذه الولاية نشطة وتظهر للمستخدمين</label>
            </div>

            <div style={{ display: 'flex', gap: 12 }}>
              <button onClick={() => saveMutation.mutate(form)} disabled={saveMutation.isLoading}
                style={{ flex: 1, padding: 12, background: '#2980B9', color: 'white', border: 'none', borderRadius: 8, cursor: 'pointer', fontWeight: 700 }}>
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
