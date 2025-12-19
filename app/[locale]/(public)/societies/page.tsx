import { createSupabaseServerClient } from '@/lib/supabase/server'
import { Link } from '@/i18n/navigation'
import { Box, Title, TextInput, Button, Text, SimpleGrid, Card, Group } from '@mantine/core'
import { getTranslations } from 'next-intl/server'

function toQuery(searchParams: { [key: string]: string | string[] | undefined }) {
  const entries = Object.entries(searchParams).map(([k, v]) => [k, Array.isArray(v) ? v[0] : v])
  return Object.fromEntries(entries)
}

export default async function SocietiesPage({ searchParams }: { searchParams: Promise<{ [key: string]: string | string[] | undefined }> }) {
  const resolvedSearchParams = await searchParams
  const { search = '' } = toQuery(resolvedSearchParams)

  const supabase = await createSupabaseServerClient()
  const t = await getTranslations('societies')
  const {
    data: { user },
  } = await supabase.auth.getUser()
  let query = supabase
    .from('societies')
    .select('id, name, slug, city, province, description')
    .order('name', { ascending: true })

  if (search) {
    query = query.ilike('name', `%${search}%`)
  }

  const { data: societies, error } = await query

  return (
    <Box maw={1000} mx="auto">
      <Title order={1} mb="lg">{t('title')}</Title>

      <form>
        <TextInput
          name="search"
          defaultValue={search}
          placeholder={t('searchPlaceholder')}
          mb="lg"
        />
      </form>

      {user && (
        <Box mb="lg">
          <Link href="/societies/new" style={{ textDecoration: 'none' }}>
            <Button color="dark" size="sm">
              {t('createSociety')}
            </Button>
          </Link>
        </Box>
      )}

      {error && (
        <Text size="sm" c="red">{error.message}</Text>
      )}

      {!error && (!societies || societies.length === 0) && (
        <Text size="sm" c="dimmed">{t('noSocietiesFound')}</Text>
      )}

      <SimpleGrid cols={{ base: 1, sm: 2 }} spacing="md">
        {societies?.map((s) => (
          <Link key={s.slug} href={`/societies/${s.slug}`} style={{ textDecoration: 'none', color: 'inherit' }}>
            <Card shadow="sm" padding="lg" withBorder>
              <Text size="lg" fw={500}>{(s as any).name ?? (s as any).ragione_sociale}</Text>
              <Text size="sm" c="dimmed">{s.city}{s.province ? `, ${s.province}` : ''}</Text>
              {s.description && (
                <Text size="sm" mt="sm" lineClamp={3}>{s.description}</Text>
              )}
            </Card>
          </Link>
        ))}
      </SimpleGrid>
    </Box>
  )
}
