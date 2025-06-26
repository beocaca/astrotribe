<script setup lang="ts">
import { ref, computed } from 'vue'

// Get category ID from route
const route = useRoute()
const categoryId = route.params.category as string

// Page meta
definePageMeta({
  title: 'Topics',
  description: 'Browse topics in this category',
})

// Composables
const { getTopics, getCategories } = useHonoApi()

// Get category info first to resolve the name
const { data: categoriesResponse } = await useLazyAsyncData('categories', () => getCategories())

// Extract categories from API response
const categories = computed(() => {
  if (!categoriesResponse.value?.success || !categoriesResponse.value?.data) return []
  return categoriesResponse.value.data
})

// Find current category
const currentCategory = computed(() => {
  return categories.value.find((cat) => cat.id === categoryId)
})

// Get topics for this category
const {
  data: topicsResponse,
  pending,
  error,
} = await useLazyAsyncData(`topics-${categoryId}`, () => getTopics(categoryId))

// Extract topics from API response
const topics = computed(() => {
  if (!topicsResponse.value?.success || !topicsResponse.value?.data) return []
  return topicsResponse.value.data
})

// Page title based on category
const pageTitle = computed(() => {
  return currentCategory.value?.title || 'Category Topics'
})

// Don't show breadcrumbs - they should be in the nav bar
// If you want to keep them, use proper category name:
const breadcrumbs = computed(() => [
  { label: 'Discover', url: '/discover' },
  { label: currentCategory.value?.title || 'Category', url: null },
])
</script>

<template>
  <div class="min-h-screen bg-black">
    <!-- Star field background placeholder -->
    <div class="absolute inset-0 bg-gradient-to-b from-purple-900/20 to-blue-900/20" />

    <div class="relative z-10 container mx-auto px-4 py-8">
      <!-- Remove breadcrumb if it's in nav bar, or fix the name -->
      <!-- <DiscoverBreadcrumb :items="breadcrumbs" class="mb-8" /> -->

      <!-- Page Header -->
      <div class="mb-12">
        <div class="flex items-center mb-4">
          <div
            class="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-xl flex items-center justify-center mr-6"
          >
            <Icon
              name="mdi:telescope"
              class="w-8 h-8 text-white"
            />
          </div>
          <div>
            <h1 class="text-4xl font-bold text-white mb-2">
              {{ pageTitle }}
            </h1>
            <p class="text-slate-300">
              {{ currentCategory?.summary || 'Explore research topics and discoveries' }}
            </p>
          </div>
        </div>

        <!-- Stats -->
        <div
          v-if="topics"
          class="flex items-center space-x-6 text-sm text-slate-400"
        >
          <span>{{ topics.length }} topics available</span>
          <span>•</span>
          <span>Updated recently</span>
        </div>
      </div>

      <!-- Loading State -->
      <div
        v-if="pending"
        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
      >
        <DiscoverSkeletonCard
          v-for="i in 9"
          :key="i"
        />
      </div>

      <!-- Error State -->
      <div
        v-else-if="error"
        class="text-center py-12"
      >
        <div class="bg-red-900/20 border border-red-500/30 rounded-lg p-6 max-w-md mx-auto">
          <h3 class="text-red-400 text-lg font-semibold mb-2">Unable to Load Topics</h3>
          <p class="text-red-300 text-sm">{{ error }}</p>
        </div>
      </div>

      <!-- Topics Grid -->
      <div
        v-else-if="topics?.length"
        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
      >
        <DiscoverTopicCard
          v-for="topic in topics"
          :key="topic.id"
          :topic="topic"
        />
      </div>

      <!-- Empty State -->
      <div
        v-else
        class="text-center py-12"
      >
        <div class="bg-slate-800/50 border border-slate-700/50 rounded-lg p-8 max-w-md mx-auto">
          <Icon
            name="mdi:search"
            class="w-12 h-12 text-slate-500 mx-auto mb-4"
          />
          <h3 class="text-slate-300 text-lg font-semibold mb-2">No Topics Found</h3>
          <p class="text-slate-500 text-sm">This category doesn't have any topics yet.</p>
        </div>
      </div>
    </div>
  </div>
</template>
