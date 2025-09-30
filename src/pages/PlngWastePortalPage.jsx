import React, { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient.js';
import PlngFilters from '../components/PlngFilters.jsx';
import ReportTable from '../components/ReportTable.jsx';
import DetailsModal from '../components/DetailsModal.jsx';
import Pagination from '../components/Pagination.jsx';
import Notification from '../components/Notification.jsx';

const plngCampamentos = [
  "RBI MLV 03 - KP 077+600", "RBI MLV 04 - KP 094+300", "RBI MLV 06 - KP 167+445",
  "RBI MLV 07 - KP 190+340", "SPAT MLV11 - KP 334+231", "SPAT MLV12 - KP 349+750",
  "DCVG KP000+015 - KP 000+015", "DCVG KP064+004 CI - KP 064+004", "DCVG KP115+992 - KP 115+992",
  "DCVG KP243+947 - KP 243+947", "DCVG KP368+371 - KP 368+371", "Proteccion Mecanica - KP 379+713"
];

export default function PlngWastePortalPage() {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [selectedReportDetails, setSelectedReportDetails] = useState(null);
  const [isModalLoading, setIsModalLoading] = useState(false);
  const [filters, setFilters] = useState({ dateStart: '', dateEnd: '', campamento: '' });
  const [currentPage, setCurrentPage] = useState(1);
  const [reportsPerPage, setReportsPerPage] = useState(10);
  const [totalReports, setTotalReports] = useState(0);
  const [notification, setNotification] = useState({ message: '', type: '' });

  const showNotification = (message, type = 'info') => setNotification({ message, type });
  const handleFilterChange = (name, value) => setFilters(prev => ({ ...prev, [name]: value }));
  const handleApplyFilters = () => { setCurrentPage(1); fetchReports(); };
  const handlePageChange = (page) => setCurrentPage(page);
  const handleReportsPerPageChange = (number) => { setReportsPerPage(number); setCurrentPage(1); };
  const handleCloseModal = () => setSelectedReportDetails(null);

  const fetchReports = async () => {
    setLoading(true);
    setError(null);
    try {
      const from = (currentPage - 1) * reportsPerPage;
      const to = from + reportsPerPage - 1;

      let query = supabase
        .from('weekly_reports')
        .select(`id, semana, campamento, total_kilos, status, numero_guia, condicion, responsable_recepcion, profiles ( nombres, apellido )`, { count: 'exact' })
        .in('campamento', plngCampamentos)
        .order('created_at', { ascending: false });

      if (filters.campamento) query = query.eq('campamento', filters.campamento);
      if (filters.dateStart) query = query.gte('fecha_inicio', filters.dateStart);
      if (filters.dateEnd) query = query.lte('fecha_fin', filters.dateEnd);
      
      query = query.range(from, to);

      let { data, error: fetchError, count } = await query;
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
    fetchReports();
  }, [currentPage, reportsPerPage]);

  const handleExportFilteredToCSV = async () => {
    showNotification("Iniciando exportación...", "info");
    try {
        let query = supabase
          .from('weekly_reports')
          .select(`*, profiles(nombres, apellido), report_categories(*, report_items(*))`)
          .in('campamento', plngCampamentos);

        if (filters.campamento) query = query.eq('campamento', filters.campamento);
        if (filters.dateStart) query = query.gte('fecha_inicio', filters.dateStart);
        if (filters.dateEnd) query = query.lte('fecha_fin', filters.dateEnd);
        
        const { data: reportsToExport, error } = await query;
        if (error) throw error;

        if (!reportsToExport || reportsToExport.length === 0) {
            showNotification('No hay datos para exportar con los filtros seleccionados.', 'error');
            return;
        }
        
        const flatData = [];
        reportsToExport.forEach(report => {
            const reportBase = {
                usuario: `${report.profiles?.nombres || ''} ${report.profiles?.apellido || ''}`.trim(),
                semana: report.semana,
                campamento: report.campamento,
                area: report.area,
                condicion: report.condicion,
                responsable_recepcion: report.responsable_recepcion,
                estado: report.status,
                numero_guia: report.numero_guia,
            };
            if (!report.report_categories || report.report_categories.length === 0) {
              flatData.push(reportBase);
            } else {
              report.report_categories.forEach(category => {
                  category.report_items.forEach(item => { flatData.push({ ...reportBase, categoria: category.categoria_nombre, residuo: item.item_nombre, lunes: item.lunes, martes: item.martes, miercoles: item.miercoles, jueves: item.jueves, viernes: item.viernes, sabado: item.sabado, domingo: item.domingo, total_item: item.total_item, }); });
              });
            }
        });
        const headers = ['Usuario', 'Semana', 'Campamento', 'Área', 'Nro. Guía', 'Condición', 'Responsable Recepción', 'Estado', 'Categoría', 'Residuo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo', 'Total Item'];
        const csvContent = [ 
            headers.join(','), 
            ...flatData.map(row => [ 
                `"${row.usuario || ''}"`, `"${row.semana || ''}"`, `"${row.campamento || ''}"`, 
                `"${row.area || ''}"`, `"${row.numero_guia || ''}"`, `"${row.condicion || ''}"`, 
                `"${row.responsable_recepcion || ''}"`, `"${row.estado || ''}"`, 
                `"${row.categoria || ''}"`, `"${row.residuo || ''}"`, 
                row.lunes ?? 0, row.martes ?? 0, row.miercoles ?? 0, row.jueves ?? 0, 
                row.viernes ?? 0, row.sabado ?? 0, row.domingo ?? 0, row.total_item ?? 0, 
            ].join(',')) 
        ].join('\n');
        const blob = new Blob([`\uFEFF${csvContent}`], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement('a');
        const url = URL.createObjectURL(blob);
        link.setAttribute('href', url);
        link.setAttribute('download', 'Ecovibe_Reportes_Residuos_PLNG.csv');
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        showNotification("Exportación completada con éxito.", "success");
    } catch (err) {
        console.error("Error exporting to CSV:", err);
        showNotification(`Error al exportar: ${err.message}`, "error");
    }
  };
  
  const handleShowDetails = async (reportId) => {
    setIsModalLoading(true);
    setSelectedReportDetails({ id: reportId, report_categories: [] });
    try {
      const { data, error } = await supabase.from('weekly_reports').select(`*, report_categories (*, report_items (*))`).eq('id', reportId).single();
      if (error) throw error;
      setSelectedReportDetails(data);
    } catch (err) {
      console.error("Error fetching report details:", err);
    } finally {
      setIsModalLoading(false);
    }
  };

  return (
    <div className="p-4 sm:p-6 lg:p-8">
      <Notification message={notification.message} type={notification.type} onClose={() => setNotification({ message: '', type: '' })} />
      <div className="flex items-center space-x-3 mb-8">
        <h1 className="text-2xl sm:text-3xl font-bold text-gray-800">Portal de Reportes de Residuos PLNG</h1>
      </div>
      <PlngFilters filters={filters} onFilterChange={handleFilterChange} onApplyFilters={handleApplyFilters} onExport={handleExportFilteredToCSV} />
      {error && <p className="text-red-500 text-center mb-4">Error: {error}</p>}
      <ReportTable 
        reports={reports} 
        loading={loading} 
        onShowDetails={handleShowDetails} 
        showConditionColumn={true}
        showReceptionResponsible={true}
      />
      <Pagination currentPage={currentPage} reportsPerPage={reportsPerPage} totalReports={totalReports} onPageChange={handlePageChange} onReportsPerPageChange={handleReportsPerPageChange} />
      <DetailsModal reportDetails={selectedReportDetails} onClose={handleCloseModal} loading={isModalLoading} showNotification={showNotification} />
    </div>
  );
}

