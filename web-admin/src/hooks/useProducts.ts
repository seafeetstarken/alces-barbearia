import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { supabase } from '@/lib/supabase';
import type { Product } from '@/lib/supabase/types';

export function useProducts(storeId?: string) {
    const queryClient = useQueryClient();

    const productsQuery = useQuery({
        queryKey: ['products', storeId],
        queryFn: async () => {
            let query = supabase
                .from('products')
                .select('*')
                .order('name');

            if (storeId) {
                query = query.eq('store_id', storeId);
            }

            const { data, error } = await query;
            if (error) throw error;
            return data as Product[];
        },
    });

    const createProduct = useMutation({
        mutationFn: async (product: Omit<Product, 'id' | 'created_at'>) => {
            const { data, error } = await supabase
                .from('products')
                .insert(product)
                .select()
                .single();

            if (error) throw error;
            return data as Product;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['products'] });
        },
    });

    const updateProduct = useMutation({
        mutationFn: async ({ id, ...updates }: Partial<Product> & { id: string }) => {
            const { data, error } = await supabase
                .from('products')
                .update(updates)
                .eq('id', id)
                .select()
                .single();

            if (error) throw error;
            return data as Product;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['products'] });
        },
    });

    const updateStock = useMutation({
        mutationFn: async ({ id, quantity, type }: { id: string; quantity: number; type: 'add' | 'remove' }) => {
            const { data: product } = await supabase
                .from('products')
                .select('stock_quantity')
                .eq('id', id)
                .single();

            const currentStock = product?.stock_quantity ?? 0;
            const newStock = type === 'add' ? currentStock + quantity : currentStock - quantity;

            const { data, error } = await supabase
                .from('products')
                .update({ stock_quantity: Math.max(0, newStock) })
                .eq('id', id)
                .select()
                .single();

            if (error) throw error;
            return data as Product;
        },
        onSuccess: () => {
            queryClient.invalidateQueries({ queryKey: ['products'] });
        },
    });

    const products = productsQuery.data ?? [];
    const activeProducts = products.filter(p => p.is_active);
    const lowStockProducts = products.filter(p => p.stock_quantity <= p.min_stock);

    return {
        products,
        activeProducts,
        lowStockProducts,
        isLoading: productsQuery.isLoading,
        error: productsQuery.error,
        createProduct: createProduct.mutate,
        updateProduct: updateProduct.mutate,
        updateStock: updateStock.mutate,
        isCreating: createProduct.isPending,
        isUpdating: updateProduct.isPending,
    };
}
