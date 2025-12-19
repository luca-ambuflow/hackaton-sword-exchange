import './globals.css'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  // This root layout is required but should NOT include html/body tags
  // The locale layout will handle those
  return children
}
