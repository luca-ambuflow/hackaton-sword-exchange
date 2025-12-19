'use client'

import { Button, Group } from '@mantine/core'
import { approveSocietyAction, rejectSocietyAction } from './actions'
import { useTranslations } from 'next-intl'

interface SocietyApprovalActionsProps {
  societyId: string
}

export function SocietyApprovalActions({ societyId }: SocietyApprovalActionsProps) {
  const t = useTranslations('admin')

  const handleApprove = async () => {
    const formData = new FormData()
    formData.append('societyId', societyId)
    await approveSocietyAction(formData)
  }

  const handleReject = async () => {
    const formData = new FormData()
    formData.append('societyId', societyId)
    await rejectSocietyAction(formData)
  }

  return (
    <Group gap="sm">
      <form action={handleApprove}>
        <Button type="submit" color="green" size="sm">
          {t('approve')}
        </Button>
      </form>
      <form action={handleReject}>
        <Button type="submit" color="red" size="sm">
          {t('reject')}
        </Button>
      </form>
    </Group>
  )
}
