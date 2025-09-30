import React from 'react';

const getStatusBadge = (status) => {
    const statuses = {
      'pending': 'bg-yellow-100 text-yellow-800',
      'approved': 'bg-green-100 text-green-800',
    };
    const text = {
      'pending': 'Pendiente',
      'approved': 'Aprobado'
    };
    return <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${statuses[status] || 'bg-gray-100 text-gray-800'}`}>{text[status] || status}</span>;
}

export default function WaterReportTable({ reports, loading }) {
  return (
    <div className="bg-white rounded-lg shadow-md overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Campamento</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Empresa</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Responsable</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Consumo Diario (m³)</th>
            <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {loading ? (
            <tr>
              <td colSpan="6" className="p-8 text-center text-gray-500">
                Cargando reportes...
              </td>
            </tr>
          ) : reports.length > 0 ? (
            reports.map(report => (
              <tr key={report.id} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{new Date(report.fecha + 'T00:00:00').toLocaleDateString()}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{report.campamento}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{report.empresa}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{report.responsable || 'N/A'}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-medium">{(report.salida_consumo_diario || 0).toFixed(2)}</td>
                <td className="px-6 py-4 whitespace-nowrap">{getStatusBadge(report.status)}</td>
              </tr>
            ))
          ) : (
            <tr><td colSpan="6" className="p-8 text-center text-gray-500">No se encontraron reportes.</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}

