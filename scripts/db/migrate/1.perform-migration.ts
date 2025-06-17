// scripts/dbMigrate.ts
import { exec } from 'child_process'
import * as path from 'path'
import * as fs from 'fs'
import { fileURLToPath } from 'url'
import chalk from 'chalk'
import { preMigrationChecks } from './0.pre-migration'
import { appendCronJobs } from './tasks/extractCronJobs'
import { postMigrationCleanup } from './4.post-migration-cleanup'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// Get project root by going up from scripts directory
const projectRoot = path.resolve(__dirname, '../../../')
const migrationsDir = path.join(projectRoot, 'supabase/migrations')

const migrationName = process.argv[2]

if (!migrationName) {
  console.error(chalk.red('✖ Error: Missing migration name'))
  console.error(chalk.yellow('\nUsage: pnpm run db:migrate <migration_name>\n'))
  process.exit(1)
}

console.log(chalk.blue('\n📦 Starting migration process'))
console.log(chalk.gray(`• Migration name: ${chalk.white(migrationName)}`))
console.log(chalk.gray(`• Migrations directory: ${chalk.white(migrationsDir)}\n`))

function runCommand(command: string): Promise<void> {
  return new Promise((resolve, reject) => {
    console.log(chalk.cyan('⚡ Executing command:'))
    console.log(chalk.gray(`$ ${command}\n`))

    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error(chalk.red('✖ Command failed:'))
        console.error(chalk.red(stderr))
        reject(error)
      } else {
        if (stdout.trim()) {
          console.log(chalk.gray(stdout))
        }
        console.log(chalk.green('✓ Command completed successfully\n'))
        resolve()
      }
    })
  })
}

function findLatestMigrationFile(migrationName: string): string | null {
  console.log(chalk.cyan(`🔍 Looking for migration file: ${migrationName}`))

  const files = fs.readdirSync(migrationsDir)
  const matchingFiles = files
    .filter((file) => file.endsWith(`_${migrationName}.sql`))
    .map((file) => ({
      name: file,
      time: fs.statSync(path.join(migrationsDir, file)).mtime.getTime(),
    }))
    .sort((a, b) => b.time - a.time)

  if (matchingFiles.length === 0) {
    console.log(chalk.yellow('⚠ No matching migration files found'))
    return null
  }

  const foundFile = path.join(migrationsDir, matchingFiles[0]!.name)
  console.log(chalk.green(`✓ Found migration file: ${chalk.white(foundFile)}\n`))
  return foundFile
}

async function runMigration() {
  try {
    // Step 0: Pre-migration checks (includes table comments processing)
    console.log(chalk.blue('🔍 Step 0: Running pre-migration checks'))
    await preMigrationChecks()
    console.log(chalk.green('✓ Pre-migration checks completed successfully\n'))

    // Step 1: Generate the migration
    console.log(chalk.blue('📝 Step 1: Generating migration'))
    await runCommand(`supabase db diff -f "${migrationName}"`)

    // Step 2: Find the generated migration file
    console.log(chalk.blue('🔍 Step 2: Locating migration file'))
    let migrationFilePath = findLatestMigrationFile(migrationName as string)

    if (!migrationFilePath) {
      console.warn(chalk.yellow('⚠ No migration file found, creating an empty one'))
      // Create an empty migration file if none found
      migrationFilePath = createEmptyMigrationFile(migrationName as string)
    }

    console.log(chalk.blue('🔧 Step 3: Extract and append cron jobs'))
    await appendCronJobs(migrationFilePath)

    // Step 4: Reset the database
    console.log(chalk.blue('🔄 Step 5: Resetting database'))
    await runCommand('supabase db reset')

    // Step 5: Setup the database
    console.log(chalk.blue('🚀 Step 6: Setting up database'))
    await runCommand('npm run db:setup')

    // Step 6: Post-migration cleanup
    console.log(chalk.blue('🧹 Step 7: Post-migration cleanup'))
    await postMigrationCleanup()

    console.log(chalk.green(`\n✨ Migration "${migrationName}" completed successfully! ✨\n`))

    // Final reminder about table comments
    console.log(chalk.blue('📝 SEMI-AUTOMATED WORKFLOW:'))
    console.log(chalk.gray('   1. Source file auto-updated: supabase/comments/table-comments.sql'))
    console.log(chalk.gray('   2. Check git diff to see what changed'))
    console.log(chalk.gray('   3. Copy relevant changes to your migration file'))
    console.log(chalk.gray('   4. Temp files cleaned up automatically\n'))
  } catch (error: any) {
    console.error(chalk.red(`\n✖ Migration "${migrationName}" failed.\n`))
    console.error(chalk.red(error))

    // Don't clean up on failure so user can review changes
    console.log(chalk.yellow('💡 Tip: Check git diff for any table comment changes'))
    console.log(chalk.yellow('     Source file may have been auto-updated'))

    process.exit(1)
  }
}

function createEmptyMigrationFile(migrationName: string): string {
  // Generate timestamp in the same format as Supabase
  const timestamp = new Date()
    .toISOString()
    .replace(/[-T:.Z]/g, '')
    .slice(0, 14)
  const fileName = `${timestamp}_${migrationName}.sql`
  const filePath = path.join(migrationsDir, fileName)

  const content = `-- ============================================================================
-- MIGRATION: ${migrationName}
-- Generated: ${new Date().toISOString()}
-- Purpose: Empty migration (no schema changes detected)
-- ============================================================================

-- This migration was created because no schema changes were detected by Supabase,
-- but the migration process was requested. This commonly happens when:
-- 1. Only table comments changed (handled separately)
-- 2. Only data changes were made
-- 3. Only configuration changes were made

-- You can add any manual SQL changes below this comment:

`

  fs.writeFileSync(filePath, content)
  console.log(chalk.green(`✓ Created empty migration file: ${chalk.white(fileName)}`))

  return filePath
}

runMigration()
