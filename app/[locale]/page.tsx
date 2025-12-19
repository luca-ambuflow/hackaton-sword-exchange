import { useTranslations } from 'next-intl'
import { Link } from '@/i18n/navigation'

export default function HomePage() {
  const t = useTranslations('app')
  return (
    <main className="min-h-dvh bg-white text-gray-900">
      <div className="mx-auto max-w-3xl px-6 py-16">
        <h1 className="text-3xl font-bold tracking-tight sm:text-4xl">
          {t('title')}
        </h1>
        <p className="mt-4 text-gray-600">{t('tagline')}</p>

        <div className="mt-8 flex items-center gap-4">
          <Link
            href="/societies"
            className="rounded-md bg-black px-4 py-2 text-white hover:bg-gray-800"
          >
            {t('getStarted')}
          </Link>
          <div className="text-sm text-gray-500">/it, /en, /de</div>
        </div>
      </div>
    </main>
  )
}
