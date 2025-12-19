"use client"

import { signInAction } from '../actions'
import { Link } from '@/i18n/navigation'
import { Box, Title, Stack, TextInput, PasswordInput, Button, Text, Anchor } from '@mantine/core'
import { useTranslations } from 'next-intl'

export default function SignInPage() {
  const t = useTranslations('auth')
  return (
    <Box maw={400} mx="auto">
      <Title order={1} mb="xl">{t('signIn')}</Title>
      <form action={signInAction}>
        <Stack gap="md">
          <TextInput
            id="email"
            name="email"
            label={t('email')}
            type="email"
            required
          />
          
          <PasswordInput
            id="password"
            name="password"
            label={t('password')}
            minLength={6}
            required
          />
          
          <Button type="submit" color="dark" fullWidth>
            {t('signIn')}
          </Button>
        </Stack>
      </form>
      <Text size="sm" mt="md">
        {t('noAccount')} <Anchor component={Link} href="/auth/sign-up">{t('signUp')}</Anchor>
      </Text>
    </Box>
  )
}
