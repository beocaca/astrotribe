<script setup lang="ts">
import { ref, computed } from 'vue'

// Page meta
definePageMeta({
  title: 'Discover - AstronEra',
  description: 'Explore astronomy and space technology topics',
})

// Composables
const { getCategories } = useHonoApi()

// Use proper async data handling
const {
  data: categoriesResponse,
  pending,
  error,
} = await useLazyAsyncData('categories', async () => {
  try {
    return await getCategories()
  } catch (err) {
    console.error('Failed to fetch categories:', err)
    throw err
  }
})

// Extract the actual categories data from API response
const categories = computed(() => {
  console.log('🔍 Raw categories response:', categoriesResponse.value)

  if (!categoriesResponse.value) return null

  // API returns { success: true, data: [...], meta: {...} }
  if (categoriesResponse.value.success && categoriesResponse.value.data) {
    console.log('✅ Categories data found:', categoriesResponse.value.data.length)
    return categoriesResponse.value.data
  }

  console.log('❌ No categories in response')
  return null
})

// Group categories by domain field
const groupedCategories = computed(() => {
  if (!categories.value || !Array.isArray(categories.value)) {
    console.log('🔍 No categories data or not an array:', categories.value)
    return { astronomy: [], spaceTech: [] }
  }

  console.log('🔍 Processing categories:', categories.value.length)
  console.log('🔍 Sample category:', categories.value[0])

  const astronomy = categories.value.filter((cat) => cat.domain === 'astronomy')
  const spaceTech = categories.value.filter((cat) => cat.domain === 'space_tech')

  console.log('🔍 Final grouping:', {
    astronomy: astronomy.length,
    spaceTech: spaceTech.length,
    astronomyTitles: astronomy.map((c) => c.title),
    spaceTechTitles: spaceTech.map((c) => c.title),
  })

  return { astronomy, spaceTech }
})
</script>

<template>
  <div class="min-h-screen bg-slate-900">
    <div class="mx-auto px-6 py-12 max-w-none">
      <!-- Page Header -->
      <div class="text-center mb-16">
        <h1 class="text-4xl md:text-5xl font-bold text-white mb-4"> Discover the Universe </h1>
        <p class="text-lg text-slate-300">
          Explore cutting-edge research and breakthrough technologies.
        </p>
      </div>

      <!-- Loading State -->
      <div
        v-if="pending"
        class="grid grid-cols-1 lg:grid-cols-2 gap-8"
      >
        <div class="space-y-6">
          <div class="flex items-center gap-4 mb-6">
            <div class="w-8 h-8 bg-slate-700 rounded animate-pulse"></div>
            <div class="h-6 bg-slate-700 rounded w-32 animate-pulse"></div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div
              v-for="i in 4"
              :key="i"
              class="h-32 bg-slate-700 rounded-lg animate-pulse"
            ></div>
          </div>
        </div>
        <div class="space-y-6">
          <div class="flex items-center gap-4 mb-6">
            <div class="w-8 h-8 bg-slate-700 rounded animate-pulse"></div>
            <div class="h-6 bg-slate-700 rounded w-40 animate-pulse"></div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div
              v-for="i in 4"
              :key="i"
              class="h-32 bg-slate-700 rounded-lg animate-pulse"
            ></div>
          </div>
        </div>
      </div>

      <!-- Error State -->
      <div
        v-else-if="error"
        class="text-center py-12"
      >
        <div class="bg-red-900/20 border border-red-500/30 rounded-lg p-6 max-w-md mx-auto">
          <h3 class="text-red-400 text-lg font-semibold mb-2">Unable to Load Categories</h3>
          <p class="text-red-300 text-sm">{{ error }}</p>
          <PrimeButton
            label="Retry"
            class="mt-4"
            @click="refreshCookie('categories')"
          />
        </div>
      </div>

      <!-- Categories Content - Side by Side Scale Carousels -->
      <div
        v-else
        class="grid grid-cols-1 lg:grid-cols-2 gap-16"
      >
        <!-- Astronomy Section -->
        <section class="space-y-6">
          <div class="text-center mb-8">
            <div class="flex items-center justify-center gap-3 mb-3">
              <div class="w-10 h-10 bg-blue-500 rounded-lg flex items-center justify-center">
                <Icon
                  name="mdi:telescope"
                  class="w-6 h-6 text-white"
                />
              </div>
              <h2 class="text-2xl font-bold text-white">Astronomy</h2>
            </div>
            <p class="text-slate-400 text-sm"
              >{{ groupedCategories.astronomy.length }} categories</p
            >
          </div>

          <div v-if="groupedCategories.astronomy.length">
            <EmblaCarousel
              :items="groupedCategories.astronomy"
              type="astronomy"
              :has-navigation="true"
            >
              <template #default="{ item }">
                <DiscoverCategoryCard
                  :category="item"
                  theme="astronomy"
                />
              </template>
            </EmblaCarousel>
          </div>

          <div
            v-else
            class="text-slate-400 text-center py-8 text-sm"
          >
            No astronomy categories available
          </div>
        </section>

        <!-- Space Technology Section -->
        <section class="space-y-6">
          <div class="text-center mb-8">
            <div class="flex items-center justify-center gap-3 mb-3">
              <div class="w-10 h-10 bg-orange-500 rounded-lg flex items-center justify-center">
                <Icon
                  name="mdi:rocket"
                  class="w-6 h-6 text-white"
                />
              </div>
              <h2 class="text-2xl font-bold text-white">Space Technology</h2>
            </div>
            <p class="text-slate-400 text-sm"
              >{{ groupedCategories.spaceTech.length }} categories</p
            >
          </div>

          <div v-if="groupedCategories.spaceTech.length">
            <EmblaCarousel
              :items="groupedCategories.spaceTech"
              type="spaceTech"
              :has-navigation="true"
            >
              <template #default="{ item }">
                <DiscoverCategoryCard
                  :category="item"
                  theme="spaceTech"
                />
              </template>
            </EmblaCarousel>
          </div>

          <div
            v-else
            class="text-slate-400 text-center py-8 text-sm"
          >
            No space technology categories available
          </div>
        </section>
      </div>
    </div>
  </div>
</template>
