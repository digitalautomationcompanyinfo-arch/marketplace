import React, { useState } from 'react';
import { ChevronUp, ChevronDown, Search, Filter } from 'lucide-react';

/**
 * DataTable - World-class table with sort, search, pagination
 * Columns: [{ key, label, render?: fn, sortable?, width? }]
 */
export default function DataTable({
  columns = [],
  data = [],
  loading = false,
  totalRows = 0,
  page = 1,
  pageSize = 20,
  onPageChange,
  searchable = true,
  onSearch,
  searchPlaceholder = 'بحث...',
  emptyText = 'لا توجد بيانات',
  actions,             // component to render in top-right (buttons, filters)
  rowKey = 'id',
}) {
  const [sortKey, setSortKey]     = useState(null);
  const [sortDir, setSortDir]     = useState('asc');
  const [searchText, setSearch]   = useState('');

  const totalPages = Math.max(1, Math.ceil(totalRows / pageSize));

  const handleSort = (key) => {
    if (!key) return;
    if (sortKey === key) setSortDir(d => d === 'asc' ? 'desc' : 'asc');
    else { setSortKey(key); setSortDir('asc'); }
  };

  const handleSearch = (e) => {
    const v = e.target.value;
    setSearch(v);
    onSearch?.(v);
  };

  // Client-side fallback sort if no server sort
  const sortedData = [...data].sort((a, b) => {
    if (!sortKey) return 0;
    const va = a[sortKey] ?? '';
    const vb = b[sortKey] ?? '';
    if (va < vb) return sortDir === 'asc' ? -1 : 1;
    if (va > vb) return sortDir === 'asc' ? 1 : -1;
    return 0;
  });

  const SortIcon = ({ col }) => {
    if (!col.sortable) return null;
    return (
      <span style={{ display: 'inline-flex', flexDirection: 'column', marginRight: 4, opacity: sortKey === col.key ? 1 : 0.3 }}>
        <ChevronUp   size={10} style={{ marginBottom: -3, color: sortKey === col.key && sortDir === 'asc' ? 'var(--primary-light)' : undefined }} />
        <ChevronDown size={10} style={{ color: sortKey === col.key && sortDir === 'desc' ? 'var(--primary-light)' : undefined }} />
      </span>
    );
  };

  return (
    <div>
      {/* Toolbar */}
      {(searchable || actions) && (
        <div style={{ display: 'flex', gap: 12, marginBottom: 16, flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between' }}>
          {searchable && (
            <div className="search-bar" style={{ maxWidth: 320, flex: 1 }}>
              <Search size={16} className="search-icon" />
              <input
                value={searchText}
                onChange={handleSearch}
                placeholder={searchPlaceholder}
              />
            </div>
          )}
          {actions && <div style={{ display: 'flex', gap: 10 }}>{actions}</div>}
        </div>
      )}

      {/* Table */}
      <div className="table-wrapper">
        <table>
          <thead>
            <tr>
              {columns.map(col => (
                <th
                  key={col.key}
                  style={{ width: col.width, cursor: col.sortable ? 'pointer' : 'default', userSelect: 'none' }}
                  onClick={() => col.sortable && handleSort(col.key)}
                >
                  <span style={{ display: 'inline-flex', alignItems: 'center' }}>
                    {col.label}
                    <SortIcon col={col} />
                  </span>
                </th>
              ))}
            </tr>
          </thead>

          <tbody>
            {loading ? (
              Array.from({ length: 8 }).map((_, i) => (
                <tr key={i}>
                  {columns.map(col => (
                    <td key={col.key}>
                      <div className="skeleton" style={{ height: 16, borderRadius: 4, width: '70%' }} />
                    </td>
                  ))}
                </tr>
              ))
            ) : sortedData.length === 0 ? (
              <tr>
                <td colSpan={columns.length}>
                  <div className="empty-state">
                    <div style={{ fontSize: 40, marginBottom: 8 }}>📭</div>
                    <h3>{emptyText}</h3>
                  </div>
                </td>
              </tr>
            ) : (
              sortedData.map((row, ri) => (
                <tr key={row[rowKey] ?? ri}>
                  {columns.map(col => (
                    <td key={col.key}>
                      {col.render ? col.render(row[col.key], row) : (row[col.key] ?? '—')}
                    </td>
                  ))}
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 16, flexWrap: 'wrap', gap: 10 }}>
          <span style={{ fontSize: 13, color: 'var(--text-muted)' }}>
            صفحة {page} من {totalPages} | إجمالي {totalRows?.toLocaleString()} سجل
          </span>
          <div className="pagination">
            <button className="page-btn" disabled={page <= 1} onClick={() => onPageChange?.(page - 1)}>→</button>
            {Array.from({ length: Math.min(totalPages, 7) }, (_, i) => {
              const p = i + 1;
              return (
                <button key={p} className={`page-btn ${p === page ? 'active' : ''}`} onClick={() => onPageChange?.(p)}>
                  {p}
                </button>
              );
            })}
            <button className="page-btn" disabled={page >= totalPages} onClick={() => onPageChange?.(page + 1)}>←</button>
          </div>
        </div>
      )}
    </div>
  );
}

