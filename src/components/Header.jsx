import React from 'react';
import { supabase } from '../supabaseClient';
import { useNavigate } from 'react-router-dom';

export default function Header() {
  const navigate = useNavigate();

  const handleLogout = async () => {
    await supabase.auth.signOut();
    navigate('/');s
  };

  return (
    <header className="mb-8 flex flex-col sm:flex-row justify-between items-start sm:items-center">
      <div>
        <div className="flex items-center space-x-3">
          <img src="/logo.png" alt="Ecovibe Logo" className="h-10 w-10 rounded-lg" />
          <h1 className="text-2xl sm:text-3xl font-bold text-gray-800">Portal de Reportes Ecovibe</h1>
        </div>
        <p className="text-gray-500 mt-1">Visualiza y filtra los reportes de generación de residuos.</p>
      </div>
      <button 
        onClick={handleLogout}
        className="mt-4 sm:mt-0 bg-red-500 text-white font-bold py-2 px-4 rounded-lg hover:bg-red-600 transition duration-300"
      >
        Cerrar Sesión
      </button>
    </header>
  );
}
