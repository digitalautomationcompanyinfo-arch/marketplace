import React from 'react';

/**
 * Badge component
 * Usage: <Badge variant="success">مفعّل</Badge>
 */
export function Badge({ children, variant = 'muted', size = 'sm' }) {
  const sizes = { sm: '12px 10px 2px 10px', md: '5px 12px' };
  return (
    <span
      className={`badge badge-${variant}`}
      style={{ padding: sizes[size] }}
    >
      {children}
    </span>
  );
}

/** Status badge for provider verification */
export function StatusBadge({ status }) {
  const map = {
    approved: { label: 'معتمد',   variant: 'success' },
    pending:  { label: 'انتظار', variant: 'warning' },
    rejected: { label: 'مرفوض',  variant: 'danger'  },
    active:   { label: 'نشط',    variant: 'success' },
    inactive: { label: 'موقوف',  variant: 'danger'  },
    expired:  { label: 'منتهي',  variant: 'muted'   },
  };
  const cfg = map[status] || { label: status, variant: 'muted' };
  return <Badge variant={cfg.variant}>{cfg.label}</Badge>;
}

/** Role badge */
export function RoleBadge({ role }) {
  const map = {
    super_admin: { label: 'مدير عام',  variant: 'danger'  },
    admin:       { label: 'مدير',      variant: 'primary' },
    moderator:   { label: 'مشرف',      variant: 'info'    },
    provider:    { label: 'مزود',      variant: 'purple'  },
    user:        { label: 'مستخدم',    variant: 'muted'   },
  };
  const cfg = map[role] || { label: role, variant: 'muted' };
  return <Badge variant={cfg.variant}>{cfg.label}</Badge>;
}

/** Simple dot indicator */
export function DotIndicator({ active, label }) {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 6, fontSize: 13 }}>
      <span style={{
        width: 8, height: 8, borderRadius: '50%',
        background: active ? 'var(--accent)' : 'var(--text-muted)',
        display: 'inline-block',
      }} />
      {label ?? (active ? 'نشط' : 'غير نشط')}
    </span>
  );
}

