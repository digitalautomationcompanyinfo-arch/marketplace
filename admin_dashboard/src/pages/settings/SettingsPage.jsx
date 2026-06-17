import React, { useState, useEffect } from 'react';
import { useQuery, useMutation } from '@tanstack/react-query';
import { Settings, Save, Sliders } from 'lucide-react';
import api from '../../services/api';
import toast from 'react-hot-toast';

const DEFAULT_SETTINGS = {
  platform_name: 'كيف نخدمك',
  support_phone: '+966500000000',
  support_email: 'support@marketplace.com',
  delivery_fee_default: '10',
  min_order_amount: '20',
  max_delivery_radius_km: '25',
  commission_percent: '15',
  trial_days: '14',
  allow_guest_checkout: 'false',
  maintenance_mode: 'false',
};

export default function SettingsPage() {
  const [settings, setSettings] = useState(DEFAULT_SETTINGS);

  const { data, isLoading } = useQuery({
    queryKey: ['system-settings'],
    queryFn: () => api.get('/admin/settings').then(r => r.data.data),
  });

  useEffect(() => {
    if (data) setSettings(prev => ({ ...prev, ...data }));
  }, [data]);

  const { mutate: save, isLoading: saving } = useMutation({
    mutationFn: (body) => api.put('/admin/settings', body),
    onSuccess: () => toast.success('تم حفظ الإعدادات بنجاح ✅'),
    onError: () => toast.error('فشل في حفظ الإعدادات'),
  });

  const handleChange = (key, value) => setSettings(s => ({ ...s, [key]: value }));

  const SettingRow = ({ label, settingKey, type = 'text', hint }) => (
    <div className="flex items-start justify-between py-4 border-b border-gray-100 dark:border-gray-800 last:border-0">
      <div>
        <div className="font-semibold">{label}</div>
        {hint && <div className="text-xs text-gray-400 mt-0.5">{hint}</div>}
      </div>
      {type === 'toggle' ? (
        <label className="flex items-center cursor-pointer gap-2">
          <div
            className={`relative w-12 h-6 rounded-full transition-colors ${settings[settingKey] === 'true' ? 'bg-blue-500' : 'bg-gray-300 dark:bg-gray-600'}`}
            onClick={() => handleChange(settingKey, settings[settingKey] === 'true' ? 'false' : 'true')}
          >
            <div className={`absolute top-1 w-4 h-4 rounded-full bg-white shadow transition-all ${settings[settingKey] === 'true' ? 'left-7' : 'left-1'}`} />
          </div>
          <span className="text-sm">{settings[settingKey] === 'true' ? 'مفعّل' : 'معطّل'}</span>
        </label>
      ) : (
        <input
          type={type}
          value={settings[settingKey] || ''}
          onChange={e => handleChange(settingKey, e.target.value)}
          className="input w-56 text-left"
          dir={type === 'number' ? 'ltr' : 'rtl'}
        />
      )}
    </div>
  );

  return (
    <div className="space-y-6 max-w-3xl">
      <div className="flex items-center justify-between">
        <h1 className="page-title"><Sliders className="inline-block ml-2" size={24} />إعدادات النظام</h1>
        <button
          className="btn btn-primary flex items-center gap-2"
          onClick={() => save(settings)}
          disabled={saving || isLoading}
        >
          <Save size={16} /> {saving ? 'جاري الحفظ...' : 'حفظ الإعدادات'}
        </button>
      </div>

      {isLoading ? <div className="loading-spinner" /> : (
        <>
          {/* General Settings */}
          <div className="card">
            <h2 className="section-title mb-2 flex items-center gap-2"><Settings size={18} /> الإعدادات العامة</h2>
            <SettingRow label="اسم المنصة" settingKey="platform_name" hint="يظهر في الإشعارات وواجهات التطبيقات" />
            <SettingRow label="هاتف الدعم الفني" settingKey="support_phone" />
            <SettingRow label="البريد الإلكتروني للدعم" settingKey="support_email" />
            <SettingRow label="وضع الصيانة" settingKey="maintenance_mode" type="toggle" hint="عند التفعيل، تُوقف التطبيقات مؤقتاً" />
          </div>

          {/* Financial Settings */}
          <div className="card">
            <h2 className="section-title mb-2 flex items-center gap-2"><Settings size={18} /> الإعدادات المالية</h2>
            <SettingRow label="رسوم التوصيل الافتراضية (ج.س)" settingKey="delivery_fee_default" type="number" />
            <SettingRow label="الحد الأدنى للطلب (ج.س)" settingKey="min_order_amount" type="number" />
            <SettingRow label="عمولة المنصة (%)" settingKey="commission_percent" type="number" hint="نسبة من إيرادات المزود" />
            <SettingRow label="أيام النسخة التجريبية" settingKey="trial_days" type="number" />
          </div>

          {/* App Settings */}
          <div className="card">
            <h2 className="section-title mb-2 flex items-center gap-2"><Settings size={18} /> إعدادات التطبيقات</h2>
            <SettingRow label="أقصى نطاق توصيل (كم)" settingKey="max_delivery_radius_km" type="number" hint="الحد الأقصى للبحث عن المزودين" />
            <SettingRow label="السماح بالتسوق بدون حساب" settingKey="allow_guest_checkout" type="toggle" />
          </div>
        </>
      )}
    </div>
  );
}

