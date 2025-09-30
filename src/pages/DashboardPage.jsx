import React, { useState, useEffect } from 'react';
import { supabase } from '../supabaseClient.js';
import Spinner from '../components/Spinner.jsx';
import WasteSummaryChart from '../components/WasteSummaryChart.jsx';

// Componente para las tarjetas de resumen
const StatCard = ({ title, value, icon, loading }) => (
  <div className="bg-white p-6 rounded-lg shadow-md flex items-center space-x-4">
    <div className="text-4xl">{icon}</div>
    <div>
      <p className="text-gray-500 text-sm font-medium">{title}</p>
      {loading ? (
        <div className="h-8 w-24 bg-gray-200 rounded animate-pulse"></div>
      ) : (
        <p className="text-2xl font-bold text-gray-800">{value}</p>
      )}
    </div>
  </div>
);


export default function DashboardPage() {
  const [summaryData, setSummaryData] = useState({
    totalResiduos: 0,
    totalAgua: 0,
    reportesPlng: 0,
    nuevosReportesHoy: 0,
  });
  const [chartData, setChartData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDashboardData = async () => {
      setLoading(true);
      try {
        const today = new Date().toISOString().slice(0, 10);
        const firstDayOfMonth = new Date(new Date().getFullYear(), new Date().getMonth(), 1).toISOString().slice(0, 10);

        // --- Fetch para las tarjetas de resumen ---
        const { data: wasteData, error: wasteError } = await supabase.from('weekly_reports').select('total_kilos').gte('fecha_inicio', firstDayOfMonth);
        if (wasteError) throw wasteError;
        const totalResiduos = wasteData.reduce((sum, report) => sum + report.total_kilos, 0);

        const { data: waterData, error: waterError } = await supabase.from('water_reports').select('salida_consumo_diario').gte('fecha', firstDayOfMonth);
        if (waterError) throw waterError;
        const totalAgua = waterData.reduce((sum, report) => sum + (report.salida_consumo_diario || 0), 0);
        
        const { count: plngCount, error: plngError } = await supabase.from('weekly_reports').select('*', { count: 'exact', head: true }).in('campamento', [ "RBI MLV 03 - KP 077+600", "RBI MLV 04 - KP 094+300", "RBI MLV 06 - KP 167+445", "RBI MLV 07 - KP 190+340", "SPAT MLV11 - KP 334+231", "SPAT MLV12 - KP 349+750", "DCVG KP000+015 - KP 000+015", "DCVG KP064+004 CI - KP 064+004", "DCVG KP115+992 - KP 115+992", "DCVG KP243+947 - KP 243+947", "DCVG KP368+371 - KP 368+371", "Proteccion Mecanica - KP 379+713" ]);
        if (plngError) throw plngError;

        const { data: newReportsData, error: newReportsError } = await supabase
          .from('weekly_reports')
          .select('id', { count: 'exact' })
          .gte('created_at', `${today} 00:00:00`)
          .lte('created_at', `${today} 23:59:59`);
        if (newReportsError) throw newReportsError;
        
        setSummaryData({ totalResiduos, totalAgua, reportesPlng: plngCount, nuevosReportesHoy: newReportsData.length });

        // --- Fetch para el gráfico de barras (Residuos por campamento en el último mes) ---
        const { data: wasteChartRawData, error: chartError } = await supabase
          .from('weekly_reports')
          .select('campamento, total_kilos')
          .gte('fecha_inicio', firstDayOfMonth);
        
        if (chartError) throw chartError;

        // Procesar datos para el gráfico
        const processedChartData = wasteChartRawData.reduce((acc, report) => {
          const camp = report.campamento || 'Desconocido';
          if (!acc[camp]) {
            acc[camp] = { name: camp, total: 0 };
          }
          acc[camp].total += report.total_kilos;
          return acc;
        }, {});
        
        setChartData(Object.values(processedChartData));

      } catch (error) {
        console.error("Error fetching dashboard data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, []);

  return (
    <div className="p-4 sm:p-6 lg:p-8">
      <div className="mb-8">
        <h1 className="text-2xl sm:text-3xl font-bold text-gray-800">Dashboard de Resumen</h1>
        <p className="text-gray-500 mt-1">Vista rápida de los indicadores clave.</p>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatCard title="Total Residuos (Mes)" value={`${summaryData.totalResiduos.toLocaleString('es-PE', { maximumFractionDigits: 2 })} Kg`} icon="📄" loading={loading} />
        <StatCard title="Total Consumo Agua (Mes)" value={`${summaryData.totalAgua.toLocaleString('es-PE', { maximumFractionDigits: 2 })} m³`} icon="💧" loading={loading} />
        <StatCard title="Total Reportes PLNG" value={summaryData.reportesPlng.toLocaleString('es-PE')} icon="📦" loading={loading} />
        <StatCard title="Nuevos Reportes (Hoy)" value={summaryData.nuevosReportesHoy.toLocaleString('es-PE')} icon="✨" loading={loading} />
      </div>
      
      <div className="mt-8 bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-bold text-gray-700 mb-4">Residuos por Campamento (Último Mes)</h2>
          {loading ? <Spinner/> : <WasteSummaryChart data={chartData} />}
      </div>
    </div>
  );
}

