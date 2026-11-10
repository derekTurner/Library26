-- SupaLibrary26 / schema.sql
--
-- Postgres/Supabase equivalent of the Mongoose models in ../seed/index.js.
--
-- WARNING: this script DROPS the library tables before recreating them, which
-- mirrors the "drop the collections, then reseed" behaviour of seed/index.js.
--
-- Run this file first, then run seed.sql.

begin;

-- ---------------------------------------------------------------------------
-- Reset (comment these out if you want to keep existing data)
-- ---------------------------------------------------------------------------
drop table if exists public.book_instances cascade;
drop table if exists public.book_genres cascade;
drop table if exists public.book_authors cascade;
drop table if exists public.books cascade;
drop table if exists public.genres cascade;
drop table if exists public.authors cascade;

-- ---------------------------------------------------------------------------
-- Author
-- ---------------------------------------------------------------------------
create table public.authors (
  id            uuid primary key default gen_random_uuid(),
  first_name    text not null check (char_length(first_name) <= 100),
  family_name   text not null check (char_length(family_name) <= 100),
  date_of_birth date,
  date_of_death date,
  constraint authors_death_after_birth check (
    date_of_death is null
    or date_of_birth is null
    or date_of_death >= date_of_birth
  )
);

comment on table public.authors is
  'Equivalent of the Mongoose Author model. _id -> id, Date -> date.';

-- ---------------------------------------------------------------------------
-- Genre
-- ---------------------------------------------------------------------------
create table public.genres (
  id   uuid primary key default gen_random_uuid(),
  name text not null
);

comment on table public.genres is
  'Equivalent of the Mongoose Genre model.';

-- ---------------------------------------------------------------------------
-- Book
--
-- In Mongo, Book.author and Book.genre are arrays of ObjectIds. In Postgres
-- those many-to-many relationships are stored in the junction tables below.
-- ---------------------------------------------------------------------------
create table public.books (
  id      uuid primary key default gen_random_uuid(),
  title   text not null,
  summary text not null,
  isbn    text not null
);

comment on table public.books is
  'Equivalent of the Mongoose Book model. Authors/genres live in junction tables.';

-- ---------------------------------------------------------------------------
-- Book <-> Author (many-to-many)
-- ---------------------------------------------------------------------------
create table public.book_authors (
  book_id   uuid not null references public.books (id) on delete cascade,
  author_id uuid not null references public.authors (id) on delete restrict,
  primary key (book_id, author_id)
);

create index book_authors_author_id_idx on public.book_authors (author_id);

-- ---------------------------------------------------------------------------
-- Book <-> Genre (many-to-many)
-- ---------------------------------------------------------------------------
create table public.book_genres (
  book_id  uuid not null references public.books (id) on delete cascade,
  genre_id uuid not null references public.genres (id) on delete restrict,
  primary key (book_id, genre_id)
);

create index book_genres_genre_id_idx on public.book_genres (genre_id);

-- ---------------------------------------------------------------------------
-- BookInstance
-- ---------------------------------------------------------------------------
create table public.book_instances (
  id       uuid primary key default gen_random_uuid(),
  book_id  uuid not null references public.books (id) on delete cascade,
  imprint  text not null,
  status   text not null default 'Maintenance'
             check (status in ('Available', 'Maintenance', 'Loaned', 'Reserved')),
  due_back timestamptz default now()
);

create index book_instances_book_id_idx on public.book_instances (book_id);
create index book_instances_status_idx on public.book_instances (status);

comment on table public.book_instances is
  'Equivalent of the Mongoose BookInstance model. Date -> timestamptz.';

commit;
