import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { CashRegister, Transaction, TransactionItem } from '@/lib/supabase/types';

export type TransactionWithRelations = Transaction & {
    barber: { id: string; name: string } | null;
    client: { id: string; name: string } | null;
};

export function useCashier(storeId?: string) {
    const queryClient = useQueryClient();

    // Get today's open cash register
    const cashRegisterQuery = useQuery({
        queryKey: ['cashRegister', storeId, 'open'],
        queryFn: async () => {
            let query = supabase
                .from('cash_registers')
                .select('*')
                .eq('status', 'open')
                .order('opened_at', { ascending: false })
                .limit(1);

            if (storeId) {
                query = query.eq('store_id', storeId);
            }

            const { data, error } = await query.maybeSingle();
            if (error) throw error;
            return data as CashRegister | null;
        },
    });

    // Get today's transactions
    const today = new Date().toISOString().split('T')[0];
    const transactionsQuery = useQuery({
        queryKey: ['transactions', storeId, today],
        queryFn: async () => {
            let query = supabase
                .from('transactions')
                .select('*, barber:barbers(id, name), client:clients(id, name)')
                .gte('created_at', `${today}T00:00:00`)
                .order('created_at', { ascending: false });

            if (storeId) {
                query = query.eq('store_id', storeId);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data as TransactionWithRelations[];
        },
    });

    const openCashRegister = useMutation({
        mutationFn: async ({ openingBalance, openedBy }: { openingBalance: number; openedBy?: string }) => {
            if (!storeId) throw new Error('Store ID required');

            const { data, error } = await supabase
                .from('cash_registers')
                .insert({
                    store_id: storeId,
                    opening_balance: openingBalance,
                    opened_by: openedBy,
                    status: 'open',
                })
                .select()
                .single();

            if (error) throw error;
            return data as CashRegister;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['cashRegister'] });
        },
    });

    const closeCashRegister = useMutation({
        mutationFn: async ({ closingBalance, closedBy }: { closingBalance: number; closedBy?: string }) => {
            const cashRegister = cashRegisterQuery.data;
            if (!cashRegister) throw new Error('No open cash register');

            const { data, error } = await supabase
                .from('cash_registers')
                .update({
                    closing_balance: closingBalance,
                    closed_by: closedBy,
                    closed_at: new Date().toISOString(),
                    status: 'closed',
                })
                .eq('id', cashRegister.id)
                .select()
                .single();

            if (error) throw error;
            return data as CashRegister;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['cashRegister'] });
        },
    });

    const createTransaction = useMutation({
        mutationFn: async ({
            transaction,
            items,
        }: {
            transaction: Omit<Transaction, 'id' | 'created_at'>;
            items?: Omit<TransactionItem, 'id' | 'transaction_id'>[];
        }) => {
            const cashRegister = cashRegisterQuery.data;

            const { data: txn, error: txnError } = await supabase
                .from('transactions')
                .insert({
                    ...transaction,
                    cash_register_id: cashRegister?.id,
                })
                .select()
                .single();

            if (txnError) throw txnError;

            // Insert items if provided
            if (items && items.length > 0) {
                const { error: itemsError } = await supabase
                    .from('transaction_items')
                    .insert(items.map(item => ({ ...item, transaction_id: txn.id })));

                if (itemsError) throw itemsError;

                // Calculate and record points for service transactions
                const serviceItems = items.filter(item => item.service_id && item.points > 0);
                if (serviceItems.length > 0 && transaction.barber_id) {
                    const totalPoints = serviceItems.reduce((sum, item) => sum + item.points * item.quantity, 0);

                    await supabase.from('points').insert({
                        store_id: transaction.store_id,
                        barber_id: transaction.barber_id,
                        transaction_id: txn.id,
                        points: totalPoints,
                    });
                }
            }

            return txn as Transaction;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['transactions'] });
            queryClient.invalidateQueries({ queryKey: ['points'] });
        },
    });

    // Calculate totals
    const transactions = transactionsQuery.data ?? [];
    const totalIncome = transactions
        .filter(t => t.type === 'service' || t.type === 'product' || t.type === 'deposit')
        .reduce((sum, t) => sum + t.amount, 0);
    const totalExpenses = transactions
        .filter(t => t.type === 'expense' || t.type === 'withdrawal')
        .reduce((sum, t) => sum + t.amount, 0);

    return {
        cashRegister: cashRegisterQuery.data,
        isOpen: !!cashRegisterQuery.data,
        transactions,
        totalIncome,
        totalExpenses,
        balance: totalIncome - totalExpenses + (cashRegisterQuery.data?.opening_balance ?? 0),
        isLoading: cashRegisterQuery.isLoading || transactionsQuery.isLoading,
        openCashRegister: openCashRegister.mutate,
        closeCashRegister: closeCashRegister.mutate,
        closeCashRegisterAsync: closeCashRegister.mutateAsync,
        createTransaction: createTransaction.mutate,
        createTransactionAsync: createTransaction.mutateAsync,
        error: cashRegisterQuery.error || transactionsQuery.error,
        isOpening: openCashRegister.isPending,
        isClosing: closeCashRegister.isPending,
        isCreating: createTransaction.isPending,
    };
}
