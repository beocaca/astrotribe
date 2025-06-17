import { createClient, type SupabaseClient } from '@supabase/supabase-js'
import { env } from '../env.js'

export interface ClientConfig {
  role: 'anon' | 'service' | 'authenticated'
  authToken?: string
}

export class SupabaseClientManager {
  private static instance: SupabaseClientManager
  private clients: Map<string, SupabaseClient> = new Map()

  private constructor() {}

  static getInstance(): SupabaseClientManager {
    if (!SupabaseClientManager.instance) {
      SupabaseClientManager.instance = new SupabaseClientManager()
    }
    return SupabaseClientManager.instance
  }

  getClient(config: ClientConfig): SupabaseClient {
    const key = `${config.role}_${config.authToken || 'default'}`

    if (this.clients.has(key)) {
      return this.clients.get(key)!
    }

    let client: SupabaseClient

    switch (config.role) {
      case 'service':
        client = createClient(env.NUXT_PUBLIC_SUPABASE_URL!, env.NUXT_SUPABASE_SERVICE_KEY!, {
          auth: { persistSession: false },
        })
        break

      case 'authenticated':
        if (!config.authToken) {
          throw new Error('Auth token required for authenticated client')
        }
        client = createClient(env.NUXT_PUBLIC_SUPABASE_URL!, env.NUXT_PUBLIC_SUPABASE_KEY!, {
          global: {
            headers: { Authorization: `Bearer ${config.authToken}` },
          },
          auth: { persistSession: false },
        })
        break

      case 'anon':
      default:
        client = createClient(env.NUXT_PUBLIC_SUPABASE_URL!, env.NUXT_PUBLIC_SUPABASE_KEY!, {
          auth: { persistSession: false },
        })
        break
    }

    this.clients.set(key, client)
    return client
  }

  clearCache(): void {
    this.clients.clear()
  }
}
