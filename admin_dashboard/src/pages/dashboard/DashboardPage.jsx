import { useQuery, useQueryClient } from '@tanstack/react-query';
import { Link } from 'react-router-dom';
import toast from 'react-hot-toast';
import {
  Users, Store, DollarSign, Clock, TrendingUp,
  AlertTriangle, CheckCircle, BarChart2, Bell, ArrowLeft
} from 'lucide-react';
import api from '../../services/api';
import socketService from '../../services/socket.service';
import StatsCard from '../../components/charts/StatsCard';
import { RevenueChart, CategoryChart } from '../../components/charts/RevenueChart';
import { Badge } from '../../components/ui/Badge';

// Mock data for development (replaced by real API)
const MOCK = {
  kpis: {
    total_users: 4280, new_users_month: 340,
    total_providers: 892, active_providers: 648,
    revenue_today: 1240, revenue_month: 38500, revenue_total: 192000,
    pending_requests: 12,
  },
  revenue_chart: [
    { date: '2026-03-01', revenue: 1800, subscriptions: 14 },
    { date: '2026-03-04', revenue: 2200, subscriptions: 18 },
    { date: '2026-03-07', revenue: 1950, subscriptions: 16 },
    { date: '2026-03-10', revenue: 2800, subscriptions: 22 },
    { date: '2026-03-13', revenue: 3100, subscriptions: 25 },
    { date: '2026-03-14', revenue: 1240, subscriptions: 10 },
  ],
  categories_dist: [
    { name: 'مطاعم', count: 180 }, { name: 'صحة', count: 95 },
    { name: 'إلكترونيات', count: 72 }, { name: 'ملابس', count: 68 },
    { name: 'بقالة', count: 55 }, { name: 'تجميل', count: 48 },
  ],
  pending: [
    { id: 1, business_name: 'مطعم البيت السعودي', category: 'مطاعم', time: 'قبل 45 دقيقة' },
    { id: 2, business_name: 'صيدلية الحياة الجديدة', category: 'صحة ودواء', time: 'قبل 2 ساعة' },
    { id: 3, business_name: 'تقنية الوادي للإلكترونيات', category: 'إلكترونيات', time: 'قبل 4 ساعات' },
    { id: 4, business_name: 'بوتيك النخبة', category: 'ملابس وأزياء', time: 'قبل 6 ساعات' },
  ],
  recent_users: [
    { name: 'أحمد محمد علي', time: 'منذ 12 دقيقة', phone: '+966501234567' },
    { name: 'سارة عبدالله العلي', time: 'منذ 34 دقيقة', phone: '+966507654321' },
    { name: 'محمد خالد السعد', time: 'منذ ساعة', phone: '+966509876543' },
    { name: 'نورة فهد الحربي', time: 'منذ 2 ساعة', phone: '+966502345678' },
  ],
};

export default function DashboardPage() {
  const queryClient = useQueryClient();

  const { data, isLoading } = useQuery({
    queryKey: ['dashboard'],
    queryFn: () => api.get('/admin/dashboard').then(r => r.data.data),
    placeholderData: MOCK,
    retry: 1,
  });

  React.useEffect(() => {
    const handleUpdate = (payload) => {
      console.log('📊 Stats update received:', payload);
      queryClient.invalidateQueries(['dashboard']);
      if (payload.type === 'provider_review') {
        toast.success(`تم تحديث حالة مزود بنجاح!`, { icon: '🔄' });
      } else {
        toast.success('تحديث لحظي للبيانات...', { icon: '⚡', duration: 2000 });
      }
    };

    socketService.on('admin:stats_update', handleUpdate);
    return () => socketService.off('admin:stats_update');
  }, [queryClient]);

  const kpis = data?.kpis || MOCK.kpis;
  const revChart = data?.revenue_chart?.length ? data.revenue_chart : [];
  const catDist  = data?.categories_dist?.length ? data.categories_dist : [];
  const pending  = data?.pending || [];
  const recentUsers = data?.recent_users || [];

  const totalRevenue = revChart.reduce((s, r) => s + (r.revenue || 0), 0);

  return (
    <div className="fade-in space-y-8">
      {/* ─── Page Header ─────────────────────────────────── */}
      <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-4 mb-8">
        <div>
          <h1 className="text-3xl font-black text-primary tracking-tight">
            لوحة القيادة المركزية 🚀
          </h1>
          <div className="flex items-center gap-4 mt-1">
            <p className="text-muted font-bold text-sm uppercase tracking-widest">
              {new Date().toLocaleDateString('ar-SD', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
            </p>
            {/* Phase 25/30: System Integrity Heartbeat */}
            <div className={`flex items-center gap-2 px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-tighter ${
              kpis.health?.status === 'healthy' ? 'bg-green-100 text-green-700' : 
              kpis.health?.status === 'compromised' ? 'bg-red-100 text-red-700 animate-pulse' : 'bg-orange-100 text-orange-700'
            }`}>
              <div className={`w-2 h-2 rounded-full ${
                kpis.health?.status === 'healthy' ? 'bg-green-500 shadow-[0_0_8px_rgba(34,197,94,0.5)]' : 
                kpis.health?.status === 'compromised' ? 'bg-red-500 shadow-[0_0_8px_rgba(239,68,68,0.5)]' : 'bg-orange-500'
              }`} />
              {kpis.health?.status === 'healthy' ? 'نظام متزن 💎' : kpis.health?.status === 'compromised' ? 'اختراق حسابي 🚨' : 'تحذير تقني ⚠️'}
            </div>
            {kpis.health?.last_run && (
              <p className="text-[10px] text-muted-foreground font-medium">
                آخر صيانة: {new Date(kpis.health.last_run).toLocaleTimeString('ar-SD', { hour: '2-digit', minute: '2-digit' })}
              </p>
            )}
          </div>
        </div>
        
        <div className="flex items-center gap-3">
          {kpis.pending_requests > 0 && (
            <Link to="/providers/pending" className="no-underline group">
              <div className="flex items-center gap-3 bg-gradient-to-br from-red-500 to-red-700 text-white px-6 py-3 rounded-2xl font-black text-sm shadow-xl shadow-red-200/50 group-hover:scale-105 transition-all">
                <Bell size={18} className="group-hover:rotate-12 transition-transform" />
                {kpis.pending_requests} طلب انتظار
              </div>
            </Link>
          )}
        </div>
      </div>

      {/* ─── KPI Cards ───────────────────────────────────── */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <StatsCard
          label="إجمالي المستخدمين"
          value={kpis.total_users?.toLocaleString('ar-SD')}
          change={`+${kpis.new_users_month}`}
          changeLabel="هذا الشهر"
          variant="primary"
          icon={<Users size={22} />}
          loading={isLoading}
          className="card-premium stat-card-vibrant"
        />
        <StatsCard
          label="المزودون النشطون"
          value={kpis.active_providers?.toLocaleString('ar-SD')}
          subValue={`الإجمالي: ${kpis.total_providers?.toLocaleString('ar-SD')}`}
          change="+8.2%"
          variant="success"
          icon={<Store size={22} />}
          loading={isLoading}
          className="card-premium stat-card-vibrant"
        />
        <StatsCard
          label="إيرادات الشهر"
          value={`${kpis.revenue_month?.toLocaleString('ar-SD')} ج.س`}
          subValue={`اليوم: ${kpis.revenue_today?.toLocaleString('ar-SD')} ج.س`}
          change="+15.3%"
          variant="warning"
          icon={<DollarSign size={22} />}
          loading={isLoading}
          className="card-premium stat-card-vibrant shadow-glow"
        />
        <StatsCard
          label="متوسط زمن السحب"
          value={`${kpis.payout_avg_hours || 0} ساعة`}
          subValue={`طلبات معلقة: ${kpis.pending_providers || 0}`}
          variant={kpis.payout_avg_hours > 48 ? 'danger' : 'success'}
          icon={<Clock size={22} />}
          loading={isLoading}
          className="card-premium stat-card-vibrant"
        />
      </div>

      {/* ─── Intelligence Row (Phase 30) ──────────────────── */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        {/* Revenue by Category Chart */}
        <div className="lg:col-span-2 card p-6 !border-none !shadow-xl bg-white rounded-3xl">
          <div className="flex justify-between items-center mb-6">
            <h3 className="font-black text-lg text-primary flex items-center gap-2">
              <BarChart2 className="text-secondary" />
              أداء الفئات (آخر 30 يوم)
            </h3>
            <span className="text-xs font-bold text-muted uppercase tracking-widest">تحليل حجم المبيعات</span>
          </div>
          <div className="space-y-4">
            {data?.revenue_by_category?.length > 0 ? data.revenue_by_category.map((c, i) => {
              const maxVal = Math.max(...data.revenue_by_category.map(x => Number(x.volume)), 1);
              const pct = (Number(c.volume) / maxVal) * 100;
              const colors = ['#2980B9','#27AE60','#E74C3C','#F39C12','#8E44AD','#1ABC9C'];
              return (
                <div key={i} className="space-y-1">
                  <div className="flex justify-between text-sm font-bold">
                    <span>{c.name}</span>
                    <span className="text-primary">{Number(c.volume).toLocaleString('ar-SD')} ج.س</span>
                  </div>
                  <div className="h-2 bg-slate-50 rounded-full overflow-hidden border border-slate-100">
                    <div 
                      className="h-full transition-all duration-1000 shadow-[0_0_8px_rgba(41,128,185,0.3)]"
                      style={{ width: `${pct}%`, backgroundColor: colors[i % colors.length] }}
                    />
                  </div>
                </div>
              );
            }) : (
              <div className="text-center py-12">
                <TrendingUp size={40} className="mx-auto text-slate-200 mb-2" />
                <p className="text-slate-400 font-medium">لا توجد مبيعات كافية لتحليل الفئات حالياً</p>
              </div>
            )}
          </div>
        </div>

        {/* Operation Pulse */}
        <div className="card p-6 flex flex-col justify-between !border-none !shadow-xl bg-white rounded-3xl">
          <h3 className="font-black text-lg text-primary mb-4 flex items-center gap-2">
            <TrendingUp className="text-green-500" />
            نبض العمليات
          </h3>
          <div className="space-y-6 flex-1">
            <div className="p-4 bg-green-50/50 rounded-2xl border border-green-100/50">
              <p className="text-xs font-black text-green-700/60 mb-1 uppercase tracking-wider">صافي أرباح المنصة</p>
              <p className="text-2xl font-black text-green-700">{kpis.total_commissions?.toLocaleString('ar-SD')} <span className="text-xs">ج.س</span></p>
            </div>
            <div className="p-4 bg-orange-50/50 rounded-2xl border border-orange-100/50">
              <p className="text-xs font-black text-orange-700/60 mb-1 uppercase tracking-wider">إيرادات مفقودة (إلغاءات)</p>
              <p className="text-2xl font-black text-orange-700">{kpis.lost_revenue_month?.toLocaleString('ar-SD')} <span className="text-xs">ج.س</span></p>
            </div>
            <div className="p-4 bg-blue-50/50 rounded-2xl border border-blue-100/50">
              <p className="text-xs font-black text-blue-700/60 mb-1 uppercase tracking-wider">كفاءة معالجة المبالغ</p>
              <div className="flex items-center gap-2 mt-1">
                 <div className="px-2 py-0.5 bg-blue-500 text-white text-[10px] font-black rounded-lg uppercase">Excellent</div>
                 <span className="text-xs font-bold text-blue-800">أقل من 24 ساعة</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* ─── Second Row: Pending + Recent Users ──────────── */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20 }}>

        {/* Pending Providers */}
        <div className="card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
            <h3 style={{ margin: 0, fontSize: 15, fontWeight: 700 }}>
              <AlertTriangle size={16} style={{ marginLeft: 6, color: 'var(--warning)', verticalAlign: 'middle' }} />
              طلبات التسجيل الجديدة
            </h3>
            <Link to="/providers/pending" style={{ color: 'var(--primary-light)', fontSize: 13, textDecoration: 'none', display: 'flex', alignItems: 'center', gap: 4 }}>
              عرض الكل <ArrowLeft size={14} />
            </Link>
          </div>

          {pending.length === 0 && <div style={{padding: '20px 0', color: '#7F8C8D', fontSize: 13}}>لا توجد طلبات جديدة</div>}
          {pending.map((p, i) => (
            <div key={p.id} style={{
              display: 'flex', alignItems: 'center', gap: 12,
              padding: '12px 0',
              borderBottom: i < pending.length - 1 ? '1px solid var(--border)' : 'none',
            }}>
              <div style={{
                width: 42, height: 42, borderRadius: 10,
                background: 'linear-gradient(135deg, #D6EAF8, #BDD7EE)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                flexShrink: 0,
              }}>
                <Store size={18} color="var(--primary-light)" />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ fontWeight: 700, fontSize: 14, overflow: 'hidden', whiteSpace: 'nowrap', textOverflow: 'ellipsis' }}>
                  {p.business_name}
                </div>
                <div style={{ color: 'var(--text-muted)', fontSize: 12, marginTop: 2 }}>
                  {p.category} · {new Date(p.time).toLocaleDateString('ar-SD')}
                </div>
              </div>
              <Badge variant="warning">انتظار</Badge>
            </div>
          ))}
        </div>

        {/* Recent Users */}
        <div className="card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 16 }}>
            <h3 style={{ margin: 0, fontSize: 15, fontWeight: 700 }}>
              <CheckCircle size={16} style={{ marginLeft: 6, color: 'var(--accent)', verticalAlign: 'middle' }} />
              أحدث المستخدمين
            </h3>
            <Link to="/users" style={{ color: 'var(--primary-light)', fontSize: 13, textDecoration: 'none', display: 'flex', alignItems: 'center', gap: 4 }}>
              عرض الكل <ArrowLeft size={14} />
            </Link>
          </div>

          {recentUsers.length === 0 && <div style={{padding: '20px 0', color: '#7F8C8D', fontSize: 13}}>لا يوجد مستخدمون جدد</div>}
          {recentUsers.map((u, i) => {
            const colors = ['#2980B9','#27AE60','#E74C3C','#8E44AD'];
            const initials = u.name ? u.name.split(' ').slice(0,2).map(w => w[0]).join('') : '?';
            return (
              <div key={i} style={{
                display: 'flex', alignItems: 'center', gap: 12,
                padding: '12px 0',
                borderBottom: i < recentUsers.length - 1 ? '1px solid var(--border)' : 'none',
              }}>
                <div className="avatar" style={{ background: colors[i % colors.length], flexShrink: 0 }}>
                  {initials}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontWeight: 700, fontSize: 14 }}>{u.name}</div>
                  <div style={{ color: 'var(--text-muted)', fontSize: 12, marginTop: 2 }}>{u.phone} · {new Date(u.time).toLocaleDateString('ar-SD')}</div>
                </div>
                <Badge variant="success">جديد</Badge>
              </div>
            );
          })}
        </div>
      </div>

      {/* ─── Quick Actions (bottom) ───────────────────────── */}
      <div style={{ marginTop: 24, display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14 }}>
        {[
          { label: 'إضافة فئة جديدة',    icon: '🏷️', to: '/categories',          color: '#2980B9' },
          { label: 'إرسال إشعار لعام',   icon: '📣', to: '/notifications',       color: '#27AE60' },
          { label: 'مراجعة البلاغات',    icon: '⚠️', to: '/reports',             color: '#E74C3C' },
          { label: 'تقارير الاشتراك',     icon: '💰', to: '/subscriptions',       color: '#F39C12' },
        ].map((a, i) => (
          <Link key={i} to={a.to} style={{ textDecoration: 'none' }}>
            <div style={{
              background: 'white', borderRadius: 12, padding: '16px 20px',
              display: 'flex', alignItems: 'center', gap: 12,
              boxShadow: 'var(--shadow)', border: '1px solid var(--border)',
              transition: 'var(--transition)', cursor: 'pointer',
              borderRight: `4px solid ${a.color}`,
            }}
              onMouseEnter={e => e.currentTarget.style.transform = 'translateY(-2px)'}
              onMouseLeave={e => e.currentTarget.style.transform = 'translateY(0)'}
            >
              <span style={{ fontSize: 24 }}>{a.icon}</span>
              <span style={{ fontWeight: 700, fontSize: 14, color: 'var(--text-primary)' }}>{a.label}</span>
            </div>
          </Link>
        ))}
      </div>

      <style>{`
        @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.8; }
        }
      `}</style>
    </div>
  );
}

