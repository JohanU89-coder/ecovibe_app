import React, { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient';

// Recibimos las props del componente padre (PortalPage)
export default function Filters({ filters, onFilterChange, onApplyFilters, onExport }) {
  const [campamentos, setCampamentos] = useState([]);

  useEffect(() => {
    // Función para obtener los nombres únicos de los campamentos desde Supabase
    const fetchCampamentos = async () => {
      const { data, error } = await supabase.from('weekly_reports').select('campamento');
      if (error) {
        console.error("Error fetching campamentos:", error.message);
        return;
      }
      // Usamos Set para obtener valores únicos y luego lo convertimos a un array ordenado
      const uniqueCampamentos = [...new Set(data.map(item => item.campamento).filter(c => c))];
      uniqueCampamentos.sort();
      setCampamentos(uniqueCampamentos);
    };

    fetchCampamentos();
  }, []);

  // Manejador de cambios genérico para todos los inputs
  const handleChange = (e) => {
    onFilterChange(e.target.name, e.target.value);
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md mb-8">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {/* Filtro de Fecha Inicio */}
        <div>
          <label htmlFor="date-start" className="block text-sm font-medium text-gray-700 mb-1">Fecha Inicio</label>
          <input
            type="date"
            id="date-start"
            name="dateStart" // name debe coincidir con la clave en el estado de filtros
            value={filters.dateStart}
            onChange={handleChange}
            className="w-full p-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
          />
        </div>
        {/* Filtro de Fecha Fin */}
        <div>
          <label htmlFor="date-end" className="block text-sm font-medium text-gray-700 mb-1">Fecha Fin</label>
          <input
            type="date"
            id="date-end"
            name="dateEnd"
            value={filters.dateEnd}
            onChange={handleChange}
            className="w-full p-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
          />
        </div>
        {/* Filtro de Campamento */}
        <div>
          <label htmlFor="campamento-filter" className="block text-sm font-medium text-gray-700 mb-1">Campamento</label>
          <select
            id="campamento-filter"
            name="campamento"
            value={filters.campamento}
            onChange={handleChange}
            className="w-full p-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
          >
            <option value="">Todos</option>
            {campamentos.map(camp => <option key={camp} value={camp}>{camp}</option>)}
          </select>
        </div>
        {/* Filtro de Área */}
        <div>
          <label htmlFor="area-filter" className="block text-sm font-medium text-gray-700 mb-1">Área</label>
          <select
            id="area-filter"
            name="area"
            value={filters.area}
            onChange={handleChange}
            className="w-full p-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500"
          >
            <option value="">Todas</option>
            <option value="Mantenimiento">Mantenimiento</option>
            <option value="AID">AID</option>
          </select>
        </div>
      </div>
      {/* Botones de Acción */}
      <div className="mt-4 flex justify-end items-center space-x-3">
        <button
          onClick={onApplyFilters}
          className="bg-blue-600 text-white font-bold py-2 px-4 rounded-lg hover:bg-blue-700 transition duration-300"
        >
          Aplicar Filtros
        </button>
        <button
          onClick={onExport}
          className="bg-green-600 text-white font-bold py-2 px-4 rounded-lg hover:bg-green-700 transition duration-300"
        >
          Exportar a CSV
        </button>
      </div>
    </div>
  );
}

