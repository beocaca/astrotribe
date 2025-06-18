import { ref, reactive } from 'vue'

export interface Category {
  id: string
  name: string
  body?: string
}

export interface Topic {
  id: string
  name: string
}

export interface Feature {
  id: string
  title: string
  description?: string
  status: string
}

export function useOnboardingData() {
  // State for categories (interests)
  const categories = ref<Category[]>([])
  const loadingCategories = ref(false)
  const categoriesError = ref<string | null>(null)

  // State for features
  const features = ref<Feature[]>([])
  const loadingFeatures = ref(false)
  const featuresError = ref<string | null>(null)

  // State for topics (topics)
  const topics = ref<Topic[]>([])
  const loadingTopics = ref(false)
  const topicsError = ref<string | null>(null)

  // Fetch categories for interests step
  async function fetchCategories() {
    if (categories.value.length > 0) {
      return categories.value
    }

    loadingCategories.value = true
    categoriesError.value = null

    try {
      const { data, error } = await useFetch<Category[]>('/api/categories')

      if (error.value) {
        throw new Error(error.value.message || 'Failed to fetch categories')
      }

      categories.value = data.value || []
      return categories.value
    } catch (err: any) {
      console.error('Error fetching categories:', err)
      categoriesError.value = err.message || 'Failed to load categories'
      return []
    } finally {
      loadingCategories.value = false
    }
  }

  // Fetch features for feature interests step
  async function fetchFeatures() {
    if (features.value.length > 0) {
      return features.value
    }

    loadingFeatures.value = true
    featuresError.value = null

    try {
      const { data, error } = await useFetch<Feature[]>('/api/features')

      if (error.value) {
        throw new Error(error.value.message || 'Failed to fetch features')
      }

      features.value = data.value || []
      return features.value
    } catch (err: any) {
      console.error('Error fetching features:', err)
      featuresError.value = err.message || 'Failed to load features'
      return []
    } finally {
      loadingFeatures.value = false
    }
  }

  // Fetch topics for topics step
  async function fetchTopics() {
    if (topics.value.length > 0) {
      return topics.value
    }

    loadingTopics.value = true
    topicsError.value = null

    try {
      const { data, error } = await useFetch<Topic[]>('/api/topics')

      if (error.value) {
        throw new Error(error.value.message || 'Failed to fetch topics')
      }

      topics.value = data.value || []
      return topics.value
    } catch (err: any) {
      console.error('Error fetching topics:', err)
      topicsError.value = err.message || 'Failed to load topics'
      return []
    } finally {
      loadingTopics.value = false
    }
  }

  // Search topics by name (for autocomplete)
  function searchTopics(query: string) {
    if (!query || query.length < 2) return []

    const normalizedQuery = query.toLowerCase()
    return topics.value.filter((tag) => tag.name.toLowerCase().includes(normalizedQuery))
  }

  // Fetch countries for location step
  const countries = ref<any[]>([])
  const loadingCountries = ref(false)
  const countriesError = ref<string | null>(null)

  async function fetchCountries() {
    if (countries.value.length > 0) {
      return countries.value
    }

    loadingCountries.value = true
    countriesError.value = null

    try {
      const { data, error } = await useFetch('/api/countries')

      if (error.value) {
        throw new Error(error.value.message || 'Failed to fetch countries')
      }

      countries.value = data.value || []
      return countries.value
    } catch (err: any) {
      console.error('Error fetching countries:', err)
      countriesError.value = err.message || 'Failed to load countries'
      return []
    } finally {
      loadingCountries.value = false
    }
  }

  // Fetch cities by country
  const cities = reactive<Record<string, any[]>>({})
  const loadingCities = ref(false)
  const citiesError = ref<string | null>(null)

  async function fetchCitiesByCountry(countryId: string) {
    if (cities[countryId]?.length > 0) {
      return cities[countryId]
    }

    loadingCities.value = true
    citiesError.value = null

    try {
      const { data, error } = await useFetch(`/api/cities?countryId=${countryId}`)

      if (error.value) {
        throw new Error(error.value.message || 'Failed to fetch cities')
      }

      cities[countryId] = data.value || []
      return cities[countryId]
    } catch (err: any) {
      console.error(`Error fetching cities for country ${countryId}:`, err)
      citiesError.value = err.message || 'Failed to load cities'
      return []
    } finally {
      loadingCities.value = false
    }
  }

  return {
    // Categories
    categories,
    loadingCategories,
    categoriesError,
    fetchCategories,

    // Features
    features,
    loadingFeatures,
    featuresError,
    fetchFeatures,

    // Topics
    topics,
    loadingTopics,
    topicsError,
    fetchTopics,
    searchTopics,

    // Countries
    countries,
    loadingCountries,
    countriesError,
    fetchCountries,

    // Cities
    cities,
    loadingCities,
    citiesError,
    fetchCitiesByCountry,
  }
}
