<script setup lang="ts">
import { ref, watch } from 'vue'
import { usePersona } from '~/composables/usePersona'
import { useOrganizations, type Organization } from '~/composables/useOrganizations'
import { useAnimation } from '~/composables/useAnimation'
import { useAnalytics } from '#imports'

const { conf: motionConstants } = useAnimation()
const { trackUserEngagement, UserEngagementMetric } = useAnalytics()

// Get persona state from our composable
const { activePersona, personaStyles } = usePersona()

// Get organizations from our composable
const { allOrganizations, organizations, personaOrganization, getOrganizationById, visitWebsite } =
  useOrganizations()

// Active organization state
const activeOrganization = ref<Organization | null>(null)

// Initialize active organization based on persona
const getInitialOrganization = (): Organization | null => {
  // First try to get the persona-specific organization
  if (personaOrganization.value) return personaOrganization.value

  // If no persona-specific organization, get the first organization
  if (organizations.value.length > 0) {
    return organizations.value[0] || null
  }

  return null
}

// Set initial active organization
activeOrganization.value = getInitialOrganization()

// Update active organization when persona changes
watch(
  () => activePersona.value,
  () => {
    activeOrganization.value = getInitialOrganization()
  },
)

// Select a specific organization
const selectOrganization = (organizationId: number): void => {
  const organization = getOrganizationById(organizationId)
  if (organization) {
    activeOrganization.value = organization

    // Track organization selection
    trackUserEngagement(UserEngagementMetric.ActionsPerSession, {
      action: 'select_organization',
      organization_id: organization.id,
      organization_name: organization.name,
    })
  }
}

// Handle visit website button click
const handleVisitWebsite = (organization: Organization): void => {
  // Track the action
  trackUserEngagement(UserEngagementMetric.ActionsPerSession, {
    action: 'visit_organization_website',
    organization_id: organization.id,
    organization_name: organization.name,
  })

  // Use the composable method to open the website
  visitWebsite(organization)
}

// Track when users click "View All Organizations"
const trackViewAllOrganizations = (): void => {
  trackUserEngagement(UserEngagementMetric.ActionsPerSession, {
    action: 'view_all_organizations',
    persona: activePersona.value?.name || 'unknown',
  })
}
</script>

<template>
  <section class="py-16 md:py-20 relative overflow-hidden">
    <!-- Background with persona-specific gradient -->
    <div
      class="absolute inset-0 bg-gradient-to-b from-slate-950 to-primary-950/70 z-0 transition-colors duration-700"
    ></div>

    <!-- Background accents -->
    <div
      class="absolute left-0 top-1/3 w-64 h-64 rounded-full blur-3xl transition-colors duration-700"
      :class="`bg-${activePersona.color}-600/5`"
    ></div>
    <div
      class="absolute right-0 bottom-1/3 w-64 h-64 rounded-full blur-3xl transition-colors duration-700"
      :class="`bg-${activePersona.color}-600/5`"
    ></div>

    <div class="wrapper relative z-10 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <!-- Section header -->
      <div
        v-motion="motionConstants.sectionTitle"
        class="text-center max-w-3xl mx-auto mb-8"
      >
        <h2
          class="text-3xl md:text-4xl font-bold mb-4 transition-colors duration-500"
          :class="personaStyles.sectionHeading"
        >
          Astronomy Organizations
        </h2>
        <p class="text-gray-300 text-lg">
          Explore leading organizations in astronomy and space science that are pushing the
          boundaries of human knowledge.
        </p>
      </div>

      <!-- Recommended for you section - Moved to top under subtitle -->
      <div
        v-motion
        :initial="{ opacity: 0, y: 20 }"
        :visibleOnce="{ opacity: 1, y: 0, transition: { delay: 0.2 } }"
        class="mb-10 text-center"
      >
        <h3 class="text-lg font-medium text-white mb-4 flex items-center justify-center gap-2">
          <Icon
            name="mdi:star"
            class="text-yellow-500"
            size="20"
          />
          <span>Recommended for {{ activePersona.name }}</span>
        </h3>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4 max-w-4xl mx-auto">
          <div
            v-for="organization in allOrganizations"
            :key="`rec-${organization.id}`"
            class="bg-slate-900/40 backdrop-blur-sm rounded-lg border border-slate-800/50 p-4 transition-all duration-300 cursor-pointer"
            :class="
              activeOrganization && organization.id === activeorganization.id
                ? `border-${organization.color}-500/50 bg-${organization.color}-900/20`
                : `hover:border-${organization.color}-800/30`
            "
            @click="selectOrganization(organization.id)"
          >
            <div class="flex items-center gap-3 mb-2">
              <div
                class="w-8 h-8 rounded-full flex items-center justify-center transition-colors duration-500"
                :class="`bg-${organization.color}-900/50 text-${organization.color}-500`"
              >
                <Icon
                  :name="organization.icon"
                  size="16"
                />
              </div>
              <div class="text-left">
                <h4 class="font-medium text-white text-sm">{{ organization.name }}</h4>
                <p class="text-xs text-gray-400">{{ organization.industry }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Organization selection tabs -->
      <div
        v-motion
        :initial="{ opacity: 0, y: 20 }"
        :visibleOnce="{ opacity: 1, y: 0, transition: { delay: 0.3 } }"
        class="flex flex-wrap justify-center gap-3 mb-10"
      >
        <button
          v-for="organization in organizations"
          :key="organization.id"
          class="px-4 py-2 rounded-full transition-all duration-300 flex items-center gap-2"
          :class="
            activeOrganization && activeorganization.id === organization.id
              ? `bg-${organization.color}-500/20 text-${organization.color}-300 border border-${organization.color}-500/30`
              : 'bg-slate-800/30 text-gray-400 border border-slate-700/20 hover:bg-slate-800/50'
          "
          @click="selectOrganization(organization.id)"
        >
          <Icon
            :name="organization.icon"
            size="16"
          />
          {{ organization.name }}
        </button>
      </div>

      <!-- Organization details display -->
      <div
        v-if="activeOrganization"
        v-motion
        :initial="{ opacity: 0, y: 30 }"
        :visibleOnce="{ opacity: 1, y: 0, transition: { delay: 0.4 } }"
        class="max-w-4xl mx-auto"
      >
        <div
          class="rounded-xl bg-slate-900/60 backdrop-blur-sm border border-slate-800/50 overflow-hidden transition-all duration-500"
          :class="`border-${activeOrganization.color}-800/30 shadow-xl shadow-${activeOrganization.color}-900/10`"
        >
          <!-- Organization header -->
          <div
            class="px-6 py-4 border-b border-slate-800/30 flex items-center justify-between transition-colors duration-500"
            :class="`bg-${activeOrganization.color}-900/20`"
          >
            <div class="flex items-center gap-4">
              <div
                class="w-12 h-12 rounded-full flex items-center justify-center transition-colors duration-500"
                :class="`bg-${activeOrganization.color}-900/50 text-${activeOrganization.color}-500`"
              >
                <Icon
                  :name="activeOrganization.icon"
                  size="24"
                />
              </div>
              <div>
                <h3 class="text-xl font-semibold text-white">{{ activeOrganization.name }}</h3>
                <p class="text-gray-400"
                  >{{ activeOrganization.industry }} • {{ activeOrganization.location }}</p
                >
              </div>
            </div>
            <div>
              <span
                class="px-3 py-1 rounded-full text-xs font-medium transition-colors duration-500"
                :class="`bg-${activeOrganization.color}-900/50 text-${activeOrganization.color}-400 border border-${activeOrganization.color}-800/30`"
              >
                Est. {{ activeOrganization.founded }}
              </span>
            </div>
          </div>

          <!-- Organization details -->
          <div class="p-6">
            <div class="mb-6">
              <p class="text-gray-300">{{ activeOrganization.description }}</p>
            </div>

            <div class="mb-6">
              <h4 class="text-lg font-medium text-white mb-2">Highlights</h4>
              <ul class="text-gray-300 list-disc pl-5 space-y-1">
                <li
                  v-for="(highlight, index) in activeOrganization.highlights"
                  :key="index"
                >
                  {{ highlight }}
                </li>
              </ul>
            </div>

            <div class="flex flex-wrap justify-between items-center">
              <div class="mb-4 md:mb-0">
                <div class="text-sm text-gray-400 mb-1">Organization Size</div>
                <div class="text-white font-medium">{{ activeOrganization.size }}</div>
              </div>

              <PrimeButton
                class="transition-colors duration-500"
                :class="personaStyles.primaryButton"
                @click="handleVisitWebsite(activeOrganization)"
              >
                <Icon
                  name="mdi:web"
                  class="mr-2"
                  size="16"
                />
                Visit Website
              </PrimeButton>
            </div>
          </div>
        </div>
      </div>

      <!-- View All Organizations button moved to bottom as CTA -->
      <div class="mt-12 text-center">
        <PrimeButton
          size="large"
          class="transition-colors duration-500"
          :class="personaStyles.primaryButton"
          @click="trackViewAllOrganizations"
        >
          <Icon
            name="mdi:office-building"
            class="mr-2"
            size="20"
          />
          View All Organizations
        </PrimeButton>
      </div>
    </div>
  </section>
</template>

<style scoped>
/* Add any component-specific styles here */
</style>
