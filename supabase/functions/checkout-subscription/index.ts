import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { createSubscription, getSubscriptionPayments, getPixQrCode } from '../_shared/asaas.ts'

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

    const { planName, price, billingType, customerId, creditCard, creditCardHolderInfo } = await req.json()

    if (!customerId) throw new Error('Customer ID is required')

    // Create subscription in Asaas
    const today = new Date()
    const nextDueDate = new Date(today)
    nextDueDate.setDate(today.getDate() + 1) // Give 1 day for initial payment or immediate
    // For PIX, it can be today. For Credit Card, usually processed immediately.
    
    const subscriptionData = {
      customer: customerId,
      billingType: billingType || 'PIX', // PIX or CREDIT_CARD
      value: price,
      nextDueDate: today.toISOString().split('T')[0],
      description: `Assinatura Clube Alce's: ${planName}`,
      cycle: 'MONTHLY',
      ...(billingType === 'CREDIT_CARD' && creditCard ? { creditCard, creditCardHolderInfo } : {})
    }

    const asaasSub = await createSubscription(subscriptionData)

    // Save to profiles
    await supabaseClient
      .from('profiles')
      .update({ 
        active_subscription_id: asaasSub.id,
        active_subscription_status: asaasSub.status // usually 'PENDING' until paid
      })
      .eq('id', user.id)

    let pixQrCode = null
    let invoiceUrl = asaasSub.invoiceUrl
    
    if (billingType === 'PIX' || !billingType) {
      try {
        // Wait 1.5 seconds to make sure Asaas generated the first payment
        await new Promise(resolve => setTimeout(resolve, 1500))
        const payments = await getSubscriptionPayments(asaasSub.id)
        if (payments && payments.data && payments.data.length > 0) {
          const firstPayment = payments.data[0]
          invoiceUrl = firstPayment.invoiceUrl || invoiceUrl
          pixQrCode = await getPixQrCode(firstPayment.id)
        }
      } catch (err) {
        console.error("Failed to fetch Pix QR code for subscription:", err)
      }
    }

    return new Response(
      JSON.stringify({ 
        subscription: {
          ...asaasSub,
          invoiceUrl,
          pixQrCode
        } 
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})

