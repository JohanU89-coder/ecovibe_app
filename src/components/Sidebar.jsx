import React from 'react';
import { NavLink, useNavigate } from 'react-router-dom';
import { supabase } from '../supabaseClient.js';

export default function Sidebar() {
  const navigate = useNavigate();

  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/');
  };
  
  const linkClasses = "flex items-center px-4 py-2 text-gray-100 rounded-lg hover:bg-green-700";
  const activeLinkClasses = "bg-green-700 font-bold";

  return (
    <div className="w-64 h-screen bg-green-800 text-white flex flex-col p-4">
      <div className="mb-8 text-center">
        <img src="/logo.png" alt="Ecovibe Logo" className="w-20 h-20 mx-auto mb-2 rounded-full bg-white p-1" />
        <h1 className="text-2xl font-bold">Portal Ecovibe</h1>
      </div>
      <nav className="flex-grow space-y-2">
        <NavLink to="/portal/dashboard" className={({ isActive }) => `${linkClasses} ${isActive ? activeLinkClasses : ''}`}>
          <span className="mr-3 text-xl">📊</span>
          Dashboard
        </NavLink>
        <NavLink to="/portal/residuos" className={({ isActive }) => `${linkClasses} ${isActive ? activeLinkClasses : ''}`}>
          <span className="mr-3 text-xl">🚮</span>
          Residuos MLV
        </NavLink>
        <NavLink to="/portal/residuos-plng" className={({ isActive }) => `${linkClasses} ${isActive ? activeLinkClasses : ''}`}>
          <span className="mr-3 text-xl">📦</span>
          Residuos PLNG
        </NavLink>
        <NavLink to="/portal/agua" className={({ isActive }) => `${linkClasses} ${isActive ? activeLinkClasses : ''}`}>
          <span className="mr-3 text-xl">💧</span>
          Reportes Agua MLV
        </NavLink>
      </nav>
      <div>
        <button onClick={handleLogout} className="w-full bg-red-600 hover:bg-red-700 text-white font-bold py-2 px-4 rounded-lg">
          Cerrar Sesión
        </button>
      </div>
    </div>
  );
}

