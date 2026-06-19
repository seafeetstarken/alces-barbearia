-- ==============================================
-- MIGRAÇÃO DE GAMIFICAÇÃO: O CAMINHO DO ALCE
-- Execute este script no SQL Editor do Supabase
-- ==============================================

-- 1. Adicionando campos à tabela de Perfil
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS xp INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS alce_coins INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS level INTEGER DEFAULT 1;

-- 2. Adicionando campo de categoria aos Serviços
ALTER TABLE public.services 
ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'Geral';

-- Opcional: Classificando alguns serviços existentes (exemplo)
UPDATE public.services SET category = 'Cortes' WHERE name ILIKE '%corte%';
UPDATE public.services SET category = 'Barboterapia' WHERE name ILIKE '%barba%';
UPDATE public.services SET category = 'Química' WHERE name ILIKE '%química%' OR name ILIKE '%luzes%' OR name ILIKE '%pigmentação%';
