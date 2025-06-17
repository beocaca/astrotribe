<template>
  <div class="space-y-4 p-4">
    <PrimeButton
      :pt="{ root: 'px-2 py-1 text-sm' }"
      severity="danger"
      @click="clearState"
    >
      Nuxt State
    </PrimeButton>
    <PrimeButton
      :pt="{ root: 'px-2 py-1 text-sm' }"
      severity="danger"
      label="Nuxt Data"
      @click="clearData"
    />
    <PrimeButton
      :pt="{ root: 'px-2 py-1 text-sm' }"
      severity="danger"
      label="Ref Nuxt Data"
      @click="refreshData"
    />
    <PrimeButton
      :pt="{ root: 'px-2 py-1 text-sm' }"
      severity="danger"
      label="Reload App"
      @click="reloadApp"
    />
    <PrimeButton
      :pt="{ root: 'px-2 py-1 text-sm' }"
      severity="danger"
      label="Reset Pinia"
      @click="resetAllStores"
    />
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { getActivePinia } from 'pinia'
import type { Store, Pinia } from 'pinia'
import { clearNuxtState, clearNuxtData, refreshNuxtData, reloadNuxtApp } from '#app'

interface ExtendedPinia extends Pinia {
  _s: Map<string, Store>
}

const isRefreshing = ref(false)

const clearState = () => {
  clearNuxtState()
}

const clearData = () => {
  clearNuxtData()
}

const refreshData = async () => {
  isRefreshing.value = true
  try {
    await refreshNuxtData()
  } finally {
    isRefreshing.value = false
  }
}

const reloadApp = () => {
  reloadNuxtApp()
}

const resetPinia = (): Record<string | 'all', () => void> => {
  const pinia = getActivePinia() as ExtendedPinia | undefined

  if (!pinia) {
    throw new Error('[Pinia] No active instance – are you calling this before Nuxt injected it?')
  }

  const resetStores: Record<string, () => void> = {}

  pinia._s.forEach((store, name) => {
    resetStores[name] = () => store.$reset()
  })

  resetStores.all = () => {
    pinia._s.forEach((store) => store.$reset())
  }

  return resetStores
}

const resetAllStores = () => {
  try {
    resetPinia()
  } catch (err) {
    console.error('Failed to reset stores:', err)
  }
}
</script>

<style scoped></style>
