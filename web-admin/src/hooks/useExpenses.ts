import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Expense } from '@/lib/supabase/types';

export function useExpenses(storeId?: string) {
    const queryClient = useQueryClient();

    const expensesQuery = useQuery({
        queryKey: ['expenses', storeId],
        queryFn: async () => {
            let query = supabase
                .from('expenses')
                .select('*, created_by_profile:profiles(full_name)')
                .order('expense_date', { ascending: false });

            if (storeId) {
                query = query.eq('store_id', storeId);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data as (Expense & { created_by_profile: { full_name: string } | null })[];
        },
    });

    const createExpense = useMutation({
        mutationFn: async (expense: Omit<Expense, 'id' | 'created_at'>) => {
            const { data, error } = await supabase
                .from('expenses')
                .insert(expense)
                .select()
                .single();

            if (error) throw error;
            return data as Expense;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['expenses'] });
        },
    });

    const deleteExpense = useMutation({
        mutationFn: async (id: string) => {
            const { error } = await supabase
                .from('expenses')
                .delete()
                .eq('id', id);

            if (error) throw error;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['expenses'] });
        },
    });

    // Group by category
    const expenses = expensesQuery.data ?? [];
    const expensesByCategory = expenses.reduce((acc, e) => {
        if (!acc[e.category]) {
            acc[e.category] = { category: e.category, total: 0, count: 0 };
        }
        acc[e.category].total += e.amount;
        acc[e.category].count += 1;
        return acc;
    }, {} as Record<string, { category: string; total: number; count: number }>);

    const totalExpenses = expenses.reduce((sum, e) => sum + e.amount, 0);

    return {
        expenses,
        expensesByCategory: Object.values(expensesByCategory),
        totalExpenses,
        isLoading: expensesQuery.isLoading,
        error: expensesQuery.error,
        createExpense: createExpense.mutate,
        deleteExpense: deleteExpense.mutate,
        isCreating: createExpense.isPending,
        isDeleting: deleteExpense.isPending,
    };
}
