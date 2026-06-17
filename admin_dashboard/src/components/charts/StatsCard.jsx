import React from 'react';
import { TrendingUp, TrendingDown } from 'lucide-react';

/**
 * StatsCard - World-class KPI card component
 * Usage: <StatsCard label="المستخدمون" value="1,234" change="+12%" variant="primary" icon={<Users />} />
 */
export default function StatsCard({
  label,
  value,
  change,
  changeLabel = 'من الشهر الماضي',
  variant = 'primary',
  icon,
  subValue,
  onClick,
  loading = false,
}) {
  const isUp = change && !change.startsWith('-');

  if (loading) {
    return (
      <div className="stat-card" style={{ cursor: 'default' }}>
        <div className="skeleton" style={{ width: 52, height: 52, borderRadius: 8, flexShrink: 0 }} />
        <div style={{ flex: 1 }}>
          <div className="skeleton" style={{ width: 80, height: 12, marginBottom: 10 }} />
          <div className="skeleton" style={{ width: 120, height: 28, marginBottom: 8 }} />
          <div className="skeleton" style={{ width: 100, height: 12 }} />
        </div>
      </div>
    );
  }

  return (
    <div
      className={`stat-card ${variant}`}
      onClick={onClick}
      style={{ cursor: onClick ? 'pointer' : 'default' }}
    >
      {icon && (
        <div className={`stat-icon ${variant}`}>
          {icon}
        </div>
      )}

      <div style={{ flex: 1, minWidth: 0 }}>
        <div className="stat-label">{label}</div>
        <div className="stat-value">{value ?? '—'}</div>

        {subValue && (
          <div style={{ fontSize: 12, color: 'var(--text-muted)', marginBottom: 4 }}>{subValue}</div>
        )}

        {change && (
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 4 }}>
            <span className={`stat-change ${isUp ? 'up' : 'down'}`}>
              {isUp
                ? <TrendingUp size={11} />
                : <TrendingDown size={11} />}
              {change}
            </span>
            <span style={{ fontSize: 11, color: 'var(--text-muted)' }}>{changeLabel}</span>
          </div>
        )}
      </div>
    </div>
  );
}

