"use client"

import { Tabs } from '@mantine/core'
import { usePathname, useRouter } from '@/i18n/navigation'
import { useTranslations } from 'next-intl'

export default function AdminTabs() {
  const t = useTranslations('admin')
  const pathname = usePathname()
  const router = useRouter()

  // Determine active tab based on pathname
  const getActiveTab = () => {
    if (pathname.includes('/admin/societies')) return 'societies'
    if (pathname.includes('/admin/users')) return 'users'
    return 'dashboard'
  }

  const handleTabChange = (value: string | null) => {
    if (!value) return
    switch (value) {
      case 'dashboard':
        router.push('/admin')
        break
      case 'societies':
        router.push('/admin/societies')
        break
      case 'users':
        router.push('/admin/users')
        break
    }
  }

  return (
    <Tabs value={getActiveTab()} onChange={handleTabChange}>
      <Tabs.List>
        <Tabs.Tab value="dashboard">{t('dashboard')}</Tabs.Tab>
        <Tabs.Tab value="societies">{t('societies')}</Tabs.Tab>
        <Tabs.Tab value="users">{t('users')}</Tabs.Tab>
      </Tabs.List>
    </Tabs>
  )
}
