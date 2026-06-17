// LoginPage.jsx
import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../../store/authStore';
import { Store, Eye, EyeOff } from 'lucide-react';
import toast from 'react-hot-toast';
import api from '../../services/api';

export default function LoginPage() {
  const [email, setEmail] = useState('admin@marketplace.com');
  const [password, setPassword] = useState('');
  const [showPass, setShowPass] = useState(false);
  const [loading, setLoading] = useState(false);
  const [showMfa, setShowMfa] = useState(false);
  const [mfaToken, setMfaToken] = useState('');

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      // 1. Initial Login
      if (!showMfa) {
        const res = await api.post('/admin/auth/login', { email, password });
        login(res.data.data.accessToken, res.data.data.admin);
        navigate('/dashboard');
      } else {
        // 2. MFA Verification
        const res = await api.post('/admin/auth/mfa/verify', { email, token: mfaToken });
        login(res.data.data.accessToken, res.data.data.admin);
        navigate('/dashboard');
      }
    } catch (err) {
      console.error('Login error:', err);
      // FIX: Catch special 403 "mfa_required" status
      if (err.response?.status === 403 && err.response?.data?.mfa_required) {
        setShowMfa(true);
        toast.success('رمز التحقق الثنائي مطلوب');
      } else {
        const msg = err.response?.data?.message || 'فشل الاتصال بالخادم - ' + err.message;
        toast.error(msg);
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ minHeight: '100vh', background: '#1A3C5E', display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: 'Cairo, Arial, sans-serif' }}>
      <div style={{ background: 'white', borderRadius: 24, padding: 40, width: 420, boxShadow: '0 20px 60px rgba(0,0,0,0.2)' }}>
        <div style={{ textAlign: 'center', marginBottom: 32 }}>
          <img src="/assets/images/logo_primary.png" alt="Logo" style={{ height: 120, margin: '0 auto 16px', display: 'block' }} />
          <h1 style={{ fontSize: 24, fontWeight: 700, color: '#1A3C5E', margin: 0 }}>كيف نخدمك</h1>
          <p style={{ color: '#7F8C8D', fontSize: 12, marginTop: 2, letterSpacing: 1 }}>How Can We Serve You</p>
          <p style={{ color: '#1A3C5E', fontSize: 14, marginTop: 8, fontWeight: 600 }}>لوحة التحكم الإدارية</p>
        </div>

        <form onSubmit={handleLogin}>
          {!showMfa ? (
            <>
              <div style={{ marginBottom: 16 }}>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6, color: '#2C3E50' }}>البريد الإلكتروني</label>
                <input value={email} onChange={e => setEmail(e.target.value)} type="email"
                  style={{ width: '100%', padding: '12px 14px', border: '1px solid #E0E0E0', borderRadius: 10, fontFamily: 'Cairo', fontSize: 14, direction: 'rtl', boxSizing: 'border-box' }} />
              </div>

              <div style={{ marginBottom: 24 }}>
                <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6, color: '#2C3E50' }}>كلمة المرور</label>
                <div style={{ position: 'relative' }}>
                  <input value={password} onChange={e => setPassword(e.target.value)} type={showPass ? 'text' : 'password'}
                    placeholder="أدخل كلمة المرور"
                    style={{ width: '100%', padding: '12px 14px', border: '1px solid #E0E0E0', borderRadius: 10, fontFamily: 'Cairo', fontSize: 14, direction: 'rtl', boxSizing: 'border-box' }} />
                  <button type="button" onClick={() => setShowPass(!showPass)}
                    style={{ position: 'absolute', left: 12, top: 12, background: 'none', border: 'none', cursor: 'pointer', color: '#95A5A6' }}>
                    {showPass ? <EyeOff size={18} /> : <Eye size={18} />}
                  </button>
                </div>
              </div>
            </>
          ) : (
            <div style={{ marginBottom: 24 }}>
              <label style={{ display: 'block', fontSize: 13, fontWeight: 600, marginBottom: 6, color: '#1A3C5E', textAlign: 'center' }}>ادخل رمز التحقق الثنائي (MFA)</label>
              <input value={mfaToken} onChange={e => setMfaToken(e.target.value)} type="text" maxLength={6} autoFocus
                placeholder="000000"
                style={{ width: '100%', padding: '16px', border: '2px solid #1A3C5E', borderRadius: 12, fontFamily: 'Cairo', fontSize: 24, textAlign: 'center', letterSpacing: 8, direction: 'ltr', boxSizing: 'border-box' }} />
              <p style={{ fontSize: 12, color: '#7F8C8D', textAlign: 'center', marginTop: 12 }}>افتح تطبيق Authenticator للحصول على الرمز</p>
            </div>
          )}

          <button type="submit" disabled={loading}
            style={{ width: '100%', padding: 14, background: loading ? '#BDC3C7' : '#1A3C5E', color: 'white', border: 'none', borderRadius: 12, cursor: loading ? 'default' : 'pointer', fontFamily: 'Cairo', fontWeight: 700, fontSize: 16 }}>
            {loading ? 'جارٍ العمل...' : (showMfa ? 'تأكيد الرمز' : 'تسجيل الدخول')}
          </button>
          
          {showMfa && (
            <button type="button" onClick={() => setShowMfa(false)}
              style={{ width: '100%', marginTop: 12, padding: 8, background: 'none', color: '#7F8C8D', border: 'none', cursor: 'pointer', fontFamily: 'Cairo', fontSize: 13 }}>
              العودة لتسجيل الدخول
            </button>
          )}
        </form>
      </div>
    </div>
  );
}

