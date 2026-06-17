import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Commission, Points } from '@/lib/supabase/types';

export function useCommissions(storeId?: string) {
    const queryClient = useQueryClient();

    // Get barber points for current period
    const pointsQuery = useQuery({
        queryKey: ['points', storeId],
        queryFn: async () => {
            const startOfMonth = new Date();
            startOfMonth.setDate(1);
            startOfMonth.setHours(0, 0, 0, 0);

            let query = supabase
                .from('points')
                .select('*, barber:barbers(id, name, level_multiplier)')
                .gte('earned_at', startOfMonth.toISOString());

            if (storeId) {
                query = query.eq('store_id', storeId);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data;
        },
    });

    // Get commissions history
    const commissionsQuery = useQuery({
        queryKey: ['commissions', storeId],
        queryFn: async () => {
            let query = supabase
                .from('commissions')
                .select('*, barber:barbers(id, name)')
                .order('period_end', { ascending: false })
                .limit(50);

            if (storeId) {
                query = query.eq('store_id', storeId);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data as (Commission & { barber: { id: string; name: string } })[];
        },
    });

    // Calculate commission for a period
    const calculateCommission = useMutation({
        mutationFn: async ({
            barberId,
            periodStart,
            periodEnd,
            commissionPercentage = 43,
        }: {
            barberId: string;
            periodStart: Date;
            periodEnd: Date;
            commissionPercentage?: number;
        }) => {
            if (!storeId) throw new Error('Store ID required');

            // Get barber info
            const { data: barber } = await supabase
                .from('barbers')
                .select('level_multiplier')
                .eq('id', barberId)
                .single();

            // Get points for period
            const { data: points } = await supabase
                .from('points')
                .select('points')
                .eq('barber_id', barberId)
                .gte('earned_at', periodStart.toISOString())
                .lte('earned_at', periodEnd.toISOString());

            // Get total revenue for period
            const { data: transactions } = await supabase
                .from('transactions')
                .select('amount')
                .eq('store_id', storeId)
                .in('type', ['service', 'product'])
                .gte('created_at', periodStart.toISOString())
                .lte('created_at', periodEnd.toISOString());

            // Get all barber points for period
            const { data: allPoints } = await supabase
                .from('points')
                .select('points')
                .eq('store_id', storeId)
                .gte('earned_at', periodStart.toISOString())
                .lte('earned_at', periodEnd.toISOString());

            const totalRevenue = transactions?.reduce((sum, t) => sum + t.amount, 0) ?? 0;
            const totalPool = totalRevenue * (commissionPercentage / 100);
            const barberPoints = points?.reduce((sum, p) => sum + p.points, 0) ?? 0;
            const allBarberPoints = allPoints?.reduce((sum, p) => sum + p.points, 0) ?? 0;

            // Calculate share based on points ratio
            const pointsRatio = allBarberPoints > 0 ? barberPoints / allBarberPoints : 0;
            const baseValue = totalPool * pointsRatio;
            const multiplier = barber?.level_multiplier ?? 1;
            const finalValue = baseValue * multiplier;

            // Insert commission record
            const { data, error } = await supabase
                .from('commissions')
                .insert({
                    store_id: storeId,
                    barber_id: barberId,
                    period_start: periodStart.toISOString().split('T')[0],
                    period_end: periodEnd.toISOString().split('T')[0],
                    total_points: barberPoints,
                    base_value: baseValue,
                    multiplier,
                    final_value: finalValue,
                    status: 'pending',
                })
                .select()
                .single();

            if (error) throw error;
            return data as Commission;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['commissions'] });
        },
    });

    const markAsPaid = useMutation({
        mutationFn: async (commissionId: string) => {
            const { data, error } = await supabase
                .from('commissions')
                .update({
                    status: 'paid',
                    paid_at: new Date().toISOString(),
                })
                .eq('id', commissionId)
                .select()
                .single();

            if (error) throw error;
            return data as Commission;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['commissions'] });
        },
    });

    // Aggregate points by barber
    const pointsByBarber = ((pointsQuery.data as unknown[]) ?? []).reduce((acc, p) => {
        const barberId = (p as Record<string, unknown>).barber_id as string;
        if (!acc[barberId]) {
            acc[barberId] = {
                barberId,
                barberName: ((p as Record<string, unknown>).barber as Record<string, unknown>)?.name as string ?? 'Unknown',
                multiplier: ((p as Record<string, unknown>).barber as Record<string, unknown>)?.level_multiplier as number ?? 1,
                totalPoints: 0,
            };
        }
        acc[barberId].totalPoints += (p as Record<string, number>).points;
        return acc;
    }, {} as Record<string, { barberId: string; barberName: string; multiplier: number; totalPoints: number }>);

    return {
        points: pointsQuery.data ?? [],
        pointsByBarber: Object.values(pointsByBarber) as { barberId: string; barberName: string; multiplier: number; totalPoints: number }[],
        commissions: commissionsQuery.data ?? [],
        isLoading: pointsQuery.isLoading || commissionsQuery.isLoading,
        calculateCommission: calculateCommission.mutate,
        markAsPaid: markAsPaid.mutate,
        isCalculating: calculateCommission.isPending,
        isMarkingPaid: markAsPaid.isPending,
    };
}
