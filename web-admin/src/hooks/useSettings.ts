import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Settings } from '@/lib/supabase/types';

export function useSettings(storeId?: string) {
    const queryClient = useQueryClient();

    const settingsQuery = useQuery({
        queryKey: ['settings', storeId],
        queryFn: async () => {
            let query = supabase.from('settings').select('*');

            if (storeId) {
                query = query.eq('store_id', storeId);
            }

            const { data, error } = await query.limit(1).single();
            if (error) {
                // If no settings exist, return default
                if (error.code === 'PGRST116') {
                    return null;
                }
                throw error;
            }
            return data as Settings;
        },
    });

    const updateSettings = useMutation({
        mutationFn: async (updates: Partial<Settings>) => {
            if (!storeId) throw new Error('Store ID required');

            // Check if settings exist
            const { data: existing } = await supabase
                .from('settings')
                .select('id')
                .eq('store_id', storeId)
                .single();

            if (existing) {
                // Update existing
                const { data, error } = await supabase
                    .from('settings')
                    .update(updates)
                    .eq('store_id', storeId)
                    .select()
                    .single();

                if (error) throw error;
                return data as Settings;
            } else {
                // Insert new
                const { data, error } = await supabase
                    .from('settings')
                    .insert({ ...updates, store_id: storeId })
                    .select()
                    .single();

                if (error) throw error;
                return data as Settings;
            }
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['settings'] });
        },
    });

    // Apply theme settings to CSS variables
    const applyTheme = (settings: Settings | null) => {
        if (!settings) return;

        const root = document.documentElement;

        // Apply colors (convert hex to HSL would be needed, for now just set raw values)
        if (settings.primary_color) {
            root.style.setProperty('--brand-primary', settings.primary_color);
        }
        if (settings.font_family) {
            root.style.setProperty('--font-sans', settings.font_family);
        }
        if (settings.border_radius) {
            root.style.setProperty('--radius', `${settings.border_radius}rem`);
        }
    };

    return {
        settings: settingsQuery.data,
        isLoading: settingsQuery.isLoading,
        error: settingsQuery.error,
        updateSettings: updateSettings.mutate,
        isUpdating: updateSettings.isPending,
        applyTheme,
    };
}
