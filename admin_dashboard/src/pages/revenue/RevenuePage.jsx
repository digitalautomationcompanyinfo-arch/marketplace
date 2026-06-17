import React, { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { BarChart2, TrendingUp, Award, MapPin } from 'lucide-react';
import { Link } from 'react-router-dom';
import {
  ResponsiveContainer, LineChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, BarChart, Bar, PieChart, Pie, Cell, Legend,
} from 'recharts';
import api from '../../services/api';

const COLORS = ['#3B82F6','#10B981','#F59E0B','#EF4444','#8B5CF6','#06B6D4','#F97316','#84CC16'];

export default function RevenuePage() {
  const [period, setPeriod] = useState('30');

  const { data, isLoading } = useQuery({
    queryKey: ['revenue-analytics', period],
    queryFn: () => api.get('/admin/revenue/analytics', { params: { period } }).then(r => r.data.data),
  });

  const daily       = data?.daily_revenue    || [];
  const byCategory  = data?.by_category      || [];
  const byRegion    = data?.by_region        || [];
  const topProviders= data?.top_providers    || [];

  const kpis = data?.kpis || {};
  const totalGMV = kpis.gmv || 0;
  const netCommission = kpis.commissions || 0;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="page-title"><BarChart2 className="inline-block ml-2" size={24} />تحليلات الإيرادات</h1>
        <div className="flex gap-4">
          <select className="input w-40" value={period} onChange={e => setPeriod(e.target.value)}>
            <option value="7">آخر 7 أيام</option>
            <option value="30">آخر 30 يوم</option>
            <option value="90">آخر 3 أشهر</option>
          </select>
          <Link to="/revenue/map" className="btn btn-primary flex items-center gap-2">
            <MapPin size={16} /> خريطة الإيرادات
          </Link>
        </div>
      </div>

      {/* KPI Summary - Hardened for Financial Transparency */}
      <div className="grid grid-cols-4 gap-4">
        <div className="card text-center border-b-4 border-green-500">
          <TrendingUp size={28} className="mx-auto text-green-500 mb-2" />
          <div className="text-xl font-bold">{parseFloat(totalGMV).toLocaleString('ar-SD')} ج.س</div>
          <div className="text-gray-400 text-xs">إجمالي مبيعات السوق (GMV)</div>
        </div>
        <div className="card text-center border-b-4 border-blue-600">
          <Award size={28} className="mx-auto text-blue-600 mb-2" />
          <div className="text-xl font-bold text-blue-600">{parseFloat(netCommission).toLocaleString('ar-SD')} ج.س</div>
          <div className="text-gray-400 text-xs">صافي ربح المنصة (عمولات)</div>
        </div>
        <div className="card text-center border-b-4 border-purple-500">
          <BarChart2 size={28} className="mx-auto text-purple-500 mb-2" />
          <div className="text-xl font-bold">{parseFloat(kpis.subscriptions_revenue || 0).toLocaleString('ar-SD')} ج.س</div>
          <div className="text-gray-400 text-xs">إيرادات الاشتراكات</div>
        </div>
        <div className="card text-center border-b-4 border-orange-500">
          <MapPin size={28} className="mx-auto text-orange-500 mb-2" />
          <div className="text-xl font-bold" style={{ fontSize: 16 }}>{byRegion[0]?.region || '—'}</div>
          <div className="text-gray-400 text-xs">الولاية الأكثر نشاطاً</div>
        </div>
      </div>

      {isLoading ? <div className="loading-spinner" /> : (
        <>
          {/* Daily Revenue Line Chart */}
          <div className="card">
            <h2 className="section-title mb-4">الإيرادات اليومية</h2>
            <ResponsiveContainer width="100%" height={260}>
              <LineChart data={daily}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.06)" />
                <XAxis dataKey="day" tick={{ fontSize: 11 }} />
                <YAxis tick={{ fontSize: 11 }} />
                <Tooltip formatter={v => [`${v} ج.س`]} />
                <Line type="monotone" dataKey="revenue" stroke="#3B82F6" strokeWidth={2.5} dot={false} />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="grid grid-cols-2 gap-6">
            {/* By Category Bar */}
            <div className="card">
              <h2 className="section-title mb-4">الإيرادات حسب الفئة</h2>
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={byCategory} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.06)" />
                  <XAxis type="number" tick={{ fontSize: 11 }} />
                  <YAxis dataKey="category" type="category" width={90} tick={{ fontSize: 11 }} />
                  <Tooltip formatter={v => [`${v} ج.س`]} />
                  <Bar dataKey="revenue" fill="#10B981" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>

            {/* By Region Pie */}
            <div className="card">
              <h2 className="section-title mb-4">توزيع الطلبات حسب الولاية</h2>
              <ResponsiveContainer width="100%" height={220}>
                <PieChart>
                  <Pie data={byRegion} dataKey="orders" nameKey={byRegion[0]?.state_name ? "state_name" : "region"} cx="50%" cy="50%" outerRadius={80} label>
                    {byRegion.map((_, i) => <Cell key={i} fill={COLORS[i % COLORS.length]} />)}
                  </Pie>
                  <Legend />
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Top Providers Table */}
          <div className="card">
            <h2 className="section-title mb-4">أعلى 10 مزودين من حيث الإيرادات</h2>
            <table className="data-table w-full">
              <thead>
                <tr><th>#</th><th>المزود</th><th>الطلبات المكتملة</th><th>الإيرادات</th><th>التقييم</th></tr>
              </thead>
              <tbody>
                {topProviders.map((p, i) => (
                  <tr key={i}>
                    <td className="text-gray-400">{i + 1}</td>
                    <td className="font-semibold">{p.business_name}</td>
                    <td>{p.completed_orders}</td>
                    <td className="text-green-500 font-bold">{parseFloat(p.total_revenue || 0).toFixed(2)} ج.س</td>
                    <td>⭐ {parseFloat(p.rating_avg || 0).toFixed(1)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}

