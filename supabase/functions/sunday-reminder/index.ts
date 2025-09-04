// supabase/functions/sunday-reminder/index.ts

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

// Definición de la estructura de un reporte para que TypeScript nos ayude
interface Report {
  user_id: string;
  profile: {
    nombres: string;
  } | null;
}

Deno.serve(async (req) => {
  // Manejo de la solicitud pre-vuelo (CORS)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Crear un cliente de Supabase con permisos de administrador
    const supabaseClient = createClient(
      Deno.env.get('https://vrlkwdihwiscincrdiew.supabase.co') ?? '',
      Deno.env.get('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZybGt3ZGlod2lzY2luY3JkaWV3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1NDk1MzcyNywiZXhwIjoyMDcwNTI5NzI3fQ.i2B7l59xartn1UbzSC1KhEo30v2wxrH3-0sVykdEV7g') ?? '', // Usamos la service_role key para tener acceso total
    );

    // 1. Obtener la fecha del domingo y lunes pasados para definir la semana actual
    const today = new Date();
    const dayOfWeek = today.getDay(); // Domingo = 0, Lunes = 1, ...
    const mostRecentMonday = new Date(today);
    mostRecentMonday.setDate(today.getDate() - (dayOfWeek === 0 ? 6 : dayOfWeek - 1));
    mostRecentMonday.setHours(0, 0, 0, 0); // Inicio del día lunes

    const endOfWeek = new Date(mostRecentMonday);
    endOfWeek.setDate(mostRecentMonday.getDate() + 6);
    endOfWeek.setHours(23, 59, 59, 999); // Fin del día domingo

    // 2. Buscar reportes de esta semana que todavía estén 'in_progress'
    const { data: reports, error: reportsError } = await supabaseClient
      .from('weekly_reports')
      .select('user_id, profile:profiles(nombres)')
      .eq('status', 'in_progress')
      .gte('fecha_inicio', mostRecentMonday.toISOString())
      .lte('fecha_fin', endOfWeek.toISOString());

    if (reportsError) throw reportsError;
    if (!reports || reports.length === 0) {
      return new Response(JSON.stringify({ message: 'No hay reportes pendientes para notificar.' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    // 3. Crear las notificaciones para cada usuario con reporte pendiente
    const notificationsToInsert = reports.map((report: Report) => {
      const userName = report.profile?.nombres?.split(' ')[0] || 'usuario';
      return {
        user_id: report.user_id,
        title: '¡No olvides tu reporte semanal! 📝',
        message: `Hola ${userName}, recuerda completar tu reporte de esta semana antes de que termine el día.`,
        type: 'reminder',
      };
    });

    // 4. Insertar todas las notificaciones en la base de datos
    const { error: insertError } = await supabaseClient
      .from('notifications')
      .insert(notificationsToInsert);

    if (insertError) throw insertError;

    return new Response(JSON.stringify({ message: `Se crearon ${notificationsToInsert.length} notificaciones de recordatorio.` }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});

