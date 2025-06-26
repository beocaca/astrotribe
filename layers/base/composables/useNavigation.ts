import { useMediaQuery } from '@vueuse/core'
import { useState } from '#imports'

// composables/useNavigation.ts
export const useNavigation = () => {
  const isSidebarOpen = useState('nav-sidebar-open', () => true)
  const isMobileSidebarOpen = useState('nav-mobile-sidebar-open', () => false)
  const isMobile = useMediaQuery('(max-width: 768px)')

  const toggleSidebar = (value?: boolean) => {
    console.log('toggleSidebar called', { current: isSidebarOpen.value, value })
    isSidebarOpen.value = value ?? !isSidebarOpen.value
    console.log('toggleSidebar result', isSidebarOpen.value)
  }

  const toggleMobileSidebar = (value?: boolean) => {
    isMobileSidebarOpen.value = value ?? !isMobileSidebarOpen.value
  }

  const closeMobileSidebar = () => {
    isMobileSidebarOpen.value = false
  }

  return {
    isSidebarOpen: readonly(isSidebarOpen),
    isMobileSidebarOpen: readonly(isMobileSidebarOpen),
    isMobile,
    toggleSidebar,
    toggleMobileSidebar,
    closeMobileSidebar,
  }
}
