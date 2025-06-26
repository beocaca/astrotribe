<script setup lang="ts">
interface ScaleCategoryCardProps {
  category: {
    id: string
    title: string
    summary?: string
    domain?: 'astronomy' | 'space_tech'
    topic_count?: number
  }
  theme?: 'astronomy' | 'spaceTech'
}

const props = withDefaults(defineProps<ScaleCategoryCardProps>(), {
  theme: 'astronomy',
})

const router = useRouter()

// Theme-specific colors for the scale carousel
const themeClasses = computed(() => {
  return props.theme === 'astronomy'
    ? 'bg-slate-800 border-blue-500/30 hover:border-blue-400/50'
    : 'bg-slate-800 border-orange-500/30 hover:border-orange-400/50'
})

const accentColor = computed(() => {
  return props.theme === 'astronomy' ? 'text-blue-400' : 'text-orange-400'
})

// Navigation
const handleClick = () => {
  router.push(`/discover/${props.category.id}`)
}

// Optimized text for scale carousel (more readable when scaled)
const displayTitle = computed(() => {
  if (props.category.title.length > 40) {
    return props.category.title.substring(0, 40) + '...'
  }
  return props.category.title
})

const displaySummary = computed(() => {
  if (!props.category.summary)
    return 'Explore groundbreaking research and discoveries in this field'
  if (props.category.summary.length > 160) {
    return props.category.summary.substring(0, 160) + '...'
  }
  return props.category.summary
})
</script>

<template>
  <div
    class="group relative border rounded-lg p-5 cursor-pointer transition-all duration-300 hover:scale-105 w-full h-full flex flex-col justify-between shadow-lg backdrop-blur-sm"
    :class="themeClasses"
    @click="handleClick"
  >
    <!-- Card Content -->
    <div class="space-y-3 flex-1 flex flex-col">
      <!-- Title -->
      <h3
        class="text-xl font-bold text-white group-hover:transition-colors leading-tight line-clamp-2"
      >
        {{ displayTitle }}
      </h3>

      <!-- Summary -->
      <p class="text-sm text-slate-300 leading-relaxed line-clamp-3 flex-1">
        {{ displaySummary }}
      </p>
    </div>

    <!-- Footer -->
    <div class="flex items-center justify-between pt-4 border-t border-slate-700/50 mt-4">
      <div class="flex items-center gap-2">
        <div
          class="w-1.5 h-1.5 rounded-full"
          :class="theme === 'astronomy' ? 'bg-blue-400' : 'bg-orange-400'"
        ></div>
        <span class="text-xs text-slate-400 font-medium">
          {{ category.topic_count || 0 }} topics
        </span>
      </div>

      <div
        class="flex items-center gap-2 text-sm opacity-70 group-hover:opacity-100 transition-all group-hover:translate-x-1"
        :class="accentColor"
      >
        <span class="font-medium">Explore</span>
        <Icon
          name="mdi:arrow-right"
          class="w-4 h-4"
        />
      </div>
    </div>

    <!-- Enhanced hover glow -->
    <div
      class="absolute inset-0 rounded-lg opacity-0 group-hover:opacity-8 transition-opacity duration-300 pointer-events-none blur-sm"
      :class="theme === 'astronomy' ? 'bg-blue-500' : 'bg-orange-500'"
    />

    <!-- Subtle gradient overlay -->
    <div
      class="absolute inset-0 rounded-lg opacity-5 pointer-events-none"
      :class="
        theme === 'astronomy'
          ? 'bg-gradient-to-br from-blue-500/20 to-purple-600/20'
          : 'bg-gradient-to-br from-orange-500/20 to-red-600/20'
      "
    />
  </div>
</template>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-4 {
  display: -webkit-box;
  -webkit-line-clamp: 4;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* Ensure the card maintains aspect ratio and fills container */
.group {
  min-height: 200px; /* Smaller card height */
  max-width: 400px; /* Smaller max width */
  margin: 0 auto;
}

/* Enhanced scaling for focus effect - reduced scale to prevent cutoff */
.group:hover {
  transform: scale(1.02); /* Reduced from 1.05 */
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.25);
}
</style>
