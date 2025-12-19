import { Button as MantineButton, ButtonProps as MantineButtonProps } from '@mantine/core'
import * as React from 'react'

export interface ButtonProps extends Omit<MantineButtonProps, 'variant'> {
  variant?: 'default' | 'ghost' | 'outline'
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'default', ...props }, ref) => {
    const mantineVariant = variant === 'default' ? 'filled' : variant === 'ghost' ? 'subtle' : 'outline'
    const color = variant === 'default' ? 'dark' : 'gray'
    
    return (
      <MantineButton 
        ref={ref} 
        variant={mantineVariant} 
        color={color}
        {...props} 
      />
    )
  }
)
Button.displayName = 'Button'
