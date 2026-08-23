-- Insert a profile for every auth.user that does not yet have a row in public.profiles.
-- Uses available fields from auth.users; safe to run multiple times.

INSERT INTO public.profiles (id, name, email, role, is_active, created_at)
SELECT
  u.id,
  COALESCE(u.raw_user_meta_data->>'full_name', u.raw_user_meta_data->>'name', u.email) AS name,
  u.email,
  'pengguna' AS role,
  true AS is_active,
  COALESCE(u.created_at, now()) AS created_at
FROM auth.users u
LEFT JOIN public.profiles p ON p.id = u.id
WHERE p.id IS NULL;
