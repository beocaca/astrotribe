<script setup lang="ts">
interface TopicCardProps {
  topic: {
    id: string
    name?: string
    title?: string
    summary?: string
    total_entities?: number
    entity_counts?: {
      people?: number
      research?: number
      news?: number
      organizations?: number
    }
  }
}

const props = defineProps<TopicCardProps>()
const router = useRouter()

// Get topic title from name or title field
const topicTitle = computed(() => {
  return props.topic.title || props.topic.name || 'Untitled Topic'
})

// Calculate total entities if not provided
const totalEntities = computed(() => {
  // Debug logging
  console.log('🔍 Topic data:', props.topic)

  // First try direct total_entities field
  if (props.topic.total_entities) return props.topic.total_entities

  // Then try entity_counts object
  const counts = props.topic.entity_counts
  if (counts) {
    const total =
      (counts.people || 0) +
      (counts.research || 0) +
      (counts.news || 0) +
      (counts.organizations || 0)
    console.log('🔍 Calculated total from counts:', total, counts)
    return total
  }

  console.log('🔍 No entity counts found, returning 0')
  return 0
})

// Navigation
const handleClick = () => {
  router.push(`/discover/topics/${props.topic.id}`)
}

// Format large numbers
const formatCount = (count: number) => {
  if (count >= 1000) {
    return `${(count / 1000).toFixed(1)}k`
  }
  return count.toString()
}
</script>

<template>
  <div
    class="group bg-slate-900/50 border border-slate-700/50 rounded-xl p-6 cursor-pointer transition-all duration-300 hover:border-blue-500/50 hover:shadow-lg hover:shadow-blue-500/10"
    @click="handleClick"
  >
    <!-- Topic Header -->
    <div class="mb-4">
      <h3
        class="text-lg font-semibold text-white mb-2 group-hover:text-blue-300 transition-colors line-clamp-2"
      >
        {{ topicTitle }}
      </h3>
      <p class="text-sm text-slate-400 line-clamp-3 leading-relaxed">
        {{ topic.summary || 'Explore the latest research and discoveries in this area' }}
      </p>
    </div>

    <!-- Entity Counts -->
    <div class="space-y-3">
      <!-- Total Count -->
      <div class="flex items-center justify-between">
        <span class="text-sm font-medium text-slate-300">Total Entities</span>
        <span class="text-lg font-bold text-blue-400">{{ formatCount(totalEntities) }}</span>
      </div>

      <!-- Breakdown -->
      <div
        v-if="topic.entity_counts"
        class="grid grid-cols-2 gap-2 text-xs"
      >
        <div
          v-if="topic.entity_counts.people"
          class="flex justify-between"
        >
          <span class="text-slate-500">People</span>
          <span class="text-slate-300">{{ formatCount(topic.entity_counts.people) }}</span>
        </div>
        <div
          v-if="topic.entity_counts.research"
          class="flex justify-between"
        >
          <span class="text-slate-500">Research</span>
          <span class="text-slate-300">{{ formatCount(topic.entity_counts.research) }}</span>
        </div>
        <div
          v-if="topic.entity_counts.news"
          class="flex justify-between"
        >
          <span class="text-slate-500">News</span>
          <span class="text-slate-300">{{ formatCount(topic.entity_counts.news) }}</span>
        </div>
        <div
          v-if="topic.entity_counts.organizations"
          class="flex justify-between"
        >
          <span class="text-slate-500">Organizations</span>
          <span class="text-slate-300">{{ formatCount(topic.entity_counts.organizations) }}</span>
        </div>
      </div>
    </div>

    <!-- Action Indicator -->
    <div class="mt-4 pt-4 border-t border-slate-700/50 flex items-center justify-between">
      <span class="text-xs text-slate-500">Click to explore</span>
      <Icon
        name="arrow-right"
        class="w-4 h-4 text-slate-500 group-hover:text-blue-400 group-hover:translate-x-1 transition-all"
      />
    </div>
  </div>
</template>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-3 {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
