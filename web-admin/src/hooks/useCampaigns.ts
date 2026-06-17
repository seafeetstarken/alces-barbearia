import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/lib/supabase";
import type { Campaign, CampaignResultStatus } from "@/lib/supabase/types";

export interface CampaignOverviewItem {
  id: string;
  name: string;
  status: Campaign["status"];
  objective: string;
  channel: Campaign["channel"];
  starts_at: string | null;
  ends_at: string | null;
  delivered: number;
  opened: number;
  converted: number;
  revenue_amount: number;
}

interface RpcEnvelope<T> {
  data: T;
  error: { code?: string; message?: string } | null;
  meta?: Record<string, unknown>;
}

export function useCampaigns(storeId?: string) {
  const queryClient = useQueryClient();

  const overviewQuery = useQuery({
    queryKey: ["campaign-overview", storeId],
    queryFn: async () => {
      if (!storeId) return [] as CampaignOverviewItem[];

      const { data, error } = await supabase.rpc(
        "api_campaign_overview" as never,
        { target_store_id: storeId } as never,
      );

      if (error) throw error;
      const envelope = (data ?? { data: [], error: null }) as RpcEnvelope<CampaignOverviewItem[]>;
      if (envelope.error) throw new Error(envelope.error.message ?? "Falha ao carregar campanhas");
      return envelope.data ?? [];
    },
    enabled: Boolean(storeId),
  });

  const createCampaign = useMutation({
    mutationFn: async (campaign: Omit<Campaign, "id" | "created_at" | "updated_at">) => {
      const { data, error } = await supabase
        .from("campaigns")
        .insert(campaign as never)
        .select()
        .single();

      if (error) throw error;
      return data as Campaign;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["campaign-overview", storeId] });
    },
  });

  const registerCampaignResult = useMutation({
    mutationFn: async ({
      campaignId,
      status,
      revenueAmount,
      clientId,
    }: {
      campaignId: string;
      status: CampaignResultStatus;
      revenueAmount?: number;
      clientId?: string | null;
    }) => {
      if (!storeId) throw new Error("Loja não encontrada");

      const { error } = await supabase.from("campaign_results").insert({
        campaign_id: campaignId,
        store_id: storeId,
        client_id: clientId ?? null,
        status,
        revenue_amount: revenueAmount ?? 0,
        metadata: {},
      } as never);

      if (error) throw error;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["campaign-overview", storeId] });
    },
  });

  return {
    campaigns: overviewQuery.data ?? [],
    isLoading: overviewQuery.isLoading,
    error: overviewQuery.error,
    createCampaign: createCampaign.mutate,
    registerCampaignResult: registerCampaignResult.mutate,
    isCreating: createCampaign.isPending,
    isRegisteringResult: registerCampaignResult.isPending,
  };
}
