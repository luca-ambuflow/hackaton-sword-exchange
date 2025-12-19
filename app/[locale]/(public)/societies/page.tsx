import { createSupabaseServerClient } from '@/lib/supabase/server'
import { Link } from '@/i18n/navigation'

function toQuery(searchParams: { [key: string]: string | string[] | undefined }) {
  const entries = Object.entries(searchParams).map(([k, v]) => [k, Array.isArray(v) ? v[0] : v])
  return Object.fromEntries(entries)
}

export default async function SocietiesPage({ searchParams }: { searchParams: { [key: string]: string | string[] | undefined } }) {
  const { search = '' } = toQuery(searchParams)

  const supabase = createSupabaseServerClient()
  let query = supabase
    .from('societies')
    .select('id, name, slug, city, province, description')
    .order('name', { ascending: true })

  if (search) {
    query = query.ilike('name', `%${search}%`)
  }

  const { data: societies, error } = await query

  return (
    <div className="mx-auto max-w-4xl p-6">
      <h1 className="mb-4 text-2xl font-semibold">Societies</h1>

      <form className="mb-6">
        <input
          type="text"
          name="search"
          defaultValue={search}
          placeholder="Search by name"
          className="w-full rounded border px-3 py-2"
        />
      </form>

      {error && (
        <p className="text-sm text-red-600">{error.message}</p>
      )}

      {!error && (!societies || societies.length === 0) && (
        <p className="text-sm text-gray-600">No societies found.</p>
      )}

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        {societies?.map((s) => (
          <Link key={s.slug} href={`/societies/${s.slug}`} className="rounded border p-4 hover:shadow">
            <h3 className="text-lg font-medium">{(s as any).name ?? (s as any).ragione_sociale}</h3>
            <p className="text-sm text-gray-600">{s.city}{s.province ? `, ${s.province}` : ''}</p>
            {s.description && (
              <p className="mt-2 line-clamp-3 text-sm text-gray-700">{s.description}</p>
            )}
          </Link>
        ))}
      </div>
    </div>
  )
}
