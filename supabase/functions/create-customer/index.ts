import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { createCustomer } from '../_shared/asaas.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    // Get the authenticated user
    const { data: { user } } = await supabaseClient.auth.getUser()
    if (!user) throw new Error('Not authenticated')

    const { name, cpf, phone } = await req.json()

    // Retrieve profile to see if it already has an asaas_customer_id
    const { data: profile } = await supabaseClient
      .from('profiles')
      .select('asaas_customer_id, email, full_name')
      .eq('id', user.id)
      .single()

    if (profile?.asaas_customer_id) {
      return new Response(
        JSON.stringify({ customerId: profile.asaas_customer_id }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Call Asaas API to create customer
    const asaasCustomer = await createCustomer({
      name: name || profile?.full_name || 'Alce Client',
      email: user.email || profile?.email,
      cpfCnpj: cpf,
      phone: phone
    })

    // Update profile with the new customer ID
    await supabaseClient
      .from('profiles')
      .update({ asaas_customer_id: asaasCustomer.id })
      .eq('id', user.id)

    return new Response(
      JSON.stringify({ customerId: asaasCustomer.id }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
