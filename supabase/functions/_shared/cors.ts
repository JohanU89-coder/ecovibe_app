// supabase/functions/_shared/cors.ts

// Estos son los encabezados estándar necesarios para que las funciones de Supabase
// puedan ser llamadas desde un navegador web de forma segura.
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};
