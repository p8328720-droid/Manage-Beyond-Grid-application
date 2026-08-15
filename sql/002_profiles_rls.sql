ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY select_own_or_admin ON public.profiles
  FOR SELECT
  USING (auth.uid() = id OR (auth.jwt() ->> 'role') = 'administrator');

CREATE POLICY insert_own ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY update_own_or_admin ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id OR (auth.jwt() ->> 'role') = 'administrator')
  WITH CHECK (auth.uid() = id OR (auth.jwt() ->> 'role') = 'administrator');

CREATE POLICY delete_admin ON public.profiles
  FOR DELETE
  USING ((auth.jwt() ->> 'role') = 'administrator');
