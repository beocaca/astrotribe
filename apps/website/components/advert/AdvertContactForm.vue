<script setup lang="ts">
import { ref, reactive } from 'vue'
import { zodResolver } from '@primevue/forms/resolvers/zod'
import { z } from 'zod'

// Define the form validation schema
const formSchema = z.object({
  name: z.string().min(2, 'Name is required'),
  organization: z.string().min(2, 'Organization name is required'),
  email: z.string().email('Please enter a valid email address'),
  phone: z.string().optional(),
  website: z.string().optional(),
  preferredDate: z.date().nullable().optional(),
  message: z.string().min(10, 'Please provide more details in your message'),
  customerType: z.string().min(1, 'Please select an organization type'),
})

// Create the resolver
const formResolver = zodResolver(formSchema)

// Initial form values
const initialValues = reactive({
  name: '',
  organization: '',
  email: '',
  phone: '',
  website: '',
  preferredDate: null,
  message: '',
  customerType: null,
})

// Form state management
const {
  isDialogVisible,
  isSubmitting,
  submitSuccess,
  submitError,
  successMessage,
  errorMessage,
  openDialog,
  setSuccess,
  setError,
  startSubmitting,
  stopSubmitting,
} = useFormDialog()

// Customer types
const customerTypes = [
  { name: 'Space-Tech Organization', value: 'space-tech' },
  { name: 'Institution', value: 'institution' },
  { name: 'Event Organizer', value: 'events' },
  { name: 'Researcher', value: 'researcher' },
  { name: 'Other', value: 'other' },
]

// Form submission
const submitForm = async (result) => {
  if (!result.valid) {
    // Form validation failed, no need to do anything as error messages will be displayed
    return
  }

  startSubmitting()

  try {
    // Simulating API call for demo purposes
    await new Promise((resolve) => setTimeout(resolve, 1500))

    setSuccess("Thank you! Your request has been submitted. We'll be in touch within 24 hours.")

    // Close dialog after 3 seconds on success
    setTimeout(() => {
      isDialogVisible.value = false
    }, 3000)
  } catch (error) {
    console.error('Form submission error:', error)
    setError(
      'There was an error submitting your request. Please try again or contact us directly at connectus@astronera.org.',
    )
  } finally {
    stopSubmitting()
  }
}
</script>

<template>
  <div
    id="contact-form"
    class="my-8"
  >
    <div class="text-center">
      <PrimeButton
        class="bg-primary-600 hover:bg-primary-700 px-6 py-3"
        @click="openDialog"
      >
        Advertise With Us
        <Icon
          name="i-lucide-rocket"
          class="ml-2"
        />
      </PrimeButton>
    </div>

    <IBFormDialog
      v-model:visible="isDialogVisible"
      title="Advertise With AstronEra"
      :loading="isSubmitting"
      :success-message="submitSuccess ? successMessage : ''"
      :error-message="submitError ? errorMessage : ''"
      submit-button-text="Submit Your Information"
      :initial-values="initialValues"
      :resolver="formResolver"
      @submit="submitForm"
    >
      <template #content>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <IBFormField
            id="name"
            name="name"
            label="Full Name"
            required
            :initial-value="initialValues.name"
          >
            <template #default="{ field }">
              <PrimeInputText
                id="name"
                v-model="field.value"
                class="w-full"
                placeholder="Your name"
              />
            </template>
          </IBFormField>

          <IBFormField
            id="organization"
            name="organization"
            label="Organization Name"
            required
            :initial-value="initialValues.organization"
          >
            <template #default="{ field }">
              <PrimeInputText
                id="organization"
                v-model="field.value"
                class="w-full"
                placeholder="Your organization"
              />
            </template>
          </IBFormField>

          <IBFormField
            id="email"
            name="email"
            label="Email Address"
            required
            :initial-value="initialValues.email"
          >
            <template #default="{ field }">
              <PrimeInputText
                id="email"
                v-model="field.value"
                type="email"
                class="w-full"
                placeholder="your.email@organization.com"
              />
            </template>
          </IBFormField>

          <IBFormField
            id="phone"
            name="phone"
            label="Phone Number"
            :initial-value="initialValues.phone"
          >
            <template #default="{ field }">
              <PrimeInputText
                id="phone"
                v-model="field.value"
                class="w-full"
                placeholder="Your phone number"
              />
            </template>
          </IBFormField>

          <IBFormField
            id="website"
            name="website"
            label="Website"
            :initial-value="initialValues.website"
          >
            <template #default="{ field }">
              <PrimeInputText
                id="website"
                v-model="field.value"
                class="w-full"
                placeholder="yourorganization.com"
              />
            </template>
          </IBFormField>

          <IBFormField
            id="customerType"
            name="customerType"
            label="Organization Type"
            required
            :initial-value="initialValues.customerType"
          >
            <template #default="{ field }">
              <PrimeDropdown
                id="customerType"
                v-model="field.value"
                :options="customerTypes"
                option-label="name"
                option-value="value"
                placeholder="Select organization type"
                class="w-full"
              />
            </template>
          </IBFormField>

          <IBFormField
            id="preferredDate"
            name="preferredDate"
            label="Preferred Meeting Date"
            :initial-value="initialValues.preferredDate"
          >
            <template #default="{ field }">
              <PrimeCalendar
                id="preferredDate"
                v-model="field.value"
                class="w-full"
                placeholder="Select date"
                show-icon
              />
            </template>
          </IBFormField>

          <IBFormField
            id="message"
            name="message"
            label="Your Message"
            required
            :full-width="true"
            :initial-value="initialValues.message"
          >
            <template #default="{ field }">
              <PrimeTextarea
                id="message"
                v-model="field.value"
                rows="4"
                class="w-full"
                placeholder="Tell us about your organization and advertising goals"
              />
            </template>
          </IBFormField>
        </div>
      </template>
    </IBFormDialog>
  </div>
</template>
