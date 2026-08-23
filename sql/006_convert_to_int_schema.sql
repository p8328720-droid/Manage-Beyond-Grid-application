CREATE TABLE IF NOT EXISTS public.users (
  user_id BIGSERIAL PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100) UNIQUE,
  password VARCHAR(255),
  role VARCHAR(30),
  phone VARCHAR(20),
  status VARCHAR(30),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

INSERT INTO public.users (name, email, role, created_at, status)
SELECT p.name, p.email, COALESCE(p.role,'pengguna'), p.created_at, CASE WHEN p.is_active THEN 'active' ELSE 'inactive' END
FROM public.profiles p
ON CONFLICT (email) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.devices_int (
  device_id BIGSERIAL PRIMARY KEY,
  user_id BIGINT REFERENCES public.users(user_id) ON DELETE SET NULL,
  device_name VARCHAR(100),
  device_type VARCHAR(50),
  serial_number VARCHAR(100),
  location VARCHAR(150),
  status VARCHAR(50),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  old_device_uuid UUID
);

INSERT INTO public.devices_int (user_id, device_name, device_type, serial_number, location, status, created_at, updated_at, old_device_uuid)
SELECT u.user_id, d.device_name, d.device_type, d.serial_number, d.location, d.status, d.created_at, d.updated_at, d.device_id
FROM public.devices d
LEFT JOIN public.profiles p ON p.id = d.user_id
LEFT JOIN public.users u ON u.email = p.email
WHERE d.device_id IS NOT NULL
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS public.device_logs_int (
  log_id BIGSERIAL PRIMARY KEY,
  device_id BIGINT REFERENCES public.devices_int(device_id) ON DELETE CASCADE,
  temperature numeric(8,2),
  humidity numeric(8,2),
  power_usage numeric(12,2),
  voltage numeric(10,2),
  status VARCHAR(50),
  recorded_at timestamptz DEFAULT now()
);

INSERT INTO public.device_logs_int (device_id, temperature, humidity, power_usage, voltage, status, recorded_at)
SELECT di.device_id, l.temperature, l.humidity, l.power_usage, l.voltage, l.status, l.recorded_at
FROM public.device_logs l
JOIN public.devices_int di ON di.old_device_uuid = l.device_id;

CREATE TABLE IF NOT EXISTS public.device_controls_int (
  control_id BIGSERIAL PRIMARY KEY,
  device_id BIGINT REFERENCES public.devices_int(device_id) ON DELETE CASCADE,
  action VARCHAR(50),
  value VARCHAR(255),
  executed_by BIGINT REFERENCES public.users(user_id),
  executed_at timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now()
);

INSERT INTO public.device_controls_int (device_id, action, value, executed_by, executed_at, created_at)
SELECT di.device_id, c.action, c.value, u.user_id, c.executed_at, c.created_at
FROM public.device_controls c
LEFT JOIN public.profiles p ON p.id = c.executed_by
LEFT JOIN public.users u ON u.email = p.email
JOIN public.devices_int di ON di.old_device_uuid = c.device_id;

CREATE TABLE IF NOT EXISTS public.ai_insights_int (
  insight_id BIGSERIAL PRIMARY KEY,
  device_id BIGINT REFERENCES public.devices_int(device_id) ON DELETE CASCADE,
  title VARCHAR(150),
  description TEXT,
  severity VARCHAR(30),
  is_read BOOLEAN DEFAULT false,
  created_at timestamptz DEFAULT now()
);

INSERT INTO public.ai_insights_int (device_id, title, description, severity, is_read, created_at)
SELECT di.device_id, a.title, a.description, a.severity, a.is_read, a.created_at
FROM public.ai_insights a
JOIN public.devices_int di ON di.old_device_uuid = a.device_id;

CREATE TABLE IF NOT EXISTS public.notifications_int (
  notification_id BIGSERIAL PRIMARY KEY,
  device_id BIGINT REFERENCES public.devices_int(device_id) ON DELETE SET NULL,
  user_id BIGINT REFERENCES public.users(user_id) ON DELETE CASCADE,
  title VARCHAR(150),
  message TEXT,
  type VARCHAR(50),
  status VARCHAR(30),
  created_at timestamptz DEFAULT now(),
  read_at timestamptz
);

INSERT INTO public.notifications_int (device_id, user_id, title, message, type, status, created_at, read_at)
SELECT di.device_id, u.user_id, n.title, n.message, n.type, n.status, n.created_at, n.read_at
FROM public.notifications n
LEFT JOIN public.profiles p ON p.id = n.user_id
LEFT JOIN public.users u ON u.email = p.email
LEFT JOIN public.devices_int di ON di.old_device_uuid = n.device_id;
