<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

const form = useOnboardingForm()

const isLoading = ref(true)

// Check if topic is selected
const isTopicSelected = (tagId: string) => {
  const topicIds = form.getFieldState('topics')?.value || []
  return Array.isArray(topicIds) && topicIds.includes(tagId)
}

// Toggle topic selection
function toggleTopic(tagId: string) {
  const currentTopics = Array.isArray(form.getFieldState('topics')?.value) ?
    [...form.getFieldState('topics')!.value] :
    []

  const index = currentTopics.indexOf(tagId)

  if (index === -1) {
    currentTopics.push(tagId)
  } else {
    currentTopics.splice(index, 1)
  }

  form.setFieldValue('topics', currentTopics)
}
</script>

<template>
  <div class="topics-step">
    <h2 class="text-2xl font-bold mb-2">Select topics you'd like to follow</h2>
    <p class="text-gray-400 mb-6">These topics will personalize your feed.</p>

    <!-- Loading -->
    <div
      v-if="isLoading"
      class="flex justify-center my-8"
    >
      <PrimeProgressSpinner />
    </div>

    <!-- Topics content -->
    <div v-else>
      <!-- Selected Topics -->
      <div class="mb-8">
        <h3 class="text-lg font-medium mb-3">Selected Topics</h3>
        <div class="relative">

      </div>

      <!-- Validation error -->
      <PrimeFormField
        v-slot="field"
        name="topics"
      >
        <input
          type="hidden"
          v-bind="field.props"
        />
        <PrimeMessage
          v-if="field.invalid && field.touched"
          severity="error"
          class="mb-4"
        >
          {{ field.error?.message }}
        </PrimeMessage>
      </PrimeFormField>

      <!-- Browse topics -->
      <div class="mb-8">
        <h3 class="text-lg font-medium mb-3">Browse Topics</h3>
        <div
          class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 overflow-y-scroll max-h-80 px-2 border border-primary-800 rounded-lg"
        >

        </div>
      </div>
    </div>
  </div>
</template>
