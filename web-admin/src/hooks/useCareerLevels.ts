import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { CareerLevel } from '@/lib/supabase/types';

export function useCareerLevels(storeId?: string) {
    const queryClient = useQueryClient();

    const levelsQuery = useQuery({
        queryKey: ['careerLevels', storeId],
        queryFn: async () => {
            let query = supabase
                .from('career_levels')
                .select('*')
                .order('level_order');

            if (storeId) {
                query = query.eq('store_id', storeId);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data as CareerLevel[];
        },
    });

    const createLevel = useMutation({
        mutationFn: async (level: Omit<CareerLevel, 'id' | 'created_at'>) => {
            const { data, error } = await supabase
                .from('career_levels')
                .insert(level)
                .select()
                .single();

            if (error) throw error;
            return data as CareerLevel;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['careerLevels'] });
        },
    });

    const updateLevel = useMutation({
        mutationFn: async ({ id, ...updates }: Partial<CareerLevel> & { id: string }) => {
            const { data, error } = await supabase
                .from('career_levels')
                .update(updates)
                .eq('id', id)
                .select()
                .single();

            if (error) throw error;
            return data as CareerLevel;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['careerLevels'] });
        },
    });

    const deleteLevel = useMutation({
        mutationFn: async (id: string) => {
            const { error } = await supabase
                .from('career_levels')
                .delete()
                .eq('id', id);

            if (error) throw error;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['careerLevels'] });
        },
    });

    return {
        levels: levelsQuery.data ?? [],
        isLoading: levelsQuery.isLoading,
        error: levelsQuery.error,
        createLevel: createLevel.mutate,
        updateLevel: updateLevel.mutate,
        deleteLevel: deleteLevel.mutate,
        isCreating: createLevel.isPending,
        isUpdating: updateLevel.isPending,
        isDeleting: deleteLevel.isPending,
    };
}
