<script setup lang="ts">
const router = useRouter()
const toast = useNotification()
const supabase = useSupabaseClient()
const { adminURL, loginPath, authURL } = useRuntimeConfig().public
// const { profile, isAdmin } = storeToRefs(userStore)
// const userStore = useCurrentUser()

const profileMenu = ref(null)
const toggleMenu = (e) => {
  profileMenu.value?.toggle(e)
}

const items = computed(() => {
  const menuItems = [
    {
      label: 'Settings',
      command: () => router.push('/settings/account'), // Updated from '/settings/profile'
    },
    {
      label: 'Logout',
      command: signOut,
    },
  ]

  if (false) {
    // isAdmin.value
    menuItems.splice(2, 0, {
      label: 'Admin',
      command: () => navigateTo(adminURL, { external: true }),
    })
  }

  return menuItems
})

const signOut = async () => {
  const { error } = await supabase.auth.signOut()

  if (error) {
    console.error(error.message)
    toast.error({ summary: 'Could not log out', message: error.message })
  } else {
    return navigateTo(String(`${authURL}${loginPath}`), { external: true })
  }
}

const loading = useLoadingStore()
const isLoading = computed(() => loading.isLoading('currentUser'))

const avatarUrl = ref(null)
const fallbackLoaded = ref(false)

// Generate fallback avatar URL using UI Avatars
const getFallbackAvatarUrl = (name: string) => {
  const initials =
    name
      ?.split(' ')
      .map((word) => word[0])
      .join('')
      .toUpperCase() || 'U'
  return `https://ui-avatars.com/api/?name=${initials}&background=random&size=128`
}

// watch(
//   profile,
//   (newProfile) => {
//     if (newProfile?.avatar) {
//       avatarUrl.value = newProfile.avatar
//       fallbackLoaded.value = false
//     } else {
//       // Use name from profile for the fallback avatar, or default to 'User'
//       avatarUrl.value = getFallbackAvatarUrl(newProfile?.full_name || 'User')
//       fallbackLoaded.value = true
//     }
//   },
//   { immediate: true },
// )

// const handleImageError = () => {
//   if (!fallbackLoaded.value) {
//     // Only load fallback if we haven't already tried
//     avatarUrl.value = getFallbackAvatarUrl(profile.value?.full_name || 'User')
//     fallbackLoaded.value = true
//   }
//   console.log('Avatar image load error, using fallback')
// }
</script>

<template>
  <div
    class="sticky top-0 z-50 flex h-14 items-center justify-between foreground px-4 border-b border-color"
  >
    <!-- start -->
    <div class="flex items-center gap-4">
      <IBNavHamburger />
      <IBBreadcrumbs class="hidden text-sm lg:block" />
      <!-- <RoleOverride /> -->
    </div>
    <!-- center -->
    <div class="flex w-full max-w-[70%] gap-4 px-4 py-2 lg:max-w-xl" />
    <!-- end -->
    <ClientOnly>
      <div
        v-if="isLoading"
        class="flex items-center justify-end gap-4"
      >
        <PrimeSkeleton class="min-h-4 min-w-10 rounded-md" />
        <PrimeSkeleton
          :pt="{
            root: 'min-w-10 min-h-10 rounded-full',
          }"
        />
      </div>
      <div class="flex items-center">
        <PrimeAvatar
          v-if="avatarUrl"
          :image="avatarUrl"
          size="normal"
          shape="circle"
          class="cursor-pointer"
          @click="toggleMenu"
        />
        <PrimeMenu
          ref="profileMenu"
          :model="items"
          :popup="true"
        />
      </div>
    </ClientOnly>
  </div>
</template>
