import React, { useEffect } from 'react';
import { X } from 'lucide-react';

/**
 * Modal component
 * Usage: <Modal open={open} onClose={() => setOpen(false)} title="..." size="md">
 *          <p>Content</p>
 *        </Modal>
 */
export default function Modal({ open, onClose, title, children, size = 'md', footer, hideClose = false }) {
  // Close on ESC key
  useEffect(() => {
    if (!open) return;
    const handler = (e) => { if (e.key === 'Escape') onClose?.(); };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [open, onClose]);

  // Prevent body scroll
  useEffect(() => {
    document.body.style.overflow = open ? 'hidden' : '';
    return () => { document.body.style.overflow = ''; };
  }, [open]);

  if (!open) return null;

  const widthMap = { sm: 420, md: 600, lg: 800, xl: 1000 };
  const maxWidth = widthMap[size] || 600;

  return (
    <div
      className="modal-backdrop"
      onClick={(e) => { if (e.target === e.currentTarget) onClose?.(); }}
    >
      <div className="modal fade-in" style={{ maxWidth }}>
        <div className="modal-header">
          <h3 className="modal-title">{title}</h3>
          {!hideClose && (
            <button
              onClick={onClose}
              className="btn btn-ghost btn-icon"
              style={{ color: 'var(--text-muted)' }}
            >
              <X size={18} />
            </button>
          )}
        </div>

        <div className="modal-body">{children}</div>

        {footer && (
          <div className="modal-footer">{footer}</div>
        )}
      </div>
    </div>
  );
}

/** Confirmation modal shorthand */
export function ConfirmModal({ open, onClose, onConfirm, title, message, confirmText = 'تأكيد', confirmVariant = 'danger', loading = false }) {
  return (
    <Modal
      open={open}
      onClose={onClose}
      title={title}
      size="sm"
      footer={
        <>
          <button className="btn btn-ghost" onClick={onClose} disabled={loading}>إلغاء</button>
          <button
            className={`btn btn-${confirmVariant}`}
            onClick={onConfirm}
            disabled={loading}
          >
            {loading ? <span className="spinner" /> : confirmText}
          </button>
        </>
      }
    >
      <p style={{ color: 'var(--text-secondary)', fontSize: 15, lineHeight: 1.7 }}>{message}</p>
    </Modal>
  );
}

