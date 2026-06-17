import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Tag, Plus, Trash2, ToggleLeft, ToggleRight } from 'lucide-react';
import api from '../../services/api';
import { Badge } from '../../components/ui/Badge';
import toast from 'react-hot-toast';

export default function PromotionsPage() {
  const qc = useQueryClient();
  const [form, setForm] = useState({
    code: '', discount_type: 'percent', discount_value: '', min_order_amount: '', max_uses: '', expires_at: '',
  });
  const [showForm, setShowForm] = useState(false);

  const { data: promos = [], isLoading } = useQuery({
    queryKey: ['promotions'],
    queryFn: () => api.get('/admin/promotions').then(r => r.data.data),
  });

  const { mutate: create, isLoading: creating } = useMutation({
    mutationFn: (body) => api.post('/admin/promotions', body),
    onSuccess: () => { qc.invalidateQueries(['promotions']); setShowForm(false); toast.success('تم إنشاء الكوبون'); },
    onError: () => toast.error('فشل في إنشاء الكوبون'),
  });

  const { mutate: toggle } = useMutation({
    mutationFn: ({ id, is_active }) => api.patch(`/admin/promotions/${id}`, { is_active }),
    onSuccess: () => qc.invalidateQueries(['promotions']),
  });

  const { mutate: remove } = useMutation({
    mutationFn: (id) => api.delete(`/admin/promotions/${id}`),
    onSuccess: () => { qc.invalidateQueries(['promotions']); toast.success('تم حذف الكوبون'); },
  });

  const handleSubmit = (e) => {
    e.preventDefault();
    create({
      ...form,
      discount_value: parseFloat(form.discount_value),
      min_order_amount: parseFloat(form.min_order_amount) || 0,
      max_uses: parseInt(form.max_uses) || null,
    });
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="page-title"><Tag className="inline-block ml-2" size={24} />الكوبونات والعروض</h1>
        <button className="btn btn-primary flex items-center gap-2" onClick={() => setShowForm(v => !v)}>
          <Plus size={16} /> إنشاء كوبون جديد
        </button>
      </div>

      {showForm && (
        <form onSubmit={handleSubmit} className="card space-y-4">
          <h2 className="section-title">كوبون جديد</h2>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="form-label">كود الكوبون *</label>
              <input className="input" placeholder="مثال: WELCOME50" required
                value={form.code} onChange={e => setForm(f => ({ ...f, code: e.target.value.toUpperCase() }))} />
            </div>
            <div>
              <label className="form-label">نوع الخصم</label>
              <select className="input" value={form.discount_type} onChange={e => setForm(f => ({ ...f, discount_type: e.target.value }))}>
                <option value="percent">نسبة مئوية (%)</option>
                <option value="fixed">قيمة ثابتة (ج.س)</option>
              </select>
            </div>
            <div>
              <label className="form-label">قيمة الخصم *</label>
              <input className="input" type="number" placeholder="مثال: 20" required min="0"
                value={form.discount_value} onChange={e => setForm(f => ({ ...f, discount_value: e.target.value }))} />
            </div>
            <div>
              <label className="form-label">الحد الأدنى للطلب (ج.س)</label>
              <input className="input" type="number" placeholder="50" min="0"
                value={form.min_order_amount} onChange={e => setForm(f => ({ ...f, min_order_amount: e.target.value }))} />
            </div>
            <div>
              <label className="form-label">الحد الأقصى للاستخدام</label>
              <input className="input" type="number" placeholder="غير محدود" min="1"
                value={form.max_uses} onChange={e => setForm(f => ({ ...f, max_uses: e.target.value }))} />
            </div>
            <div>
              <label className="form-label">تاريخ الانتهاء</label>
              <input className="input" type="date"
                value={form.expires_at} onChange={e => setForm(f => ({ ...f, expires_at: e.target.value }))} />
            </div>
          </div>
          <div className="flex gap-3 justify-end">
            <button type="button" className="btn btn-ghost" onClick={() => setShowForm(false)}>إلغاء</button>
            <button type="submit" className="btn btn-primary" disabled={creating}>
              {creating ? 'جاري الحفظ...' : 'حفظ الكوبون'}
            </button>
          </div>
        </form>
      )}

      {isLoading ? <div className="loading-spinner" /> : (
        <div className="card overflow-hidden">
          <table className="data-table w-full">
            <thead>
              <tr><th>الكود</th><th>نوع الخصم</th><th>القيمة</th><th>الاستخدامات</th><th>الانتهاء</th><th>الحالة</th><th>إجراء</th></tr>
            </thead>
            <tbody>
              {promos.map(p => (
                <tr key={p.id}>
                  <td><code className="bg-gray-100 dark:bg-gray-800 px-2 py-1 rounded font-bold tracking-widest">{p.code}</code></td>
                  <td>{p.discount_type === 'percent' ? 'نسبة مئوية' : 'قيمة ثابتة'}</td>
                  <td className="text-green-600 font-bold">
                    {p.discount_type === 'percent' ? `${p.discount_value}%` : `${p.discount_value} ج.س`}
                  </td>
                  <td>{p.usage_count} / {p.max_uses || '∞'}</td>
                  <td className="text-sm text-gray-400">{p.expires_at ? new Date(p.expires_at).toLocaleDateString('ar-SD') : 'غير محدد'}</td>
                  <td><Badge color={p.is_active ? 'green' : 'gray'}>{p.is_active ? 'فعال' : 'موقوف'}</Badge></td>
                  <td>
                    <div className="flex gap-2">
                      <button className="btn btn-ghost p-1" onClick={() => toggle({ id: p.id, is_active: !p.is_active })}>
                        {p.is_active ? <ToggleRight size={20} className="text-green-500" /> : <ToggleLeft size={20} className="text-gray-400" />}
                      </button>
                      <button className="btn btn-ghost p-1 text-red-400 hover:text-red-600" onClick={() => remove(p.id)}>
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {promos.length === 0 && <div className="empty-state"><Tag size={48} /><p>لا توجد كوبونات</p></div>}
        </div>
      )}
    </div>
  );
}

