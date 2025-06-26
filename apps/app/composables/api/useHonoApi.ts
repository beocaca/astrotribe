// composables/api/useHonoApi.ts - UPDATED
import { ofetch } from 'ofetch'

const honoApi = ofetch.create({
  baseURL:
    process.env.NODE_ENV === 'development'
      ? 'http://localhost:3001'
      : process.env.NUXT_PUBLIC_API_URL,

  onRequest({ request, options }) {
    console.log('🚀 [HONO API Request]', request, options)
  },

  onResponse({ request, response }) {
    console.log('✅ [HONO API Response]', request, response.status)
  },

  onResponseError({ request, response }) {
    console.error('❌ [HONO API Error]', request, response.status, response.statusText)
  },
})

export const useHonoApi = () => {
  const supabase = useSupabaseClient()

  // Helper to get auth headers
  const getAuthHeaders = async () => {
    const {
      data: { session },
    } = await supabase.auth.getSession()

    if (!session?.access_token) {
      throw new Error('No authentication session found')
    }

    return {
      Authorization: `Bearer ${session.access_token}`,
    }
  }

  return {
    // Test connectivity
    testConnection: () => honoApi('/v1/test/connection'),

    // Categories endpoints (existing)
    getCategories: async () => {
      const headers = await getAuthHeaders()
      return honoApi('/v1/discovery/categories', { headers })
    },

    getCategory: async (id: string) => {
      const headers = await getAuthHeaders()
      return honoApi(`/v1/discovery/categories/${id}`, { headers })
    },

    // Topics endpoints (updated)
    getTopics: async (categoryId: string, options?: { limit?: number; offset?: number }) => {
      const headers = await getAuthHeaders()
      const params = new URLSearchParams({
        category_id: categoryId,
        ...(options?.limit && { limit: options.limit.toString() }),
        ...(options?.offset && { offset: options.offset.toString() }),
      })

      return honoApi(`/v1/discovery/topics?${params}`, { headers })
    },

    // NEW: Rich topic cluster detail
    getTopicCluster: async (topicId: string) => {
      const headers = await getAuthHeaders()
      return honoApi(`/v1/discovery/topics/${topicId}/cluster`, { headers })
    },

    // NEW: Entity detail endpoint
    getEntity: async (entityType: string, entityId: string) => {
      const headers = await getAuthHeaders()
      return honoApi(`/v1/entities/${entityType}/${entityId}`, { headers })
    },
  }
}
