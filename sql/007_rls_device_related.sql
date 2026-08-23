-- Enable RLS and policies for UUID-based tables
ALTER TABLE IF EXISTS public.devices ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS devices_select_owner_admin ON public.devices
  FOR SELECT
  USING (auth.uid() = user_id OR (auth.jwt() ->> 'role') = 'administrator');

CREATE POLICY IF NOT EXISTS devices_insert_owner ON public.devices
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS devices_update_owner_admin ON public.devices
  FOR UPDATE
  USING (auth.uid() = user_id OR (auth.jwt() ->> 'role') = 'administrator')
  WITH CHECK (auth.uid() = user_id OR (auth.jwt() ->> 'role') = 'administrator');

CREATE POLICY IF NOT EXISTS devices_delete_admin ON public.devices
  FOR DELETE
  USING ((auth.jwt() ->> 'role') = 'administrator');

-- device_logs: allow owner of device or admin
ALTER TABLE IF EXISTS public.device_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS device_logs_select_owner_admin ON public.device_logs
  FOR SELECT
  USING (
    auth.uid() = (SELECT user_id FROM public.devices WHERE device_id = public.device_logs.device_id)
    OR (auth.jwt() ->> 'role') = 'administrator'
  );

CREATE POLICY IF NOT EXISTS device_logs_insert_owner ON public.device_logs
  FOR INSERT
  WITH CHECK (
    auth.uid() = (SELECT user_id FROM public.devices WHERE device_id = public.device_logs.device_id)
  );

CREATE POLICY IF NOT EXISTS device_logs_delete_admin ON public.device_logs
  FOR DELETE
  USING ((auth.jwt() ->> 'role') = 'administrator');

-- device_controls: allow device owner and admin; allow executed_by as admin or same user
ALTER TABLE IF EXISTS public.device_controls ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS device_controls_select_owner_admin ON public.device_controls
  FOR SELECT
  USING (
    auth.uid() = (SELECT user_id FROM public.devices WHERE device_id = public.device_controls.device_id)
    OR (auth.jwt() ->> 'role') = 'administrator'
  );

CREATE POLICY IF NOT EXISTS device_controls_insert_owner ON public.device_controls
  FOR INSERT
  WITH CHECK (
    auth.uid() = (SELECT user_id FROM public.devices WHERE device_id = public.device_controls.device_id)
    OR auth.uid() = executed_by
  );

CREATE POLICY IF NOT EXISTS device_controls_update_owner_admin ON public.device_controls
  FOR UPDATE
  USING (
    auth.uid() = (SELECT user_id FROM public.devices WHERE device_id = public.device_controls.device_id)
    OR (auth.jwt() ->> 'role') = 'administrator'
  )
  WITH CHECK (
    auth.uid() = (SELECT user_id FROM public.devices WHERE device_id = public.device_controls.device_id)
    OR (auth.jwt() ->> 'role') = 'administrator'
  );

-- ai_insights: owner is device owner or admin
ALTER TABLE IF EXISTS public.ai_insights ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS ai_insights_select_owner_admin ON public.ai_insights
  FOR SELECT
  USING (
    auth.uid() = (SELECT user_id FROM public.devices WHERE device_id = public.ai_insights.device_id)
    OR (auth.jwt() ->> 'role') = 'administrator'
  );

CREATE POLICY IF NOT EXISTS ai_insights_insert_owner ON public.ai_insights
  FOR INSERT
  WITH CHECK (
    auth.uid() = (SELECT user_id FROM public.devices WHERE device_id = public.ai_insights.device_id)
  );

-- notifications: allow recipient (user_id) or device owner or admin
ALTER TABLE IF EXISTS public.notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS notifications_select_owner_admin ON public.notifications
  FOR SELECT
  USING (
    auth.uid() = user_id
    OR auth.uid() = (SELECT user_id FROM public.devices WHERE device_id = public.notifications.device_id)
    OR (auth.jwt() ->> 'role') = 'administrator'
  );

CREATE POLICY IF NOT EXISTS notifications_insert_owner ON public.notifications
  FOR INSERT
  WITH CHECK (
    auth.uid() = user_id
    OR auth.uid() = (SELECT user_id FROM public.devices WHERE device_id = public.notifications.device_id)
  );

CREATE POLICY IF NOT EXISTS notifications_update_owner_admin ON public.notifications
  FOR UPDATE
  USING (
    auth.uid() = user_id
    OR (auth.jwt() ->> 'role') = 'administrator'
  )
  WITH CHECK (
    auth.uid() = user_id
    OR (auth.jwt() ->> 'role') = 'administrator'
  );

-- Now enable RLS and policies for INT-based tables (suffix _int)
ALTER TABLE IF EXISTS public.devices_int ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS devices_int_select_owner_admin ON public.devices_int
  FOR SELECT
  USING (
    (auth.jwt() ->> 'role') = 'administrator'
    OR (auth.jwt() ->> 'email') = (SELECT email FROM public.users WHERE user_id = public.devices_int.user_id)
  );

CREATE POLICY IF NOT EXISTS devices_int_insert_owner ON public.devices_int
  FOR INSERT
  WITH CHECK (
    (auth.jwt() ->> 'role') = 'administrator'
    OR (auth.jwt() ->> 'email') = (SELECT email FROM public.users WHERE user_id = public.devices_int.user_id)
  );

CREATE POLICY IF NOT EXISTS devices_int_update_owner_admin ON public.devices_int
  FOR UPDATE
  USING (
    (auth.jwt() ->> 'role') = 'administrator'
    OR (auth.jwt() ->> 'email') = (SELECT email FROM public.users WHERE user_id = public.devices_int.user_id)
  )
  WITH CHECK (
    (auth.jwt() ->> 'role') = 'administrator'
    OR (auth.jwt() ->> 'email') = (SELECT email FROM public.users WHERE user_id = public.devices_int.user_id)
  );

ALTER TABLE IF EXISTS public.device_logs_int ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS device_logs_int_select_owner_admin ON public.device_logs_int
  FOR SELECT
  USING (
    (auth.jwt() ->> 'role') = 'administrator'
    OR (auth.jwt() ->> 'email') = (
      SELECT email FROM public.users WHERE user_id = (
        SELECT user_id FROM public.devices_int WHERE device_id = public.device_logs_int.device_id
      )
    )
  );

CREATE POLICY IF NOT EXISTS device_logs_int_insert_owner ON public.device_logs_int
  FOR INSERT
  WITH CHECK (
    (auth.jwt() ->> 'role') = 'administrator'
    OR (auth.jwt() ->> 'email') = (
      SELECT email FROM public.users WHERE user_id = (
        SELECT user_id FROM public.devices_int WHERE device_id = public.device_logs_int.device_id
      )
    )
  );

ALTER TABLE IF EXISTS public.device_controls_int ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS device_controls_int_select_owner_admin ON public.device_controls_int
  FOR SELECT
  USING (
    (auth.jwt() ->> 'role') = 'administrator'
    OR (auth.jwt() ->> 'email') = (
      SELECT email FROM public.users WHERE user_id = (
        SELECT user_id FROM public.devices_int WHERE device_id = public.device_controls_int.device_id
      )
    )
  );

CREATE POLICY IF NOT EXISTS device_controls_int_insert_owner ON public.device_controls_int
  FOR INSERT
  WITH CHECK (
    (auth.jwt() ->> 'role') = 'administrator'
    OR (auth.jwt() ->> 'email') = (
      SELECT email FROM public.users WHERE user_id = (
        SELECT user_id FROM public.devices_int WHERE device_id = public.device_controls_int.device_id
      )
    )
  );

ALTER TABLE IF EXISTS public.ai_insights_int ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS ai_insights_int_select_owner_admin ON public.ai_insights_int
  FOR SELECT
  USING (
    (auth.jwt() ->> 'role') = 'administrator'
    OR (auth.jwt() ->> 'email') = (
      SELECT email FROM public.users WHERE user_id = (
        SELECT user_id FROM public.devices_int WHERE device_id = public.ai_insights_int.device_id
      )
    )
  );

CREATE POLICY IF NOT EXISTS ai_insights_int_insert_owner ON public.ai_insights_int
  FOR INSERT
  WITH CHECK (
    (auth.jwt() ->> 'role') = 'administrator'
    OR (auth.jwt() ->> 'email') = (
      SELECT email FROM public.users WHERE user_id = (
        SELECT user_id FROM public.devices_int WHERE device_id = public.ai_insights_int.device_id
      )
    )
  );

ALTER TABLE IF EXISTS public.notifications_int ENABLE ROW LEVEL SECURITY;

CREATE POLICY IF NOT EXISTS notifications_int_select_owner_admin ON public.notifications_int
  FOR SELECT
  USING (
    (auth.jwt() ->> 'role') = 'administrator'
    OR (auth.jwt() ->> 'email') = (SELECT email FROM public.users WHERE user_id = public.notifications_int.user_id)
    OR (auth.jwt() ->> 'email') = (
      SELECT email FROM public.users WHERE user_id = (
        SELECT user_id FROM public.devices_int WHERE device_id = public.notifications_int.device_id
      )
    )
  );

CREATE POLICY IF NOT EXISTS notifications_int_insert_owner ON public.notifications_int
  FOR INSERT
  WITH CHECK (
    (auth.jwt() ->> 'role') = 'administrator'
    OR (auth.jwt() ->> 'email') = (SELECT email FROM public.users WHERE user_id = public.notifications_int.user_id)
  );
