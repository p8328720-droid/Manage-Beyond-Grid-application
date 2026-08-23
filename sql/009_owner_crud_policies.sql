DROP POLICY IF EXISTS delete_admin ON public.profiles;
CREATE POLICY delete_own_or_admin ON public.profiles
  FOR DELETE
  USING (auth.uid() = id OR (auth.jwt() ->> 'role') = 'administrator');

DROP POLICY IF EXISTS devices_delete_admin ON public.devices;
CREATE POLICY devices_delete_owner_admin ON public.devices
  FOR DELETE
  USING (auth.uid() = user_id OR (auth.jwt() ->> 'role') = 'administrator');
