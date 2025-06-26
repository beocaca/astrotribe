// scripts/db/migrate/tasks/extractCronJobs.ts
import fs from 'fs'
import chalk from 'chalk'
import type { Pool } from 'pg'
import pool from '../../shared/clients/pg.client.js'
import { GenericDiffer, createDiffConfig, type DiffResult } from '../utils/diffing.utils.js'

interface CronJob {
  jobid: number
  schedule: string
  command: string
}

/**
 * Configuration for cron job diffing
 */
const cronJobDiffConfig = createDiffConfig('cron', 'cron-jobs', 'cron-jobs.sql', {
  generateHeader:
    () => `-- ============================================================================
-- CRON JOBS
-- Generated: ${new Date().toISOString()}
-- Purpose: Single source of truth for cron job configurations
-- ============================================================================

`,
  extractContent: (line: string) => {
    // Extract command from cron job SQL for comparison
    const match = line.match(/WHERE command = '([^']+)'/)
    return match && match[1] !== undefined ? match[1] : null
  },
  contentEquals: (line1: string, line2: string) => {
    // Compare the actual cron job definitions, ignoring whitespace
    return line1.replace(/\s+/g, ' ').trim() === line2.replace(/\s+/g, ' ').trim()
  },
})

/**
 * Generate a clean job name from command
 */
function generateJobName(command: string): string {
  return command
    .toLowerCase()
    .replace(/^select\s+public\./i, '')
    .replace(/^call\s+public\./i, '')
    .replace(/\(\)$/, '')
    .replace(/[^a-z0-9_]/g, '_')
    .substring(0, 63) // PostgreSQL identifier limit
}

/**
 * Extract all cron jobs from the database
 */
async function extractCronJobs(): Promise<CronJob[]> {
  try {
    const result = await pool.query(`
      SELECT 
        jobid,
        schedule,
        command
      FROM 
        cron.job
      ORDER BY
        jobid;
    `)

    return result.rows
  } catch (error) {
    console.error('Error extracting cron jobs:', error)
    throw error
  }
}

/**
 * Generate SQL content from cron jobs
 */
function generateCronJobsSQL(cronJobs: CronJob[]): string {
  if (cronJobs.length === 0) {
    return ''
  }

  const jobStatements = cronJobs.map((job) => {
    const schedule = job.schedule.replace(/'/g, "''")
    const command = job.command.replace(/'/g, "''")
    const jobName = generateJobName(command)

    return `-- Job ID: ${job.jobid} | Schedule: ${job.schedule}
DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM cron.job 
    WHERE command = '${command}'
  ) THEN
    PERFORM cron.schedule(
      '${jobName}',
      '${schedule}',
      '${command}'
    );
  END IF;
END $$;`
  })

  return jobStatements.join('\n\n') + '\n'
}

/**
 * Process cron jobs and generate diff
 */
async function processCronJobs(): Promise<DiffResult> {
  console.log(chalk.cyan('📅 Extracting cron jobs from database...'))

  const differ = new GenericDiffer(cronJobDiffConfig)

  try {
    // Extract current cron jobs from database
    const cronJobs = await extractCronJobs()
    const newContent = differ.generateContent([generateCronJobsSQL(cronJobs)])

    // Process and diff
    return await differ.processDiff(newContent)
  } catch (error) {
    console.error(chalk.red('Error processing cron jobs:'), error)
    throw error
  }
}

/**
 * Initialize cron jobs file if it doesn't exist
 */
async function initializeCronJobsFile(): Promise<void> {
  const differ = new GenericDiffer(cronJobDiffConfig)

  const cronJobs = await extractCronJobs()
  const initialContent = generateCronJobsSQL(cronJobs)

  await differ.initializeSourceFile(initialContent)
}

/**
 * Validate cron jobs for issues
 */
async function validateCronJobs(): Promise<{
  invalidSchedules: string[]
  duplicateCommands: string[]
  suspiciousCommands: string[]
}> {
  const cronJobs = await extractCronJobs()
  const invalidSchedules: string[] = []
  const duplicateCommands: string[] = []
  const suspiciousCommands: string[] = []

  const commandCounts = new Map<string, number>()

  cronJobs.forEach((job) => {
    // Check for duplicate commands
    const count = commandCounts.get(job.command) || 0
    commandCounts.set(job.command, count + 1)

    // Basic schedule validation (could be enhanced)
    if (!job.schedule.match(/^[\d*/,\-\s]+$/)) {
      invalidSchedules.push(`Job ${job.jobid}: ${job.schedule}`)
    }

    // Check for potentially dangerous commands
    if (
      job.command.toLowerCase().includes('drop') ||
      job.command.toLowerCase().includes('delete') ||
      job.command.toLowerCase().includes('truncate')
    ) {
      suspiciousCommands.push(`Job ${job.jobid}: ${job.command}`)
    }
  })

  // Find duplicates
  commandCounts.forEach((count, command) => {
    if (count > 1) {
      duplicateCommands.push(`${command} (${count} times)`)
    }
  })

  return { invalidSchedules, duplicateCommands, suspiciousCommands }
}

/**
 * Legacy function for backwards compatibility
 * This replaces the old appendCronJobs function
 */
async function appendCronJobs(migrationFilePath: string): Promise<void> {
  console.log(chalk.cyan('📅 Checking cron jobs (legacy mode)'))

  try {
    // In the new system, we don't append to migration files automatically
    // Instead, we process the cron jobs and let git show the diff
    const result = await processCronJobs()

    if (result.hasChanges) {
      console.log(
        chalk.yellow('📅 Cron jobs changed - check git diff and copy to migration if needed'),
      )
      console.log(chalk.gray('   New workflow: Copy from supabase/cron/cron-jobs.sql'))
    } else {
      console.log(chalk.gray('No new cron jobs found'))
    }

    // For now, don't modify the migration file automatically
    // User will manually copy from the source file
  } catch (error: any) {
    console.error(chalk.yellow('⚠ Warning: Failed to process cron jobs'))
    console.error(chalk.gray(error))
  }
}

// Export for backwards compatibility and new system
export {
  appendCronJobs, // Legacy compatibility
  processCronJobs, // New system
  initializeCronJobsFile, // New system
  validateCronJobs, // New system
  extractCronJobs, // Utility
  generateJobName, // Utility
  generateCronJobsSQL, // Utility
}
