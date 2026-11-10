-- SupaLibrary26 / seed.sql
--
-- Seed data copied from ../seed/index.js.
-- Run schema.sql first.
--
-- The UUIDs are fixed so this file can be re-run safely: existing rows are
-- skipped by "on conflict (id) do nothing".
-- Re-run schema.sql first if you want a clean reset.

begin;

-- ---------------------------------------------------------------------------
-- Authors (seed order matches the authors[] array in index.js)
-- ---------------------------------------------------------------------------
insert into public.authors (id, first_name, family_name, date_of_birth, date_of_death) values
  ('a0000000-0000-4000-8000-000000000001', 'Patrick', 'Rothfuss', date '1973-06-06', null),
  ('a0000000-0000-4000-8000-000000000002', 'Ben',     'Bova',     date '1932-11-08', null),
  ('a0000000-0000-4000-8000-000000000003', 'Isaac',   'Asimov',   date '1920-01-02', date '1992-04-06'),
  ('a0000000-0000-4000-8000-000000000004', 'Bob',     'Billings', null, null),
  ('a0000000-0000-4000-8000-000000000005', 'Jim',     'Jones',    date '1971-12-16', null)
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Genres (seed order matches the genres[] array in index.js)
-- ---------------------------------------------------------------------------
insert into public.genres (id, name) values
  ('b0000000-0000-4000-8000-000000000001', 'Fantasy'),
  ('b0000000-0000-4000-8000-000000000002', 'Science Fiction'),
  ('b0000000-0000-4000-8000-000000000003', 'French Poetry')
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Books (seed order matches the books[] array in index.js)
-- ---------------------------------------------------------------------------
insert into public.books (id, title, summary, isbn) values
  (
    'c0000000-0000-4000-8000-000000000001',
    'The Name of the Wind (The Kingkiller Chronicle, #1)',
    $summary$I have stolen princesses back from sleeping barrow kings. I burned down the town of Trebon. I have spent the night with Felurian and left with both my sanity and my life. I was expelled from the University at a younger age than most people are allowed in. I tread paths by moonlight that others fear to speak of during day. I have talked to Gods, loved women, and written songs that make the minstrels weep.$summary$,
    '9781473211896'
  ),
  (
    'c0000000-0000-4000-8000-000000000002',
    'The Wise Man''s Fear (The Kingkiller Chronicle, #2)',
    $summary$Picking up the tale of Kvothe Kingkiller once again, we follow him into exile, into political intrigue, courtship, adventure, love and magic... and further along the path that has turned Kvothe, the mightiest magician of his age, a legend in his own time, into Kote, the unassuming pub landlord.$summary$,
    '9788401352836'
  ),
  (
    'c0000000-0000-4000-8000-000000000003',
    'The Slow Regard of Silent Things (Kingkiller Chronicle)',
    $summary$Deep below the University, there is a dark place. Few people know of it: a broken web of ancient passageways and abandoned rooms. A young woman lives there, tucked among the sprawling tunnels of the Underthing, snug in the heart of this forgotten place.$summary$,
    '9780756411336'
  ),
  (
    'c0000000-0000-4000-8000-000000000004',
    'Apes and Angels',
    $summary$Humankind headed out to the stars not for conquest, nor exploration, nor even for curiosity. Humans went to the stars in a desperate crusade to save intelligent life wherever they found it. A wave of death is spreading through the Milky Way galaxy, an expanding sphere of lethal gamma ...$summary$,
    '9780765379528'
  ),
  (
    'c0000000-0000-4000-8000-000000000005',
    'Death Wave',
    $summary$In Ben Bova's previous novel New Earth, Jordan Kell led the first human mission beyond the solar system. They discovered the ruins of an ancient alien civilization. But one alien AI survived, and it revealed to Jordan Kell that an explosion in the black hole at the heart of the Milky Way galaxy has created a wave of deadly radiation, expanding out from the core toward Earth. Unless the human race acts to save itself, all life on Earth will be wiped out...$summary$,
    '9780765379504'
  ),
  (
    'c0000000-0000-4000-8000-000000000006',
    'Test Book 1',
    'Summary of test book 1',
    'ISBN111111'
  ),
  (
    'c0000000-0000-4000-8000-000000000007',
    'Test Book 2',
    'Summary of test book 2',
    'ISBN222222'
  )
on conflict (id) do nothing;

-- ---------------------------------------------------------------------------
-- Book authors
--   Book 1-3: Patrick Rothfuss
--   Book 4-5: Ben Bova
--   Book 6:   Jim Jones + Bob Billings
--   Book 7:   Jim Jones
-- ---------------------------------------------------------------------------
insert into public.book_authors (book_id, author_id) values
  ('c0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001'),
  ('c0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001'),
  ('c0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001'),
  ('c0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000002'),
  ('c0000000-0000-4000-8000-000000000005', 'a0000000-0000-4000-8000-000000000002'),
  ('c0000000-0000-4000-8000-000000000006', 'a0000000-0000-4000-8000-000000000005'),
  ('c0000000-0000-4000-8000-000000000006', 'a0000000-0000-4000-8000-000000000004'),
  ('c0000000-0000-4000-8000-000000000007', 'a0000000-0000-4000-8000-000000000005')
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- Book genres
--   Book 1-3: Fantasy
--   Book 4-5: Science Fiction
--   Book 6-7: Fantasy + Science Fiction
-- ---------------------------------------------------------------------------
insert into public.book_genres (book_id, genre_id) values
  ('c0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001'),
  ('c0000000-0000-4000-8000-000000000002', 'b0000000-0000-4000-8000-000000000001'),
  ('c0000000-0000-4000-8000-000000000003', 'b0000000-0000-4000-8000-000000000001'),
  ('c0000000-0000-4000-8000-000000000004', 'b0000000-0000-4000-8000-000000000002'),
  ('c0000000-0000-4000-8000-000000000005', 'b0000000-0000-4000-8000-000000000002'),
  ('c0000000-0000-4000-8000-000000000006', 'b0000000-0000-4000-8000-000000000001'),
  ('c0000000-0000-4000-8000-000000000006', 'b0000000-0000-4000-8000-000000000002'),
  ('c0000000-0000-4000-8000-000000000007', 'b0000000-0000-4000-8000-000000000001'),
  ('c0000000-0000-4000-8000-000000000007', 'b0000000-0000-4000-8000-000000000002')
on conflict do nothing;

-- ---------------------------------------------------------------------------
-- Book instances
-- ---------------------------------------------------------------------------
insert into public.book_instances (id, book_id, imprint, status, due_back) values
  ('d0000000-0000-4000-8000-000000000001', 'c0000000-0000-4000-8000-000000000001', 'London Gollancz, 2014.',                                'Available',   null),
  ('d0000000-0000-4000-8000-000000000002', 'c0000000-0000-4000-8000-000000000002', ' Gollancz, 2011.',                                     'Loaned',      timestamptz '2020-06-06 00:00:00+00'),
  ('d0000000-0000-4000-8000-000000000003', 'c0000000-0000-4000-8000-000000000003', ' Gollancz, 2015.',                                     'Maintenance', null),
  ('d0000000-0000-4000-8000-000000000004', 'c0000000-0000-4000-8000-000000000004', 'New York Tom Doherty Associates, 2016.',               'Available',   null),
  ('d0000000-0000-4000-8000-000000000005', 'c0000000-0000-4000-8000-000000000004', 'New York Tom Doherty Associates, 2016.',               'Available',   null),
  ('d0000000-0000-4000-8000-000000000006', 'c0000000-0000-4000-8000-000000000004', 'New York Tom Doherty Associates, 2016.',               'Available',   null),
  ('d0000000-0000-4000-8000-000000000007', 'c0000000-0000-4000-8000-000000000005', 'New York, NY Tom Doherty Associates, LLC, 2015.',      'Available',   null),
  ('d0000000-0000-4000-8000-000000000008', 'c0000000-0000-4000-8000-000000000005', 'New York, NY Tom Doherty Associates, LLC, 2015.',      'Maintenance', null),
  ('d0000000-0000-4000-8000-000000000009', 'c0000000-0000-4000-8000-000000000005', 'New York, NY Tom Doherty Associates, LLC, 2015.',      'Loaned',      null),
  ('d0000000-0000-4000-8000-000000000010', 'c0000000-0000-4000-8000-000000000001', 'Imprint XXX2',                                         'Maintenance', null),
  ('d0000000-0000-4000-8000-000000000011', 'c0000000-0000-4000-8000-000000000002', 'Imprint XXX3',                                         'Maintenance', null)
on conflict (id) do nothing;

commit;
