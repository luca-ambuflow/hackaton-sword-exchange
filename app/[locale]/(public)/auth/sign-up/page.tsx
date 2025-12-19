import { signUpAction } from '../actions'
import { Link } from '@/i18n/navigation'

export default function SignUpPage() {
  return (
    <div className="mx-auto max-w-md p-6">
      <h1 className="mb-6 text-2xl font-semibold">Create account</h1>
      <form action={signUpAction} className="space-y-4">
        <div>
          <label htmlFor="email" className="block text-sm font-medium">Email</label>
          <input
            id="email"
            name="email"
            type="email"
            required
            className="mt-1 w-full rounded border px-3 py-2"
          />
        </div>
        <div>
          <label htmlFor="password" className="block text-sm font-medium">Password</label>
          <input
            id="password"
            name="password"
            type="password"
            minLength={6}
            required
            className="mt-1 w-full rounded border px-3 py-2"
          />
        </div>
        <button
          type="submit"
          className="w-full rounded bg-black px-4 py-2 text-white hover:opacity-90"
        >
          Sign up
        </button>
      </form>
      <p className="mt-4 text-sm">
        Already have an account? <Link href="/auth/sign-in" className="underline">Sign in</Link>
      </p>
    </div>
  )
}
