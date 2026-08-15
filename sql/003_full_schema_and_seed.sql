CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS public.devices (
  device_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  device_name varchar(100),
  device_type varchar(50),
  serial_number varchar(100),
  location varchar(150),
  status varchar(50),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.device_logs (
  log_id bigserial PRIMARY KEY,
  device_id uuid REFERENCES public.devices(device_id) ON DELETE CASCADE,
  temperature numeric(8,2),
  humidity numeric(8,2),
  power_usage numeric(12,2),
  voltage numeric(10,2),
  status varchar(50),
  recorded_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.device_controls (
  control_id bigserial PRIMARY KEY,
  device_id uuid REFERENCES public.devices(device_id) ON DELETE CASCADE,
  action varchar(50),
  value varchar(255),
  executed_by uuid REFERENCES public.profiles(id),
  executed_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.ai_insights (
  insight_id bigserial PRIMARY KEY,
  device_id uuid REFERENCES public.devices(device_id) ON DELETE CASCADE,
  title varchar(150),
  description text,
  severity varchar(30),
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.notifications (
  notification_id bigserial PRIMARY KEY,
  device_id uuid REFERENCES public.devices(device_id) ON DELETE SET NULL,
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE,
  title varchar(150),
  message text,
  type varchar(50),
  status varchar(30),
  created_at timestamptz DEFAULT now(),
  read_at timestamptz
);

INSERT INTO public.profiles (id, name, email, role, is_active, created_at)
VALUES
  (gen_random_uuid(), 'Admin MBG', 'admin@mbg.io', 'administrator', true, now()),
  (gen_random_uuid(), 'Teknisi MBG', 'teknisi@mbg.io', 'teknisi', true, now()),
  (gen_random_uuid(), 'Pengguna Demo', 'user@mbg.io', 'pengguna', true, now())
ON CONFLICT DO NOTHING;

INSERT INTO public.devices (device_id, user_id, device_name, device_type, serial_number, location, status)
SELECT gen_random_uuid(), p.id, 'MBG Sensor A', 'temperature_sensor', 'SN-1001', 'Lab 1', 'online'
FROM public.profiles p
WHERE p.email = 'teknisi@mbg.io'
LIMIT 1;
