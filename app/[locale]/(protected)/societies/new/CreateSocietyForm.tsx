"use client"

import { useFormState } from 'react-dom'
import { createSocietyAction } from '../actions'
import { Stack, TextInput, Textarea, Button, Alert } from '@mantine/core'
import { useTranslations } from 'next-intl'

const initialState = {
  error: null as string | null,
}

export default function CreateSocietyForm() {
  const [state, formAction] = useFormState(createSocietyAction, initialState)
  const t = useTranslations('societies.form')

  return (
    <form action={formAction}>
      <Stack gap="md">
        {state?.error && (
          <Alert color="red" title={t('error')}>
            {state.error}
          </Alert>
        )}
        
        <TextInput
          label={t('name')}
          name="name"
          required
        />
        
        <TextInput
          label={t('ragioneSociale')}
          name="ragione_sociale"
          required
        />
        
        <TextInput
          label={t('codiceFiscale')}
          name="codice_fiscale"
          required
        />
        
        <TextInput
          label={t('sede')}
          name="sede"
          required
        />
        
        <TextInput
          label={t('city')}
          name="city"
        />
        
        <TextInput
          label={t('province')}
          name="province"
        />
        
        <Textarea
          label={t('description')}
          name="description"
          rows={4}
        />
        
        <Button type="submit" color="dark">
          {t('create')}
        </Button>
      </Stack>
    </form>
  )
}
