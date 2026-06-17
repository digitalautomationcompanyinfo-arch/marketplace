import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Package, Clock, CheckCircle, XCircle, Truck, Filter } from 'lucide-react';
import api from '../../services/api';
import { Badge } from '../../components/ui/Badge';
import toast from 'react-hot-toast';

const STATUS_OPTIONS = ['pending', 'accepted', 'processing', 'out_for_delivery', 'delivered', 'cancelled'];
const STATUS_LABELS = {
  pending: 'في الانتظار', accepted: 'مقبول', processing: 'جاري التحضير',
  out_for_delivery: 'في الطريق', delivered: 'تم التوصيل', cancelled: 'ملغى',
};
const STATUS_COLORS = {
  pending: 'yellow', accepted: 'blue', processing: 'orange',
  out_for_delivery: 'purple', delivered: 'green', cancelled: 'red',
};

export default function OrdersPage() {
  const qc = useQueryClient();
  const [filters, setFilters] = useState({ status: '', page: 1 });

  const { data, isLoading } = useQuery({
    queryKey: ['admin-orders', filters],
    queryFn: () => api.get('/admin/orders', { params: filters }).then(r => r.data),
  });

  const { mutate: changeStatus } = useMutation({
    mutationFn: ({ id, status }) => api.patch(`/admin/orders/${id}/status`, { status }),
    onSuccess: () => { qc.invalidateQueries(['admin-orders']); toast.success('تم تحديث حالة الطلب'); },
    onError: () => toast.error('فشل في تحديث الحالة'),
  });

  const orders = data?.data || [];
  const pagination = data?.pagination || {};

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="page-title"><Package className="inline-block ml-2" size={24} />إدارة الطلبات</h1>
        <div className="flex gap-3 items-center">
          <Filter size={18} className="text-gray-400" />
          <select
            className="input w-48"
            value={filters.status}
            onChange={e => setFilters(f => ({ ...f, status: e.target.value, page: 1 }))}
          >
            <option value="">كل الحالات</option>
            {STATUS_OPTIONS.map(s => <option key={s} value={s}>{STATUS_LABELS[s]}</option>)}
          </select>
        </div>
      </div>

      {isLoading ? (
        <div className="loading-spinner" />
      ) : (
        <div className="card overflow-hidden">
          <table className="data-table w-full">
            <thead>
              <tr>
                <th>رقم الطلب</th>
                <th>العميل</th>
                <th>المزود</th>
                <th>المبلغ</th>
                <th>الحالة</th>
                <th>التاريخ</th>
                <th>إجراء</th>
              </tr>
            </thead>
            <tbody>
              {orders.map(order => (
                <tr key={order.id}>
                  <td className="font-mono text-sm">#{order.uuid?.slice(-6) || order.id}</td>
                  <td>
                    <div className="font-semibold">{order.customer_name}</div>
                    <div className="text-xs text-gray-400">{order.customer_phone}</div>
                  </td>
                  <td>{order.provider_name}</td>
                  <td className="font-bold text-green-600">{parseFloat(order.total_amount || 0).toFixed(2)} ج.س</td>
                  <td>
                    <Badge color={STATUS_COLORS[order.status]}>{STATUS_LABELS[order.status] || order.status}</Badge>
                  </td>
                  <td className="text-sm text-gray-400">
                    {new Date(order.created_at).toLocaleDateString('ar-SD')}
                  </td>
                  <td>
                    <select
                      className="input text-sm py-1 px-2"
                      value={order.status}
                      onChange={e => changeStatus({ id: order.id, status: e.target.value })}
                    >
                      {STATUS_OPTIONS.map(s => <option key={s} value={s}>{STATUS_LABELS[s]}</option>)}
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {orders.length === 0 && (
            <div className="empty-state"><Package size={48} /><p>لا توجد طلبات</p></div>
          )}
        </div>
      )}

      {/* Pagination */}
      {pagination.pages > 1 && (
        <div className="flex justify-center gap-2">
          {Array.from({ length: pagination.pages }, (_, i) => i + 1).map(p => (
            <button
              key={p}
              className={`btn ${p === filters.page ? 'btn-primary' : 'btn-ghost'} px-3 py-1 text-sm`}
              onClick={() => setFilters(f => ({ ...f, page: p }))}
            >{p}</button>
          ))}
        </div>
      )}
    </div>
  );
}

