<script setup lang="ts">
import { ref, computed } from 'vue'

// Get topic ID from route
const route = useRoute()
const topicId = route.params.id as string

// Page meta
definePageMeta({
  title: 'Topic Cluster',
  description: 'Explore topic cluster details',
})

// Composables
const { getTopicCluster } = useHonoApi()

// Get topic cluster data
const {
  data: clusterResponse,
  pending,
  error,
} = await useLazyAsyncData(`topic-cluster-${topicId}`, () => getTopicCluster(topicId))

// Extract cluster data from API response
const cluster = computed(() => {
  if (!clusterResponse.value?.success || !clusterResponse.value?.data) return null
  return clusterResponse.value.data
})

// Active tab state
const activeTab = ref('overview')

// Available tabs with dynamic counts from API data (not array length)
const tabs = computed(() => [
  { id: 'overview', label: 'Overview', icon: 'mdi:file-text' },
  {
    id: 'people',
    label: 'People',
    icon: 'mdi:users',
    count: cluster.value?.entity_counts?.people || 0, // Use API count, not array length
  },
  {
    id: 'research',
    label: 'Research',
    icon: 'mdi:book-open',
    count: cluster.value?.entity_counts?.research || 0, // Use API count, not array length
  },
  {
    id: 'news',
    label: 'News',
    icon: 'mdi:newspaper',
    count: cluster.value?.entity_counts?.news || 0, // Use API count, not array length
  },
  {
    id: 'organizations',
    label: 'Organizations',
    icon: 'mdi:building',
    count: cluster.value?.entity_counts?.organizations || 0, // Use API count, not array length
  },
])

// Breadcrumb data - remove or fix to show actual category name
const breadcrumbs = computed(() => [
  { label: 'Discover', url: '/discover' },
  { label: 'Topics', url: '/discover' },
  { label: cluster.value?.title || cluster.value?.name || 'Topic', url: null },
])

// Total entities count from API
const totalEntities = computed(() => {
  return cluster.value?.total_entities || 0
})
</script>

<template>
  <div class="min-h-screen bg-black">
    <!-- Star field background placeholder -->
    <div class="absolute inset-0 bg-gradient-to-b from-purple-900/20 to-blue-900/20" />

    <div class="relative z-10 container mx-auto px-4 py-8">
      <!-- Loading State -->
      <div
        v-if="pending"
        class="animate-pulse"
      >
        <div class="h-6 bg-slate-700/50 rounded w-1/3 mb-8"></div>
        <div class="h-10 bg-slate-700/50 rounded w-2/3 mb-4"></div>
        <div class="h-6 bg-slate-700/30 rounded w-1/2 mb-8"></div>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <DiscoverSkeletonCard
            v-for="i in 6"
            :key="i"
          />
        </div>
      </div>

      <!-- Error State -->
      <div
        v-else-if="error"
        class="text-center py-12"
      >
        <div class="bg-red-900/20 border border-red-500/30 rounded-lg p-6 max-w-md mx-auto">
          <h3 class="text-red-400 text-lg font-semibold mb-2">Unable to Load Topic</h3>
          <p class="text-red-300 text-sm">{{ error }}</p>
        </div>
      </div>

      <!-- Topic Content -->
      <div v-else-if="cluster">
        <!-- Remove breadcrumb if it's in nav, or keep with proper names -->
        <!-- <DiscoverBreadcrumb :items="breadcrumbs" class="mb-8" /> -->

        <!-- Topic Header -->
        <div class="mb-8">
          <h1 class="text-4xl md:text-5xl font-bold text-white mb-4">
            {{ cluster.title || cluster.name }}
          </h1>
          <p class="text-xl text-slate-300 max-w-4xl">
            {{
              cluster.summary ||
              'Explore the research, people, and organizations driving discoveries in this field.'
            }}
          </p>

          <!-- Quick Stats -->
          <div class="flex items-center space-x-6 mt-6 text-sm text-slate-400">
            <span class="flex items-center space-x-2">
              <Icon
                name="mdi:database"
                class="w-4 h-4"
              />
              <span>{{ totalEntities }} total entities</span>
            </span>
            <span>•</span>
            <span>Last updated recently</span>
          </div>
        </div>

        <!-- Tab Navigation -->
        <div class="mb-8">
          <div class="border-b border-slate-700">
            <nav class="flex space-x-8">
              <button
                v-for="tab in tabs"
                :key="tab.id"
                class="pb-4 px-1 border-b-2 font-medium text-sm transition-colors"
                :class="
                  activeTab === tab.id
                    ? 'border-blue-500 text-blue-400'
                    : 'border-transparent text-slate-400 hover:text-slate-300'
                "
                @click="activeTab = tab.id"
              >
                <div class="flex items-center space-x-2">
                  <Icon
                    :name="tab.icon"
                    class="w-4 h-4"
                  />
                  <span>{{ tab.label }}</span>
                  <span
                    v-if="tab.count !== undefined"
                    class="bg-slate-700 text-slate-300 text-xs px-2 py-0.5 rounded-full"
                  >
                    {{ tab.count }}
                  </span>
                </div>
              </button>
            </nav>
          </div>
        </div>

        <!-- Tab Content -->
        <div class="min-h-[60vh]">
          <!-- Overview Tab -->
          <div
            v-if="activeTab === 'overview'"
            class="space-y-8"
          >
            <!-- Topic Overview Section -->
            <div class="bg-slate-900/50 border border-slate-700/50 rounded-xl p-8">
              <h2 class="text-2xl font-bold text-white mb-6">Topic Overview</h2>

              <!-- Placeholder for generated overview content -->
              <div class="prose prose-invert max-w-none">
                <p class="text-slate-300 text-lg leading-relaxed mb-6">
                  {{
                    cluster.summary ||
                    'This topic represents a significant area of research and development in the field. Our comprehensive analysis covers the key players, breakthrough research, latest news, and organizations driving innovation in this space.'
                  }}
                </p>

                <!-- Placeholder for future deep research content -->
                <div class="bg-blue-900/20 border border-blue-500/30 rounded-lg p-6">
                  <div class="flex items-start space-x-3">
                    <Icon
                      name="mdi:info"
                      class="w-5 h-5 text-blue-400 mt-0.5"
                    />
                    <div>
                      <h3 class="text-blue-300 font-semibold mb-2"
                        >Coming Soon: Deep Research Analysis</h3
                      >
                      <p class="text-blue-200/80 text-sm">
                        We're preparing a comprehensive research article covering the main
                        developments, key findings, and future outlook for this topic. This will
                        include analysis of the most influential papers, leading researchers, and
                        breakthrough discoveries.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Quick Stats Grid with API counts -->
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div class="bg-slate-900/50 border border-slate-700/50 rounded-lg p-4 text-center">
                <div class="text-2xl font-bold text-blue-400 mb-1">{{
                  cluster.entity_counts?.people || 0
                }}</div>
                <div class="text-sm text-slate-400">Researchers</div>
              </div>
              <div class="bg-slate-900/50 border border-slate-700/50 rounded-lg p-4 text-center">
                <div class="text-2xl font-bold text-green-400 mb-1">{{
                  cluster.entity_counts?.research || 0
                }}</div>
                <div class="text-sm text-slate-400">Papers</div>
              </div>
              <div class="bg-slate-900/50 border border-slate-700/50 rounded-lg p-4 text-center">
                <div class="text-2xl font-bold text-orange-400 mb-1">{{
                  cluster.entity_counts?.news || 0
                }}</div>
                <div class="text-sm text-slate-400">News Articles</div>
              </div>
              <div class="bg-slate-900/50 border border-slate-700/50 rounded-lg p-4 text-center">
                <div class="text-2xl font-bold text-purple-400 mb-1">{{
                  cluster.entity_counts?.organizations || 0
                }}</div>
                <div class="text-sm text-slate-400">Organizations</div>
              </div>
            </div>
          </div>

          <!-- People Tab -->
          <div v-else-if="activeTab === 'people'">
            <DiscoverEntityGrid
              v-if="cluster.entities?.people?.length"
              :entities="cluster.entities.people"
              entity-type="people"
              title="Researchers & Experts"
              :total-count="cluster.entity_counts?.people || 0"
            />
            <div
              v-else
              class="text-center py-12"
            >
              <Icon
                name="mdi:users"
                class="w-12 h-12 text-slate-500 mx-auto mb-4"
              />
              <h3 class="text-slate-300 text-lg font-semibold mb-2">No People Found</h3>
              <p class="text-slate-500"
                >No researchers or experts are currently associated with this topic.</p
              >
            </div>
          </div>

          <!-- Research Tab -->
          <div v-else-if="activeTab === 'research'">
            <DiscoverEntityGrid
              v-if="cluster.entities?.research?.length"
              :entities="cluster.entities.research"
              entity-type="research"
              title="Research Papers & Studies"
              :total-count="cluster.entity_counts?.research || 0"
            />
            <div
              v-else
              class="text-center py-12"
            >
              <Icon
                name="mdi:book-open"
                class="w-12 h-12 text-slate-500 mx-auto mb-4"
              />
              <h3 class="text-slate-300 text-lg font-semibold mb-2">No Research Found</h3>
              <p class="text-slate-500"
                >No research papers or studies are currently associated with this topic.</p
              >
            </div>
          </div>

          <!-- News Tab -->
          <div v-else-if="activeTab === 'news'">
            <DiscoverEntityGrid
              v-if="cluster.entities?.news?.length"
              :entities="cluster.entities.news"
              entity-type="news"
              title="Latest News & Updates"
              :total-count="cluster.entity_counts?.news || 0"
            />
            <div
              v-else
              class="text-center py-12"
            >
              <Icon
                name="mdi:newspaper"
                class="w-12 h-12 text-slate-500 mx-auto mb-4"
              />
              <h3 class="text-slate-300 text-lg font-semibold mb-2">No News Found</h3>
              <p class="text-slate-500"
                >No news articles are currently associated with this topic.</p
              >
            </div>
          </div>

          <!-- Organizations Tab -->
          <div v-else-if="activeTab === 'organizations'">
            <DiscoverEntityGrid
              v-if="cluster.entities?.organizations?.length"
              :entities="cluster.entities.organizations"
              entity-type="organizations"
              title="Organizations & Institutions"
              :total-count="cluster.entity_counts?.organizations || 0"
            />
            <div
              v-else
              class="text-center py-12"
            >
              <Icon
                name="mdi:building"
                class="w-12 h-12 text-slate-500 mx-auto mb-4"
              />
              <h3 class="text-slate-300 text-lg font-semibold mb-2">No Organizations Found</h3>
              <p class="text-slate-500"
                >No organizations are currently associated with this topic.</p
              >
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
