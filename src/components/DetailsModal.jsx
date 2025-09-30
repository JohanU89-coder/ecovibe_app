import React from 'react';

// Función Helper para formatear y descargar el CSV
const handleExportDetailsToCSV = (reportDetails, showNotification) => {
  if (!reportDetails || !reportDetails.report_categories || reportDetails.report_categories.length === 0) {
    showNotification("No hay detalles para exportar.", "error");
    return;
  }

  showNotification("Generando archivo CSV...", "info");

  const flatData = [];
  reportDetails.report_categories.forEach(category => {
    category.report_items.forEach(item => {
      flatData.push({
        categoria: category.categoria_nombre,
        residuo: item.item_nombre,
        lunes: item.lunes,
        martes: item.martes,
        miercoles: item.miercoles,
        jueves: item.jueves,
        viernes: item.viernes,
        sabado: item.sabado,
        domingo: item.domingo,
        total_item: item.total_item,
        unidad: category.unidad,
      });
    });
  });

  const headers = ['Categoría', 'Residuo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo', 'Total Item', 'Unidad'];
  
  const csvContent = [
    headers.join(','),
    ...flatData.map(row => [
      `"${row.categoria || ''}"`,
      `"${row.residuo || ''}"`,
      row.lunes ?? 0,
      row.martes ?? 0,
      row.miercoles ?? 0,
      row.jueves ?? 0,
      row.viernes ?? 0,
      row.sabado ?? 0,
      row.domingo ?? 0,
      row.total_item ?? 0,
      `"${row.unidad || ''}"`
    ].join(','))
  ].join('\n');

  const blob = new Blob([`\uFEFF${csvContent}`], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);
  const fileName = `Detalle_Reporte_${reportDetails.semana}_${reportDetails.campamento}.csv`;
  link.setAttribute('href', url);
  link.setAttribute('download', fileName);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  showNotification("Exportación completada.", "success");
};


export default function DetailsModal({ reportDetails, onClose, loading, showNotification }) {
  if (!reportDetails) {
    return null;
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-lg shadow-xl w-full max-w-4xl max-h-[90vh] flex flex-col">
        <div className="p-6 border-b flex justify-between items-center">
          <div>
            <h2 className="text-2xl font-bold text-gray-800">Detalles del Reporte</h2>
            <p className="text-sm text-gray-500">Semana: {reportDetails.semana} - Campamento: {reportDetails.campamento}</p>
          </div>
          <div>
            <button
              onClick={() => handleExportDetailsToCSV(reportDetails, showNotification)}
              className="bg-green-600 text-white font-bold py-2 px-4 rounded-lg hover:bg-green-700 transition duration-300 mr-4 disabled:opacity-50 disabled:cursor-not-allowed"
              disabled={loading || !reportDetails.report_categories || reportDetails.report_categories.length === 0}
            >
              Exportar CSV
            </button>
            <button onClick={onClose} className="text-gray-500 hover:text-gray-800 text-3xl font-bold">&times;</button>
          </div>
        </div>
        <div className="p-6 overflow-y-auto">
          {loading ? (
            <div className="text-center text-gray-500">Cargando detalles...</div>
          ) : (
            <>
              {!reportDetails.report_categories || reportDetails.report_categories.length === 0 ? (
                <div className="text-center text-gray-500">Este reporte no tiene residuos registrados.</div>
              ) : (
                reportDetails.report_categories.map(cat => (
                  <div key={cat.id} className="mb-6">
                    <h3 className="text-lg font-bold text-gray-700 mb-2">{cat.categoria_nombre} ({cat.total_categoria.toFixed(2)} {cat.unidad})</h3>
                    <div className="overflow-x-auto border rounded-lg">
                      <table className="min-w-full divide-y divide-gray-200 table-fixed">
                        <thead className="bg-gray-50">
                          <tr>
                            <th style={{ width: '35%' }} className="px-4 py-2 text-left text-xs font-medium text-gray-500 uppercase">Residuo</th>
                            <th style={{ width: '7%' }} className="px-2 py-2 text-center text-xs font-medium text-gray-500 uppercase">L</th>
                            <th style={{ width: '7%' }} className="px-2 py-2 text-center text-xs font-medium text-gray-500 uppercase">M</th>
                            <th style={{ width: '7%' }} className="px-2 py-2 text-center text-xs font-medium text-gray-500 uppercase">X</th>
                            <th style={{ width: '7%' }} className="px-2 py-2 text-center text-xs font-medium text-gray-500 uppercase">J</th>
                            <th style={{ width: '7%' }} className="px-2 py-2 text-center text-xs font-medium text-gray-500 uppercase">V</th>
                            <th style={{ width: '7%' }} className="px-2 py-2 text-center text-xs font-medium text-gray-500 uppercase">S</th>
                            <th style={{ width: '7%' }} className="px-2 py-2 text-center text-xs font-medium text-gray-500 uppercase">D</th>
                            <th style={{ width: '16%' }} className="px-4 py-2 text-right text-xs font-medium text-gray-500 uppercase">Total</th>
                          </tr>
                        </thead>
                        <tbody className="bg-white divide-y divide-gray-200">
                          {cat.report_items.map(item => (
                            <tr key={item.id}>
                              <td className="px-4 py-3 text-left text-sm text-gray-800">{item.item_nombre}</td>
                              <td className="px-2 py-3 text-center text-sm">{item.lunes}</td>
                              <td className="px-2 py-3 text-center text-sm">{item.martes}</td>
                              <td className="px-2 py-3 text-center text-sm">{item.miercoles}</td>
                              <td className="px-2 py-3 text-center text-sm">{item.jueves}</td>
                              <td className="px-2 py-3 text-center text-sm">{item.viernes}</td>
                              <td className="px-2 py-3 text-center text-sm">{item.sabado}</td>
                              <td className="px-2 py-3 text-center text-sm">{item.domingo}</td>
                              <td className="px-4 py-3 text-right text-sm font-semibold">{item.total_item.toFixed(2)}</td>
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                ))
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
}

