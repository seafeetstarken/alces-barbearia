import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Service } from '@/lib/supabase/types';

export function useServices(storeId?: string) {
    const queryClient = useQueryClient();

    const servicesQuery = useQuery({
        queryKey: ['services', storeId],
        queryFn: async () => {
            let query = supabase
                .from('services')
                .select('*')
                .order('name');

            if (storeId) {
                query = query.eq('store_id', storeId);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data as Service[];
        },
    });

    const createService = useMutation({
        mutationFn: async (service: Omit<Service, 'id' | 'created_at'>) => {
            const { data, error } = await supabase
                .from('services')
                .insert(service)
                .select()
                .single();

            if (error) throw error;
            return data as Service;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['services'] });
        },
    });

    const updateService = useMutation({
        mutationFn: async ({ id, ...updates }: Partial<Service> & { id: string }) => {
            const { data, error } = await supabase
                .from('services')
                .update(updates)
                .eq('id', id)
                .select()
                .single();

            if (error) throw error;
            return data as Service;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['services'] });
        },
    });

    const deleteService = useMutation({
        mutationFn: async (id: string) => {
            const { error } = await supabase
                .from('services')
                .delete()
                .eq('id', id);

            if (error) throw error;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['services'] });
        },
    });

    const activeServices = servicesQuery.data?.filter(s => s.is_active) ?? [];

    return {
        services: servicesQuery.data ?? [],
        activeServices,
        isLoading: servicesQuery.isLoading,
        error: servicesQuery.error,
        createService: createService.mutate,
        updateService: updateService.mutate,
        deleteService: deleteService.mutate,
        isCreating: createService.isPending,
        isUpdating: updateService.isPending,
        isDeleting: deleteService.isPending,
    };
}
