import React from 'react';

// Lista específica de campamentos para PLNG
const plngCampamentos = [
  "RBI MLV 03 - KP 077+600", "RBI MLV 04 - KP 094+300", "RBI MLV 06 - KP 167+445",
  "RBI MLV 07 - KP 190+340", "SPAT MLV11 - KP 334+231", "SPAT MLV12 - KP 349+750",
  "DCVG KP000+015 - KP 000+015", "DCVG KP064+004 CI - KP 064+004", "DCVG KP115+992 - KP 115+992",
  "DCVG KP243+947 - KP 243+947", "DCVG KP368+371 - KP 368+371", "Proteccion Mecanica - KP 379+713"
].sort();

export default function PlngFilters({ filters, onFilterChange, onApplyFilters, onExport }) {
  
  const handleInputChange = (e) => {
    onFilterChange(e.target.name, e.target.value);
  };

  return (
    <div className="bg-white p-6 rounded-lg shadow-md mb-8">
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
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
            {plngCampamentos.map(camp => (
              <option key={camp} value={camp}>{camp}</option>
            ))}
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
