# Performance & Optimization Roadmap
## خارطة الطريق لتحسين الأداء والتوسعية

---

## 📊 حالة الأداء الحالية

### Metrics القاعدية

| Metric | Current | Target | Priority |
|--------|---------|--------|----------|
| API Response Time | 150-300ms | <100ms | High |
| Search Query Time | 200ms | <50ms | High |
| Database Pool | 50 connections | 100-200 | Medium |
| Redis Hit Rate | 60% | 75%+ | Medium |
| Memory Usage | Monitored | <2GB | Low |
| CPU Utilization | Monitored | <70% avg | Low |

---

## 🚀 التحسينات المقترحة

### 1. Database Query Optimization

#### 1.1 N+1 Query Problem Detection

**Current Issue**: Orders endpoint fetches provider separately for each order

```javascript
// ❌ BEFORE: N+1 Problem
const orders = await query('SELECT * FROM orders WHERE user_id = $1', [userId]);
for (let order of orders.rows) {
  const provider = await query('SELECT * FROM providers WHERE id = $1', [order.provider_id]);
  order.provider = provider.rows[0];
}

// ✅ AFTER: Optimized JOIN
const orders = await query(`
  SELECT 
    o.*,
    p.business_name,
    p.rating_avg,
    p.images
  FROM orders o
  LEFT JOIN providers p ON o.provider_id = p.id
  WHERE o.user_id = $1
  ORDER BY o.created_at DESC
`, [userId]);
```

**Implementation Plan**:
- [ ] Audit all endpoints for N+1 patterns
- [ ] Create JOIN-based queries
- [ ] Add database query logging
- [ ] Test performance improvements

#### 1.2 Query Plan Analysis

```bash
# Run EXPLAIN ANALYZE on slow queries
EXPLAIN ANALYZE
SELECT * FROM products 
WHERE category_id = 5 
AND is_available = true
ORDER BY rating_avg DESC
LIMIT 20;

# Expected: <50ms with proper indexes
```

#### 1.3 Missing Indexes

**Recommended Indexes**:

```sql
-- Search optimization
CREATE INDEX idx_products_search ON products 
USING GIN (to_tsvector('arabic', name || ' ' || description));

-- Status queries
CREATE INDEX idx_orders_status_date ON orders(status, created_at DESC) 
WHERE is_deleted = false;

-- Geospatial queries
CREATE INDEX idx_providers_location ON providers 
USING GIST (location)
WHERE verification_status = 'approved';

-- Wallet transactions
CREATE INDEX idx_wallet_user_date ON wallet_transactions(user_id, created_at DESC);

-- Ratings aggregation
CREATE INDEX idx_reviews_provider_rating ON reviews(provider_id, rating) 
WHERE is_deleted = false;
```

---

### 2. Caching Strategy Enhancement

#### 2.1 Current Redis Usage

```
- User profiles: 5-minute TTL
- Provider listings: 15-minute TTL  
- Search results: 1-hour TTL
- Category data: 24-hour TTL
```

#### 2.2 Proposed Caching Layers

```javascript
// Multi-tier caching strategy
const getCachedProvider = async (providerId) => {
  // L1: In-memory cache (app instance)
  if (memoryCache.has(`provider:${providerId}`)) {
    return memoryCache.get(`provider:${providerId}`);
  }

  // L2: Redis (distributed)
  const redisKey = `provider:${providerId}`;
  let provider = await redis.get(redisKey);
  
  if (!provider) {
    // L3: Database
    provider = await query(
      'SELECT * FROM providers WHERE id = $1',
      [providerId]
    );
    
    // Cache back up the layers
    await redis.setex(redisKey, 300, JSON.stringify(provider)); // 5min
    memoryCache.set(`provider:${providerId}`, provider);
  }

  return provider;
};
```

#### 2.3 Cache Invalidation Events

```javascript
// Event-driven cache invalidation
const EventEmitter = require('events');
const cacheInvalidator = new EventEmitter();

// When provider updates
cacheInvalidator.on('provider:updated', async (providerId) => {
  await redis.del(`provider:${providerId}`);
  memoryCache.delete(`provider:${providerId}`);
  
  // Also invalidate related caches
  await redis.del(`provider:products:${providerId}`);
  await redis.del(`provider:reviews:${providerId}`);
});

// Usage in provider update controller
await cacheInvalidator.emit('provider:updated', providerId);
```

#### 2.4 Cache Hit Rate Monitoring

```javascript
const cacheStats = {
  hits: 0,
  misses: 0,
  
  getHitRate() {
    const total = this.hits + this.misses;
    return total > 0 ? (this.hits / total) * 100 : 0;
  },
  
  getStats() {
    return {
      hits: this.hits,
      misses: this.misses,
      hitRate: `${this.getHitRate().toFixed(2)}%`,
      target: '75%'
    };
  }
};

// Log cache stats every 5 minutes
setInterval(() => {
  logger.info('Cache Stats:', cacheStats.getStats());
}, 5 * 60 * 1000);
```

---

### 3. Connection Pooling Optimization

#### 3.1 Current Configuration

```javascript
// Currently: 50 connections
const pool = new Pool({
  max: 50,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});
```

#### 3.2 Recommended Configuration

```javascript
// Based on concurrent users estimation
const pool = new Pool({
  max: 150,              // Peak concurrent connections
  min: 20,               // Always keep warm
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
  
  // Connection validation
  query_timeout: 10000,   // Kill queries > 10s
  idle_in_transaction_session_timeout: 60000,
  
  // Monitoring
  connectionStatusCallback: (err, client) => {
    if (err) {
      logger.error('Pool connection error:', err);
    }
  }
});
```

#### 3.3 Connection Pool Monitoring

```javascript
setInterval(() => {
  const poolStatus = {
    total: pool.totalCount,
    idle: pool.idleCount,
    waiting: pool.waitingCount,
    utilization: `${((pool.totalCount - pool.idleCount) / pool.totalCount * 100).toFixed(2)}%`
  };
  
  logger.info('Pool Status:', poolStatus);
  
  // Alert if >90% utilization
  if (poolStatus.utilization > 90) {
    logger.alertCritical(
      new Error('Database pool near capacity'),
      poolStatus
    );
  }
}, 60000); // Every minute
```

---

### 4. API Response Optimization

#### 4.1 Response Compression

```javascript
// Enable gzip compression for all responses
const compression = require('compression');
app.use(compression({
  level: 6,          // Balance: 1 (fast) to 9 (best compression)
  threshold: 1000,   // Only compress >1KB
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  }
}));
```

#### 4.2 Pagination Optimization

```javascript
// Replace offset-based with cursor-based pagination
// Current: ?page=2&limit=20 → OFFSET 40
// Proposed: ?cursor=abc123def&limit=20 (faster for large datasets)

const getCursorPaginatedOrders = async (userId, cursor = null, limit = 20) => {
  let query = `
    SELECT * FROM orders 
    WHERE user_id = $1
  `;
  
  const params = [userId];
  
  if (cursor) {
    query += ` AND id < $2`;
    params.push(cursor);
  }
  
  query += ` ORDER BY id DESC LIMIT $${params.length + 1}`;
  params.push(limit + 1);
  
  const result = await query(query, params);
  const hasMore = result.rows.length > limit;
  
  return {
    data: result.rows.slice(0, limit),
    nextCursor: hasMore ? result.rows[limit - 1].id : null,
    hasMore
  };
};
```

#### 4.3 Response Field Filtering

```javascript
// Allow clients to select only needed fields
// /api/users?fields=id,email,wallet_balance

const selectFields = (data, fields) => {
  if (!fields) return data;
  
  const fieldList = fields.split(',').map(f => f.trim());
  
  if (Array.isArray(data)) {
    return data.map(item => 
      fieldList.reduce((obj, field) => {
        obj[field] = item[field];
        return obj;
      }, {})
    );
  }
  
  return fieldList.reduce((obj, field) => {
    obj[field] = data[field];
    return obj;
  }, {});
};
```

---

### 5. Backend Performance Monitoring

#### 5.1 Slow Query Logging

```javascript
// Log all queries >500ms
const logSlowQuery = (duration, sql, params) => {
  if (duration > 500) {
    logger.warn('🐢 Slow Query', {
      duration: `${duration}ms`,
      sql: sql.substring(0, 100) + '...',
      params: params.length
    });
  }
};
```

#### 5.2 Request Duration Tracking

```javascript
// Already implemented: perfLogger middleware
app.use((req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = Date.now() - start;
    
    if (duration > 500) {
      logger.warn(`⏱️ Slow request: ${req.method} ${req.path} (${duration}ms)`);
    }
    
    // Track in metrics system
    metrics.recordRequest(req.method, req.path, duration, res.statusCode);
  });
  
  next();
});
```

#### 5.3 Error Rate Monitoring

```javascript
const errorMetrics = {
  '4xx': 0,
  '5xx': 0,
  
  track(statusCode) {
    if (statusCode >= 400 && statusCode < 500) this['4xx']++;
    if (statusCode >= 500) this['5xx']++;
  },
  
  getErrorRate() {
    const total = this['4xx'] + this['5xx'];
    return {
      errors: total,
      rate_4xx: this['4xx'],
      rate_5xx: this['5xx']
    };
  }
};

// Alert if 5xx > 5% of requests
setInterval(() => {
  const rate = errorMetrics.getErrorRate();
  if (rate.rate_5xx > 50) { // Assuming 1000 requests tracked
    logger.alertCritical(
      new Error('High 5xx error rate detected'),
      rate
    );
  }
}, 60000);
```

---

### 6. Frontend Optimization (React Admin Dashboard)

#### 6.1 Code Splitting

```javascript
// Instead of loading all routes at once
import { lazy, Suspense } from 'react';

const Dashboard = lazy(() => import('./pages/Dashboard'));
const Providers = lazy(() => import('./pages/Providers'));
const Orders = lazy(() => import('./pages/Orders'));

const AppRouter = () => (
  <Suspense fallback={<LoadingSpinner />}>
    <Routes>
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/providers" element={<Providers />} />
      <Route path="/orders" element={<Orders />} />
    </Routes>
  </Suspense>
);
```

#### 6.2 Image Optimization

```javascript
// Use Next.js Image or react-lazyload
import LazyLoad from 'react-lazyload';

const ProviderImage = ({ src, alt }) => (
  <LazyLoad height={200} offset={100}>
    <img 
      src={src} 
      alt={alt}
      loading="lazy"
      style={{ width: '100%', height: 'auto' }}
    />
  </LazyLoad>
);
```

#### 6.3 React Query Optimization

```javascript
// Optimize stale time and caching
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5,    // 5 minutes
      cacheTime: 1000 * 60 * 10,   // 10 minutes
      retry: 2,
      retryDelay: (attempt) => Math.min(1000 * 2 ** attempt, 30000),
    },
  },
});
```

---

## 📊 Success Metrics

| Metric | Before | After | Timeline |
|--------|--------|-------|----------|
| API Response Time | 250ms avg | <100ms | Week 2-3 |
| Search Time | 200ms | <50ms | Week 2 |
| Cache Hit Rate | 60% | 75%+ | Week 1 |
| DB Connections | 50 | 150 (optimized) | Week 1 |
| Page Load Time | 3s | <1.5s | Week 3 |
| Error Rate | Monitor | <1% | Ongoing |

---

## ✅ Implementation Checklist

- [ ] Database query optimization (N+1 fixes)
- [ ] Index creation for slow queries
- [ ] Cache strategy implementation
- [ ] Connection pool tuning
- [ ] API response field filtering
- [ ] Cursor-based pagination
- [ ] Performance monitoring dashboard
- [ ] Frontend code splitting
- [ ] Image optimization
- [ ] Load testing (k6 or Apache JMeter)

---

## 🎯 Load Testing Strategy

```javascript
// k6 load test script
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 },
    { duration: '5m', target: 100 },
    { duration: '2m', target: 200 },
    { duration: '5m', target: 200 },
    { duration: '2m', target: 0 },
  ],
};

export default function () {
  const res = http.get('https://api.marketplace.com/providers?limit=20');
  
  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 200ms': (r) => r.timings.duration < 200,
  });
  
  sleep(1);
}
```

---

**Estimated Timeline: 3-4 weeks for all optimizations**
**Expected Performance Gain: 60-70% improvement in response times**

