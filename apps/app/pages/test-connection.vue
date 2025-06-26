<!-- pages/test-connection.vue - UPDATED -->
<script setup lang="ts">
const { testConnection, getCategories, getTopics, getTopicCluster } = useHonoApi()

const connectionResult = ref(null)
const categoriesResult = ref(null)
const topicsResult = ref(null)
const topicClusterResult = ref(null)
const feedsResult = ref(null)

const isLoading = ref(false)
const error = ref<unknown | null>(null)

// Selected IDs for testing drill-down
const selectedCategoryId = ref<string>('')
const selectedTopicId = ref<string>('')

const runConnectionTest = async () => {
  isLoading.value = true
  error.value = null
  connectionResult.value = null

  try {
    const result = await testConnection()
    connectionResult.value = result
    console.log('✅ Connection successful:', result)
  } catch (err) {
    error.value = err
    console.error('❌ Connection failed:', err)
  } finally {
    isLoading.value = false
  }
}

const runCategoriesTest = async () => {
  isLoading.value = true
  error.value = null
  categoriesResult.value = null

  try {
    const result = await getCategories()
    categoriesResult.value = result

    // Auto-select first category for testing
    if (result?.data?.length > 0) {
      selectedCategoryId.value = result.data[0].id
      console.log('✅ Selected category:', {
        id: result.data[0].id,
        title: result.data[0].title,
      })
    }

    console.log('✅ Categories successful:', result)
  } catch (err) {
    error.value = err
    console.error('❌ Categories failed:', err)
  } finally {
    isLoading.value = false
  }
}

const runTopicsTest = async () => {
  if (!selectedCategoryId.value) {
    error.value = new Error('Please run Categories test first to select a category')
    return
  }

  isLoading.value = true
  error.value = null
  topicsResult.value = null

  try {
    const result = await getTopics(selectedCategoryId.value, { limit: 5 })
    topicsResult.value = result

    // Auto-select first topic for testing
    if (result?.data?.length > 0) {
      selectedTopicId.value = result.data[0].id
    }

    console.log('✅ Topics successful:', result)
  } catch (err) {
    error.value = err
    console.error('❌ Topics failed:', err)
  } finally {
    isLoading.value = false
  }
}

const runTopicClusterTest = async () => {
  if (!selectedTopicId.value) {
    error.value = new Error('Please run Topics test first to select a topic')
    return
  }

  isLoading.value = true
  error.value = null
  topicClusterResult.value = null

  try {
    const result = await getTopicCluster(selectedTopicId.value)
    topicClusterResult.value = result

    console.log('✅ Topic cluster successful:', result)
  } catch (err) {
    error.value = err
    console.error('❌ Topic cluster failed:', err)
  } finally {
    isLoading.value = false
  }
}

// Auto-run connection test on mount
onMounted(() => {
  runConnectionTest()
})

const previewCategories = computed(() =>
  JSON.stringify(categoriesResult.value?.data?.slice(0, 2), null, 2),
)
</script>

<template>
  <div class="p-8 max-w-6xl mx-auto">
    <h1 class="text-3xl font-bold mb-8">HONO API Discovery Endpoints Test</h1>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <!-- Connection Test -->
      <div class="space-y-4">
        <h2 class="text-xl font-semibold">1. API Connection Test</h2>
        <PrimeButton
          :loading="isLoading"
          class="w-full"
          @click="runConnectionTest"
        >
          Test API Connection
        </PrimeButton>

        <div
          v-if="connectionResult"
          class="p-4 bg-green-900/20 border border-green-500 rounded-lg"
        >
          <h3 class="text-green-400 font-semibold mb-2">✅ API Connection Successful!</h3>
          <pre class="text-xs text-green-300 overflow-auto">{{
            JSON.stringify(connectionResult, null, 2)
          }}</pre>
        </div>
      </div>

      <!-- Categories Test -->
      <div class="space-y-4">
        <h2 class="text-xl font-semibold">2. Categories Test</h2>
        <PrimeButton
          :loading="isLoading"
          severity="secondary"
          class="w-full"
          @click="runCategoriesTest"
        >
          Test Categories
        </PrimeButton>

        <div
          v-if="categoriesResult"
          class="p-4 bg-green-900/20 border border-green-500 rounded-lg"
        >
          <h3 class="text-green-400 font-semibold mb-2">✅ Categories Retrieved!</h3>
          <p class="text-sm text-green-300 mb-2">
            Found {{ categoriesResult.data?.length }} categories
            {{
              selectedCategoryId
                ? `(Selected: ${categoriesResult.data?.find((c) => c.id === selectedCategoryId)?.title})`
                : ''
            }}
          </p>
          <pre class="text-xs text-green-300 overflow-auto max-h-40">
            {{ previewCategories }}
          </pre>
        </div>
      </div>

      <!-- Topics Test -->
      <div class="space-y-4">
        <h2 class="text-xl font-semibold">3. Topics Test</h2>
        <PrimeButton
          :loading="isLoading"
          severity="info"
          class="w-full"
          :disabled="!selectedCategoryId"
          @click="runTopicsTest"
        >
          Test Topics
        </PrimeButton>

        <div
          v-if="topicsResult"
          class="p-4 bg-cyan-900/20 border border-cyan-500 rounded-lg"
        >
          <h3 class="text-cyan-400 font-semibold mb-2">✅ Topics Retrieved!</h3>
          <p class="text-xs text-cyan-300 mb-2">Selected: {{ selectedTopicId }}</p>
          <pre class="text-xs text-cyan-300 overflow-auto max-h-40">{{
            JSON.stringify(topicsResult, null, 2)
          }}</pre>
        </div>
      </div>

      <!-- Topic Cluster Test -->
      <div class="space-y-4">
        <h2 class="text-xl font-semibold">4. Topic Cluster Test</h2>
        <PrimeButton
          :loading="isLoading"
          severity="warning"
          class="w-full"
          :disabled="!selectedTopicId"
          @click="runTopicClusterTest"
        >
          Test Topic Cluster
        </PrimeButton>

        <div
          v-if="topicClusterResult"
          class="p-4 bg-amber-900/20 border border-amber-500 rounded-lg"
        >
          <h3 class="text-amber-400 font-semibold mb-2">✅ Topic Cluster Retrieved!</h3>
          <p class="text-xs text-amber-300 mb-2">
            Total Entities: {{ topicClusterResult.data?.total_entities }}
          </p>
          <p class="text-xs text-amber-300 mb-2">
            People: {{ topicClusterResult.data?.entity_counts?.people }}, Research:
            {{ topicClusterResult.data?.entity_counts?.research }}, News:
            {{ topicClusterResult.data?.entity_counts?.news }}, Organizations:
            {{ topicClusterResult.data?.entity_counts?.organizations }}
          </p>
          <pre class="text-xs text-amber-300 overflow-auto max-h-40">{{
            JSON.stringify(topicClusterResult.data?.entities, null, 2)
          }}</pre>
        </div>
      </div>

      <!-- Error State -->
      <div
        v-if="error"
        class="lg:col-span-2 p-4 bg-red-900/20 border border-red-500 rounded-lg"
      >
        <h3 class="text-red-400 font-semibold mb-2">❌ Test Failed</h3>
        <pre class="text-sm text-red-300">{{ JSON.stringify(error, null, 2) }}</pre>
      </div>

      <!-- Loading State -->
      <div
        v-if="isLoading"
        class="lg:col-span-2 p-4 bg-purple-900/20 border border-purple-500 rounded-lg"
      >
        <h3 class="text-purple-400 font-semibold">🔄 Running test...</h3>
      </div>
    </div>

    <!-- Quick Test All Button -->
    <div class="mt-8 text-center">
      <PrimeButton
        :loading="isLoading"
        severity="contrast"
        size="large"
        @click="
          async () => {
            await runCategoriesTest()
            if (selectedCategoryId) {
              await runTopicsTest()
              if (selectedTopicId) {
                await runTopicClusterTest()
              }
            }
          }
        "
      >
        🚀 Test All Discovery Endpoints
      </PrimeButton>
    </div>
  </div>
</template>
