import { faker } from '@faker-js/faker'
import type { Pool } from 'pg'

import {
  ERROR_MESSAGES,
  ERROR_TYPES,
  SERVICE_NAMES,
  SEVERITIES,
  COMMON_ERRORS,
  generateStackTrace,
} from './errors'

export const formatTimeWithZone = (date: Date) => {
  return (
    date.toLocaleTimeString('en-US', {
      hour12: false,
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      timeZone: 'UTC',
    }) + '+00'
  )
}

export const getContentStatusFlow = (entityType: string) => {
  const commonStatuses = ['draft', 'pending_review', 'published', 'archived'] as const

  // Add entity-specific statuses
  switch (entityType) {
    case 'news':
      return [...commonStatuses, 'pending_review', 'scraped', 'archived', 'processing']
    case 'research':
      return [...commonStatuses, 'pending_crawl', 'irrelevant']
    default:
      return commonStatuses
  }
}

export const randomEnum = <T extends string>(values: readonly T[]): T => {
  return faker.helpers.arrayElement(values as T[])
}

export { ERROR_MESSAGES, ERROR_TYPES, SERVICE_NAMES, SEVERITIES, COMMON_ERRORS, generateStackTrace }
