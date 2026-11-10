# SupaLibrary26

Instructions and SQL for recreating the `seed/` library database on
[Supabase](https://supabase.com) (Postgres).

The original project uses Mongoose models backed by MongoDB. This folder
contains the same tables and the same seed records as `seed/index.js`, written
as plain SQL so they can be applied with the Supabase SQL Editor, `psql`, or any
Postgres client.

## Files

| File | Purpose |
| --- | --- |
| `schema.sql` | Creates the tables, constraints, and indexes. **Drops the library tables first**, matching the reset behaviour of `seed/index.js`. |
| `seed.sql` | Inserts the same 5 authors, 3 genres, 7 books, and 11 book instances. Safe to re-run because the IDs are fixed. |
| `env.example.txt` | Template for the Supabase URL, keys, and database connection string. |

## Data model

MongoDB collections map to Postgres tables like this:

| Mongoose model / collection | Postgres table | Notes |
| --- | --- | --- |
| `Author` | `public.authors` | `_id` -> `uuid`, `Date` -> `date` |
| `Genre` | `public.genres` | |
| `Book` | `public.books` | `author` and `genre` arrays are normalised below |
| `Book.author` (array of ObjectIds) | `public.book_authors` | Many-to-many junction table |
| `Book.genre` (array of ObjectIds) | `public.book_genres` | Many-to-many junction table |
| `BookInstance` | `public.book_instances` | `book` -> `book_id`, `Date` -> `timestamptz` |

Relationships:

```text
authors 1 --- * book_authors * --- 1 books 1 --- * book_genres * --- 1 genres
                                      |
                                      | 1
                                      |
                                      * book_instances
```

Schema translation details:

- `Schema.Types.ObjectId` becomes `uuid` with `gen_random_uuid()` as the default.
- Required fields become `not null`.
- `max: 100` on the author names becomes a `char_length(...) <= 100` check
  (Mongoose's `max` is actually a number validator; the 100-character limit was
  clearly the intent).
- The `status` enum becomes a `check` constraint with the same four values and
  the same `Maintenance` default.
- `due_back` keeps its `now()` default but remains nullable, as in the original.
- No extra `created_at` / `updated_at` columns were added, so the shape matches
  the original models.
- Deleting a book cascades to its junction rows and book instances. Deleting an
  author or genre is restricted while a book still references it.

## Option 1: Supabase SQL Editor (easiest)

1. Create a project at <https://supabase.com/dashboard>.
2. Open **SQL Editor** -> **New query**.
3. Paste the contents of `schema.sql` and click **Run**. You should see
   "Success. No rows returned."
4. Open another new query, paste the contents of `seed.sql`, and click **Run**.
5. Check the result with the verification queries below.

No local installation is required for this option.

## Option 2: `psql` from the command line

Get the connection string from **Project Settings -> Database -> Connection
string**. Use the direct connection or the session pooler (port `5432`) for
schema changes.

```bash
psql "postgresql://postgres.<project-ref>:<password>@aws-0-<region>.pooler.supabase.com:5432/postgres" -f schema.sql
psql "postgresql://postgres.<project-ref>:<password>@aws-0-<region>.pooler.supabase.com:5432/postgres" -f seed.sql
```

On Windows PowerShell, pass the connection string with `$env:DATABASE_URL` or
quote it as shown above.

You can also set `DATABASE_URL` in a `.env` file (copy `env.example.txt`) and
use your usual Postgres tooling. `.env` is already ignored by the root
`.gitignore`.

## Verify the seed

Run this in the SQL Editor:

```sql
select 'authors'        as table_name, count(*) from public.authors
union all
select 'genres',                       count(*) from public.genres
union all
select 'books',                        count(*) from public.books
union all
select 'book_authors',                 count(*) from public.book_authors
union all
select 'book_genres',                  count(*) from public.book_genres
union all
select 'book_instances',               count(*) from public.book_instances;
```

Expected counts:

| table | rows |
| --- | --- |
| `authors` | 5 |
| `genres` | 3 |
| `books` | 7 |
| `book_authors` | 8 |
| `book_genres` | 9 |
| `book_instances` | 11 |

To see the data the way Mongoose's `populate()` would present it:

```sql
select
  b.title,
  a.first_name || ' ' || a.family_name as author,
  g.name as genre,
  bi.imprint,
  bi.status,
  bi.due_back
from public.books b
left join public.book_authors ba on ba.book_id = b.id
left join public.authors a       on a.id = ba.author_id
left join public.book_genres bg  on bg.book_id = b.id
left join public.genres g        on g.id = bg.genre_id
left join public.book_instances bi on bi.book_id = b.id
order by b.title, author, g.name, bi.imprint;
```

## Using the database from Node

Install the Supabase client:

```bash
npm install @supabase/supabase-js
```

Create a client (server-side example):

```js
// config/supabase.js
import 'dotenv/config';
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
);
```

Fetch books with their authors and genres (the equivalent of Mongoose
`populate`):

```js
const { data, error } = await supabase
  .from('books')
  .select(`
    id,
    title,
    summary,
    isbn,
    book_authors ( authors ( id, first_name, family_name ) ),
    book_genres  ( genres  ( id, name ) )
  `)
  .order('title');

if (error) console.error(error);
else console.log(data);
```

Insert a book instance:

```js
const { error } = await supabase.from('book_instances').insert({
  book_id: 'c0000000-0000-4000-8000-000000000001',
  imprint: 'London Gollancz, 2014.',
  status: 'Available'
});
```

Use the **anon** key in browser/client code and the **service role** key only in
trusted server-side code.

## Resetting the data

To wipe and reseed, run `schema.sql` again (it drops and recreates the tables),
then run `seed.sql`. Running `seed.sql` on its own is also safe; the fixed UUIDs
and `on conflict (id) do nothing` prevent duplicates.

## Optional: Row Level Security

Supabase exposes the `public` schema through its API. If you use the anon key
from a browser, enable RLS and add read-only policies:

```sql
alter table public.authors        enable row level security;
alter table public.genres         enable row level security;
alter table public.books          enable row level security;
alter table public.book_authors   enable row level security;
alter table public.book_genres    enable row level security;
alter table public.book_instances enable row level security;

create policy "Public read authors"        on public.authors        for select using (true);
create policy "Public read genres"         on public.genres         for select using (true);
create policy "Public read books"          on public.books          for select using (true);
create policy "Public read book_authors"   on public.book_authors   for select using (true);
create policy "Public read book_genres"    on public.book_genres    for select using (true);
create policy "Public read book_instances" on public.book_instances for select using (true);
```

With these policies, anonymous users can read but not write. Writes can be done
with the service role key, which bypasses RLS, or with additional policies for
authenticated users. If RLS is enabled with no policies, the anon key gets no
access at all.

## Differences from the MongoDB version

- There are no embedded ObjectId arrays; authors and genres are joined through
  junction tables. A book can technically have zero authors at the database
  level, so keep the "at least one author" rule in the application.
- `isbn` is not unique, matching the original schema. Add a unique index if your
  data should enforce it.
- `date_of_birth` and `date_of_death` are `date` values rather than timestamps,
  because the seed data only contains dates.
- Postgres enforces the foreign keys and status enum that MongoDB did not.
