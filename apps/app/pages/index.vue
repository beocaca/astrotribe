<script setup lang="ts">
definePageMeta({
  name: 'AstroTribe',
})
//
// const userStore = useCurrentUser()
// const { profile } = storeToRefs(userStore)
</script>

<template>
  <div class="grid w-full min-h-screen gap-6 p-6">
    <!-- Welcome Section -->
    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
      <!-- Welcome Card -->
      <div
        class="bg-gray-900/50 flex flex-col rounded-xl p-6 border border-gray-800 md:col-span-2 xl:col-span-3 xl:row-span-2"
      >
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <h1 class="text-2xl font-bold"
              >Welcome
              <!-- {{ profile.given_name }} -->
              👋</h1
            >
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped></style>
