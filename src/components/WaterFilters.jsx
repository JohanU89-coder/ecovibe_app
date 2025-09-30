import React, { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient.js';

export default function WaterFilters({ filters, onFilterChange, onApplyFilters, onExport }) {
  const [campamentos, setCampamentos] = useState([]);
  const [empresas, setEmpresas] = useState([]);

  useEffect(() => {
    const fetchFilterData = async () => {
      const { data: campData, error: campError } = await supabase.from('water_reports').select('campamento');
      if (campError) console.error("Error fetching campamentos:", campError);
      else setCampamentos([...new Set(campData.map(item => item.campamento).filter(Boolean))].sort());

      const { data: empData, error: empError } = await supabase.from('water_reports').select('empresa');
      if (empError) console.error("Error fetching empresas:", empError);
      else setEmpresas([...new Set(empData.map(item => item.empresa).filter(Boolean))].sort());
    };
    fetchFilterData();
  }, []);

  const handleInputChange = (e) => {
    onFilterChange(e.target.name, e.target.value);
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md mb-8">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div>
          <label htmlFor="dateStart" className="block text-sm font-medium text-gray-700 mb-1">Fecha Inicio</label>
          <input type="date" name="dateStart" id="dateStart" value={filters.dateStart} onChange={handleInputChange} className="w-full p-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500" />
        </div>
        <div>
          <label htmlFor="dateEnd" className="block text-sm font-medium text-gray-700 mb-1">Fecha Fin</label>
          <input type="date" name="dateEnd" id="dateEnd" value={filters.dateEnd} onChange={handleInputChange} className="w-full p-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500" />
        </div>
        <div>
          <label htmlFor="campamento" className="block text-sm font-medium text-gray-700 mb-1">Campamento</label>
          <select name="campamento" id="campamento" value={filters.campamento} onChange={handleInputChange} className="w-full p-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500">
            <option value="">Todos</option>
            {campamentos.map(c => <option key={c} value={c}>{c}</option>)}
          </select>
        </div>
        <div>
          <label htmlFor="empresa" className="block text-sm font-medium text-gray-700 mb-1">Empresa</label>
          <select name="empresa" id="empresa" value={filters.empresa} onChange={handleInputChange} className="w-full p-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500">
            <option value="">Todas</option>
            {empresas.map(e => <option key={e} value={e}>{e}</option>)}
          </select>
        </div>
      </div>
      <div className="mt-4 flex justify-end items-center space-x-3">
        <button onClick={onApplyFilters} className="bg-blue-600 text-white font-bold py-2 px-4 rounded-lg hover:bg-blue-700 transition duration-300">
          Aplicar Filtros
        </button>
        <button onClick={onExport} className="bg-green-600 text-white font-bold py-2 px-4 rounded-lg hover:bg-green-700 transition duration-300">
          Exportar a CSV
        </button>
      </div>
    </div>
  );
}

