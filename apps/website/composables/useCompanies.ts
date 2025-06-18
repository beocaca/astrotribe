import { ref, computed } from 'vue'
import { usePersona } from './usePersona'

export interface Organization {
  id: number
  name: string
  logo: string
  description: string
  industry: string
  location: string
  founded: number
  size: string
  website: string
  color: string
  icon: string
  bestFor: string
  highlights: string[]
}

export function useOrganizations() {
  const { activePersona } = usePersona()

  // Mock data for organizations
  const allOrganizations = ref<Organization[]>([
    {
      id: 1,
      name: 'SpaceX',
      logo: '/images/organizations/spacex.png',
      description:
        'American aerospace manufacturer and space transportation services organization.',
      industry: 'Aerospace',
      location: 'Hawthorne, California',
      founded: 2002,
      size: '10,000+ employees',
      website: 'https://www.spacex.com',
      color: 'blue',
      icon: 'mdi:rocket-launch',
      bestFor: 'enthusiast',
      highlights: [
        'Developing Starship spacecraft for Mars missions',
        'Reusable rocket technology',
        'Starlink satellite internet constellation',
        'Commercial crew missions to ISS',
      ],
    },
    {
      id: 2,
      name: 'NASA',
      logo: '/images/organizations/nasa.png',
      description:
        "The National Aeronautics and Space Administration is America's civil space program and the global leader in space exploration.",
      industry: 'Government Agency',
      location: 'Washington, D.C.',
      founded: 1958,
      size: '17,000+ employees',
      website: 'https://www.nasa.gov',
      color: 'indigo',
      icon: 'mdi:telescope',
      bestFor: 'researcher',
      highlights: [
        'Artemis program to return humans to the Moon',
        'Mars Exploration Program',
        'James Webb Space Telescope',
        'Earth Science missions',
      ],
    },
    {
      id: 3,
      name: 'Astronomical Society',
      logo: '/images/organizations/astronomical-society.png',
      description:
        'Professional organization of astronomers and other scientists dedicated to the advancement of astronomy and geophysics.',
      industry: 'Non-profit',
      location: 'London, UK',
      founded: 1820,
      size: '1,000+ members',
      website: 'https://www.astronomicalsociety.org',
      color: 'red',
      icon: 'mdi:star',
      bestFor: 'sci-commer',
      highlights: [
        'Public outreach and education programs',
        'Monthly astronomy magazine publication',
        'Annual astronomy conferences',
        'Grants for astronomy research and education',
      ],
    },
  ])

  // Filter organizations alphabetically
  const organizations = computed(() => {
    return [...allOrganizations.value].sort((a, b) => a.name.localeCompare(b.name))
  })

  // Get persona-specific organization
  const personaOrganization = computed(() => {
    if (!activePersona.value) return null
    const personaName = activePersona.value.name.toLowerCase()
    return (
      allOrganizations.value.find(
        (organization) => organization.bestFor.toLowerCase() === personaName,
      ) || null
    )
  })

  // Get organization by ID
  const getOrganizationById = (organizationId: number): Organization | null => {
    return allOrganizations.value.find((organization) => organization.id === organizationId) || null
  }

  // Visit organization website
  const visitWebsite = (organization: Organization): void => {
    if (organization.website) {
      window.open(organization.website, '_blank')
    }
  }

  return {
    allOrganizations: allOrganizations.value,
    organizations,
    personaOrganization,
    getOrganizationById,
    visitWebsite,
  }
}
