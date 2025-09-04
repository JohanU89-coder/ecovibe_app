// supabase/functions/monday-reminder/index.ts

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { corsHeaders } from '../_shared/cors.ts';

// Definición de la estructura de un perfil para que TypeScript nos ayude
interface Profile {
  id: string;
  nombres: string;
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

    // 1. Obtener todos los perfiles de usuario activos
    const { data: profiles, error: profilesError } = await supabaseClient
      .from('profiles')
      .select('id, nombres');

    if (profilesError) throw profilesError;
    if (!profiles || profiles.length === 0) {
      return new Response(JSON.stringify({ message: 'No hay usuarios para notificar.' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    // 2. Crear las notificaciones de inicio de semana
    const notificationsToInsert = profiles.map((profile: Profile) => {
      const userName = profile.nombres?.split(' ')[0] || 'usuario';
      return {
        user_id: profile.id,
        title: '¡Comienza una nueva semana! 🚀',
        message: `Hola ${userName}, es hora de crear tu reporte de generación de residuos para esta semana.`,
        type: 'reminder',
      };
    });

    // 3. Insertar todas las notificaciones en la base de datos
    const { error: insertError } = await supabaseClient
      .from('notifications')
      .insert(notificationsToInsert);

    if (insertError) throw insertError;

    return new Response(JSON.stringify({ message: `Se crearon ${notificationsToInsert.length} notificaciones de inicio de semana.` }), {
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

