// scripts/db/init/config.ts

interface InitSteps {
  setAdminUsers: boolean
  refreshViews: boolean
  addVaultSecrets: boolean
}

export interface DatabaseConfig {
  // Control which initialization steps to run
  steps: InitSteps

  // Admin users to set up
  admins: string[]
}

export const databaseConfig: DatabaseConfig = {
  steps: {
    setAdminUsers: false,
    refreshViews: false,
    addVaultSecrets: true,
  },

  admins: ['e8976b16-02a9-4595-a8a9-6457548eec12', 'e1bf12c6-aad4-4905-bda2-127c027504a3'],
}
