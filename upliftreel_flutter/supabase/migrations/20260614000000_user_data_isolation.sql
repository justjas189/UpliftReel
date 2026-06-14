-- UpliftReel multi-user data isolation.
--
-- Three per-user tables backing Preferences, Mood selections, and Watch
-- History. Isolation is enforced in the database, not the app: Row Level
-- Security ties every row to auth.uid(), so a query authenticated as one user
-- can never read or write another user's rows even if the client is buggy or
-- hostile. The app layer adds per-uid local namespacing + best-effort sync on
-- top, but THIS is the source of truth for "accounts never leak into each
-- other".
--
-- Apply with: supabase db push   (or paste into the SQL editor).

-- ---------------------------------------------------------------------------
-- Preferences: one row per user, the whole UserPreferences blob as JSONB.
-- Stored as a blob (not normalized columns) to mirror the local SharedPrefs
-- shape exactly and keep the sync a dumb round-trip.
-- ---------------------------------------------------------------------------
create table if not exists public.preferences (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb       not null,
  updated_at timestamptz not null default now()
);

alter table public.preferences enable row level security;

drop policy if exists "preferences are private" on public.preferences;
create policy "preferences are private"
  on public.preferences
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Mood entries: append-only log of mood selections (capped at 100/user in the
-- app). client_id is the app-generated stable id so re-syncing the same local
-- entry upserts rather than duplicating.
-- ---------------------------------------------------------------------------
create table if not exists public.mood_entries (
  id          uuid        primary key default gen_random_uuid(),
  user_id     uuid        not null default auth.uid()
                          references auth.users (id) on delete cascade,
  client_id   text        not null,
  mood        text        not null,
  intensity   integer     not null check (intensity between 1 and 10),
  seriousness integer     not null check (seriousness between 1 and 10),
  created_at  timestamptz not null,
  unique (user_id, client_id)
);

create index if not exists mood_entries_user_created_idx
  on public.mood_entries (user_id, created_at desc);

alter table public.mood_entries enable row level security;

drop policy if exists "mood entries are private" on public.mood_entries;
create policy "mood entries are private"
  on public.mood_entries
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- Watch history: the recommendation/watched ledger. One row per (user, movie);
-- carries the denormalized movie blob + match metadata so history renders
-- offline without re-fetching TMDB.
-- ---------------------------------------------------------------------------
create table if not exists public.watch_history (
  user_id           uuid        not null default auth.uid()
                                references auth.users (id) on delete cascade,
  movie_id          text        not null,
  movie             jsonb       not null,
  is_recommendation boolean     not null default false,
  is_watched        boolean     not null default false,
  match_score       numeric,
  recommended_at    timestamptz not null,
  updated_at        timestamptz not null default now(),
  primary key (user_id, movie_id)
);

create index if not exists watch_history_user_recommended_idx
  on public.watch_history (user_id, recommended_at desc);

alter table public.watch_history enable row level security;

drop policy if exists "watch history is private" on public.watch_history;
create policy "watch history is private"
  on public.watch_history
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
