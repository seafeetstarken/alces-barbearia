import { useEffect, useMemo, useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Store, MembershipRole } from '@/lib/supabase/types';

const ACTIVE_STORE_KEY = 'active_store_id';

interface StoreMembership {
    store_id: string;
    role: MembershipRole;
    store: Store | null;
}

export function useStore(storeId?: string) {
    const queryClient = useQueryClient();
    const [activeStoreId, setActiveStoreIdState] = useState<string | null>(() => {
        if (typeof window === 'undefined') return null;
        return localStorage.getItem(ACTIVE_STORE_KEY);
    });

    const membershipsQuery = useQuery({
        queryKey: ['store-memberships'],
        queryFn: async () => {
            const { data, error } = await supabase
                .from('user_store_memberships')
                .select('store_id, role, store:stores(*)')
                .eq('is_active', true)
                .order('created_at', { ascending: true });

            if (error) throw error;
            return (data ?? []) as unknown as StoreMembership[];
        },
    });

    const stores = useMemo(
        () => (membershipsQuery.data ?? []).map((membership) => membership.store).filter(Boolean) as Store[],
        [membershipsQuery.data]
    );

    const resolvedStoreId = storeId ?? activeStoreId ?? stores[0]?.id ?? null;

    useEffect(() => {
        if (!storeId && !activeStoreId && stores[0]?.id) {
            localStorage.setItem(ACTIVE_STORE_KEY, stores[0].id);
            setActiveStoreIdState(stores[0].id);
        }
    }, [storeId, activeStoreId, stores]);

    const storeQuery = useQuery({
        queryKey: ['store', resolvedStoreId],
        queryFn: async () => {
            if (!resolvedStoreId) return null;

            const { data, error } = await supabase
                .from('stores')
                .select('*')
                .eq('id', resolvedStoreId)
                .single();

            if (error) throw error;
            return data as Store;
        },
        enabled: Boolean(resolvedStoreId),
    });

    const updateStore = useMutation({
        mutationFn: async (updates: Partial<Store>) => {
            if (!resolvedStoreId) throw new Error('Store ID required');

            const { data, error } = await supabase
                .from('stores')
                .update(updates)
                .eq('id', resolvedStoreId)
                .select()
                .single();

            if (error) throw error;
            return data as Store;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['store', resolvedStoreId] });
            queryClient.invalidateQueries({ queryKey: ['store-memberships'] });
        },
    });

    const setActiveStoreId = (nextStoreId: string) => {
        localStorage.setItem(ACTIVE_STORE_KEY, nextStoreId);
        setActiveStoreIdState(nextStoreId);
    };

    return {
        store: storeQuery.data,
        stores,
        memberships: membershipsQuery.data ?? [],
        activeStoreId: resolvedStoreId,
        setActiveStoreId,
        isLoading: membershipsQuery.isLoading || storeQuery.isLoading,
        error: membershipsQuery.error || storeQuery.error,
        updateStore: updateStore.mutate,
        isUpdating: updateStore.isPending,
    };
}
