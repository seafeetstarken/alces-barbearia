import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/lib/supabase";
import type { StoreSubscription, SubscriptionPlan, SubscriptionStatus } from "@/lib/supabase/types";

interface RpcEnvelope<T> {
  data: T;
  error: { code?: string; message?: string } | null;
  meta?: Record<string, unknown>;
}

export function useBilling(storeId?: string) {
  const queryClient = useQueryClient();

  const plansQuery = useQuery({
    queryKey: ["subscription-plans"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from("subscription_plans")
        .select("*")
        .eq("is_active", true)
        .order("amount_cents", { ascending: true });

      if (error) throw error;
      return (data ?? []) as SubscriptionPlan[];
    },
  });

  const subscriptionQuery = useQuery({
    queryKey: ["store-subscription", storeId],
    queryFn: async () => {
      if (!storeId) return null;

      const { data, error } = await supabase.rpc(
        "api_store_subscription_status" as never,
        { target_store_id: storeId } as never,
      );

      if (error) throw error;
      const envelope = (data ?? { data: null, error: null }) as RpcEnvelope<StoreSubscription | null>;
      if (envelope.error) throw new Error(envelope.error.message ?? "Falha ao carregar assinatura");
      return envelope.data ?? null;
    },
    enabled: Boolean(storeId),
  });

  const updateSubscriptionStatus = useMutation({
    mutationFn: async ({
      planId,
      status,
      providerSubscriptionId,
    }: {
      planId: string;
      status: SubscriptionStatus;
      providerSubscriptionId?: string;
    }) => {
      if (!storeId) throw new Error("Loja não encontrada");

      const activeSubscription = subscriptionQuery.data;
      if (activeSubscription?.id) {
        const { data, error } = await supabase.from("store_subscriptions")
          .update({
            plan_id: planId,
            status,
            provider_subscription_id: providerSubscriptionId ?? activeSubscription.provider_subscription_id,
            canceled_at: status === "canceled" ? new Date().toISOString() : null,
          } as never)
          .eq("id", activeSubscription.id)
          .select()
          .single();

        if (error) throw error;
        return data as StoreSubscription;
      }

      const { data, error } = await supabase.from("store_subscriptions")
        .insert({
          store_id: storeId,
          plan_id: planId,
          provider: "asaas",
          status,
          provider_subscription_id: providerSubscriptionId ?? null,
          current_period_start: new Date().toISOString(),
          current_period_end: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString(),
        } as never)
        .select()
        .single();

      if (error) throw error;
      return data as StoreSubscription;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["store-subscription", storeId] });
    },
  });

  return {
    plans: plansQuery.data ?? [],
    subscription: subscriptionQuery.data,
    isLoading: plansQuery.isLoading || subscriptionQuery.isLoading,
    error: plansQuery.error || subscriptionQuery.error,
    updateSubscriptionStatus: updateSubscriptionStatus.mutate,
    updateSubscriptionStatusAsync: updateSubscriptionStatus.mutateAsync,
    isUpdating: updateSubscriptionStatus.isPending,
  };
}
