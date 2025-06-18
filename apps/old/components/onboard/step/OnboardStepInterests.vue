<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import type { FormInstance } from '@primevue/forms'
import { useOnboardingStore } from '@/stores/useOnboardingStore'

defineProps<{ form: FormInstance }>()

const isLoading = ref(true)
</script>

<template>
  <div class="interests-step">
    <h2 class="text-2xl font-bold mb-2">What topics are you interested in?</h2>
    <p class="text-gray-400 mb-6">Select categories that match your interests.</p>

    <!-- Loading state -->
    <div
      v-if="isLoading"
      class="flex justify-center my-8"
    >
      <PrimeProgressSpinner />
    </div>

    <!-- Form content -->
    <div v-else>
      <FormSelectableCardField
        name="interests"
        :options="[
          {
            value: 'technology',
            label: 'Technology',
            description: 'Latest trends in tech',
            icon: 'mdi:computer',
          },
          {
            value: 'health',
            label: 'Health',
            description: 'Wellness and health tips',
            icon: 'mdi:heart',
          },
          {
            value: 'finance',
            label: 'Finance',
            description: 'Investment and financial advice',
            icon: 'mdi:currency-usd',
          },
          {
            value: 'travel',
            label: 'Travel',
            description: 'Travel guides and tips',
            icon: 'mdi:airplane',
          },
          {
            value: 'food',
            label: 'Food',
            description: 'Recipes and food culture',
            icon: 'mdi:food',
          },
        ]"
        :multiple="true"
      >
        <template #card-content="{ option, selected }">
          <div class="flex items-center gap-3 p-2">
            <div class="w-6 h-6 flex items-center justify-center">
              <Icon
                :name="selected ? 'mdi:check-circle' : 'mdi:circle-outline'"
                size="24px"
                :class="selected ? 'text-primary-500' : 'text-gray-400'"
              />
            </div>
            <div>
              <h3 class="text-lg font-medium">{{ option.label }}</h3>
              <p
                v-if="option.description"
                class="text-sm text-gray-400"
              >
                {{ option.description }}
              </p>
            </div>
          </div>
        </template>
      </FormSelectableCardField>
    </div>
  </div>
</template>
