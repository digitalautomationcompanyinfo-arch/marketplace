import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Search, UserX, UserCheck, Trash2, Download, Filter, TrendingUp } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../services/api';



export default function UsersPage() {
  const qc = useQueryClient();
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('all');
  const [page, setPage] = useState(1);

  const { data = { data: [] }, isLoading } = useQuery({
    queryKey: ['users', search, filter, page],
    queryFn: () => api.get(`/admin/users?search=${search}&is_active=${filter === 'active' ? true : filter === 'inactive' ? false : ''}&page=${page}&limit=15`).then(r => r.data),
    placeholderData: { data: [] },
  });

  const updateMutation = useMutation({
    mutationFn: ({ id, is_active }) => api.put(`/admin/users/${id}`, { is_active }),
    onSuccess: () => { toast.success('تم التحديث'); qc.invalidateQueries(['users']); },
  });

  const deleteMutation = useMutation({
    mutationFn: (id) => api.delete(`/admin/users/${id}`),
    onSuccess: () => { toast.success('تم الحذف'); qc.invalidateQueries(['users']); },
  });

  const adjustWalletMutation = useMutation({
    mutationFn: (data) => api.post('/admin/wallet/adjust', data),
    onSuccess: () => { 
      toast.success('تم تعديل الرصيد بنجاح'); 
      qc.invalidateQueries(['users']); 
    },
    onError: (err) => toast.error(err.response?.data?.message || 'فشل تعديل الرصيد')
  });

  const handleAdjustWallet = (user) => {
    const amount = window.prompt(`تعديل رصيد ${user.full_name}\nالرصيد الحالي: ${user.wallet_balance} ج.س\n\nأدخل المبلغ (استخدم - للنقص):`);
    if (amount === null || amount === '') return;
    
    const reason = window.prompt('سبب التعديل:');
    if (!reason) return;

    adjustWalletMutation.mutate({ 
      user_id: user.id, 
      amount: parseFloat(amount), 
      reason 
    });
  };

  const filtered = (data.data || []).filter(u =>
    (!search || u.full_name?.toLowerCase().includes(search.toLowerCase()) || u.phone?.includes(search)) &&
    (filter === 'all' || (filter === 'active' ? u.is_active : !u.is_active))
  );

  return (
    <div style={{ fontFamily: 'Cairo, Arial, sans-serif' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
        <div>
          <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A3C5E', margin: 0 }}>المستخدمون</h1>
          <p style={{ color: '#7F8C8D', fontSize: 14, margin: '4px 0 0' }}>{filtered.length} مستخدم</p>
        </div>
        <button style={btnStyle('#27AE60')} onClick={() => {}}>
          <Download size={16} /> تصدير Excel
        </button>
      </div>

      {/* فلاتر */}
      <div style={{ display: 'flex', gap: 12, marginBottom: 20 }}>
        <div style={{ flex: 1, position: 'relative' }}>
          <Search size={16} style={{ position: 'absolute', right: 12, top: 11, color: '#95A5A6' }} />
          <input value={search} onChange={e => setSearch(e.target.value)}
            placeholder="بحث بالاسم أو الهاتف..."
            style={{ width: '100%', padding: '10px 36px 10px 12px', border: '1px solid #E0E0E0', borderRadius: 10, fontFamily: 'Cairo', fontSize: 14, direction: 'rtl', boxSizing: 'border-box' }} />
        </div>
        {['all','active','inactive'].map(f => (
          <button key={f} onClick={() => setFilter(f)}
            style={{ padding: '10px 16px', border: 'none', borderRadius: 10, cursor: 'pointer', fontFamily: 'Cairo', fontWeight: 600, fontSize: 13,
              background: filter === f ? '#1A3C5E' : '#F5F6FA', color: filter === f ? 'white' : '#566573' }}>
            {f === 'all' ? 'الكل' : f === 'active' ? 'نشط' : 'معطل'}
          </button>
        ))}
      </div>

      {/* الجدول */}
      <div style={{ background: 'white', borderRadius: 16, overflow: 'hidden', boxShadow: '0 2px 12px rgba(0,0,0,0.06)' }}>
        <table style={{ width: '100%', borderCollapse: 'collapse', fontFamily: 'Cairo' }}>
          <thead>
            <tr style={{ background: '#F8F9FA' }}>
              {['الاسم', 'الهاتف', 'المحفظة', 'التحقق', 'الحالة', 'تاريخ التسجيل', 'إجراءات'].map(h => (
                <th key={h} style={{ padding: '12px 16px', textAlign: 'right', fontSize: 13, color: '#566573', fontWeight: 600, borderBottom: '1px solid #F0F0F0' }}>{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filtered.map((user, i) => (
              <tr key={user.id} style={{ borderBottom: '1px solid #F5F6FA', background: i % 2 === 0 ? 'white' : '#FAFAFA' }}>
                <td style={tdStyle}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                    <div style={{ width: 36, height: 36, borderRadius: '50%', background: `hsl(${user.id * 40}, 60%, 75%)`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 700, color: 'white' }}>
                      {user.full_name[0]}
                    </div>
                    <div>
                      <div style={{ fontWeight: 600, fontSize: 14 }}>{user.full_name}</div>
                      <div style={{ fontSize: 12, color: '#95A5A6' }}>{user.email}</div>
                    </div>
                  </div>
                </td>
                <td style={tdStyle}>{user.phone}</td>
                <td style={tdStyle}>
                   <div style={{ fontWeight: 700, color: '#2C3E50' }}>{parseFloat(user.wallet_balance || 0).toFixed(2)} ج.س</div>
                </td>
                <td style={tdStyle}>
                  <span style={{ padding: '3px 10px', borderRadius: 20, fontSize: 12, fontWeight: 600,
                    background: user.is_verified ? '#D5F5E3' : '#FADBD8', color: user.is_verified ? '#27AE60' : '#E74C3C' }}>
                    {user.is_verified ? '✓ مُتحقق' : '✗ غير مُتحقق'}
                  </span>
                </td>
                <td style={tdStyle}>
                  <span style={{ padding: '3px 10px', borderRadius: 20, fontSize: 12, fontWeight: 600,
                    background: user.is_active ? '#D5F5E3' : '#F5F6FA', color: user.is_active ? '#27AE60' : '#95A5A6' }}>
                    {user.is_active ? 'نشط' : 'معطل'}
                  </span>
                </td>
                <td style={{ ...tdStyle, fontSize: 13, color: '#7F8C8D' }}>
                  {new Date(user.created_at).toLocaleDateString('ar-SD')}
                </td>
                 <td style={tdStyle}>
                  <div style={{ display: 'flex', gap: 6 }}>
                    <button title="تعديل المحفظة"
                      onClick={() => handleAdjustWallet(user)}
                      style={{ padding: '6px 10px', border: 'none', borderRadius: 8, cursor: 'pointer', background: '#EBF5FB', color: '#2980B9' }}>
                      <TrendingUp size={16} />
                    </button>
                    <button title={user.is_active ? 'تعطيل' : 'تفعيل'}
                      onClick={() => updateMutation.mutate({ id: user.id, is_active: !user.is_active })}
                      style={{ padding: '6px 10px', border: 'none', borderRadius: 8, cursor: 'pointer',
                        background: user.is_active ? '#FADBD8' : '#D5F5E3', color: user.is_active ? '#E74C3C' : '#27AE60' }}>
                      {user.is_active ? <UserX size={16} /> : <UserCheck size={16} />}
                    </button>
                    <button title="حذف"
                      onClick={() => window.confirm('هل تريد حذف هذا المستخدم؟') && deleteMutation.mutate(user.id)}
                      style={{ padding: '6px 10px', border: 'none', borderRadius: 8, cursor: 'pointer', background: '#FADBD8', color: '#E74C3C' }}>
                      <Trash2 size={16} />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {/* Pagination */}
        <div style={{ padding: '16px', display: 'flex', justifyContent: 'center', gap: 8 }}>
          {[1,2,3].map(p => (
            <button key={p} onClick={() => setPage(p)}
              style={{ width: 36, height: 36, border: 'none', borderRadius: 8, cursor: 'pointer', fontFamily: 'Cairo',
                background: page === p ? '#1A3C5E' : '#F5F6FA', color: page === p ? 'white' : '#566573' }}>
              {p}
            </button>
          ))}
        </div>
      </div>
    </div>
  );
}

const btnStyle = (bg) => ({
  display: 'flex', alignItems: 'center', gap: 6, padding: '10px 16px',
  background: bg, color: 'white', border: 'none', borderRadius: 10, cursor: 'pointer',
  fontFamily: 'Cairo', fontWeight: 600, fontSize: 13,
});
const tdStyle = { padding: '12px 16px', textAlign: 'right', fontSize: 14 };

