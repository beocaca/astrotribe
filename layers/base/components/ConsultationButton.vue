<script setup>
import { ref, onMounted, nextTick } from 'vue'
import { useAnalytics } from '#imports'

// Add the prop definition
const props = defineProps({
  isSidebarOpen: {
    type: Boolean,
    default: true,
  },
})

const { trackUserEngagement, UserEngagementMetric } = useAnalytics()
const showButton = ref(true)
const dialogVisible = ref(false)

const handleConsultationClick = () => {
  trackUserEngagement(UserEngagementMetric.ActionsPerSession, {
    action: 'consultation_request',
    source: 'sidebar_button', // Changed from floating_button
  })
  dialogVisible.value = true
}

onMounted(() => {
  if (import.meta.client) {
    // Load Google Calendar scheduling button resources
    const link = document.createElement('link')
    link.href = 'https://calendar.google.com/calendar/scheduling-button-script.css'
    link.rel = 'stylesheet'
    document.head.appendChild(link)

    const script = document.createElement('script')
    script.src = 'https://calendar.google.com/calendar/scheduling-button-script.js'
    script.async = true
    document.head.appendChild(script)
  }
})
</script>

<template>
  <Transition name="slide-fade">
    <div v-if="showButton">
      <button
        v-if="props.isSidebarOpen"
        class="w-full rounded-lg bg-blue-600 px-3 py-2 text-sm font-medium text-white hover:bg-blue-700 transition-colors"
        @click="handleConsultationClick"
      >
        <Icon
          name="mdi:calendar-clock"
          size="16"
          class="mr-2"
        />
        Book Consultation
      </button>

      <button
        v-else
        class="w-full rounded-lg p-2 hover:bg-gray-800 transition-colors flex items-center justify-center"
        :title="'Book Consultation'"
        @click="handleConsultationClick"
      >
        <Icon
          name="mdi:calendar-clock"
          size="20"
        />
      </button>
    </div>
  </Transition>

  <PrimeDialog
    v-model:visible="dialogVisible"
    modal
    header="Schedule a Consultation"
    class="calendar-dialog"
    :style="{ width: '90vw', height: '90vh' }"
    :dismissable-mask="true"
    :maximizable="true"
  >
    <iframe
      src="https://calendar.google.com/calendar/appointments/schedules/AcZssZ3bUSyyKHFhpezfHQ6a_3mqIonGemdu5biPNBRslpw_1w-bmkaUUTJUudTjdIdC6gB106BkdIre?gv=true"
      frameborder="0"
      class="calendar-iframe rounded h-full w-full"
      allowfullscreen
    ></iframe>
  </PrimeDialog>
</template>

<style scoped>
.slide-fade-enter-active,
.slide-fade-leave-active {
  transition: all 0.3s ease;
}

.slide-fade-enter-from,
.slide-fade-leave-to {
  transform: translateX(20px);
  opacity: 0;
}

/* Ensure the dialog has full height */
:deep(.calendar-dialog) {
  max-height: 100% !important; /* Override any PrimeVue defaults */
}

/* Style the slot content */
.dialog-content-inner {
  flex: 1; /* Take up all available space */
  display: flex;
  height: 100%;
  padding: 1rem; /* Restore padding inside your content */
}

/* Ensure iframe takes full height and width */
.calendar-iframe {
  width: 100%;
  height: 100%;
  border: none;
}

/* Additional styling for the Google Calendar button */
:deep(.goog-inline-block) {
  width: 100% !important;
}
</style>
