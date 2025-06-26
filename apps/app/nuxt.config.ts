import { fileURLToPath } from 'url'
import { dirname } from 'path'
import { defineNuxtConfig } from 'nuxt/config'
import AstroTheme from '../../shared/theme'
import { devPortMap } from '../../shared/paths.config'
import { getSharedEnv, pick } from '../../shared/env'

const env = getSharedEnv()

console.log('Environment Variables', env.public)

const publicKeys = [
  'turnstileSiteKey',
  'supabaseURL',
  'supabaseKey',
  'loginPath',
  'authURL',
  'apiURL',
  'appURL',
  'adminURL',
  'websiteURL',
  'nodeEnv',
  'devHelper',
  'posthogKey',
  'posthogURL',
  'razorpayKey',
] as const

const privateKeys = [
  'resendApiKey',
  'supabaseServiceKey',
  'openaiApiKey',
  'openaiOrg',
  'scraperKey',
] as const

const currentDir = dirname(fileURLToPath(import.meta.url))

export default defineNuxtConfig({
  extends: ['../../layers/base', '../../layers/supabase', '../../layers/crud'],

  modules: [
    '@nuxt/devtools',
    '@vueuse/nuxt',
    '@nuxt/image',
    '@pinia/nuxt',
    '@nuxt/icon',
    '@nuxt/eslint',
    '@nuxtjs/tailwindcss',
    '@nuxtjs/mdc',
    '@primevue/nuxt-module',
    '@nuxt/test-utils/module',
  ],

  ssr: false,

  imports: {
    dirs: ['stores/**', 'composables/**', 'utils/**'],
  },

  runtimeConfig: {
    serviceName: 'app',
    ...pick(env.private, [...privateKeys]),
    public: {
      serviceName: 'app',
      ...pick(env.public, [...publicKeys]),
    },
  },

  alias: {
    '~/utils': fileURLToPath(new URL('./utils', import.meta.url)),
  },

  devServer: {
    host: 'localhost',
    port: process.env.NUXT_MULTI_APP ? devPortMap.app : 3000,
  },

  future: {
    compatibilityVersion: 4,
  },

  experimental: {
    asyncContext: true,
    // debugModuleMutation: false,
  },

  compatibilityDate: '2025-01-09',

  // Add proper MIME type handling
  nitro: {
    preset: 'static',
    experimental: {
      asyncContext: true,
    },
    routeRules: {},
    alias: {
      '#shared': fileURLToPath(new URL('./shared', import.meta.url)),
    },
  },

  vite: {
    optimizeDeps: {
      exclude: ['fsevents'],
    },
  },

  image: {
    format: ['webp', 'jpg'],
    provider: 'ipx',
    ipx: {
      baseURL: '/images',
    },
  },

  primevue: {
    autoImport: true,
    components: {
      include: '*',
      prefix: 'Prime',
      exclude: ['Galleria', 'Carousel', 'Editor'],
    },
    options: {
      ripple: true,
      theme: AstroTheme,
    },
  },

  supabase: {
    url: process.env.NUXT_PUBLIC_SUPABASE_URL,
    key: process.env.NUXT_PUBLIC_SUPABASE_KEY,
    serviceKey: process.env.NUXT_SUPABASE_SERVICE_KEY,
  },

  tailwindcss: {
    configPath: `${currentDir}/tailwind.config.ts`,
    cssPath: [`${currentDir}/assets/css/tailwind.css`, { injectPosition: 0 }],
    exposeConfig: true,
    viewer: true,
  },
})
