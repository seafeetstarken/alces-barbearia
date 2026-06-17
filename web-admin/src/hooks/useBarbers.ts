import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Barber } from '@/lib/supabase/types';

export function useBarbers(storeId?: string) {
    const queryClient = useQueryClient();

    const barbersQuery = useQuery({
        queryKey: ['barbers', storeId],
        queryFn: async () => {
            let query = supabase
                .from('barbers')
                .select('*')
                .order('name');

            if (storeId) {
                query = query.eq('store_id', storeId);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data as Barber[];
        },
    });

    const createBarber = useMutation({
        mutationFn: async (barber: Omit<Barber, 'id' | 'created_at' | 'updated_at'>) => {
            const { data, error } = await supabase
                .from('barbers')
                .insert(barber)
                .select()
                .single();

            if (error) throw error;
            return data as Barber;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['barbers'] });
        },
    });

    const updateBarber = useMutation({
        mutationFn: async ({ id, ...updates }: Partial<Barber> & { id: string }) => {
            const { data, error } = await supabase
                .from('barbers')
                .update(updates)
                .eq('id', id)
                .select()
                .single();

            if (error) throw error;
            return data as Barber;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['barbers'] });
        },
    });

    const deleteBarber = useMutation({
        mutationFn: async (id: string) => {
            const { error } = await supabase
                .from('barbers')
                .delete()
                .eq('id', id);

            if (error) throw error;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['barbers'] });
        },
    });

    // Get active barbers only
    const activeBarbers = barbersQuery.data?.filter(b => b.is_active) ?? [];

    // Get leaders
    const leaders = barbersQuery.data?.filter(b => b.is_leader && b.is_active) ?? [];

    return {
        barbers: barbersQuery.data ?? [],
        activeBarbers,
        leaders,
        isLoading: barbersQuery.isLoading,
        error: barbersQuery.error,
        createBarber: createBarber.mutate,
        updateBarber: updateBarber.mutate,
        deleteBarber: deleteBarber.mutate,
        isCreating: createBarber.isPending,
        isUpdating: updateBarber.isPending,
        isDeleting: deleteBarber.isPending,
    };
}
