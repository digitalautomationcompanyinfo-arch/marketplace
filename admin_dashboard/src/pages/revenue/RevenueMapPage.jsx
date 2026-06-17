import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { MapPin, ArrowRight, TrendingUp, Filter } from 'lucide-react';
import { Link } from 'react-router-dom';
import api from '../../services/api';

export default function RevenueMapPage() {
  const { data: heatmap = [], isLoading } = useQuery({
    queryKey: ['revenue-heatmap'],
    queryFn: () => api.get('/admin/revenue/heatmap').then(r => r.data.data),
  });

  const maxRevenue = heatmap.length > 0 ? Math.max(...heatmap.map(m => parseFloat(m.total_revenue))) : 1;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link to="/revenue" className="p-2 hover:bg-gray-100 rounded-full transition-colors">
            <ArrowRight size={20} />
          </Link>
          <h1 className="page-title">خريطة الإيرادات الجغرافية</h1>
        </div>
        <div className="flex gap-2">
           <button className="btn btn-secondary flex items-center gap-2">
             <Filter size={16} /> تصفية حسب الولاية
           </button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Geographic Breakdown List */}
        <div className="lg:col-span-1 space-y-4 overflow-y-auto max-h-[700px] pr-2">
          <h2 className="text-sm font-bold text-gray-400 uppercase tracking-wider mb-4">أداء الأسواق (جغرافيا)</h2>
          {isLoading ? <div className="loading-spinner" /> : heatmap.map((item, i) => (
            <div key={i} className="card hover:border-blue-500/50 transition-all cursor-pointer group">
              <div className="flex justify-between items-start mb-2">
                <div>
                  <div className="font-bold text-lg">{item.market_name}</div>
                  <div className="text-gray-400 text-sm flex items-center gap-1">
                    <MapPin size={12} /> {item.state_name}
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-green-500 font-black">{parseFloat(item.total_revenue).toLocaleString()} ج.س</div>
                  <div className="text-xs text-gray-500">{item.orders_count} طلب</div>
                </div>
              </div>
              {/* Heat Indicator */}
              <div className="w-full h-1.5 bg-gray-100 rounded-full overflow-hidden mt-3">
                <div 
                  className="h-full bg-gradient-to-r from-blue-500 to-purple-500 group-hover:from-green-500 group-hover:to-blue-500 transition-all"
                  style={{ width: `${(parseFloat(item.total_revenue) / maxRevenue) * 100}%` }}
                />
              </div>
            </div>
          ))}
        </div>

        {/* Visual Heatmap Overlay (Mock or Visual Rep) */}
        <div className="lg:col-span-2 card bg-slate-50 dark:bg-slate-900 flex flex-col items-center justify-center min-h-[500px] relative overflow-hidden border-2 border-dashed border-gray-200">
           {/* In a real app, this is where Leaflet or Google Maps would go */}
           <div className="absolute inset-0 opacity-10 pointer-events-none">
              <svg viewBox="0 0 100 100" className="w-full h-full text-blue-500 fill-current">
                 <path d="M20,30 Q40,10 60,30 T100,30 L100,100 L0,100 Z" />
              </svg>
           </div>
           
           <div className="z-10 text-center p-8">
              <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-6">
                 <MapPin size={40} className="text-blue-600 animate-bounce" />
              </div>
              <h3 className="text-xl font-bold mb-2">توزيع النقاط الجغرافية نشط</h3>
              <p className="text-gray-500 max-w-md mx-auto mb-6">يتم حالياً عرض تحليل الأداء بناءً على إحداثيات الأسواق (خطوط الطول والعرض). اللون الأغمق يمثل كثافة مبيعات أعلى.</p>
              
              <div className="flex flex-wrap justify-center gap-4">
                 <div className="flex items-center gap-2 text-sm"><span className="w-3 h-3 rounded-full bg-blue-100" /> مبيعات منخفضة</div>
                 <div className="flex items-center gap-2 text-sm"><span className="w-3 h-3 rounded-full bg-blue-400" /> مبيعات متوسطة</div>
                 <div className="flex items-center gap-2 text-sm"><span className="w-3 h-3 rounded-full bg-blue-800" /> مبيعات مرتفعة</div>
              </div>
           </div>

           {/* Pulse Points for Top Markets */}
           {heatmap.slice(0, 5).map((m, i) => (
             <div 
               key={i}
               className="absolute w-4 h-4 rounded-full bg-blue-500 animate-ping opacity-50"
               style={{ 
                 top: `${20 + (i * 15)}%`, 
                 right: `${15 + (i * 10)}%` 
               }}
             />
           ))}
        </div>
      </div>
    </div>
  );
}
