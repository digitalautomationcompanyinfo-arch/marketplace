import React from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../services/api';
import { Activity, Trash2, Cpu, Database, Wifi, ShieldAlert, Clock, Smartphone, Server } from 'lucide-react';
import toast from 'react-hot-toast';

export default function ErrorLogsPage() {
  const queryClient = useQueryClient();

  // Health Data
  const { data: health, isLoading: loadingHealth } = useQuery({
    queryKey: ['system-health'],
    queryFn: () => api.get('/admin/health').then(r => r.data.data),
    refetchInterval: 30000, // Every 30s
  });

  // Error Logs
  const { data: logs, isLoading: loadingLogs } = useQuery({
    queryKey: ['error-logs'],
    queryFn: () => api.get('/admin/error-logs').then(r => r.data.data),
  });

  const clearMutation = useMutation({
    mutationFn: () => api.delete('/admin/error-logs'),
    onSuccess: () => {
      queryClient.invalidateQueries(['error-logs']);
      toast.success('تم مسح السجلات بنجاح');
    }
  });

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">نبض النظام وتتبع الأعطال</h1>
          <p className="text-gray-500 text-sm">مراقب الصحة الحيوية للمنصة وتطبيقات الجوال</p>
        </div>
        <button 
          onClick={() => { if(window.confirm('مسح جميع السجلات؟')) clearMutation.mutate(); }}
          className="flex items-center gap-2 px-4 py-2 bg-red-50 text-red-600 rounded-lg border border-red-200 hover:bg-red-100 transition-colors"
        >
          <Trash2 size={18} />
          مسح السجلات
        </button>
      </div>

      {/* Health Cards - FIX Phase 22: Industrial Diagnostics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <HealthCard 
          icon={Database} 
          label="قاعدة البيانات" 
          status={health?.database?.status === 'ok' ? `متصل (${health?.database?.pool?.total})` : 'فشل الاتصال'} 
          color={health?.database?.status === 'ok' ? 'green' : 'red'} 
          subtitle={health?.database?.status === 'ok' ? `نشط: ${health?.database?.pool?.total - health?.database?.pool?.idle} | خامل: ${health?.database?.pool?.idle}` : null}
        />
        <HealthCard icon={Wifi} label="Redis / Cache" status={health?.redis} color={health?.redis === 'ok' ? 'green' : 'red'} />
        <HealthCard icon={ShieldAlert} label="Firebase Auth/FCM" status={health?.firebase} color={health?.firebase === 'ok' ? 'green' : 'red'} />
        
        {/* RAM Status */}
        <div className={`p-4 rounded-xl border flex items-center gap-4 text-blue-600 bg-blue-50 border-blue-100`}>
          <div className="p-2 bg-white rounded-lg shadow-sm"><Cpu size={24} /></div>
          <div className="flex-1">
            <div className="text-xs opacity-75 font-medium">الذاكرة (RAM) - {Math.round((health?.system?.memory?.heap?.heapUsed || 0) / 1024 / 1024)}mb Heap</div>
            <div className="text-lg font-bold">{health?.system?.memory?.usage_pct || 0}%</div>
            <div className="w-full bg-blue-200 rounded-full h-1 mt-1 overflow-hidden">
               <div className="bg-blue-600 h-full transition-all" style={{ width: `${health?.system?.memory?.usage_pct || 0}%` }} />
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <HealthCard icon={Server} label="المعالج (Load 1m)" status={health?.system?.load?.[0]?.toFixed(2)} color="purple" />
        <HealthCard icon={Clock} label="وقت التشغيل" status={Math.floor((health?.system?.uptime || 0) / 3600) + ' ساعات'} color="blue" />
        <HealthCard icon={Smartphone} label="إصدار Node" status={health?.system?.node_version} color="green" />
      </div>

      {/* Logs Table */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="p-4 border-bottom bg-gray-50 font-semibold text-gray-700 flex items-center gap-2">
          <Activity size={18} className="text-blue-500" />
          آخر الأعطال المسجلة
        </div>
        
        <div className="overflow-x-auto">
          <table className="w-full text-right">
            <thead>
              <tr className="bg-gray-50 text-gray-400 text-xs font-medium uppercase tracking-wider border-b">
                <th className="px-6 py-3">المصدر</th>
                <th className="px-6 py-3">الرسالة</th>
                <th className="px-6 py-3">المسار / الشاشة</th>
                <th className="px-6 py-3">الوقت</th>
                <th className="px-6 py-3"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {loadingLogs ? (
                <tr><td colSpan="5" className="p-10 text-center text-gray-400">جاري التحميل...</td></tr>
              ) : logs?.length === 0 ? (
                <tr><td colSpan="5" className="p-10 text-center text-gray-400">لا توجد أعطال مسجلة حالياً 🎉</td></tr>
              ) : logs?.map(log => (
                <tr key={log.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full text-xs font-medium ${log.type === 'server' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800'}`}>
                      {log.type === 'server' ? <Server size={12} /> : <Smartphone size={12} />}
                      {log.app_name}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    <div className="text-sm font-semibold text-gray-900 line-clamp-1">{log.error_message}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {log.url || 'N/A'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(log.created_at).toLocaleString('ar-SD')}
                  </td>
                  <td className="px-6 py-4 text-left">
                    <button 
                      onClick={() => alert(`Stack Trace:\n${log.stack_trace}`)}
                      className="text-blue-600 hover:text-blue-800 text-xs font-medium"
                    >
                      التفاصيل
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

function HealthCard({ icon: Icon, label, status, color, subtitle }) {
  const colors = {
    green: 'text-green-600 bg-green-50 border-green-100',
    red:   'text-red-600 bg-red-50 border-red-100',
    blue:  'text-blue-600 bg-blue-50 border-blue-100',
  };
  
  return (
    <div className={`p-4 rounded-xl border flex items-center gap-4 ${colors[color] || colors.blue}`}>
      <div className="p-2 bg-white rounded-lg shadow-sm">
        <Icon size={24} />
      </div>
      <div>
        <div className="text-xs opacity-75 font-medium">{label}</div>
        <div className="text-lg font-bold uppercase">{status || '...'}</div>
        {subtitle && <div className="text-[10px] opacity-70 mt-0.5">{subtitle}</div>}
      </div>
    </div>
  );
}
