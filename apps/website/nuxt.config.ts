import { fileURLToPath } from 'url'
import { dirname, join, resolve } from 'path'
import AstroTheme from '../../shared/theme'
import { devPortMap } from '../../shared/paths.config'
import { getSharedEnv, pick } from '../../shared/env'

// Place this at the top of your nuxt.config.ts after importing env
const env = getSharedEnv()

// Load environment variables from the root .env file
const publicKeys = [
  'supabaseURL',
  'supabaseKey',
  'loginPath',
  'registerPath',
  'cmsURL',
  'authURL',
  'appURL',
  'apiURL',
  'testing',
  'websiteURL',
  'scraperURL',
  'devHelper',
  'posthogKey',
  'posthogURL',
  'razorpayKey',
] as const

const privateKeys = [
  'cmsURL',
  'resendApiKey',
  'resendFromEmail',
  'resendToEmail',
  'supabaseServiceKey',
  'googleApiKey',
  'scraperKey',
  'razorpaySecret',
] as const

const currentDir = dirname(fileURLToPath(import.meta.url))
const rootDir = join(currentDir, '../..')

const baseLayerPath = resolve(rootDir, 'layers/base')

function generateLocalUrls(start = 3000, end = 3009) {
  return Array.from({ length: end - start + 1 }, (_, i) => `http://localhost:${start + i}`)
}

const localUrls = generateLocalUrls()

const og = {
  title: 'AstronEra: Your Gateway to the Stars',
  description:
    'Connect, learn, and unravel the cosmos with astronomers and space enthusiasts from around the globe',
  image: '/astronera-logo-with-text.jpg',
  url:
    process.env.SITE_URL ||
    (process.env.NODE_ENV === 'production'
      ? 'https://astronera.org'
      : `http://localhost:${process.env.PORT || 3000}`),
}

export default defineNuxtConfig({
  extends: [baseLayerPath],
  modules: [
    '@nuxtjs/mdc',
    '@nuxtjs/seo', // Must be before @nuxt/content
    '@vueuse/nuxt',
    '@nuxt/image',
    '@pinia/nuxt',
    '@nuxt/icon',
    '@nuxt/eslint',
    '@nuxt/fonts',
    '@nuxtjs/tailwindcss',
    '@primevue/nuxt-module',
    '@nuxt/content',
    '@vueuse/motion/nuxt',
  ],

  ssr: true,

  imports: {
    dirs: ['stores', 'composables/*', 'utils/*'],
  },

  devtools: { enabled: true },

  app: {
    layoutTransition: { name: 'layout', mode: 'out-in' },
    head: {
      link: [
        { rel: 'icon', href: '/favicon.ico', sizes: 'any' },
        {
          rel: 'preload',
          href: 'https://fonts.gstatic.com/s/orbitron/v30/yMJRMIlzdpvBhQQL_SC3UVY1.woff2',
          as: 'font',
          type: 'font/woff2',
          crossorigin: 'anonymous',
        },
        {
          rel: 'preload',
          href: 'https://fonts.gstatic.com/s/sourcecodepro/v22/HI_SiYsKILxRpg3hIP6sJ7fM7PXs.woff2',
          as: 'font',
          type: 'font/woff2',
          crossorigin: 'anonymous',
        },
      ],
      htmlAttrs: { lang: 'en' },
      meta: [
        { property: 'title', content: og.description },
        { property: 'description', content: og.description },
        { property: 'og:title', content: og.title },
        { property: 'og:type', content: 'website' },
        { property: 'og:image', content: og.image },
        { property: 'og:description', content: og.description },
        { property: 'og:url', content: og.url },
        { name: 'twitter:card', content: 'Twitter Card' },
        { name: 'twitter:title', content: og.title },
        { name: 'twitter:description', content: og.description },
        { name: 'twitter:image', content: og.image },
      ],
      script: [
        // Insert your Google Tag Manager Script here
        { src: 'https://www.youtube.com/iframe_api', async: true },
      ],
    },
  },

  site: { url: og.url, name: 'AstronEra', description: 'Astronomy Hub', defaultLocale: 'en' },

  content: {
    // Studio preview configuration - enhanced for better performance
    preview: {
      api: 'https://api.nuxt.studio',
      dev: true,
      gitInfo: {
        name: 'astrotribe',
        owner: 'incubrain',
        url: 'https://github.com/incubrain/astrotribe',
      },
    },

    database: {
      type: 'sqlite',
      filename: resolve(currentDir, './.data/content/contents.sqlite'),
    },

    experimental: {
      sqliteConnector: 'better-sqlite3', // or 'sqlite3' if needed
    },

    build: {
      // Optimize markdown processing
      markdown: {
        // Streamline TOC for better performance
        toc: {
          depth: 2,
          searchDepth: 2,
        },
        // Disable unnecessary remark plugins
        remarkPlugins: {
          'remark-emoji': false,
          'remark-gfm': {
            // Keep GFM but optimize its options
            singleTilde: false,
          },
        },
        // Optimize rehype plugins
        rehypePlugins: {
          // Disable or configure as needed
        },
      },
      // Optimize path metadata handling for better performance
      pathMeta: {
        forceLeadingSlash: true,
      },
    },

    // Rendering optimization
    renderer: {
      // Limit anchor links to essential headings only
      anchorLinks: { h2: true, h3: true, h4: false, h5: false, h6: false },
    },

    // Content hot reload configuration - optimize for development experience
    watch: {
      enabled: true,
      port: 4000, // Choose a consistent port
      showURL: false, // Reduce console noise
    },
  },

  runtimeConfig: {
    serviceName: 'website',
    ...pick(env.private, [...privateKeys]),
    public: {
      serviceName: 'website',
      ...pick(env.public, [...publicKeys]),
    },
  },

  alias: {
    '#config': fileURLToPath(new URL('../../shared', import.meta.url)),
  },

  build: {
    transpile: [
      'embla-carousel-vue',
      'embla-carousel-autoplay',
      'embla-carousel-auto-scroll',
      'gsap',
    ],
  },

  routeRules: {
    '/': { prerender: true },
    '/blog': { prerender: true },
    '/blog/category/*': {
      prerender: true,
    },
    '/blog/category/*/page/*': {
      prerender: true,
    },
    '/blog/*': {
      prerender: true,
    },

    '/sitemap.xml': {
      headers: { 'Content-Type': 'application/xml', 'Cache-Control': 'max-age=3600' },
    },
    '/sitemap_main.xml': {
      headers: { 'Content-Type': 'application/xml', 'Cache-Control': 'max-age=3600' },
    },
    '/sitemap_blog.xml': {
      headers: { 'Content-Type': 'application/xml', 'Cache-Control': 'max-age=3600' },
    },
    '/sitemap_policies.xml': {
      headers: { 'Content-Type': 'application/xml', 'Cache-Control': 'max-age=3600' },
    },
    '/api/__sitemap__/**': { cors: true, headers: { 'Cache-Control': 'max-age=3600' } },
    // DOI LINKS
    '/doi/dsi-acknowledgement': {
      redirect: { to: '/darksky-acknowledgement', statusCode: 301 },
    },
    '/doi/dsi-endorsement': {
      redirect: { to: '/dsi-endorsement', statusCode: 301 },
    },
    '/doi/symposium-2025': {
      redirect: { to: '/symposiums/symposium-2025', statusCode: 301 },
    },
    '/doi/astrotribe-nashik-2023': {
      redirect: { to: '/projects/astrotribe-nashik-2023', statusCode: 301 },
    },
    '/doi/astrotribe-ladakh-2024': {
      redirect: { to: '/projects/astrotribe-ladakh-2024', statusCode: 301 },
    },
    '/doi/idspac-2023': {
      redirect: { to: '/conferences/idspac-2023', statusCode: 301 },
    },
  },

  devServer: { host: 'localhost', port: process.env.NUXT_MULTI_APP ? devPortMap.website : 3000 },
  future: {
    compatibilityVersion: 4,
  },

  experimental: { inlineRouteRules: true, asyncContext: true },

  compatibilityDate: '2025-03-30',

  nitro: {
    prerender: {
      routes: ['/sitemap.xml', '/sitemap_main.xml', '/sitemap_blog.xml', '/sitemap_policies.xml'],
      crawlLinks: true,
      failOnError: false,
    },
  },

  // nuxt.config.ts (add this in defineNuxtConfig)
  hooks: {
    'content:file:beforeParse'(ctx) {
      console.log('[Content Hook] beforeParse', {
        path: ctx.file.path,
        collection: ctx.collection.name,
      })
    },
    'content:file:afterParse'(ctx) {
      console.log('[Content Hook] afterParse', {
        path: ctx.file.path,
        collection: ctx.collection.name,
        content: ctx.content,
      })
    },
  },

  fonts: {
    families: [
      { name: 'Orbitron', provider: 'google' },
      { name: 'Source Code Pro', provider: 'google' },
    ],
  },

  icon: {
    provider: 'server',
    serverBundle: {
      collections: ['material-symbols', 'mdi', 'lucide'], // Limit collections to reduce size
    },
    clientBundle: {
      scan: process.env.NODE_ENV === 'production', // Only in production
    },
  },

  image: {
    format: ['webp', 'jpg', 'png'],
    quality: 80,
    dir: 'public',
    domains: ['astronera.org', 'cms.astronera.org', 'staging.cms.astronera.org', 'localhost'],
    fallback: '/defaults/fallback.jpg',
    cms: { baseURL: `${process.env.NUXT_PUBLIC_CMS_URL}/uploads/` },
    ipx: {
      maxAge: 60 * 60 * 24 * 365, // 1 year (in seconds)
    },
    providers: {
      supabase: {
        provider: '../../layers/base/supabase-provider.ts',
        options: {
          baseURL: process.env.NUXT_PUBLIC_SUPABASE_URL,
        },
      },
    },
    presets: {
      original: {
        modifiers: {
          width: 1920,
          height: 1080,
        },
      },
      mobile: {
        modifiers: {
          width: 768,
          height: 1024,
        },
      },
      thumbnail: {
        modifiers: {
          width: 300,
          height: 200,
        },
      },
    },
  },

  ogImage: {
    // Component defaults
    defaults: {
      cacheMaxAgeSeconds: 60 * 60 * 24 * 7, // 7 days
      component: '~/components/og/DefaultOgImage.vue',
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

  sitemap: {
    excludeAppSources: true,
    cacheMaxAgeSeconds: 1000 * 60 * 60, // 1 hour
    sitemaps: {
      main: { sources: ['/api/__sitemap__/main'] },
      blog: { sources: ['/api/__sitemap__/blog'] },
      policies: { sources: ['/api/__sitemap__/policies'] },
    },
    experimentalCompression: true,
    experimentalWarmUp: true,
  },

  tailwindcss: {
    configPath: `${currentDir}/tailwind.config.ts`,
    viewer: false,
    exposeConfig: process.env.NODE_ENV === 'development',
    cssPath: [`${currentDir}/assets/css/tailwind.css`, { injectPosition: 0 }],
  },
})
