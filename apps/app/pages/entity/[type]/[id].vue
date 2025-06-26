<script setup lang="ts">
const route = useRoute()
const entityType = route.params.type as string
const entityId = route.params.id as string

// Validate route params
if (!entityType || !entityId) {
  throw createError({
    statusCode: 400,
    statusMessage: 'Invalid entity parameters',
  })
}

// Fetch entity data
const {
  data: entity,
  pending,
  error,
} = await useLazyAsyncData(`entity-${entityType}-${entityId}`, async () => {
  const api = useHonoApi()
  try {
    const response = await api.getEntity(entityType, entityId)
    if (!response.success) {
      throw createError({
        statusCode: 404,
        statusMessage: response.error || 'Entity not found',
      })
    }
    return response.data
  } catch (err: any) {
    console.error('Entity fetch error:', err)
    throw createError({
      statusCode: err.statusCode || 500,
      statusMessage: err.message || 'Failed to load entity',
    })
  }
})

// Type-specific configurations
const getEntityConfig = (type: string, entityData: any) => {
  const configs = {
    'people': {
      singularName: 'Person',
      actionLabel: 'Follow Person',
      relatedTitle: 'Related Research & Organizations',
      primaryFields: [
        { label: 'Career Level', value: entityData?.career_level, type: 'badge' },
        { label: 'Nationality', value: entityData?.nationality, type: 'text' },
        { label: 'Birth Year', value: entityData?.birth_year, type: 'text' },
        { label: 'Honorific', value: entityData?.honorific_prefix, type: 'text' },
      ],
    },
    'organizations': {
      singularName: 'Organization',
      actionLabel: 'Follow Organization',
      relatedTitle: 'Related People & Research',
      primaryFields: [
        { label: 'Type', value: entityData?.organization_type, type: 'badge' },
        { label: 'Founded', value: entityData?.founding_year, type: 'text' },
        { label: 'Website', value: entityData?.url, type: 'link' },
        { label: 'Government', value: entityData?.is_government, type: 'boolean' },
      ],
    },
    'research': {
      singularName: 'Research Paper',
      actionLabel: 'Follow Paper',
      relatedTitle: 'Related Authors & Citations',
      primaryFields: [
        { label: 'Journal', value: entityData?.journal_name, type: 'text' },
        { label: 'DOI', value: entityData?.doi, type: 'link', linkPrefix: 'https://doi.org/' },
        { label: 'ArXiv ID', value: entityData?.arxiv_id, type: 'text' },
        { label: 'Published', value: entityData?.published_at, type: 'date' },
        { label: 'Open Access', value: entityData?.is_open_access, type: 'boolean' },
        { label: 'Peer Reviewed', value: entityData?.is_peer_reviewed, type: 'boolean' },
      ],
    },
    'news': {
      singularName: 'News Article',
      actionLabel: 'Follow News',
      relatedTitle: 'Related Stories & Sources',
      primaryFields: [
        { label: 'Author', value: entityData?.author_name_fallback, type: 'text' },
        { label: 'Type', value: entityData?.news_type, type: 'badge' },
        { label: 'Published', value: entityData?.published_at, type: 'date' },
        { label: 'Featured', value: entityData?.is_featured, type: 'boolean' },
      ],
    },
    'astronomy-events': {
      singularName: 'Astronomy Event',
      actionLabel: 'Follow Event',
      relatedTitle: 'Related Events & Observations',
      primaryFields: [
        { label: 'Category', value: entityData?.category, type: 'badge' },
        { label: 'Date', value: entityData?.date, type: 'text' },
        { label: 'Time', value: entityData?.time, type: 'text' },
      ],
    },
    'opportunities': {
      singularName: 'Opportunity',
      actionLabel: 'Follow Opportunities',
      relatedTitle: 'Related Jobs & Organizations',
      primaryFields: [
        { label: 'Location', value: entityData?.location, type: 'text' },
        { label: 'Employment Type', value: entityData?.employment_type, type: 'badge' },
        { label: 'Urgency', value: entityData?.urgency_level, type: 'badge' },
        { label: 'Expires', value: entityData?.expires_at, type: 'date' },
        { label: 'Application URL', value: entityData?.application_url, type: 'link' },
        { label: 'Featured', value: entityData?.featured, type: 'boolean' },
      ],
    },
  }

  return (
    configs[type as keyof typeof configs] || {
      singularName: 'Entity',
      actionLabel: 'Follow Entity',
      relatedTitle: 'Related Items',
      primaryFields: [],
    }
  )
}

const config = computed(() => getEntityConfig(entityType, entity.value))

// Helper functions
const visitWebsite = () => {
  if (entity.value?.url) {
    window.open(entity.value.url, '_blank')
  }
}

const openApplicationUrl = () => {
  if (entity.value?.application_url) {
    window.open(entity.value.application_url, '_blank')
  }
}

const openDoiUrl = () => {
  if (entity.value?.doi) {
    window.open(`https://doi.org/${entity.value.doi}`, '_blank')
  }
}

const getStatusColor = (status: string) => {
  if (!status) return 'text-gray-400'
  const colors: Record<string, string> = {
    approved: 'text-green-400',
    safe: 'text-green-400',
    Public: 'text-green-400',
    published: 'text-green-400',
    default: 'text-gray-400',
  }
  return colors[status] || colors.default
}

const formatDate = (dateString: string) => {
  if (!dateString) return ''
  return new Date(dateString).toLocaleDateString()
}

const formatValue = (field: any) => {
  if (field.value === null || field.value === undefined || field.value === '') return null

  switch (field.type) {
    case 'date':
      return formatDate(field.value)
    case 'boolean':
      return field.value ? 'Yes' : 'No'
    case 'link':
      return field.value
    default:
      return field.value
  }
}

const getBadgeColor = (value: string) => {
  const colorMap: Record<string, string> = {
    // Career levels
    student: 'bg-blue-500/20 text-blue-300 border border-blue-500/30',
    postdoc: 'bg-green-500/20 text-green-300 border border-green-500/30',
    faculty: 'bg-purple-500/20 text-purple-300 border border-purple-500/30',
    industry: 'bg-orange-500/20 text-orange-300 border border-orange-500/30',

    // Organization types
    company: 'bg-blue-500/20 text-blue-300 border border-blue-500/30',
    university: 'bg-purple-500/20 text-purple-300 border border-purple-500/30',
    government: 'bg-green-500/20 text-green-300 border border-green-500/30',
    nonprofit: 'bg-yellow-500/20 text-yellow-300 border border-yellow-500/30',

    // Employment types
    full_time: 'bg-green-500/20 text-green-300 border border-green-500/30',
    part_time: 'bg-blue-500/20 text-blue-300 border border-blue-500/30',
    contract: 'bg-orange-500/20 text-orange-300 border border-orange-500/30',
    internship: 'bg-purple-500/20 text-purple-300 border border-purple-500/30',

    // Urgency
    low: 'bg-gray-500/20 text-gray-300 border border-gray-500/30',
    normal: 'bg-blue-500/20 text-blue-300 border border-blue-500/30',
    high: 'bg-orange-500/20 text-orange-300 border border-orange-500/30',
    urgent: 'bg-red-500/20 text-red-300 border border-red-500/30',
  }

  return colorMap[value?.toLowerCase()] || 'bg-gray-500/20 text-gray-300 border border-gray-500/30'
}
</script>

<template>
  <div class="min-h-screen bg-slate-900 text-white">
    <!-- Loading State -->
    <div
      v-if="pending"
      class="flex items-center justify-center min-h-screen"
    >
      <div class="text-center">
        <div class="animate-pulse">
          <div class="h-8 bg-slate-700 rounded w-64 mb-4 mx-auto"></div>
          <div class="h-4 bg-slate-700 rounded w-32 mx-auto"></div>
        </div>
        <p class="text-slate-400 mt-4">Loading {{ config.singularName.toLowerCase() }}...</p>
      </div>
    </div>

    <!-- Error State -->
    <div
      v-else-if="error"
      class="flex items-center justify-center min-h-screen"
    >
      <div class="text-center">
        <div class="text-red-400 text-xl mb-4">
          {{ error.statusMessage || 'Failed to load entity' }}
        </div>
        <PrimeButton
          label="Go Back"
          severity="secondary"
          @click="$router.go(-1)"
        />
      </div>
    </div>

    <!-- Entity Content -->
    <template v-else-if="entity">
      <!-- Hero Section -->
      <div class="bg-gradient-to-r from-blue-900 to-purple-900 p-8">
        <div class="max-w-4xl mx-auto">
          <div class="flex items-start justify-between">
            <div>
              <h1 class="text-4xl font-bold text-white mb-2">
                {{ entity.name || entity.title || 'Unknown Entity' }}
              </h1>
              <div class="flex items-center gap-4 text-blue-200">
                <span class="px-3 py-1 bg-blue-800 rounded-full text-sm">{{
                  config.singularName
                }}</span>
                <span v-if="entity.created_at">Created {{ formatDate(entity.created_at) }}</span>
              </div>
            </div>
            <div class="flex gap-3">
              <PrimeButton
                severity="secondary"
                outlined
                @click="$router.go(-1)"
              >
                <Icon name="mdi:arrow-left" />
                Back
              </PrimeButton>
              <PrimeButton
                v-if="entity.url"
                icon="pi pi-external-link"
                class="bg-white text-blue-900 hover:bg-blue-50 px-4"
                @click="visitWebsite"
              >
                {{ entityType === 'research' ? 'View Paper' : 'Visit Website' }}
              </PrimeButton>
            </div>
          </div>
        </div>
      </div>

      <!-- Quick Status Bar -->
      <div class="bg-slate-800 border-b border-slate-700">
        <div class="max-w-4xl mx-auto px-8 py-4">
          <div class="flex gap-8 text-sm">
            <div
              v-if="entity.is_public_computed !== undefined"
              class="flex items-center gap-2"
            >
              <span class="text-slate-400">Status:</span>
              <span :class="getStatusColor(entity.is_public_computed ? 'Public' : 'Draft')">
                {{ entity.is_public_computed ? 'Public' : 'Draft' }}
              </span>
            </div>
            <div
              v-if="entity.review_status"
              class="flex items-center gap-2"
            >
              <span class="text-slate-400">Review:</span>
              <span :class="getStatusColor(entity.review_status)">{{ entity.review_status }}</span>
            </div>
            <div
              v-if="entity.moderation_status"
              class="flex items-center gap-2"
            >
              <span class="text-slate-400">Safety:</span>
              <span :class="getStatusColor(entity.moderation_status)">{{
                entity.moderation_status
              }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Main Content -->
      <div class="max-w-4xl mx-auto p-8">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <!-- Primary Info -->
          <div class="lg:col-span-2 space-y-6">
            <!-- Description/Abstract -->
            <div
              v-if="entity.description || entity.abstract"
              class="bg-slate-800 rounded-lg p-6"
            >
              <h2 class="text-xl font-semibold mb-4 text-blue-300">
                {{ entity.abstract ? 'Abstract' : 'About' }}
              </h2>
              <p class="text-slate-300 leading-relaxed">
                {{ entity.description || entity.abstract }}
              </p>
            </div>

            <!-- Primary Details -->
            <div class="bg-slate-800 rounded-lg p-6">
              <h2 class="text-xl font-semibold mb-4 text-blue-300">Details</h2>
              <div class="space-y-3">
                <template
                  v-for="field in config.primaryFields"
                  :key="field.label"
                >
                  <div
                    v-if="formatValue(field)"
                    class="flex justify-between py-2 border-b border-slate-700 last:border-b-0"
                  >
                    <span class="text-slate-400">{{ field.label }}:</span>

                    <!-- Badge -->
                    <span
                      v-if="field.type === 'badge'"
                      :class="getBadgeColor(field.value)"
                      class="px-2 py-1 rounded text-xs font-medium uppercase tracking-wide"
                    >
                      {{ field.value }}
                    </span>

                    <!-- Link -->
                    <a
                      v-else-if="field.type === 'link' && field.value"
                      :href="field.linkPrefix ? field.linkPrefix + field.value : field.value"
                      target="_blank"
                      rel="noopener noreferrer"
                      class="text-blue-400 hover:text-blue-300 underline"
                    >
                      {{ field.value }}
                      <i class="pi pi-external-link text-xs ml-1"></i>
                    </a>

                    <!-- Boolean -->
                    <span
                      v-else-if="field.type === 'boolean'"
                      :class="field.value ? 'text-green-400' : 'text-gray-400'"
                    >
                      {{ formatValue(field) }}
                    </span>

                    <!-- Default -->
                    <span
                      v-else
                      class="text-slate-200"
                    >
                      {{ formatValue(field) }}
                    </span>
                  </div>
                </template>
              </div>
            </div>

            <!-- Related Section -->
            <div class="bg-slate-800 rounded-lg p-6">
              <h2 class="text-xl font-semibold mb-4 text-blue-300">{{ config.relatedTitle }}</h2>
              <p class="text-slate-400 text-center py-8"> Coming soon... </p>
            </div>
          </div>

          <!-- Sidebar -->
          <div class="space-y-6">
            <!-- Follow Action -->
            <div class="bg-slate-800 rounded-lg p-6">
              <PrimeButton
                class="w-full mb-4"
                severity="secondary"
                disabled
              >
                <i class="pi pi-heart mr-2"></i>
                {{ config.actionLabel }}
              </PrimeButton>
              <p class="text-xs text-slate-500 text-center">Following feature coming soon</p>
            </div>

            <!-- Quick Actions -->
            <div
              v-if="entity.application_url || entity.doi"
              @click="openApplicationUrl"
            >
              <h3 class="font-semibold mb-4 text-slate-300">Quick Actions</h3>
              <div class="space-y-3">
                <!-- Application URL for opportunities -->
                <PrimeButton
                  v-if="entity.application_url"
                  label="Apply Now"
                  icon="pi pi-send"
                  size="small"
                  class="w-full"
                  @click="openDoiUrl"
                />

                <!-- DOI Link for research -->
                <PrimeButton
                  v-if="entity.doi"
                  label="View DOI"
                  icon="pi pi-book"
                  size="small"
                  class="w-full"
                  severity="info"
                  @click="openDoiUrl"
                />
              </div>
            </div>

            <!-- Metadata -->
            <div class="bg-slate-800 rounded-lg p-6">
              <h3 class="font-semibold mb-4 text-slate-300">Metadata</h3>
              <div class="space-y-3 text-sm">
                <div v-if="entity.created_at">
                  <span class="text-slate-400">Created:</span>
                  <div class="text-slate-200">{{ formatDate(entity.created_at) }}</div>
                </div>
                <div v-if="entity.updated_at">
                  <span class="text-slate-400">Updated:</span>
                  <div class="text-slate-200">{{ formatDate(entity.updated_at) }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
