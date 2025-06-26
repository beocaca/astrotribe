<script setup lang="ts">
const userStore = useCurrentUser()
const { profile } = storeToRefs(userStore)

defineProps({
  categories: {
    type: Array,
    required: true,
  },
})

const route = useRoute()

const {
  isMobile,
  isSidebarOpen,
  isMobileSidebarOpen,
  toggleSidebar,
  toggleMobileSidebar,
  closeMobileSidebar,
} = useNavigation()

// Handle navigation - close mobile nav when navigating
const handleNavigation = () => {
  if (isMobile.value) {
    closeMobileSidebar()
  }
}

// Watch route changes to close mobile nav
watch(
  () => route.path,
  () => {
    if (isMobile.value) {
      closeMobileSidebar()
    }
  },
)
</script>

<template>
  <div
    class="flex h-screen flex-col background text-gray-300 transition-all duration-300 border-r border-color"
    :class="isSidebarOpen ? 'w-64' : 'w-16'"
  >
    <!-- Header Section -->
    <div class="flex items-center justify-between p-4">
      <div class="flex items-center gap-3">
        <button
          class="rounded-lg p-2 hover:bg-gray-800"
          @click="() => toggleSidebar()"
        >
          <Icon
            name="mdi:menu"
            size="20"
          />
        </button>

        <Transition name="fade">
          <div
            v-if="isSidebarOpen"
            class="flex items-center gap-2"
          >
            <NuxtImg
              src="/logo.svg"
              alt="Logo"
              class="h-6 w-6"
            />
            <span class="font-semibold text-white">Your App</span>
          </div>
        </Transition>
      </div>
    </div>

    <!-- Navigation Content -->
    <nav class="flex-1 space-y-2 px-3">
      <div
        v-for="category in categories"
        :key="category.id"
      >
        <div
          v-if="isSidebarOpen && category.label"
          class="mb-2 px-2 text-xs font-medium text-gray-500 uppercase"
        >
          {{ category.label }}
        </div>

        <div class="space-y-1">
          <IBMenuItem
            v-for="item in category.items"
            :key="item.id"
            :icon="item.icon"
            :label="item.label"
            :to="item.slug"
            :is-sidebar-open="isSidebarOpen"
          />
        </div>
      </div>
    </nav>

    <!-- Bottom Section -->
    <div class="border-t border-gray-800 p-3 space-y-2">
      <!-- Upgrade Section -->
      <div
        v-if="profile?.user_plan !== 'pro'"
        class="space-y-2"
      >
        <div
          v-if="isSidebarOpen"
          class="rounded-lg bg-gradient-to-r from-blue-600 to-purple-600 p-3 text-sm"
        >
          <div class="font-medium text-white">Upgrade to Pro</div>
          <div class="text-blue-100">Unlock advanced features</div>
          <PrimeButton
            size="small"
            class="mt-2 w-full"
            @click="$router.push('/settings/payments')"
          >
            Upgrade
          </PrimeButton>
        </div>

        <button
          v-else
          class="w-full rounded-lg p-2 hover:bg-gray-800"
          @click="$router.push('/settings/payments')"
        >
          <Icon
            name="mdi:crown"
            size="20"
          />
        </button>
      </div>

      <!-- Book Consultation -->
      <IBConsultationButton :is-sidebar-open="isSidebarOpen" />
    </div>
  </div>
</template>
