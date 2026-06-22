import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// This endpoint receives payloads from Asaas Webhooks
serve(async (req) => {
  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '' // Need admin privileges to write to log and update without user context
    )

    const payload = await req.json()
    const { event, payment } = payload

    if (!payment) {
      return new Response('No payment data', { status: 400 })
    }

    // Log the webhook
    await supabaseClient.from('asaas_webhooks_log').insert({
      event_type: event,
      payment_id: payment.id,
      payload: payload
    })

    // Handle Subscription Payments
    if (payment.subscription) {
      if (event === 'PAYMENT_RECEIVED' || event === 'PAYMENT_CONFIRMED') {
        // Find profile with this subscription ID
        const { data: profile } = await supabaseClient
          .from('profiles')
          .select('id, xp, alce_coins, active_subscription_status')
          .eq('active_subscription_id', payment.subscription)
          .maybeSingle()

        if (profile) {
          if (profile.active_subscription_status !== 'ACTIVE') {
            let xpReward = 100;
            let coinsReward = 30;

            const desc = (payment.description || '').toLowerCase();
            if (desc.includes('cabelo e barba ilimitado')) {
              xpReward = 750;
              coinsReward = 350;
            } else if (desc.includes('corte ilimitado') || desc.includes('barba ilimitado')) {
              xpReward = 500;
              coinsReward = 250;
            }

            await supabaseClient
              .from('profiles')
              .update({ 
                active_subscription_status: 'ACTIVE',
                xp: (profile.xp || 0) + xpReward,
                alce_coins: (profile.alce_coins || 0) + coinsReward
              })
              .eq('id', profile.id)
          } else {
            await supabaseClient
              .from('profiles')
              .update({ active_subscription_status: 'ACTIVE' })
              .eq('id', profile.id)
          }
        }
      } else if (event === 'PAYMENT_OVERDUE' || event === 'PAYMENT_DELETED') {
        // Suspend subscription
        await supabaseClient
          .from('profiles')
          .update({ active_subscription_status: 'INACTIVE' })
          .eq('active_subscription_id', payment.subscription)
      }
    } 

    // Handle Single Payments (Avulso)
    else if (payment.externalReference) {
      // payment.externalReference holds our appointment ID
      if (event === 'PAYMENT_RECEIVED' || event === 'PAYMENT_CONFIRMED') {
        // Update appointment status
        await supabaseClient
          .from('appointments')
          .update({ payment_status: 'PAID' })
          .eq('id', payment.externalReference)

        // Award Gamification Points!
        // We find the user for this appointment
        const { data: appt } = await supabaseClient
          .from('appointments')
          .select('user_id')
          .eq('id', payment.externalReference)
          .single()

        if (appt?.user_id) {
          // Add 50 XP and 10 Coins
          const { data: profile } = await supabaseClient
            .from('profiles')
            .select('xp, alce_coins')
            .eq('id', appt.user_id)
            .single()
            
          if (profile) {
            await supabaseClient
              .from('profiles')
              .update({
                xp: (profile.xp || 0) + 50,
                alce_coins: (profile.alce_coins || 0) + 10
              })
              .eq('id', appt.user_id)
          }
        }
      }
    }

    return new Response(JSON.stringify({ received: true }), {
      headers: { 'Content-Type': 'application/json' }
    })
  } catch (error) {
    console.error('Webhook error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
