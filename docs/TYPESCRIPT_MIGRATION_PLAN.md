# TypeScript Migration Plan
## مخطط الهجرة من JavaScript إلى TypeScript

---

## 📊 الحالة الحالية

- **اللغة**: JavaScript + JSDoc
- **هدف**: Full TypeScript Adoption
- **الأولوية**: Phase 1 (Critical Files) → Phase 2 (Services) → Phase 3 (All)

---

## 🎯 المرحلة الأولى: Critical Files (أسبوع 1)

### 1.1 Core Types Definition (`src/types/index.ts`)

```typescript
// User Types
export interface User {
  id: number;
  uuid: string;
  email: string;
  phone: string;
  password_hash: string;
  is_verified: boolean;
  is_active: boolean;
  is_deleted: boolean;
  wallet_balance: number;
  fcm_token?: string;
  created_at: Date;
  updated_at: Date;
}

export interface AdminUser {
  id: number;
  full_name: string;
  email: string;
  password_hash: string;
  role: 'super_admin' | 'admin' | 'moderator';
  is_active: boolean;
  two_factor_enabled: boolean;
  two_factor_secret?: string;
  session_version: number;
  last_login?: Date;
  token_invalidated_at?: Date;
}

export interface Provider {
  id: number;
  uuid: string;
  provider_type: 'individual' | 'shop' | 'company';
  business_name: string;
  owner_name: string;
  category_id: number;
  verification_status: 'pending' | 'approved' | 'rejected';
  wallet_balance: number;
  subscription_expires?: Date;
  commission_rate: number;
}

export interface Order {
  id: number;
  uuid: string;
  user_id: number;
  provider_id: number;
  status: OrderStatus;
  total_amount: number;
  commission_amount: number;
  payout_status: PayoutStatus;
  payment_method: 'wallet' | 'card' | 'bank';
  created_at: Date;
}

export type OrderStatus = 
  | 'pending'
  | 'accepted'
  | 'processing'
  | 'out_for_delivery'
  | 'delivered'
  | 'cancelled';

export type PayoutStatus = 
  | 'pending'
  | 'paid'
  | 'held'
  | 'refunded'
  | 'cancelled';

// Error Handling
export interface AppErrorOptions {
  message: string;
  statusCode: number;
  isOperational?: boolean;
}

export class AppError extends Error {
  statusCode: number;
  isOperational: boolean;
  
  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
  }
}

// JWT Claims
export interface JWTPayload {
  id: number;
  type: 'user' | 'provider' | 'admin';
  role?: 'super_admin' | 'admin' | 'moderator';
  email?: string;
  iat: number;
  exp: number;
}

// Database
export interface QueryResult<T = any> {
  rows: T[];
  rowCount: number;
}

// Request Extensions
export interface AuthenticatedRequest {
  user?: User;
  provider?: Provider;
  admin?: AdminUser;
  ip: string;
}

// Pagination
export interface PaginationParams {
  page: number;
  limit: number;
  offset: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    total: number;
    page: number;
    limit: number;
    pages: number;
  };
}
```

### 1.2 Middleware Files to Convert

**Priority Order:**

1. **auth.middleware.ts** - Core authentication
2. **errorHandler.ts** - Error handling pipeline
3. **security.middleware.ts** - Security layer

```typescript
// Example: auth.middleware.ts

import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { query } from '../config/database';
import { AppError } from '../types';

declare global {
  namespace Express {
    interface Request {
      user?: any;
      admin?: any;
      provider?: any;
    }
  }
}

export const protect = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');
    
    if (!token) {
      throw new AppError('No token provided', 401);
    }

    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET!
    ) as any;

    req.user = await query(
      'SELECT * FROM users WHERE id = $1',
      [decoded.id]
    );

    next();
  } catch (error) {
    next(new AppError('Unauthorized', 401));
  }
};
```

---

## 🎯 المرحلة الثانية: Services (أسبوع 2-3)

### 2.1 Service Files to Convert

1. **auth.service.ts** - Authentication logic
2. **payment.service.ts** - Payment handling
3. **firebase.service.ts** - Firebase integration
4. **notification.service.ts** - Notifications

### 2.2 Example: auth.service.ts

```typescript
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { query } from '../config/database';
import { AppError, User, JWTPayload } from '../types';

export class AuthService {
  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 12);
  }

  async comparePasswords(
    password: string,
    hash: string
  ): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  async generateToken(
    userId: number,
    type: string,
    expiresIn: string = '24h'
  ): Promise<string> {
    const payload: JWTPayload = {
      id: userId,
      type: type as any,
      iat: Math.floor(Date.now() / 1000),
      exp: 0, // Will be set by jwt.sign
    };

    return jwt.sign(payload, process.env.JWT_SECRET!, {
      expiresIn,
    });
  }

  async verifyToken(token: string): Promise<JWTPayload> {
    return jwt.verify(
      token,
      process.env.JWT_SECRET!
    ) as JWTPayload;
  }
}
```

---

## 🎯 المرحلة الثالثة: Controllers (أسبوع 4-5)

### 3.1 Controller Files to Convert

1. **auth.controller.ts**
2. **admin.controller.ts**
3. **user.controller.ts**
4. **provider.controller.ts**

---

## 📋 Checklist للهجرة

### Phase 1: Setup
- [ ] Install TypeScript compiler
- [ ] Create `tsconfig.json`
- [ ] Create type definitions
- [ ] Update `package.json` with build scripts

### Phase 2: Critical Files
- [ ] Convert types
- [ ] Convert middleware
- [ ] Convert utilities
- [ ] Test middleware

### Phase 3: Services
- [ ] Convert auth service
- [ ] Convert payment service
- [ ] Convert notification service
- [ ] Add service tests

### Phase 4: Controllers
- [ ] Convert controllers one by one
- [ ] Update routes
- [ ] Add controller tests

### Phase 5: Complete
- [ ] Update all imports
- [ ] Run full test suite
- [ ] Update documentation

---

## ⚙️ Build Configuration

### tsconfig.json

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "moduleResolution": "node",
    "allowSyntheticDefaultImports": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist", "tests"]
}
```

### package.json Scripts

```json
{
  "scripts": {
    "build": "tsc",
    "dev": "tsc && node dist/server.js",
    "watch": "tsc --watch",
    "test": "jest --config jest.config.js",
    "type-check": "tsc --noEmit",
    "lint": "eslint src --ext .ts"
  }
}
```

---

## 🛠️ Dependencies to Add

```bash
npm install --save-dev typescript @types/node @types/express
npm install --save-dev ts-node ts-loader
npm install --save-dev eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin
npm install --save-dev @types/jest ts-jest
```

---

## 📊 Migration Timeline

| Phase | Week | Tasks | Status |
|-------|------|-------|--------|
| 1 | Week 1 | Setup + Types | ⏳ Not Started |
| 2 | Week 2 | Middleware + Utils | ⏳ Not Started |
| 3 | Week 3-4 | Services | ⏳ Not Started |
| 4 | Week 5-6 | Controllers | ⏳ Not Started |
| 5 | Week 7 | Complete + Test | ⏳ Not Started |

**Estimated Total Time: 6-7 weeks**
**Effort: 120-150 hours**

---

## ✅ Success Criteria

- [ ] All files converted to TypeScript
- [ ] No `any` types (except where necessary)
- [ ] 100% type coverage
- [ ] All tests passing
- [ ] Zero TypeScript compilation errors
- [ ] Performance maintained or improved

