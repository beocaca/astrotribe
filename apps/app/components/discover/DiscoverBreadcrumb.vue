<script setup lang="ts">
interface BreadcrumbItem {
  label: string
  url?: string | null
}

interface DiscoveryBreadcrumbProps {
  items: BreadcrumbItem[]
}

const props = defineProps<DiscoverBreadcrumbProps>()
</script>

<template>
  <nav class="flex items-center space-x-2 text-sm">
    <template
      v-for="(item, index) in items"
      :key="index"
    >
      <!-- Separator -->
      <Icon
        v-if="index > 0"
        name="chevron-right"
        class="w-4 h-4 text-slate-500"
      />

      <!-- Breadcrumb Item -->
      <NuxtLink
        v-if="item.url"
        :to="item.url"
        class="text-slate-400 hover:text-white transition-colors"
      >
        {{ item.label }}
      </NuxtLink>
      <span
        v-else
        class="text-white font-medium"
      >
        {{ item.label }}
      </span>
    </template>
  </nav>
</template>
