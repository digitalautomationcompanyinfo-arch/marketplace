import React, { useState } from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../store/authStore';
import {
  Package, BarChart2, Percent, MessageSquare, Settings,
  Globe, MapPin, Store, X, Menu, Bell, LogOut, ClipboardList
} from 'lucide-react';

const navItems = [
  { to: '/',                  icon: BarChart2,       label: 'الإحصائيات' },
  { to: '/providers',         icon: Package,         label: 'المزودون' },
  { to: '/conversations',     icon: MessageSquare,   label: 'المحادثات' },
  { to: '/offers',            icon: Percent,         label: 'العروض' },
  { to: '/states',            icon: Globe,           label: 'الولايات' },
  { to: '/markets',           icon: MapPin,          label: 'الأسواق المحليّة' },
  { to: '/subscriptions/approvals', icon: Percent,    label: 'اعتمادات الاشتراكات' },
  { to: '/audit',             icon: ClipboardList,   label: 'سجل الأنشطة' },
  { to: '/system/pulse',      icon: Activity,        label: 'نبض النظام' },
  { to: '/settings',          icon: Settings,        label: 'إعدادات النظام' },
];

import socketService from '../../services/socket.service';
import { Activity, Heart } from 'lucide-react';

export default function AdminLayout() {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [pulseCount, setPulseCount] = useState(0);
  const { admin, token, logout } = useAuthStore();
  const navigate = useNavigate();

  React.useEffect(() => {
    if (token) {
      socketService.connect(token);
      
      const socket = socketService.socket;
      if (socket) {
        socket.on('admin:system_error', (data) => {
          setPulseCount(prev => prev + 1);
          toast.error(`خطأ جديد في النظام: ${data.message || 'عطل برمجى'}`, {
            icon: '🚨',
            duration: 6000
          });
        });
      }
    }
    return () => socketService.disconnect();
  }, [token]);

  const handleLogout = () => { 
    socketService.disconnect();
    logout(); 
    navigate('/login'); 
  };

  return (
    <div dir="rtl" className="flex h-screen bg-page font-cairo overflow-hidden">

      {/* ─── Sidebar ─────────────────────────────────── */}
      <aside className={`admin-sidebar sidebar-glass flex flex-col shadow-xl transition-all duration-300 overflow-hidden ${sidebarOpen ? 'w-[260px]' : 'w-[70px]'}`}>
        {/* Logo */}
        <div className="p-4 border-b border-white/10 flex items-center gap-3">
          <img src="/assets/images/logo_icons.png" alt="Logo" className="w-9 h-9 rounded-xl object-contain shadow-glow" />
          {sidebarOpen && (
            <div className="fade-in">
              <div className="text-white font-black text-lg leading-tight">كيف نخدمك</div>
              <div className="text-blue-200/60 text-[10px] uppercase tracking-wider">Marketplace OS</div>
            </div>
          )}
        </div>

        {/* Nav */}
        <nav className="flex-1 p-3 overflow-y-auto space-y-1">
          {navItems.map(({ to, icon: Icon, label }) => (
            <NavLink key={to} to={to} className={({ isActive }) => 
              `nav-item ${isActive ? 'active shadow-lg' : ''} group animate-spring`
            }>
              <Icon size={20} className="flex-shrink-0 group-hover:scale-110 transition-transform" />
              {sidebarOpen && <span className="font-bold">{label}</span>}
            </NavLink>
          ))}
        </nav>

        {/* Admin Info */}
        {sidebarOpen && (
          <div className="p-5 border-t border-white/10 glass-effect m-2 rounded-2xl">
            <div className="text-white text-sm font-black">{admin?.full_name || 'المدير العام'}</div>
            <div className="text-blue-300/70 text-xs font-bold uppercase tracking-widest mt-1">{admin?.role || 'Super Admin'}</div>
          </div>
        )}
      </aside>

      {/* ─── Main Content ─────────────────────────────── */}
      <div className="flex-1 flex flex-col overflow-hidden">

        {/* Topbar */}
        <header className="topbar topbar-glass h-16 flex items-center justify-between px-6 z-50">
          <button onClick={() => setSidebarOpen(!sidebarOpen)}
            className="p-2 hover:bg-slate-100 rounded-xl transition-colors text-slate-600">
            {sidebarOpen ? <X size={22} /> : <Menu size={22} />}
          </button>

          <div className="flex items-center gap-4">
            <NavLink to="/system/pulse" className="p-2 hover:bg-slate-50 rounded-xl relative transition-all group">
              <Activity size={20} className={pulseCount > 0 ? 'text-red-500 animate-pulse' : 'text-slate-500'} />
              {pulseCount > 0 && <span className="absolute -top-1 -right-1 bg-red-500 text-white border-2 border-white rounded-full w-5 h-5 text-[10px] flex items-center justify-center font-black shadow-lg">{pulseCount}</span>}
            </NavLink>

            <button className="p-2 hover:bg-slate-50 rounded-xl relative transition-all">
              <Bell size={20} className="text-slate-500" />
              <span className="absolute -top-1 -right-1 bg-primary-light text-white border-2 border-white rounded-full w-5 h-5 text-[10px] flex items-center justify-center font-black shadow-lg">3</span>
            </button>

            <button onClick={handleLogout}
              className="flex items-center gap-2 px-4 py-2 bg-danger text-white hover:bg-red-600 rounded-xl font-bold text-sm transition-all shadow-lg hover:shadow-red-200">
              <LogOut size={16} />
              تسجيل الخروج
            </button>
          </div>
        </header>

        {/* Page Content */}
        <main className="flex-1 overflow-y-auto p-6 bg-page/50">
          <Outlet />
        </main>
      </div>
    </div>
  );
}

