<script setup lang="ts">
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useTimeAgo } from '@vueuse/core'
import { extractPlainText } from '~/utils/extractPlainText'

// Define props with better typing
interface NewsCardProps {
  news: {
    id: string
    content_type: string
    title: string
    url: string
    hot_score: number
    created_at: string
    updated_at: string
    published_at: string | null
    featured_image: string | null
    author: string | null
    description: string | null
    source_id: string | null
    details?: {
      categories?: Array<{ name: string; isPrimary: boolean }>
      tags?: string[]
      summaries?: Record<string, Array<{ id: string; summary: string; version: number }> | null>
      readTime?: number
      company_name?: string
      company_logo?: string
      source_name?: string
    }
  }
}

const props = defineProps<NewsCardProps>()

// Local card state
const isFlipped = ref(false)

// Extract category badges
const categories = computed(() => props.news.details?.categories?.map((c) => c.name) || [])

// Extract the primary category
const primaryCategory = computed(() => {
  const primary = props.news.details?.categories?.find((c) => c.isPrimary)
  return primary?.name || categories.value[0] || 'News'
})

// Get source name from details
const sourceName = computed(() => {
  if (props.news.details?.source_name) return props.news.details.source_name

  // Try to extract from URL (SAFE STRING ONLY)
  if (props.news.url) {
    try {
      const hostname = props.news.url
        .replace(/^https?:\/\//, '')
        .replace(/^www\./, '')
        .split('/')[0]
      return hostname
    } catch {
      return 'Source'
    }
  }
  return 'Source'
})

// Calculate reading time (fallback to estimate if not provided)
const readingTime = computed(() => {
  if (props.news.details?.readTime) return props.news.details.readTime

  // Estimate based on description length (avg reading speed: 200 words/min)
  if (props.news.description) {
    const wordCount = props.news.description.split(/\s+/).length
    return Math.max(1, Math.ceil(wordCount / 200))
  }
  return 2 // Default fallback
})

const summaryText = computed(() => {
  const uncleanText =
    props.news.details?.summaries?.undefined?.[0]?.summary ?? props.news.description
  const plainText = extractPlainText(uncleanText || '')
  return plainText.length > 400 ? plainText.slice(0, 400) + '...' : plainText
})

// Format published date
const publishedTimeAgo = computed(() => {
  if (!props.news.published_at) return ''
  return useTimeAgo(new Date(props.news.published_at)).value
})

// Handle interaction based on device
const handleCardClick = (event: MouseEvent) => {
  // Don't flip if clicking on a link or button
  const target = event.target as HTMLElement
  if (target.closest('a') || target.closest('button')) {
    event.stopPropagation()
    return
  }
  isFlipped.value = !isFlipped.value
}

const handleMouseEnter = () => {
  isFlipped.value = true
}

const handleMouseLeave = () => {
  isFlipped.value = false
}

// Image fallback
const fallbackImage = '/images/news_fallback.jpg'
const imageSource = computed(() => props.news.featured_image || fallbackImage)

const clippedSummary = computed(() => {
  const uncleanText =
    props.news.details?.summaries?.undefined?.[0]?.summary ?? props.news.description
  const plainText = extractPlainText(uncleanText || '')
  return plainText.length > 200 ? plainText.slice(0, 200) + '...' : plainText
})
</script>

<template>
  <div
    class="bg-primary-950 border border-primary-800/30 rounded-lg p-4 flex flex-col justify-between h-full hover:bg-primary-900 transition"
  >
    <div>
      <!-- Category & Source -->
      <div class="flex items-center justify-between mb-3 text-xs text-primary-500">
        <NewsCategoryBadge :category="primaryCategory" />
        <span>{{ sourceName }}</span>
      </div>

      <div class="flex items-center gap-2 text-xs text-gray-400 mb-3">
        <span>{{ publishedTimeAgo }}</span>
        <span>•</span>
        <span>{{ readingTime }}m read</span>
      </div>

      <!-- Title -->
      <h3
        class="text-xl font-bold mb-2 line-clamp-2"
        :title="news.title"
      >
        {{ news.title }}
      </h3>

      <!-- Summary -->
      <p class="text-sm text-gray-300 leading-relaxed mb-4">
        {{ clippedSummary }}
      </p>

      <!-- Tags -->
      <div
        v-if="news.details?.tags?.length"
        class="flex flex-wrap gap-2 mb-4"
      >
        <PrimeChip
          v-for="tag in news.details.tags.slice(0, 5)"
          :key="tag"
          class="bg-primary-800/50 text-xs"
        >
          {{ tag }}
        </PrimeChip>
      </div>
    </div>

    <!-- Footer -->
    <!-- Actions (BOTTOM) -->
    <div class="flex items-center justify-between pt-4 border-t border-primary-800/50 mt-4"> </div>
  </div>
</template>

<style scoped>
.perspective-1000 {
  perspective: 1000px;
}

.transform-style-preserve-3d {
  transform-style: preserve-3d;
}

.backface-hidden {
  backface-visibility: hidden;
}

.rotate-y-180 {
  transform: rotateY(180deg);
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
