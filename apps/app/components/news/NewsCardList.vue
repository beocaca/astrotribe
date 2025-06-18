<script setup lang="ts">
import { computed } from 'vue'
import { useTimeAgo } from '@vueuse/core'
import { extractPlainText } from '~/utils/extractPlainText'

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
      organization_name?: string
      organization_logo?: string
      source_name?: string
    }
  }
}

const props = defineProps<NewsCardProps>()

const sourceName = computed(() => props.news.details?.source_name ?? 'Source')

const readingTime = computed(() => {
  if (props.news.details?.readTime) return props.news.details.readTime
  if (props.news.description) {
    const wordCount = props.news.description.split(/\s+/).length
    return Math.max(1, Math.ceil(wordCount / 200))
  }
  return 2
})

const publishedTimeAgo = computed(() => {
  if (!props.news.published_at) return ''
  return useTimeAgo(new Date(props.news.published_at)).value
})

const summaryText = computed(() => {
  const uncleanText =
    props.news.details?.summaries?.undefined?.[0]?.summary ?? props.news.description
  return extractPlainText(uncleanText || '')
})

const fallbackImage = '/images/news_fallback.jpg'
const imageSource = computed(() => props.news.featured_image || fallbackImage)
</script>

<template>
  <div class="flex gap-4 items-start border-b border-primary-900 py-4">
    <!-- Image -->
    <NuxtImg
      :src="imageSource"
      :alt="news.title"
      class="w-32 h-20 rounded-lg object-cover flex-shrink-0"
    />

    <!-- Content -->
    <div class="flex flex-col gap-2 flex-grow">
      <!-- Title and Meta -->
      <div class="flex items-center justify-between">
        <h3
          class="text-lg font-semibold leading-tight line-clamp-2"
          :title="news.title"
        >
          {{ news.title }}
        </h3>
        <span class="text-xs text-gray-400 whitespace-nowrap">
          {{ publishedTimeAgo }}
        </span>
      </div>

      <div class="text-sm text-gray-300 leading-relaxed break-words prose prose-invert max-w-none">
        {{ summaryText }}
      </div>

      <div class="flex items-center gap-4 text-xs text-gray-400 mt-1">
        <span>{{ sourceName }}</span>
        <span>•</span>
        <span>{{ readingTime }} min read</span>
      </div>
    </div>

    <!-- Actions -->
    <div class="flex flex-col gap-2 items-center justify-between flex-shrink-0">
      <!-- Source Link -->
      <NuxtLink
        :to="news.url"
        target="_blank"
        rel="noopener noreferrer nofollow"
        class="p-1 hover:text-primary-500"
      >
        <Icon
          name="mdi:link-variant"
          class="w-5 h-5"
        />
      </NuxtLink>
    </div>
  </div>
</template>
