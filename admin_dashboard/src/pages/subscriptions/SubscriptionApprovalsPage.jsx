import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../services/api';
import { CheckCircle, XCircle, Clock, Eye, Download, Search } from 'lucide-react';
import toast from 'react-hot-toast';

export default function SubscriptionApprovalsPage() {
  const queryClient = useQueryClient();
  const [selectedReceipt, setSelectedReceipt] = useState(null);

  // Fetch pending subscriptions
  const { data: pending, isLoading } = useQuery({
    queryKey: ['pending-subscriptions'],
    queryFn: () => api.get('/admin/subscriptions/pending').then(r => r.data.data),
  });

  const resolveMutation = useMutation({
    mutationFn: ({ id, action, note }) => api.post(`/admin/subscriptions/${id}/resolve`, { action, note }),
    onSuccess: () => {
      queryClient.invalidateQueries(['pending-subscriptions']);
      toast.success('تمت معالجة الطلب بنجاح');
      setSelectedReceipt(null);
    },
    onError: (err) => toast.error(err.response?.data?.message || 'فشلت المعالجة')
  });

  const handleResolve = (id, action) => {
    const note = window.prompt(action === 'approve' ? 'ملاحظة إضافية للمزود (اختياري):' : 'سبب الرفض:');
    if (action === 'reject' && !note) return;
    resolveMutation.mutate({ id, action, note });
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">اعتمادات الاشتراكات (التحصيل اليدوي)</h1>
          <p className="text-gray-500 text-sm">مراجعة إيصالات التحويل البنكي وتفعيل حسابات المزودين</p>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-right">
            <thead>
              <tr className="bg-gray-50 text-gray-400 text-xs font-medium uppercase tracking-wider border-b">
                <th className="px-6 py-3">المزود / المتجر</th>
                <th className="px-6 py-3">الباقة</th>
                <th className="px-6 py-3">المبلغ المدفوع</th>
                <th className="px-6 py-3">الإيصال</th>
                <th className="px-6 py-3">الوقت</th>
                <th className="px-6 py-3"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {isLoading ? (
                <tr><td colSpan="6" className="p-10 text-center">جاري التحميل...</td></tr>
              ) : pending?.length === 0 ? (
                <tr><td colSpan="6" className="p-10 text-center text-gray-400">لا توجد طلبات معلقة حالياً</td></tr>
              ) : pending?.map(sub => (
                <tr key={sub.id} className="hover:bg-gray-50 transition-colors">
                  <td className="px-6 py-4">
                    <div className="text-sm font-bold text-gray-900">{sub.business_name}</div>
                    <div className="text-xs text-gray-500">{sub.provider_phone}</div>
                  </td>
                  <td className="px-6 py-4 text-sm font-medium text-blue-600">
                    {sub.plan_name}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-bold text-green-700">{Number(sub.amount_paid).toLocaleString()} ج.س</div>
                    <div className="text-[10px] text-gray-400">تحويل بنكي</div>
                  </td>
                  <td className="px-6 py-4">
                    <button 
                      onClick={() => setSelectedReceipt(sub)}
                      className="p-1.5 bg-gray-100 rounded-lg hover:bg-gray-200 transition-colors"
                    >
                      <Eye size={18} className="text-gray-600" />
                    </button>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {new Date(sub.created_at).toLocaleString('ar-SD')}
                  </td>
                  <td className="px-6 py-4 text-left">
                    <div className="flex gap-2">
                       <button 
                        onClick={() => handleResolve(sub.uuid, 'approve')}
                        className="p-2 bg-green-50 text-green-600 rounded-lg border border-green-200 hover:bg-green-100"
                        title="موافقة"
                      >
                        <CheckCircle size={18} />
                      </button>
                      <button 
                        onClick={() => handleResolve(sub.uuid, 'reject')}
                        className="p-2 bg-red-50 text-red-600 rounded-lg border border-red-200 hover:bg-red-100"
                        title="رفض"
                      >
                        <XCircle size={18} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* MODAL: Preview Receipt */}
      {selectedReceipt && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm">
          <div className="bg-white rounded-2xl w-full max-w-2xl overflow-hidden shadow-2xl animate-in zoom-in-95 duration-200">
            <div className="p-4 border-b flex justify-between items-center">
              <h3 className="font-bold text-gray-800">إشعار التحويل - {selectedReceipt.business_name}</h3>
              <button onClick={() => setSelectedReceipt(null)} className="p-1 hover:bg-gray-100 rounded-full">
                <XCircle size={24} className="text-gray-400" />
              </button>
            </div>
            <div className="p-6 flex flex-col items-center">
              <img 
                src={`${import.meta.env.VITE_API_URL || 'http://localhost:5000'}/${selectedReceipt.payment_receipt}`}
                className="max-h-[60vh] rounded-lg shadow-inner object-contain"
                alt="Receipt"
              />
              <div className="mt-6 flex gap-4 w-full">
                 <button 
                  onClick={() => handleResolve(selectedReceipt.uuid, 'approve')}
                  className="flex-1 py-3 bg-green-600 text-white rounded-xl font-bold hover:bg-green-700 shadow-lg shadow-green-200"
                >
                  اعتماد الدفع وتنشيط الحساب
                </button>
                <button 
                   onClick={() => handleResolve(selectedReceipt.uuid, 'reject')}
                  className="px-6 py-3 bg-red-50 text-red-600 rounded-xl font-bold hover:bg-red-100"
                >
                  رفض الإيصال
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
