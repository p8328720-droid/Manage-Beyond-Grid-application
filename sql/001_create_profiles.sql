-- Migration: create profiles table to store user profiles linked to Supabase Auth users

CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  name text,
  email text,
  role text DEFAULT 'pengguna',
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Optional: index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles (lower(email));
