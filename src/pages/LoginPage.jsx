import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../supabaseClient';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleLogin = async (event) => {
    event.preventDefault();
    setLoading(true);
    setError('');

    try {
      const { data: loginData, error: loginError } = await supabase.auth.signInWithPassword({ email, password });

      if (loginError) throw loginError;

      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('role')
        .eq('id', loginData.user.id)
        .single();

      if (profileError || !profile || profile.role !== 'admin') {
        await supabase.auth.signOut();
        throw new Error('Acceso denegado. Solo para administradores.');
      }

      navigate('/portal');

    } catch (err) {
      setError(err.message || 'Email o contraseña incorrectos.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-green-400 to-teal-600 p-4">
      <div className="w-full max-w-md p-8 space-y-8 bg-white rounded-2xl shadow-lg">
        <div className="text-center">
          <img src="/logo.png" alt="Ecovibe Logo" className="w-24 h-24 mx-auto mb-4 rounded-full" onError={(e) => { e.target.onerror = null; e.target.src='https://placehold.co/100x100/34d399/ffffff?text=E' }} />
          <h2 className="text-3xl font-bold text-gray-900">Portal Ecovibe</h2>
          <p className="mt-2 text-gray-600">Inicia sesión para continuar</p>
        </div>
        <form onSubmit={handleLogin} className="space-y-6">
          <div>
            <label htmlFor="email" className="sr-only">Email</label>
            <input
              id="email"
              name="email"
              type="email"
              autoComplete="email"
              required
              className="w-full px-4 py-3 text-gray-700 bg-gray-100 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
              placeholder="Correo Electrónico"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              disabled={loading}
            />
          </div>
          <div>
            <label htmlFor="password" className="sr-only">Contraseña</label>
            <input
              id="password"
              name="password"
              type="password"
              autoComplete="current-password"
              required
              className="w-full px-4 py-3 text-gray-700 bg-gray-100 border border-gray-300 rounded-lg focus:ring-green-500 focus:border-green-500"
              placeholder="Contraseña"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              disabled={loading}
            />
          </div>
          {error && <p className="text-sm text-center text-red-600">{error}</p>}
          <div>
            <button
              type="submit"
              disabled={loading}
              className="w-full flex justify-center py-3 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {loading ? 'Verificando...' : 'Ingresar'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

