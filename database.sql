create extension if not exists pgcrypto;

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  folio text unique,

  -- Datos del cliente
  nombre text not null,
  correo text not null,
  celular text not null,

  -- Respuestas del diagnóstico
  tipo_conflicto text,
  antiguedad text,
  disposicion text,
  relacion text,
  monto text,
  urgencia text,
  respuestas jsonb not null default '{}'::jsonb,

  -- Resultado calculado por el sitio
  resultado_tipo text,
  probabilidad_acuerdo integer,
  tiempo_estimado text,

  -- Seguimiento comercial / CRM
  status text not null default 'diagnostico',
  notas text,
  fecha_ultimo_contacto timestamptz,
  fecha_cita timestamptz,

  -- Marketing y trazabilidad
  page_url text,
  referrer text,
  user_agent text,
  utm_source text,
  utm_medium text,
  utm_campaign text,
  utm_content text,
  utm_term text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists leads_created_at_idx on public.leads (created_at desc);
create index if not exists leads_status_idx on public.leads (status);
create index if not exists leads_tipo_conflicto_idx on public.leads (tipo_conflicto);
create index if not exists leads_correo_idx on public.leads (correo);
create index if not exists leads_celular_idx on public.leads (celular);

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_leads_updated_at on public.leads;
create trigger trg_leads_updated_at
before update on public.leads
for each row
execute function public.set_updated_at();

-- Recomendación de seguridad:
-- Mantener RLS activo y escribir desde Netlify Function usando SERVICE_ROLE_KEY.
alter table public.leads enable row level security;
