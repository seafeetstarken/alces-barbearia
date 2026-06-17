import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { supabase } from "@/lib/supabase";
import type { CashbackLedgerEntry, CashbackMovementType } from "@/lib/supabase/types";

interface CashbackStatementResponse {
  balance: number;
  statement: CashbackLedgerEntry[];
}

interface RpcEnvelope<T> {
  data: T;
  error: { code?: string; message?: string } | null;
  meta?: Record<string, unknown>;
}

export function useCashback(storeId?: string, clientId?: string) {
  const queryClient = useQueryClient();

  const statementQuery = useQuery({
    queryKey: ["cashback-statement", storeId, clientId],
    queryFn: async () => {
      if (!storeId || !clientId) {
        return { balance: 0, statement: [] } as CashbackStatementResponse;
      }

      const { data, error } = await supabase.rpc(
        "api_cashback_statement" as never,
        {
          target_store_id: storeId,
          target_client_id: clientId,
          page_size: 20,
          page_offset: 0,
        } as never,
      );

      if (error) throw error;
      const envelope = (data ?? { data: { balance: 0, statement: [] }, error: null }) as RpcEnvelope<CashbackStatementResponse>;
      if (envelope.error) throw new Error(envelope.error.message ?? "Falha ao carregar cashback");
      return envelope.data;
    },
    enabled: Boolean(storeId && clientId),
  });

  const createMovement = useMutation({
    mutationFn: async ({
      movementType,
      amount,
      description,
      transactionId,
      appointmentId,
    }: {
      movementType: CashbackMovementType;
      amount: number;
      description?: string;
      transactionId?: string | null;
      appointmentId?: string | null;
    }) => {
      if (!storeId || !clientId) throw new Error("Contexto de loja/cliente ausente");

      const payload = {
        store_id: storeId,
        client_id: clientId,
        movement_type: movementType,
        amount,
        description: description ?? null,
        transaction_id: transactionId ?? null,
        appointment_id: appointmentId ?? null,
        rule_id: null,
        metadata: {},
        created_by: null,
      };

      const { data, error } = await supabase
        .from("cashback_ledger")
        .insert(payload as never)
        .select()
        .single();

      if (error) throw error;
      return data as CashbackLedgerEntry;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["cashback-statement", storeId, clientId] });
    },
  });

  return {
    balance: statementQuery.data?.balance ?? 0,
    statement: statementQuery.data?.statement ?? [],
    isLoading: statementQuery.isLoading,
    error: statementQuery.error,
    createMovement: createMovement.mutate,
    createMovementAsync: createMovement.mutateAsync,
    isCreating: createMovement.isPending,
  };
}
