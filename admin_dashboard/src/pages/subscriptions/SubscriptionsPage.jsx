// SubscriptionsPage.jsx
import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

import api from '../../services/api';

export default function SubscriptionsPage() {
  const { data: subsData, isLoading } = useQuery({
    queryKey: ['subs-overview'],
    queryFn: () => api.get('/admin/subscriptions/overview').then(r => r.data.data),
  });

  const planData = subsData?.revenue_by_plan?.map(r => ({
    name: r.name_ar, count: Number(r.count), revenue: Number(r.total)
  })) || [];

  const expiring = subsData?.expiring_soon?.map(e => ({
    name: e.business_name, plan: e.name_ar, phone: e.phone,
    days: Math.max(0, Math.ceil((new Date(e.end_date) - new Date()) / 86400000))
  })) || [];

  const totalRevenue = planData.reduce((s, p) => s + p.revenue, 0);
  const totalSubs    = subsData?.active_count || 0;

  return (
    <div style={{ fontFamily: 'Cairo, Arial, sans-serif' }}>
      <h1 style={{ fontSize: 22, fontWeight: 700, color: '#1A3C5E', marginBottom: 24 }}>الاشتراكات والإيرادات</h1>

      {/* KPIs */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3,1fr)', gap: 16, marginBottom: 24 }}>
        {[
          { label: 'إجمالي الاشتراكات النشطة', value: totalSubs, color: '#2980B9', bg: '#D6EAF8' },
          { label: 'إيرادات هذا الشهر', value: `$${totalRevenue.toLocaleString()}`, color: '#27AE60', bg: '#D5F5E3' },
          { label: 'تنتهي هذا الأسبوع', value: expiring.length, color: '#E74C3C', bg: '#FADBD8' },
        ].map((k, i) => (
          <div key={i} style={{ background: 'white', borderRadius: 16, padding: 20, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}>
            <div style={{ fontSize: 28, fontWeight: 700, color: k.color }}>{k.value}</div>
            <div style={{ fontSize: 13, color: '#7F8C8D', marginTop: 4 }}>{k.label}</div>
          </div>
        ))}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: 20 }}>
        {/* رسم بياني */}
        <div style={{ background: 'white', borderRadius: 16, padding: 20, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}>
          <h3 style={{ margin: '0 0 16px', color: '#1A3C5E' }}>الإيرادات حسب الخطة</h3>
          <ResponsiveContainer width="100%" height={220}>
            <BarChart data={planData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#F0F0F0" />
              <XAxis dataKey="name" tick={{ fontSize: 10, fontFamily: 'Cairo' }} />
              <YAxis tick={{ fontSize: 11 }} />
              <Tooltip formatter={(v, n) => [n === 'revenue' ? `$${v}` : v, n === 'revenue' ? 'الإيراد' : 'العدد']} />
              <Bar dataKey="revenue" fill="#2980B9" radius={[4,4,0,0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        {/* اشتراكات تنتهي قريباً */}
        <div style={{ background: 'white', borderRadius: 16, padding: 20, boxShadow: '0 2px 8px rgba(0,0,0,0.06)' }}>
          <h3 style={{ margin: '0 0 16px', color: '#E74C3C' }}>⚠️ تنتهي قريباً</h3>
          {expiring.map((e, i) => (
            <div key={i} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 0', borderBottom: i < expiring.length-1 ? '1px solid #F5F6FA' : 'none' }}>
              <div>
                <div style={{ fontWeight: 600, fontSize: 14 }}>{e.name}</div>
                <div style={{ fontSize: 12, color: '#7F8C8D' }}>{e.plan}</div>
              </div>
              <span style={{ padding: '4px 10px', borderRadius: 20, fontSize: 12, fontWeight: 700,
                background: e.days <= 1 ? '#FADBD8' : '#FEF9E7', color: e.days <= 1 ? '#E74C3C' : '#D4A017' }}>
                {e.days === 0 ? 'اليوم' : e.days === 1 ? 'غداً' : `${e.days} أيام`}
              </span>
            </div>
          ))}
          {expiring.length === 0 && <p style={{color: '#95A5A6', fontSize: 13, textAlign: 'center'}}>لا توجد اشتراكات تنتهي قريباً</p>}
        </div>
      </div>
    </div>
  );
}

