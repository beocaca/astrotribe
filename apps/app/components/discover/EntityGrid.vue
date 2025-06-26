<script setup lang="ts">
interface EntityGridProps {
  entities: any[]
  entityType: 'people' | 'research' | 'news' | 'organizations'
  title: string
  totalCount?: number // Add total count prop from API
}

const props = defineProps<EntityGridProps>()

const router = useRouter()

// Navigate to entity detail page
const navigateToEntity = (entity: any) => {
  // Map entity types to URL-friendly names
  const entityTypeMap = {
    'people': 'people',
    'research': 'research', 
    'news': 'news',
    'organizations': 'organizations'
  }
  
  const urlType = entityTypeMap[props.entityType] || props.entityType
  router.push(`/entity/${urlType}/${entity.id}`)
}

// Limit to first 50 entities for now (no pagination)
const displayEntities = computed(() => {
  return props.entities.slice(0, 50)
})

// Show "more available" indicator based on total count if available
const hasMore = computed(() => {
  if (props.totalCount) {
    return props.totalCount > displayEntities.value.length
  }
  return props.entities.length > 50
})

// Calculate remaining count
const remainingCount = computed(() => {
  if (props.totalCount) {
    return props.totalCount - displayEntities.value.length
  }
  return props.entities.length - 50
})

// Basic entity display based on type
const getEntityTitle = (entity: any) => {
  switch (props.entityType) {
    case 'people':
      return entity.name || entity.full_name || 'Unknown Person'
    case 'research':
      return entity.title || 'Untitled Research'
    case 'news':
      return entity.title || entity.headline || 'News Article'
    case 'organizations':
      return entity.name || 'Unknown Organization'
    default:
      return 'Unknown Entity'
  }
}

const getEntitySubtitle = (entity: any) => {
  switch (props.entityType) {
    case 'people':
      return entity.affiliation || entity.career_level || ''
    case 'research':
      return entity.journal || entity.publication_date || ''
    case 'news':
      return entity.source || entity.publication_date || ''
    case 'organizations':
      return entity.type || entity.location || ''
    default:
      return ''
  }
}

const getEntityIcon = () => {
  switch (props.entityType) {
    case 'people':
      return 'mdi:account'
    case 'research':
      return 'mdi:file-text'
    case 'news':
      return 'mdi:newspaper'
    case 'organizations':
      return 'mdi:building'
    default:
      return 'mdi:circle'
  }
}
</script>

<template>
  <div>
    <!-- Section Header -->
    <div class="flex items-center justify-between mb-6">
      <h2 class="text-2xl font-bold text-white">{{ title }}</h2>
      <div class="text-sm text-slate-400">
        <span v-if="totalCount">Showing {{ displayEntities.length }} of {{ totalCount }}</span>
        <span v-else>Showing {{ displayEntities.length }}{{ hasMore ? ` of ${entities.length}` : '' }}</span>
      </div>
    </div>

    <!-- Entities Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      <div
        v-for="entity in displayEntities"
        :key="entity.id"
        class="group bg-slate-900/50 border border-slate-700/50 rounded-lg p-4 hover:border-slate-600/50 hover:bg-slate-800/50 transition-all cursor-pointer"
        @click="navigateToEntity(entity)"
      >
        <!-- Entity Icon and Title -->
        <div class="flex items-start space-x-3">
          <div
            class="flex-shrink-0 w-10 h-10 bg-slate-700/50 rounded-lg flex items-center justify-center"
          >
            <Icon
              :name="getEntityIcon()"
              class="w-5 h-5 text-slate-300"
            />
          </div>

          <div class="flex-1 min-w-0">
            <div class="flex items-center justify-between">
              <h3 class="text-white font-medium text-sm leading-tight line-clamp-2 mb-1 flex-1">
                {{ getEntityTitle(entity) }}
              </h3>
              <Icon
                name="mdi:open-in-new"
                class="w-3 h-3 text-slate-500 ml-2 opacity-0 group-hover:opacity-100 transition-opacity"
              />
            </div>
            <p
              v-if="getEntitySubtitle(entity)"
              class="text-slate-400 text-xs line-clamp-1"
            >
              {{ getEntitySubtitle(entity) }}
            </p>
          </div>
        </div>

        <!-- Basic metadata based on entity type -->
        <div class="mt-3 text-xs text-slate-500">
          <div
            v-if="entityType === 'research' && entity.doi"
            class="truncate"
          >
            DOI: {{ entity.doi }}
          </div>
          <div
            v-else-if="entityType === 'news' && entity.publication_date"
            class="truncate"
          >
            {{ new Date(entity.publication_date).toLocaleDateString() }}
          </div>
          <div
            v-else-if="entityType === 'people' && entity.nationality"
            class="truncate"
          >
            {{ entity.nationality }}
          </div>
          <div
            v-else-if="entityType === 'organizations' && entity.website"
            class="truncate"
          >
            {{ entity.website }}
          </div>
        </div>
      </div>
    </div>

    <!-- More Available Indicator -->
    <div
      v-if="hasMore && remainingCount > 0"
      class="mt-6 text-center"
    >
      <div class="bg-slate-900/50 border border-slate-700/50 rounded-lg p-4">
        <p class="text-slate-400 text-sm">
          {{ remainingCount }} more {{ entityType }} available
        </p>
        <p class="text-slate-500 text-xs mt-1"> Pagination coming soon </p>
      </div>
    </div>

    <!-- Empty State (shouldn't happen due to v-if in parent) -->
    <div
      v-if="!displayEntities.length"
      class="text-center py-8"
    >
      <Icon
        :name="getEntityIcon()"
        class="w-12 h-12 text-slate-500 mx-auto mb-4"
      />
      <p class="text-slate-400">No {{ entityType }} found</p>
    </div>
  </div>
</template>

<style scoped>
.line-clamp-1 {
  display: -webkit-box;
  -webkit-line-clamp: 1;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
