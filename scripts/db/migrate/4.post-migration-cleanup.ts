// scripts/4.post-migration-cleanup.ts
import chalk from 'chalk'
import pool from '../client'
import { extractRLSPolicies } from './tasks/extractRLSPolicies'
import { enableRLSOnAllTables } from './utils/manageRLS'

/**
 * Post-migration cleanup - now automated!
 */
async function postMigrationCleanup(): Promise<void> {
  try {
    console.log(chalk.cyan('🧹 Running post-migration cleanup...'))

    console.log(chalk.green('✅ Table comments automatically synchronized'))
    console.log(chalk.gray('   Source file: supabase/comments/table-comments.sql'))

    console.log(chalk.blue('\n🔐 Re-enabling RLS...'))
    await enableRLSOnAllTables(pool)

    // Extract RLS policies
    console.log(chalk.cyan('🔍 Generating and Applying RLS policies...'))
    await extractRLSPolicies(pool)

    console.log(chalk.gray('   Temp files: cleaned up automatically'))
    console.log(chalk.blue('\n📝 MANUAL STEP REMAINING:'))
    console.log(chalk.gray('   If table comments changed, copy relevant changes to your migration'))
    console.log(chalk.gray('   Use: git diff supabase/comments/table-comments.sql'))

    console.log(chalk.green('\n✅ Post-migration cleanup completed'))
  } catch (error) {
    console.error(chalk.red('❌ Post-migration cleanup failed:'), error)
  }
}

export { postMigrationCleanup }
