<script setup lang="ts">
// Simple skeleton loading component
</script>

<template>
  <div class="bg-slate-800/50 border border-slate-700/50 rounded-xl p-6 animate-pulse">
    <!-- Header skeleton -->
    <div class="flex items-start justify-between mb-4">
      <div class="flex-1">
        <!-- Title skeleton -->
        <div class="h-6 bg-slate-700/50 rounded w-3/4 mb-2"></div>
        <!-- Description skeleton -->
        <div class="space-y-2">
          <div class="h-4 bg-slate-700/30 rounded w-full"></div>
          <div class="h-4 bg-slate-700/30 rounded w-2/3"></div>
        </div>
      </div>

      <!-- Icon skeleton -->
      <div class="ml-4 w-10 h-10 bg-slate-700/50 rounded-lg"></div>
    </div>

    <!-- Stats skeleton -->
    <div class="flex items-center justify-between">
      <div class="h-3 bg-slate-700/30 rounded w-16"></div>
      <div class="h-3 bg-slate-700/30 rounded w-12"></div>
    </div>
  </div>
</template>
