export const devPortMap = {
  // Nuxt apps
  app: 3000,
  admin: 3001,
  auth: 3009,
  website: 3002,
  // Vite apps
  api: 3001,
  // Not Using
  scraper: 8082,
  monitoring: 3003,
} as const

export const stagingPaths = {
  // Nuxt apps
  auth: 'https://staging.api.astronera.org',
  app: 'https://staging.app.astronera.org',
  website: 'https://staging.astronera.org',
  admin: 'https://staging.admin.astronera.org',
  // Vite apps
  api: 'https://staging.api.astronera.org',
  // Other
} as const

export const prodPaths = {
  // Nuxt apps
  auth: 'https://api.astronera.org',
  app: 'https://app.astronera.org',
  website: 'https://astronera.org',
  admin: 'https://admin.astronera.org',
  // Vite apps
  api: 'https://api.astronera.org',
  // Other
} as const
