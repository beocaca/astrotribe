// scripts/db/init/1.main.ts

import chalk from 'chalk'
import client from '../shared/clients/pg.client.js'
import { databaseConfig } from './1.config'
import { setAdminUser } from './create-admin'
import { refreshDatabaseViews } from './refresh-views'
import { createVaultSecrets } from './utils/vault-secrets'

async function main() {
  console.log(chalk.blue('🚀 Starting database initialization...'))

  try {
    // 2. Set up admin users
    if (databaseConfig.steps.setAdminUsers) {
      console.log(chalk.blue('\n👤 Setting up admin users...'))
      await setAdminUser(client, databaseConfig.admins)
    }

    // 4. Refresh database views
    if (databaseConfig.steps.refreshViews) {
      // Add this to your config
      console.log(chalk.blue('\n🔄 Refreshing database views...'))
      const viewsRefreshed = await refreshDatabaseViews(client)
      if (!viewsRefreshed) {
        throw new Error('Failed to refresh views')
      }
      console.log(chalk.green('✓ Database views refreshed'))
    }

    // 5. Add Vault Secrets
    if (databaseConfig.steps.addVaultSecrets) {
      console.log(chalk.blue('\n🔐 Adding vault secrets...'))
      const vaultSecretsAdded = await createVaultSecrets(client)
      if (!vaultSecretsAdded) {
        throw new Error('Failed to add vault secrets')
      }
      console.log(chalk.green('✓ Vault secrets added'))
    }

    console.log(chalk.green('\n✨ Database initialization completed successfully'))
    process.exit(0)
  } catch (error: any) {
    console.error(chalk.red('\n❌ Error during database initialization:'), error)
    process.exit(1)
  } finally {
    await client.end()
  }
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  main()
}
