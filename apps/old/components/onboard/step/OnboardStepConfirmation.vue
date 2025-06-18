<script setup lang="ts">
import type { FormInstance } from '@primevue/forms'
import { useOnboardingStore } from '@/stores/useOnboardingStore'

const onboardingStore = useOnboardingStore()

const form = useOnboardingForm()

const isLoading = ref(false)
const isLoadingData = ref(true)

const stepData = computed(() => onboardingStore.stepData)

// Load categories and tags
onMounted(async () => {
  isLoadingData.value = true
})

// Display helpers
const userTypeLabel = computed(() => {
  const map = {
    professional: 'Professional',
    hobbyist: 'Hobbyist',
    researcher: 'Researcher',
    student: 'Student',
    other: 'Other',
  }

  return map[stepData.value.user_type as keyof typeof map] || 'Not specified'
})

onMounted(() => {
  console.group('[Confirm Step]')
  console.log('Full stepData:', toRaw(onboardingStore.stepData))
  console.log('Form values (if any):', form.states)
  console.groupEnd()
})

const locationDisplay = computed(() => {
  const location = stepData.value.location
  if (!location || !location.full_address) return 'Not specified'
  if (location.city && location.country) return `${location.city}, ${location.country}`
  return location.full_address
})

const SummaryCard = defineComponent({
  props: {
    title: { type: String, required: true },
    icon: { type: String, required: true },
  },
  setup(props, { slots }) {
    return () =>
      h('div', { class: 'p-4 bg-gray-800/50 rounded-lg' }, [
        h('h3', { class: 'text-lg font-medium mb-2 flex items-center' }, [
          h(resolveComponent('Icon'), {
            name: props.icon,
            class: 'mr-2',
            size: '20px',
          }),
          props.title,
        ]),
        h('div', {}, slots.default?.()),
      ])
  },
})
</script>

<template>
  <div class="confirmation-step">
    <h2 class="text-2xl font-bold mb-2">You're all set!</h2>
    <p class="text-gray-400 mb-6">Review your preferences before completing the setup.</p>

    <div
      v-if="isLoadingData"
      class="flex justify-center my-8"
    >
      <PrimeProgressSpinner />
    </div>

    <div
      v-else
      class="space-y-6"
    >
      <!-- User Type -->
      <SummaryCard
        title="User Type"
        icon="mdi:account"
      >
        {{ userTypeLabel }}
      </SummaryCard>

      <!-- Feature Interests -->
      <SummaryCard
        title="Feature Interests"
        icon="mdi:rocket"
      >
        <div
          v-if="stepData.feature_interests?.length"
          class="flex flex-wrap gap-2"
        >
          <PrimeChip
            v-for="(fid, index) in stepData.feature_interests"
            :key="index"
            :label="'Feature #' + (index + 1)"
          />
        </div>
        <p
          v-else
          class="text-gray-400"
          >No feature interests selected</p
        >
      </SummaryCard>

      <!-- Location -->
      <SummaryCard
        title="Location"
        icon="mdi:map-marker"
      >
        {{ locationDisplay }}
      </SummaryCard>

      <p class="text-sm text-gray-400">
        You can edit these preferences later in your profile settings.
      </p>
    </div>
  </div>
</template>
