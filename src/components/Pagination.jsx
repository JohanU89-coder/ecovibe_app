import React from 'react';

export default function Pagination({
  currentPage,
  reportsPerPage,
  totalReports,
  onPageChange,
  onReportsPerPageChange
}) {
  const totalPages = Math.ceil(totalReports / reportsPerPage);

  const handlePrev = () => {
    if (currentPage > 1) {
      onPageChange(currentPage - 1);
    }
  };

  const handleNext = () => {
    if (currentPage < totalPages) {
      onPageChange(currentPage + 1);
    }
  };

  if (totalPages <= 1) {
    return null; // No mostrar paginación si solo hay una página
  }

  return (
    <div className="mt-6 flex flex-col sm:flex-row justify-center items-center space-y-4 sm:space-y-0 sm:space-x-6">
      <div className="flex items-center">
        <label htmlFor="reports-per-page-select" className="text-sm font-medium text-gray-600 mr-2">Mostrar:</label>
        <select
          id="reports-per-page-select"
          value={reportsPerPage}
          onChange={(e) => onReportsPerPageChange(Number(e.target.value))}
          className="p-2 border border-gray-300 rounded-md focus:ring-green-500 focus:border-green-500 bg-white text-sm"
        >
          <option value="10">10</option>
          <option value="20">20</option>
          <option value="50">50</option>
          <option value="100">100</option>
        </select>
        <span className="text-sm font-medium text-gray-600 ml-2">registros</span>
      </div>
      <div className="flex justify-center items-center space-x-4">
        <button
          onClick={handlePrev}
          disabled={currentPage === 1}
          className="bg-gray-200 text-gray-700 font-bold py-2 px-4 rounded-lg hover:bg-gray-300 transition duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Anterior
        </button>
        <span className="text-sm text-gray-600 font-medium">
          Página {currentPage} de {totalPages}
        </span>
        <button
          onClick={handleNext}
          disabled={currentPage >= totalPages}
          className="bg-gray-200 text-gray-700 font-bold py-2 px-4 rounded-lg hover:bg-gray-300 transition duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Siguiente
        </button>
      </div>
    </div>
  );
}

