// scripts/db/migrate/0.pre-migration-checks.ts
import chalk from 'chalk'
import type { Pool } from 'pg'
import pool from '../client'
import {
  processTableComments,
  initializeCommentsFile,
  validateTableComments,
} from './tasks/extractTableComments'
import { processCronJobs, initializeCronJobsFile, validateCronJobs } from './tasks/extractCronJobs'
import { dropAllRLSPolicies } from './tasks/extractRLSPolicies'
import { disableRLSOnAllTables } from './utils/manageRLS'

async function checkAndAddTriggers(pool: Pool): Promise<void> {
  const client = await pool.connect()

  try {
    console.log(chalk.cyan('🔍 Checking for missing updated_at triggers...'))

    const result = await client.query('SELECT * FROM add_missing_updated_at_triggers()')

    let triggersAdded = false
    result.rows.forEach((row) => {
      if (row.action_taken === 'Added trigger') {
        console.log(chalk.yellow(`🔧 Added updated_at trigger to table: ${row.checked_table_name}`))
        triggersAdded = true
      }
    })

    if (!triggersAdded) {
      console.log(chalk.green('✓ All tables have required updated_at triggers\n'))
    } else {
      console.log(chalk.green('\n✓ Finished adding missing triggers\n'))
    }
  } finally {
    client.release()
  }
}

async function checkCronJobs(): Promise<void> {
  try {
    console.log(chalk.cyan('📅 Processing cron jobs...'))

    // Initialize cron jobs file if it doesn't exist
    await initializeCronJobsFile()

    // Process and diff cron jobs
    const result = await processCronJobs()

    if (result.hasChanges) {
      console.log(chalk.yellow('\n⚠️  CRON JOBS HAVE CHANGED'))
      console.log(chalk.yellow('📅 Source file auto-updated - check git diff for changes'))
      console.log(chalk.yellow('📅 Copy relevant cron job changes to your migration file'))
      console.log(chalk.gray('\n   Git will show you exactly what changed in cron-jobs.sql\n'))
    }

    // Validate cron jobs
    const validation = await validateCronJobs()

    if (validation.duplicateCommands.length > 0) {
      console.log(chalk.yellow('⚠️  Duplicate cron job commands detected:'))
      validation.duplicateCommands.forEach((cmd) => {
        console.log(chalk.gray(`   • ${cmd}`))
      })
      console.log()
    }

    if (validation.suspiciousCommands.length > 0) {
      console.log(chalk.yellow('⚠️  Potentially dangerous cron commands:'))
      validation.suspiciousCommands.forEach((cmd) => {
        console.log(chalk.gray(`   • ${cmd}`))
      })
      console.log()
    }

    if (validation.invalidSchedules.length > 0) {
      console.log(chalk.yellow('⚠️  Invalid cron schedules:'))
      validation.invalidSchedules.forEach((schedule) => {
        console.log(chalk.gray(`   • ${schedule}`))
      })
      console.log()
    }

    if (
      validation.duplicateCommands.length === 0 &&
      validation.suspiciousCommands.length === 0 &&
      validation.invalidSchedules.length === 0
    ) {
      console.log(chalk.green('✓ All cron jobs are properly configured\n'))
    }
  } catch (error) {
    console.error(chalk.red('❌ Error processing cron jobs:'), error)
    throw error
  }
}

async function checkTableComments(): Promise<void> {
  try {
    console.log(chalk.cyan('📝 Processing table comments...'))

    // Initialize comments file if it doesn't exist
    await initializeCommentsFile()

    // Process and diff table comments
    const result = await processTableComments()

    if (result.hasChanges) {
      console.log(chalk.yellow('\n⚠️  TABLE COMMENTS HAVE CHANGED'))
      console.log(chalk.yellow('📋 Source file auto-updated - check git diff for changes'))
      console.log(chalk.yellow('📋 Copy relevant comment changes to your migration file'))
      console.log(chalk.gray('\n   Git will show you exactly what changed in table-comments.sql\n'))
    }

    // Validate table comments structure
    const validation = await validateTableComments()

    if (validation.tablesWithoutComments.length > 0) {
      console.log(chalk.yellow('⚠️  Tables without comments:'))
      validation.tablesWithoutComments.forEach((table) => {
        console.log(chalk.gray(`   • ${table}`))
      })
      console.log()
    }

    if (validation.tablesWithInvalidComments.length > 0) {
      console.log(chalk.yellow('⚠️  Tables with invalid comment structure:'))
      validation.tablesWithInvalidComments.forEach((table) => {
        console.log(chalk.gray(`   • ${table}`))
      })
      console.log()
    }

    if (
      validation.tablesWithoutComments.length === 0 &&
      validation.tablesWithInvalidComments.length === 0
    ) {
      console.log(chalk.green('✓ All table comments are properly structured\n'))
    }
  } catch (error) {
    console.error(chalk.red('❌ Error processing table comments:'), error)
    throw error
  }
}

export async function preMigrationChecks(): Promise<void> {
  console.log(chalk.blue('🔍 Running pre-migration checks...\n'))

  try {
    // Check and add missing triggers
    await checkAndAddTriggers(pool)

    // Process table comments
    await checkTableComments()

    console.log(chalk.blue('\n🔐 Managing RLS policies...'))
    await dropAllRLSPolicies(pool)

    console.log(chalk.blue('\n🔓 Temporarily disabling RLS for migration...'))
    await disableRLSOnAllTables(pool)

    // Process cron jobs
    await checkCronJobs()

    console.log(chalk.green('✅ Pre-migration checks completed'))
  } catch (error) {
    console.error(chalk.red('❌ Pre-migration checks failed:'), error)
    throw error
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  preMigrationChecks()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(chalk.red('❌ Pre-migration checks encountered an error:'), error)
      process.exit(1)
    })
}
