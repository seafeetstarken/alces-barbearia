import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Schedule } from '@/lib/supabase/types';

const DAY_NAMES = ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'];

export function useSchedule(storeId?: string, barberId?: string) {
    const queryClient = useQueryClient();

    const schedulesQuery = useQuery({
        queryKey: ['schedules', storeId, barberId],
        queryFn: async () => {
            let query = supabase
                .from('schedules')
                .select('*, barber:barbers(id, name)')
                .order('day_of_week')
                .order('start_time');

            if (storeId) {
                query = query.eq('store_id', storeId);
            }
            if (barberId) {
                query = query.eq('barber_id', barberId);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data as (Schedule & { barber: { id: string; name: string } })[];
        },
    });

    const createSchedule = useMutation({
        mutationFn: async (schedule: Omit<Schedule, 'id'>) => {
            const { data, error } = await supabase
                .from('schedules')
                .insert(schedule)
                .select()
                .single();

            if (error) throw error;
            return data as Schedule;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['schedules'] });
        },
    });

    const updateSchedule = useMutation({
        mutationFn: async ({ id, ...updates }: Partial<Schedule> & { id: string }) => {
            const { data, error } = await supabase
                .from('schedules')
                .update(updates)
                .eq('id', id)
                .select()
                .single();

            if (error) throw error;
            return data as Schedule;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['schedules'] });
        },
    });

    const deleteSchedule = useMutation({
        mutationFn: async (id: string) => {
            const { error } = await supabase
                .from('schedules')
                .delete()
                .eq('id', id);

            if (error) throw error;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['schedules'] });
        },
    });

    // Group by day of week
    const schedules = schedulesQuery.data ?? [];
    const schedulesByDay = schedules.reduce((acc, s) => {
        if (!acc[s.day_of_week]) {
            acc[s.day_of_week] = { day: s.day_of_week, dayName: DAY_NAMES[s.day_of_week], schedules: [] };
        }
        acc[s.day_of_week].schedules.push(s);
        return acc;
    }, {} as Record<number, { day: number; dayName: string; schedules: (Schedule & { barber: { id: string; name: string } })[] }>);

    // Get today's schedule
    const today = new Date().getDay();
    const todaySchedules = schedules.filter(s => s.day_of_week === today && s.is_active);

    return {
        schedules,
        schedulesByDay: Object.values(schedulesByDay),
        todaySchedules,
        dayNames: DAY_NAMES,
        isLoading: schedulesQuery.isLoading,
        error: schedulesQuery.error,
        createSchedule: createSchedule.mutate,
        updateSchedule: updateSchedule.mutate,
        deleteSchedule: deleteSchedule.mutate,
        isCreating: createSchedule.isPending,
        isUpdating: updateSchedule.isPending,
        isDeleting: deleteSchedule.isPending,
    };
}
