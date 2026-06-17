import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Client } from '@/lib/supabase/types';

export function useClients(storeId?: string) {
    const queryClient = useQueryClient();

    const clientsQuery = useQuery({
        queryKey: ['clients', storeId],
        queryFn: async () => {
            let query = supabase
                .from('clients')
                .select('*, preferred_barber:barbers(id, name)')
                .order('name');

            if (storeId) {
                query = query.eq('store_id', storeId);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data as (Client & { preferred_barber: { id: string; name: string } | null })[];
        },
    });

    const createClient = useMutation({
        mutationFn: async (client: Omit<Client, 'id' | 'created_at' | 'total_visits' | 'last_visit_at'>) => {
            const { data, error } = await supabase
                .from('clients')
                .insert(client)
                .select()
                .single();

            if (error) throw error;
            return data as Client;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['clients'] });
        },
    });

    const updateClient = useMutation({
        mutationFn: async ({ id, ...updates }: Partial<Client> & { id: string }) => {
            const { data, error } = await supabase
                .from('clients')
                .update(updates)
                .eq('id', id)
                .select()
                .single();

            if (error) throw error;
            return data as Client;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['clients'] });
        },
    });

    const recordVisit = useMutation({
        mutationFn: async (clientId: string) => {
            const { data: client } = await supabase
                .from('clients')
                .select('total_visits')
                .eq('id', clientId)
                .single();

            const { data, error } = await supabase
                .from('clients')
                .update({
                    total_visits: (client?.total_visits ?? 0) + 1,
                    last_visit_at: new Date().toISOString(),
                })
                .eq('id', clientId)
                .select()
                .single();

            if (error) throw error;
            return data as Client;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['clients'] });
        },
    });

    // Filter by status
    const clients = clientsQuery.data ?? [];
    const activeClients = clients.filter(c => c.status === 'active');
    const inactiveClients = clients.filter(c => c.status === 'inactive');
    const overdueClients = clients.filter(c => c.status === 'overdue');
    const blacklistClients = clients.filter(c => c.status === 'blacklist');

    return {
        clients,
        activeClients,
        inactiveClients,
        overdueClients,
        blacklistClients,
        isLoading: clientsQuery.isLoading,
        error: clientsQuery.error,
        createClient: createClient.mutate,
        updateClient: updateClient.mutate,
        recordVisit: recordVisit.mutate,
        isCreating: createClient.isPending,
        isUpdating: updateClient.isPending,
    };
}
