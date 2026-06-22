-- =========================================================================
-- CORREÇÃO DE ERRO 500 (RECURSÃO INFINITA NA POLÍTICA RLS DE PROFILES)
-- Execute este script no SQL Editor do seu painel do Supabase.
-- =========================================================================

-- 1. Remove a política antiga que causava a recursão infinita
DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;

-- 2. Cria uma função auxiliar com SECURITY DEFINER (roda com privilégios de administrador/bypass RLS)
-- Isso evita que a verificação de admin consulte a mesma tabela gerando loop.
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN SECURITY DEFINER AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true
  );
END;
$$ LANGUAGE plpgsql;

-- 3. Recria a política utilizando a nova função segura
CREATE POLICY "Admins can view all profiles" ON public.profiles 
FOR SELECT USING (
  public.is_admin()
);
