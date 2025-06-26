import { ref } from 'vue'

declare global {
  interface Window {
    __APP_NAV?: NavigationCategory[]
  }
}

export interface PageType {
  id: string
  label: string
  slug: string
  icon: string
  children?: PageType[]
  isExpanded?: boolean
}

export interface NavigationCategory {
  id: string
  label: string
  items: PageType[]
}

export interface BreadcrumbLink {
  to: string
  label: string
  ariaLabel: string
}

const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

const upgradePlan = {
  id: 'upgrade_plan',
  label: 'Upgrade to follow more topics',
  slug: '/settings/payments',
  icon: 'mdi:star',
}

const navigationCategories = ref([
  {
    id: 'main',
    label: 'Main',
    items: [
      {
        id: '1',
        label: 'Discover',
        slug: '/discover',
        icon: 'mdi:compass',
      },
    ],
  },
  // {
  //   id: 'profile',
  //   label: 'Profile',
  //   items: [],
  // },
] as NavigationCategory[])

export default function usePages() {
  const route = useRoute()

  const generateBreadcrumbs = (path: string): BreadcrumbLink[] => {
    const pathParts = path.split('/').filter(Boolean)
    let currentPath = ''

    return pathParts
      .map((part): BreadcrumbLink | null => {
        currentPath += `/${part}`

        // Skip home link
        if (currentPath === '/' || UUID_REGEX.test(part)) {
          return null
        }

        // Default handling
        return {
          to: currentPath,
          label: part.charAt(0).toUpperCase() + part.slice(1),
          ariaLabel: part.charAt(0).toUpperCase() + part.slice(1),
        }
      })
      .filter(Boolean) as BreadcrumbLink[]
  }

  const breadcrumbs = computed(() => generateBreadcrumbs(route.path))

  return {
    appLinks: navigationCategories,
    breadcrumbs,
  }
}
