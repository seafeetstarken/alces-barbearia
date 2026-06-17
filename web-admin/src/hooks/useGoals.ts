import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Goal } from '@/lib/supabase/types';

export function useGoals(storeId?: string) {
    const queryClient = useQueryClient();

    const goalsQuery = useQuery({
        queryKey: ['goals', storeId],
        queryFn: async () => {
            let query = supabase
                .from('goals')
                .select('*, barber:barbers(id, name)')
                .order('end_date', { ascending: false });

            if (storeId) {
                query = query.eq('store_id', storeId);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data as (Goal & { barber: { id: string; name: string } })[];
        },
    });

    const createGoal = useMutation({
        mutationFn: async (goal: Omit<Goal, 'id' | 'created_at' | 'current_value' | 'is_achieved'>) => {
            const { data, error } = await supabase
                .from('goals')
                .insert({ ...goal, current_value: 0, is_achieved: false })
                .select()
                .single();

            if (error) throw error;
            return data as Goal;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['goals'] });
        },
    });

    const updateGoalProgress = useMutation({
        mutationFn: async ({ id, currentValue }: { id: string; currentValue: number }) => {
            const { data: goal } = await supabase
                .from('goals')
                .select('target_value')
                .eq('id', id)
                .single();

            const isAchieved = currentValue >= (goal?.target_value ?? Infinity);

            const { data, error } = await supabase
                .from('goals')
                .update({ current_value: currentValue, is_achieved: isAchieved })
                .eq('id', id)
                .select()
                .single();

            if (error) throw error;
            return data as Goal;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['goals'] });
        },
    });

    const deleteGoal = useMutation({
        mutationFn: async (id: string) => {
            const { error } = await supabase
                .from('goals')
                .delete()
                .eq('id', id);

            if (error) throw error;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['goals'] });
        },
    });

    const goals = goalsQuery.data ?? [];
    const activeGoals = goals.filter(g => new Date(g.end_date) >= new Date() && !g.is_achieved);
    const achievedGoals = goals.filter(g => g.is_achieved);

    return {
        goals,
        activeGoals,
        achievedGoals,
        isLoading: goalsQuery.isLoading,
        error: goalsQuery.error,
        createGoal: createGoal.mutate,
        updateGoalProgress: updateGoalProgress.mutate,
        deleteGoal: deleteGoal.mutate,
        isCreating: createGoal.isPending,
        isUpdating: updateGoalProgress.isPending,
        isDeleting: deleteGoal.isPending,
    };
}
