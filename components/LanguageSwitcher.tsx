"use client"

import { useLocale } from 'next-intl'
import { useRouter, usePathname } from '@/i18n/navigation'
import { Menu, Button, Text } from '@mantine/core'
import { locales, type Locale } from '@/i18n/navigation'

const languageNames: Record<Locale, string> = {
  it: 'Italiano',
  en: 'English',
  de: 'Deutsch',
}

const languageFlags: Record<Locale, string> = {
  it: '🇮🇹',
  en: '🇬🇧',
  de: '🇩🇪',
}

export default function LanguageSwitcher() {
  const locale = useLocale() as Locale
  const router = useRouter()
  const pathname = usePathname()

  const handleLocaleChange = (newLocale: Locale) => {
    router.replace(pathname, { locale: newLocale })
  }

  return (
    <Menu shadow="md" width={150}>
      <Menu.Target>
        <Button
          variant="subtle"
          size="compact-sm"
        >
          <Text component="span" mr={6}>{languageFlags[locale]}</Text>
          {languageNames[locale]}
        </Button>
      </Menu.Target>

      <Menu.Dropdown>
        {locales.map((loc) => (
          <Menu.Item
            key={loc}
            onClick={() => handleLocaleChange(loc)}
            leftSection={<Text component="span">{languageFlags[loc]}</Text>}
            style={{ fontWeight: locale === loc ? 600 : 400 }}
          >
            {languageNames[loc]}
          </Menu.Item>
        ))}
      </Menu.Dropdown>
    </Menu>
  )
}
