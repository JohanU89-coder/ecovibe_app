import React from 'react';
import Spinner from './Spinner.jsx'; // Se añade la importación

// Función Helper para el badge de estado
const getStatusBadge = (status) => {
    const statuses = { 'in_progress': 'bg-blue-100 text-blue-800', 'completed': 'bg-green-100 text-green-800', 'terminado': 'bg-yellow-100 text-yellow-800' };
    const text = { 'in_progress': 'En Progreso', 'completed': 'Completado', 'terminado': 'Terminado' };
    return <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${statuses[status] || 'bg-gray-100 text-gray-800'}`}>{text[status] || status}</span>;
}

// Función Helper para el badge de condición (ACTUALIZADA)
const getConditionBadge = (condition) => {
    if (!condition) return <span className="text-gray-500">N/A</span>;
    const conditions = {
        'GENERADO': 'bg-green-100 text-blue-800',
        'INTERNADO': 'bg-purple-100 text-purple-800',
    };
    // Usamos toUpperCase() para asegurar que coincida sin importar si viene en mayúsculas o minúsculas
    return <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${conditions[condition.toUpperCase()] || 'bg-gray-100 text-gray-800'}`}>{condition}</span>;
}

export default function ReportTable({ reports, loading, onShowDetails, showConditionColumn = false }) {
  const colSpan = showConditionColumn ? 8 : 7;

  return (
    <div className="bg-white rounded-lg shadow-md overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Usuario</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Semana</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Campamento</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total (Kg)</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nro. Guía</th>
            {showConditionColumn && <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Condición</th>}
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
            <th scope="col" className="relative px-6 py-3"><span className="sr-only">Ver</span></th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {loading ? (
            <tr><td colSpan={colSpan}><Spinner /></td></tr>
          ) : reports.length > 0 ? (
            reports.map(report => (
              <tr key={report.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap"><div className="text-sm text-gray-900">{report.profiles?.nombres || 'Usuario'} {report.profiles?.apellido || ''}</div></td>
                <td className="px-6 py-4 whitespace-nowrap"><div className="text-sm text-gray-900">{report.semana}</div></td>
                <td className="px-6 py-4 whitespace-nowrap"><div className="text-sm text-gray-900">{report.campamento}</div></td>
                <td className="px-6 py-4 whitespace-nowrap"><div className="text-sm text-gray-900">{report.total_kilos.toFixed(2)} Kg</div></td>
                <td className="px-6 py-4 whitespace-nowrap"><div className="text-sm text-gray-500">{report.numero_guia || 'N/A'}</div></td>
                {showConditionColumn && <td className="px-6 py-4 whitespace-nowrap">{getConditionBadge(report.condicion)}</td>}
                <td className="px-6 py-4 whitespace-nowrap">{getStatusBadge(report.status)}</td>
                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                  <button onClick={() => onShowDetails(report.id)} className="text-green-600 hover:text-green-900">Ver Detalles</button>
                </td>
              </tr>
            ))
          ) : (
            <tr><td colSpan={colSpan} className="p-8 text-center text-gray-500">No se encontraron reportes.</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

