import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { createPayment } from '../_shared/asaas.ts'

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

    const { data: { user } } = await supabaseClient.auth.getUser()
    if (!user) throw new Error('Not authenticated')

    const { amount, billingType, customerId, appointmentId, description, creditCard, creditCardHolderInfo } = await req.json()

    if (!customerId) throw new Error('Customer ID is required')

    // Create payment in Asaas
    const today = new Date()
    const dueDate = new Date(today)
    dueDate.setDate(today.getDate() + 1) // Due tomorrow
    
    const paymentData = {
      customer: customerId,
      billingType: billingType || 'PIX', // PIX or CREDIT_CARD
      value: amount,
      dueDate: dueDate.toISOString().split('T')[0],
      description: description || `Agendamento Avulso Alce's Barbearia`,
      externalReference: appointmentId,
      ...(billingType === 'CREDIT_CARD' && creditCard ? { creditCard, creditCardHolderInfo } : {})
    }

    const asaasPayment = await createPayment(paymentData)

    if (appointmentId) {
      // Save payment ID to appointment
      await supabaseClient
        .from('appointments')
        .update({ 
          asaas_payment_id: asaasPayment.id,
          asaas_payment_url: asaasPayment.invoiceUrl,
          payment_status: asaasPayment.status 
        })
        .eq('id', appointmentId)
    }

    return new Response(
      JSON.stringify({ payment: asaasPayment }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
