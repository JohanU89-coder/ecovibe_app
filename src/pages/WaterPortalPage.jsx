import React, { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient.js';
import WaterFilters from '../components/WaterFilters.jsx';
import WaterReportTable from '../components/WaterReportTable.jsx';
import Pagination from '../components/Pagination.jsx';
import Notification from '../components/Notification.jsx';

export default function WaterPortalPage() {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [filters, setFilters] = useState({ dateStart: '', dateEnd: '', campamento: '', empresa: '' });
  
  const [currentPage, setCurrentPage] = useState(1);
  const [reportsPerPage, setReportsPerPage] = useState(10);
  const [totalReports, setTotalReports] = useState(0);

  const [notification, setNotification] = useState({ message: '', type: '' });

  const showNotification = (message, type = 'info') => {
    setNotification({ message, type });
  };

  const handleFilterChange = (name, value) => {
    setFilters(prev => ({ ...prev, [name]: value }));
  };

  const handleApplyFilters = () => {
    setCurrentPage(1);
    fetchWaterReports();
  };

  const handlePageChange = (page) => {
    setCurrentPage(page);
  };

  const handleReportsPerPageChange = (number) => {
    setReportsPerPage(number);
    setCurrentPage(1);
  };

  const fetchWaterReports = async () => {
    setLoading(true);
    setError(null);
    try {
      const from = (currentPage - 1) * reportsPerPage;
      const to = from + reportsPerPage - 1;

      let query = supabase
        .from('water_reports')
        .select('*', { count: 'exact' })
        .order('fecha', { ascending: false });

      if (filters.dateStart) query = query.gte('fecha', filters.dateStart);
      if (filters.dateEnd) query = query.lte('fecha', filters.dateEnd);
      if (filters.campamento) query = query.eq('campamento', filters.campamento);
      if (filters.empresa) query = query.eq('empresa', filters.empresa);

      query = query.range(from, to);

      const { data, error: fetchError, count } = await query;

      if (fetchError) throw fetchError;
      
      setReports(data);
      setTotalReports(count);
    } catch (err) {
      setError(err.message);
      showNotification(`Error al cargar reportes: ${err.message}`, "error");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchWaterReports();
  }, [currentPage, reportsPerPage]);

  const handleExportToCSV = async () => {
    showNotification("Iniciando exportación...", "info");
    try {
      let query = supabase.from('water_reports').select('*').order('fecha', { ascending: false });

      if (filters.dateStart) query = query.gte('fecha', filters.dateStart);
      if (filters.dateEnd) query = query.lte('fecha', filters.dateEnd);
      if (filters.campamento) query = query.eq('campamento', filters.campamento);
      if (filters.empresa) query = query.eq('empresa', filters.empresa);

      const { data: reportsToExport, error } = await query;
      if (error) throw error;

      if (!reportsToExport || reportsToExport.length === 0) {
        showNotification('No hay datos para exportar con los filtros seleccionados.', 'error');
        return;
      }
      
      const headers = Object.keys(reportsToExport[0]);
      const csvContent = [
        headers.join(','),
        ...reportsToExport.map(row => headers.map(header => `"${row[header] || ''}"`).join(','))
      ].join('\n');

      const blob = new Blob([`\uFEFF${csvContent}`], { type: 'text/csv;charset=utf-8;' });
      const link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      link.download = 'Ecovibe_Reportes_Agua.csv';
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      showNotification("Exportación completada.", "success");
    } catch (err) {
      showNotification(`Error al exportar: ${err.message}`, "error");
    }
  };

  return (
    <div className="p-4 sm:p-6 lg:p-8">
      <Notification 
        message={notification.message}
        type={notification.type}
        onClose={() => setNotification({ message: '', type: '' })}
      />
      
      <div className="flex items-center space-x-3 mb-8">
        <h1 className="text-2xl sm:text-3xl font-bold text-gray-800">Portal de Reportes de Agua MLV</h1>
      </div>

      <WaterFilters
        filters={filters}
        onFilterChange={handleFilterChange}
        onApplyFilters={handleApplyFilters}
        onExport={handleExportToCSV}
      />
      
      {error && <p className="text-red-500 text-center mb-4">Error: {error}</p>}

      <WaterReportTable reports={reports} loading={loading} />

      <Pagination
        currentPage={currentPage}
        reportsPerPage={reportsPerPage}
        totalReports={totalReports}
        onPageChange={handlePageChange}
        onReportsPerPageChange={handleReportsPerPageChange}
      />
    </div>
  );
}

