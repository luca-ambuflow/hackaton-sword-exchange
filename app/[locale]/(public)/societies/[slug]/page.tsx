import { createSupabaseServerClient } from '@/lib/supabase/server'
import { notFound } from 'next/navigation'

type Props = { params: { slug: string } }

export default async function SocietyDetailPage({ params }: Props) {
  const supabase = createSupabaseServerClient()

  const { data: society, error } = await supabase
    .from('societies')
    .select('id, name, slug, city, province, description')
    .eq('slug', params.slug)
    .maybeSingle()

  if (error) {
    throw new Error(error.message)
  }

  if (!society) {
    notFound()
  }

  return (
    <div className="mx-auto max-w-3xl p-6">
      <h1 className="mb-2 text-3xl font-semibold">{(society as any).name ?? (society as any).ragione_sociale}</h1>
      <p className="text-gray-600">{society.city}{society.province ? `, ${society.province}` : ''}</p>
      {society.description && (
        <p className="mt-4 whitespace-pre-wrap text-lg leading-relaxed">{society.description}</p>
      )}
    </div>
  )
}
