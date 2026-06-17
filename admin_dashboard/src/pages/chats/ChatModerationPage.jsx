import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { MessageSquare, Trash2, AlertTriangle, Filter } from 'lucide-react';
import api from '../../services/api';
import { Badge } from '../../components/ui/Badge';
import toast from 'react-hot-toast';

export default function ChatModerationPage() {
  const qc = useQueryClient();
  const [flaggedOnly, setFlaggedOnly] = useState(false);

  const { data: chats = [], isLoading } = useQuery({
    queryKey: ['admin-chats', flaggedOnly],
    queryFn: () => api.get('/admin/chats', { params: { flagged: flaggedOnly } }).then(r => r.data.data),
  });

  const { mutate: delMsg } = useMutation({
    mutationFn: (id) => api.delete(`/admin/chats/messages/${id}`),
    onSuccess: () => { qc.invalidateQueries(['admin-chats']); toast.success('تم حذف الرسالة'); },
    onError: () => toast.error('فشل في حذف الرسالة'),
  });

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="page-title">
          <MessageSquare className="inline-block ml-2" size={24} />إشراف على المحادثات
        </h1>
        <label className="flex items-center gap-2 cursor-pointer">
          <Filter size={16} className="text-gray-400" />
          <span className="text-sm text-gray-400">الرسائل المُبلَّغ عنها فقط</span>
          <input
            type="checkbox"
            checked={flaggedOnly}
            onChange={e => setFlaggedOnly(e.target.checked)}
            className="w-4 h-4 accent-blue-600"
          />
        </label>
      </div>

      {isLoading ? <div className="loading-spinner" /> : (
        <div className="grid gap-4">
          {chats.map(chat => (
            <div key={chat.conversation_id} className="card">
              <div className="flex items-start justify-between">
                <div>
                  <div className="font-semibold text-lg">{chat.customer_name} ↔ {chat.provider_name}</div>
                  <div className="text-sm text-gray-400 mt-1">
                    آخر رسالة: {chat.last_message ? new Date(chat.last_message).toLocaleString('ar-SD') : 'لا توجد'}
                  </div>
                  <div className="flex gap-3 mt-2">
                    <Badge color="blue">{chat.total_messages} رسالة</Badge>
                    {chat.flagged_count > 0 && (
                      <Badge color="red"><AlertTriangle size={12} className="inline ml-1" />{chat.flagged_count} مُبلَّغ عنها</Badge>
                    )}
                  </div>
                </div>
                <button
                  className="btn btn-ghost text-red-400 hover:text-red-600 flex items-center gap-1 text-sm"
                  onClick={() => {
                    if (window.confirm('هل أنت متأكد من حذف هذه المحادثة؟')) {
                      delMsg(chat.conversation_id);
                    }
                  }}
                >
                  <Trash2 size={16} /> حذف
                </button>
              </div>
            </div>
          ))}
          {chats.length === 0 && (
            <div className="empty-state">
              <MessageSquare size={48} />
              <p>{flaggedOnly ? 'لا توجد رسائل مُبلَّغ عنها' : 'لا توجد محادثات'}</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

