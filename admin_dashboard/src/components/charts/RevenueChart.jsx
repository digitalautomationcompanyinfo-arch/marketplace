import React from 'react';
import {
  AreaChart, Area, BarChart, Bar, XAxis, YAxis,
  CartesianGrid, Tooltip, ResponsiveContainer, Legend
} from 'recharts';

const CustomTooltip = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null;
  return (
    <div style={{
      background: 'white', border: '1px solid #e8edf2', borderRadius: 10,
      padding: '10px 14px', boxShadow: '0 4px 16px rgba(0,0,0,0.1)',
      direction: 'rtl', fontFamily: 'Cairo, sans-serif',
    }}>
      <div style={{ fontWeight: 700, marginBottom: 6, color: '#1C2833' }}>{label}</div>
      {payload.map((p, i) => (
        <div key={i} style={{ display: 'flex', gap: 8, alignItems: 'center', fontSize: 13 }}>
          <div style={{ width: 8, height: 8, borderRadius: '50%', background: p.color }} />
          <span style={{ color: '#566573' }}>{p.name}:</span>
          <span style={{ fontWeight: 700, color: '#1C2833' }}>
            {typeof p.value === 'number' && p.name?.includes('إيراد')
              ? `${p.value.toLocaleString('ar-SD')} ج.س`
              : p.value?.toLocaleString('ar-SD')}
          </span>
        </div>
      ))}
    </div>
  );
};

/** Revenue Area Chart */
export function RevenueChart({ data = [], loading = false }) {
  if (loading) {
    return <div className="skeleton" style={{ height: 280, borderRadius: 12 }} />;
  }
  if (!data.length) {
    return (
      <div style={{ height: 280, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-muted)' }}>
        لا توجد بيانات إيرادات حتى الآن
      </div>
    );
  }
  return (
    <ResponsiveContainer width="100%" height={280}>
      <AreaChart data={data} margin={{ top: 5, right: 10, left: 0, bottom: 5 }}>
        <defs>
          <linearGradient id="gradRevenue" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%"  stopColor="#2980B9" stopOpacity={0.3} />
            <stop offset="95%" stopColor="#2980B9" stopOpacity={0} />
          </linearGradient>
          <linearGradient id="gradSubs" x1="0" y1="0" x2="0" y2="1">
            <stop offset="5%"  stopColor="#27AE60" stopOpacity={0.3} />
            <stop offset="95%" stopColor="#27AE60" stopOpacity={0} />
          </linearGradient>
        </defs>
        <CartesianGrid strokeDasharray="3 3" stroke="#f0f2f5" />
        <XAxis
          dataKey="date"
          tick={{ fill: '#ABB2B9', fontSize: 12, fontFamily: 'Cairo' }}
          tickLine={false} axisLine={false}
          tickFormatter={v => v?.slice(5)} // "03-14" from "2026-03-14"
        />
        <YAxis
          yAxisId="revenue"
          tick={{ fill: '#ABB2B9', fontSize: 11, fontFamily: 'Cairo' }}
          tickLine={false} axisLine={false}
          tickFormatter={v => `${(v/1000).toFixed(0)}k`}
        />
        <YAxis
          yAxisId="subs"
          orientation="left"
          tick={{ fill: '#ABB2B9', fontSize: 11, fontFamily: 'Cairo' }}
          tickLine={false} axisLine={false}
        />
        <Tooltip content={<CustomTooltip />} />
        <Legend
          wrapperStyle={{ fontFamily: 'Cairo', fontSize: 13, paddingTop: 12 }}
          formatter={(v) => <span style={{ color: '#566573' }}>{v}</span>}
        />
        <Area
          yAxisId="revenue"
          type="monotone" dataKey="revenue" name="الإيرادات (ج.س)"
          stroke="#2980B9" strokeWidth={2.5}
          fill="url(#gradRevenue)" dot={false} activeDot={{ r: 5 }}
        />
        <Area
          yAxisId="subs"
          type="monotone" dataKey="subscriptions" name="الاشتراكات"
          stroke="#27AE60" strokeWidth={2}
          fill="url(#gradSubs)" dot={false} activeDot={{ r: 4 }}
        />
      </AreaChart>
    </ResponsiveContainer>
  );
}

/** Providers by Category Bar Chart */
export function CategoryChart({ data = [], loading = false }) {
  if (loading) return <div className="skeleton" style={{ height: 220, borderRadius: 12 }} />;
  return (
    <ResponsiveContainer width="100%" height={220}>
      <BarChart data={data} margin={{ top: 5, right: 10, left: 0, bottom: 5 }} barSize={24}>
        <CartesianGrid strokeDasharray="3 3" stroke="#f0f2f5" vertical={false} />
        <XAxis
          dataKey="name" tick={{ fill: '#ABB2B9', fontSize: 11, fontFamily: 'Cairo' }}
          tickLine={false} axisLine={false}
        />
        <YAxis
          tick={{ fill: '#ABB2B9', fontSize: 11, fontFamily: 'Cairo' }}
          tickLine={false} axisLine={false}
        />
        <Tooltip content={<CustomTooltip />} />
        <Bar dataKey="count" name="عدد المزودين" fill="#2980B9" radius={[6, 6, 0, 0]} />
      </BarChart>
    </ResponsiveContainer>
  );
}

