import React, { useState } from 'react';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { Plus, Edit2, Eye, EyeOff, GripVertical } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../services/api';



const COLORS = ['#E74C3C','#27AE60','#2980B9','#8E44AD','#F39C12','#16A085','#E91E63','#3498DB','#7F8C8D','#C0392B','#D35400','#1ABC9C','#F1C40F','#E67E22'];

export default function CategoriesPage() {
  const qc = useQueryClient();
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing]     = useState(null);
  const [form, setForm] = useState({ name: '', name_en: '', icon: '🏪', color: '#2980B9', sort_order: '' });

  const { data: categories = [] } = useQuery({
    queryKey: ['categories-admin'],
    queryFn: () => api.get('/admin/categories').then(r => r.data.data || []),
    placeholderData: [],
  });

  const saveMutation = useMutation({
    mutationFn: (cat) => cat.id ? api.put(`/admin/categories/${cat.id}`, cat) : api.post('/admin/categories', cat),
    onSuccess: () => { toast.success('تم الحفظ بنجاح'); qc.invalidateQueries(['categories-admin']); setShowModal(false); }
  });

  const openAdd  = () => { setEditing(null); setForm({ name: '', name_en: '', icon: '🏪', color: '#2980B9', sort_order: '' }); setShowModal(true); };
  const openEdit = (cat) => { setEditing(cat); setForm({ id: cat.id, name: cat.name, name_en: cat.name_en, icon: cat.icon, color: cat.color, sort_order: cat.sort_order, is_active: cat.is_active }); setShowModal(true); };

  const save = () => {
    if (!form.name.trim()) return toast.error('الاسم مطلوب');
    saveMutation.mutate(form);
  };

  const toggleActive = (cat) => {
    saveMutation.mutate({ id: cat.id, is_active: !cat.is_active });
  };

  const total = categories.reduce((s, c) => s + c.providers_count, 0);

  return (
    <div style={{ fontFamily: 'Cairo, Arial, sans-serif' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A3C5E', margin: 0 }}>إدارة الفئات</h1>
          <p style={{ color: '#7F8C8D', fontSize: 14, marginTop: 4 }}>
            {categories.length} فئة · {total} مزود إجمالاً
            <span style={{ marginRight: 8, color: '#27AE60', fontWeight: 600 }}>✓ التغييرات تظهر فوراً في التطبيق</span>
          </p>
        </div>
        <button onClick={openAdd}
          style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '10px 18px', background: '#1A3C5E', color: 'white', border: 'none', borderRadius: 10, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 600, fontSize: 14 }}>
          <Plus size={18} /> إضافة فئة جديدة
        </button>
      </div>

      {/* شبكة الفئات */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 16 }}>
        {categories.map(cat => (
          <div key={cat.id} style={{
            background: 'white', borderRadius: 16, padding: 20,
            boxShadow: '0 2px 12px rgba(0,0,0,0.06)',
            opacity: cat.is_active ? 1 : 0.55,
            border: `2px solid ${cat.is_active ? cat.color + '30' : '#F0F0F0'}`,
            transition: 'all 0.2s',
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                {/* أيقونة الفئة */}
                <div style={{ width: 52, height: 52, borderRadius: 14, background: cat.color + '20', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 26 }}>
                  {cat.icon}
                </div>
                <div>
                  <div style={{ fontWeight: 700, fontSize: 15, color: '#1A3C5E' }}>{cat.name}</div>
                  <div style={{ fontSize: 12, color: '#95A5A6', marginTop: 2 }}>{cat.name_en}</div>
                </div>
              </div>

              {/* ترقيم الترتيب */}
              <div style={{ width: 28, height: 28, borderRadius: '50%', background: cat.color, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white', fontSize: 13, fontWeight: 700 }}>
                {cat.sort_order}
              </div>
            </div>

            {/* عدد المزودين */}
            <div style={{ marginTop: 16, padding: '8px 12px', background: '#F8F9FA', borderRadius: 10, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: 13, color: '#566573' }}>المزودون</span>
              <span style={{ fontSize: 18, fontWeight: 700, color: cat.color }}>{cat.providers_count}</span>
            </div>

            {/* شريط الألوان */}
            <div style={{ marginTop: 12, height: 4, borderRadius: 2, background: '#F0F0F0', overflow: 'hidden' }}>
              <div style={{ height: '100%', width: `${Math.min(100, (cat.providers_count / total) * 100 * 3)}%`, background: cat.color, borderRadius: 2 }} />
            </div>

            {/* أزرار الإجراء */}
            <div style={{ display: 'flex', gap: 8, marginTop: 14 }}>
              <button onClick={() => openEdit(cat)}
                style={{ flex: 1, padding: '8px', border: `1px solid ${cat.color}40`, borderRadius: 8, cursor: 'pointer', background: 'white', color: cat.color, fontFamily: 'Cairo', fontSize: 12, fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 4 }}>
                <Edit2 size={14} /> تعديل
              </button>
              <button onClick={() => toggleActive(cat)}
                style={{ flex: 1, padding: '8px', border: 'none', borderRadius: 8, cursor: 'pointer', fontFamily: 'Cairo', fontSize: 12, fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 4,
                  background: cat.is_active ? '#FADBD8' : '#D5F5E3', color: cat.is_active ? '#E74C3C' : '#27AE60' }}>
                {cat.is_active ? <><EyeOff size={14} /> إخفاء</> : <><Eye size={14} /> إظهار</>}
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Modal الإضافة/التعديل */}
      {showModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 100 }}>
          <div style={{ background: 'white', borderRadius: 20, padding: 32, width: 480, boxShadow: '0 20px 60px rgba(0,0,0,0.3)' }}>
            <h3 style={{ margin: '0 0 24px', color: '#1A3C5E', fontSize: 20 }}>
              {editing ? 'تعديل الفئة' : 'إضافة فئة جديدة'}
            </h3>

            {/* معاينة */}
            <div style={{ textAlign: 'center', marginBottom: 20, padding: 16, background: '#F8F9FA', borderRadius: 12 }}>
              <div style={{ width: 64, height: 64, borderRadius: 18, background: form.color + '20', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 32, margin: '0 auto 8px' }}>
                {form.icon}
              </div>
              <div style={{ fontWeight: 700, color: '#1A3C5E' }}>{form.name || 'اسم الفئة'}</div>
            </div>

            {[
              { label: 'الاسم بالعربية *', key: 'name', placeholder: 'مثال: مطاعم وكافيهات' },
              { label: 'الاسم بالإنجليزية', key: 'name_en', placeholder: 'Restaurants' },
              { label: 'الأيقونة (Emoji)', key: 'icon', placeholder: '🍽️' },
              { label: 'الترتيب', key: 'sort_order', placeholder: '1', type: 'number' },
            ].map(f => (
              <div key={f.key} style={{ marginBottom: 14 }}>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6 }}>{f.label}</label>
                <input type={f.type || 'text'} value={form[f.key]} onChange={e => setForm(p => ({ ...p, [f.key]: e.target.value }))}
                  placeholder={f.placeholder}
                  style={{ width: '100%', padding: '10px 12px', border: '1px solid #E0E0E0', borderRadius: 10, fontFamily: 'Cairo', fontSize: 14, direction: 'rtl', boxSizing: 'border-box' }} />
              </div>
            ))}

            {/* اختيار اللون */}
            <div style={{ marginBottom: 20 }}>
              <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 8 }}>اللون</label>
              <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                {COLORS.map(c => (
                  <button key={c} onClick={() => setForm(p => ({ ...p, color: c }))}
                    style={{ width: 32, height: 32, borderRadius: '50%', background: c, border: form.color === c ? '3px solid #1A3C5E' : '3px solid transparent', cursor: 'pointer' }} />
                ))}
              </div>
            </div>

            <div style={{ display: 'flex', gap: 12 }}>
              <button onClick={save}
                style={{ flex: 1, padding: 13, background: '#1A3C5E', color: 'white', border: 'none', borderRadius: 10, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 700, fontSize: 15 }}>
                {editing ? 'حفظ التعديلات' : 'إضافة الفئة'}
              </button>
              <button onClick={() => setShowModal(false)}
                style={{ flex: 1, padding: 13, background: '#F5F6FA', color: '#566573', border: 'none', borderRadius: 10, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 600, fontSize: 15 }}>
                إلغاء
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

