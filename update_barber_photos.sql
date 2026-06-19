-- ==============================================
-- UPDATE SCRIPT: FOTOS DOS PROFISSIONAIS
-- Execute este script no SQL Editor do Supabase
-- ==============================================

UPDATE public.barbers SET avatar_url = 'assets/images/barbers/peterson.jpg' WHERE name ILIKE '%Peterson%';
UPDATE public.barbers SET avatar_url = 'assets/images/barbers/ryan.jpg' WHERE name ILIKE '%Ryan%';
UPDATE public.barbers SET avatar_url = 'assets/images/barbers/jorge.jpg' WHERE name ILIKE '%Jorge%';
UPDATE public.barbers SET avatar_url = 'assets/images/barbers/gabriel.jpg' WHERE name ILIKE '%Gabriel%';
UPDATE public.barbers SET avatar_url = 'assets/images/barbers/thiago.jpg' WHERE name ILIKE '%Thiago%';
UPDATE public.barbers SET avatar_url = 'assets/images/barbers/lucas.jpg' WHERE name ILIKE '%Lucas%';
UPDATE public.barbers SET avatar_url = 'assets/images/barbers/jefferson.jpg' WHERE name ILIKE '%Jerffeson%' OR name ILIKE '%Jefferson%';
