// scripts/db/migrate/tasks/applyRLSPolicies.ts
import chalk from 'chalk'
import type { Pool } from 'pg'
import pool from '../../client'

// Types matching your permissions_config table
type AppPlanEnum = 'free' | 'basic' | 'intermediate' | 'premium' | 'enterprise' | 'custom'
type AppRoleEnum =
  | 'guest'
  | 'user'
  | 'astroguide'
  | 'mentor'
  | 'moderator'
  | 'tenant_member'
  | 'tenant_admin'
  | 'tenant_super_admin'
  | 'admin'
  | 'super_admin'
  | 'service_role'

interface PermissionConfig {
  id: string
  table_name: string
  permission_name: string
  action: 'select' | 'insert' | 'update' | 'delete' | 'all'
  required_role: AppRoleEnum
  required_plan?: AppPlanEnum
  requires_ownership: boolean
  requires_org_membership: boolean
  condition_template?: string
  priority: number
  enabled: boolean
  notes?: string
}

interface TableInfo {
  table_name: string
  comment?: string
  access_level: 'public' | 'internal' | 'protected' | 'critical'
  has_rls: boolean
}

interface DefaultPolicy {
  action: 'select' | 'insert' | 'update' | 'delete' | 'all'
  role: AppRoleEnum
  condition_template?: string
  requires_ownership?: boolean
  requires_org_membership?: boolean
}

export class SimpleRLSPolicyApplier {
  private pool: Pool

  // Role hierarchy - higher roles inherit lower role permissions
  private readonly ROLE_HIERARCHY: Record<AppRoleEnum, AppRoleEnum[]> = {
    service_role: ['service_role'], // Special case - no inheritance, system access only
    super_admin: [
      'super_admin',
      'admin',
      'tenant_super_admin',
      'tenant_admin',
      'tenant_member',
      'moderator',
      'mentor',
      'astroguide',
      'user',
    ],
    admin: [
      'admin',
      'tenant_super_admin',
      'tenant_admin',
      'tenant_member',
      'moderator',
      'mentor',
      'astroguide',
      'user',
    ],
    tenant_super_admin: ['tenant_super_admin', 'tenant_admin', 'tenant_member', 'user'],
    tenant_admin: ['tenant_admin', 'tenant_member', 'user'],
    tenant_member: ['tenant_member', 'user'],
    moderator: ['moderator', 'user'],
    mentor: ['mentor', 'user'],
    astroguide: ['astroguide', 'user'],
    user: ['user'],
    guest: ['guest'],
  }

  // Plan hierarchy - higher plans inherit lower plan permissions
  private readonly PLAN_HIERARCHY: Record<AppPlanEnum, AppPlanEnum[]> = {
    custom: ['custom', 'enterprise', 'premium', 'intermediate', 'basic', 'free'],
    enterprise: ['enterprise', 'premium', 'intermediate', 'basic', 'free'],
    premium: ['premium', 'intermediate', 'basic', 'free'],
    intermediate: ['intermediate', 'basic', 'free'],
    basic: ['basic', 'free'],
    free: ['free'],
  }

  // Condition templates for common conditions
  private readonly CONDITION_TEMPLATES: Record<string, string> = {
    public_content:
      "visibility_status = 'published' AND review_status = 'approved' AND moderation_status = 'safe'",
    active_content: 'is_active = true AND deleted_at IS NULL',
    user_owned: 'user_id = auth.uid()',
    org_scoped: "organization_id = (auth.jwt() ->> 'organization_id')::uuid",
    user_and_org:
      "user_id = auth.uid() AND organization_id = (auth.jwt() ->> 'organization_id')::uuid",
    premium_content:
      "is_public = true OR (auth.jwt() ->> 'plan')::app_plan_enum IN ('premium', 'intermediate', 'enterprise', 'custom')",
    published_and_safe: "visibility_status = 'published' AND moderation_status = 'safe'",
    directory_ready: 'is_directory_ready = true AND is_approved = true',
  }

  // Table-specific column mappings and overrides
  private readonly TABLE_OVERRIDES: Record<
    string,
    {
      userColumn?: string
      orgColumn?: string
      customConditions?: Record<string, string>
    }
  > = {
    user_profiles: {
      userColumn: 'id', // user_profiles uses 'id' instead of 'user_id'
      customConditions: {
        user_owned: 'id = auth.uid()',
      },
    },
    addresses: {
      userColumn: 'user_id',
      orgColumn: 'organization_id',
    },
  }

  /**
   * Generate intelligent default policies based on table structure and access level
   */
  private async generateDefaultPolicies(table: TableInfo): Promise<PermissionConfig[]> {
    // Analyze table structure
    const structure = await this.analyzeTableStructure(table.table_name)

    // Get intelligent default policies
    const policyGenerator =
      this.SMART_DEFAULT_POLICIES[table.access_level] || this.SMART_DEFAULT_POLICIES['internal']
    const defaultPolicies = policyGenerator!(table, structure.hasUserColumn, structure.hasOrgColumn)

    console.log(
      chalk.gray(
        `      Table analysis: user_id=${structure.hasUserColumn}, org_id=${structure.hasOrgColumn}, junction=${structure.isJunctionTable}`,
      ),
    )

    return defaultPolicies.map((defaultPolicy, index) => ({
      id: `default-${table.table_name}-${index}`,
      table_name: table.table_name,
      permission_name: `default_${table.access_level}_${defaultPolicy.role}`,
      action: defaultPolicy.action,
      required_role: defaultPolicy.role,
      required_plan: undefined,
      requires_ownership: defaultPolicy.requires_ownership || false,
      requires_org_membership: defaultPolicy.requires_org_membership || false,
      condition_template: defaultPolicy.condition_template,
      priority: 0,
      enabled: true,
      notes: `Auto-generated default policy for ${table.access_level} table (${structure.hasUserColumn ? 'user-owned' : structure.hasOrgColumn ? 'org-scoped' : 'system'})`,
    }))
  }

  // Intelligent default policies based on table structure and access level
  private readonly SMART_DEFAULT_POLICIES: Record<
    string,
    (tableInfo: TableInfo, hasUserColumn: boolean, hasOrgColumn: boolean) => DefaultPolicy[]
  > = {
    public: (table, hasUser, hasOrg) => [
      { action: 'select', role: 'user', condition_template: 'public_content' },
    ],
    internal: (table, hasUser, hasOrg) => {
      const policies: DefaultPolicy[] = [{ action: 'select', role: 'user' }]
      // Only add ownership policies if user_id column exists
      if (hasUser) {
        policies.push({ action: 'insert', role: 'user', requires_ownership: true })
        policies.push({ action: 'update', role: 'user', requires_ownership: true })
        policies.push({ action: 'delete', role: 'user', requires_ownership: true })
      } else if (hasOrg) {
        // Organization-scoped if no user ownership but has org
        policies.push({ action: 'insert', role: 'tenant_admin', requires_org_membership: true })
        policies.push({ action: 'update', role: 'tenant_admin', requires_org_membership: true })
        policies.push({ action: 'delete', role: 'tenant_admin', requires_org_membership: true })
      } else {
        // System/reference table - admin only for modifications
        policies.push({ action: 'insert', role: 'admin' })
        policies.push({ action: 'update', role: 'admin' })
        policies.push({ action: 'delete', role: 'admin' })
      }
      return policies
    },
    protected: (table, hasUser, hasOrg) => [
      { action: 'select', role: 'admin' },
      { action: 'insert', role: 'admin' },
      { action: 'update', role: 'admin' },
      { action: 'delete', role: 'admin' },
    ],
    critical: (table, hasUser, hasOrg) => [
      { action: 'select', role: 'super_admin' },
      { action: 'insert', role: 'super_admin' },
      { action: 'update', role: 'super_admin' },
      { action: 'delete', role: 'super_admin' },
      // Service role gets full access
      { action: 'select', role: 'service_role' },
      { action: 'insert', role: 'service_role' },
      { action: 'update', role: 'service_role' },
      { action: 'delete', role: 'service_role' },
    ],
  }

  constructor(poolInstance: Pool) {
    this.pool = poolInstance
  }

  /**
   * Main function to apply RLS policies to all tables
   */
  async applyRLSPolicies(): Promise<void> {
    console.log(chalk.cyan('🔐 Applying RLS policies to database...'))

    try {
      // Get all tables with their metadata
      const tables = await this.fetchTablesWithComments()
      console.log(`Found ${tables.length} tables to process`)

      let tablesProcessed = 0
      let policiesApplied = 0

      // Process each table
      for (const table of tables) {
        console.log(chalk.gray(`Processing table: ${table.table_name}`))

        // Enable RLS if not enabled
        if (!table.has_rls) {
          await this.enableRLS(table.table_name)
          console.log(chalk.yellow(`  ✓ Enabled RLS on ${table.table_name}`))
        }

        // Get policies for this table (explicit or default)
        const policies = await this.getOrGeneratePolicies(table)

        if (policies.length > 0) {
          // Drop existing policies first (clean slate)
          await this.dropExistingPolicies(table.table_name)

          // Apply new policies
          for (const policy of policies) {
            await this.applyPolicyToTable(table.table_name, policy)
            policiesApplied++
          }
          console.log(chalk.green(`  ✓ Applied ${policies.length} policies to ${table.table_name}`))
        } else {
          console.log(chalk.gray(`  ℹ No policies needed for ${table.table_name}`))
        }

        tablesProcessed++
      }

      console.log(chalk.green('✅ RLS policies applied successfully'))
      console.log(chalk.gray(`   Tables processed: ${tablesProcessed}`))
      console.log(chalk.gray(`   Policies applied: ${policiesApplied}`))
      console.log(chalk.gray('   Supabase CLI will capture changes in migration'))
    } catch (error: any) {
      console.error(chalk.red('❌ Error applying RLS policies:'), error)
      throw error
    }
  }

  /**
   * Fetch all tables with their comments and RLS status
   */
  private async fetchTablesWithComments(): Promise<TableInfo[]> {
    const result = await this.pool.query(`
    SELECT 
      t.tablename as table_name,
      obj_description(c.oid) as comment,
      CASE WHEN c.relrowsecurity THEN true ELSE false END as has_rls
    FROM pg_tables t
    LEFT JOIN pg_class c ON c.relname = t.tablename
    WHERE t.schemaname = 'public'
      AND c.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
    ORDER BY t.tablename
  `)

    return result.rows.map((row) => ({
      table_name: row.table_name,
      comment: row.comment,
      access_level: this.parseAccessLevel(row.comment),
      has_rls: row.has_rls,
    }))
  }

  /**
   * Parse access level from table comment
   */
  private parseAccessLevel(
    comment: string | null,
  ): 'public' | 'internal' | 'protected' | 'critical' {
    if (!comment) return 'internal' // Default

    const accessMatch = comment.match(/access:([^|]+)/)
    const accessLevel = accessMatch?.[1]?.trim()

    if (['public', 'internal', 'protected', 'critical'].includes(accessLevel || '')) {
      return accessLevel as any
    }

    return 'internal' // Default fallback
  }

  /**
   * Enable RLS on a table
   */
  private async enableRLS(tableName: string): Promise<void> {
    await this.pool.query(`ALTER TABLE "${tableName}" ENABLE ROW LEVEL SECURITY`)
  }

  /**
   * Get explicit permissions for table or generate defaults
   */
  private async getOrGeneratePolicies(table: TableInfo): Promise<PermissionConfig[]> {
    try {
      // First, try to get explicit permissions from permissions_config
      const result = await this.pool.query<PermissionConfig>(
        `
      SELECT * FROM permissions_config
      WHERE table_name = $1 AND enabled = true
      ORDER BY priority DESC, required_role, action
    `,
        [table.table_name],
      )

      if (result.rows.length > 0) {
        console.log(chalk.gray(`    Found ${result.rows.length} explicit permissions`))
        return result.rows
      }

      // No explicit permissions - generate intelligent defaults based on table structure
      console.log(
        chalk.gray(`    Generating default policies for access level: ${table.access_level}`),
      )
      return await this.generateDefaultPolicies(table)
    } catch (error: any) {
      // If permissions_config table doesn't exist, generate defaults
      if (error.code === '42P01') {
        // relation does not exist
        console.log(chalk.gray('    permissions_config not found - using defaults'))
        return this.generateDefaultPolicies(table)
      }
      throw error
    }
  }

  /**
   * Check if table has specific columns for intelligent policy generation
   */
  private async analyzeTableStructure(tableName: string): Promise<{
    hasUserColumn: boolean
    hasOrgColumn: boolean
    isJunctionTable: boolean
    userColumn?: string
    orgColumn?: string
  }> {
    // Check for table-specific overrides first
    const override = this.TABLE_OVERRIDES[tableName]

    if (override) {
      return {
        hasUserColumn: !!override.userColumn,
        hasOrgColumn: !!override.orgColumn,
        isJunctionTable: false,
        userColumn: override.userColumn,
        orgColumn: override.orgColumn,
      }
    }

    const result = await this.pool.query(
      `
    SELECT column_name
    FROM information_schema.columns
    WHERE table_schema = 'public' 
      AND table_name = $1
      AND column_name IN ('user_id', 'organization_id', 'id')
  `,
      [tableName],
    )

    const columns = result.rows.map((row) => row.column_name)
    const hasUserColumn = columns.includes('user_id')
    const hasOrgColumn = columns.includes('organization_id')
    const hasIdColumn = columns.includes('id')

    // Junction tables typically have only foreign key columns and few other fields
    const allColumnsResult = await this.pool.query(
      `
    SELECT COUNT(*) as column_count
    FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = $1
  `,
      [tableName],
    )

    const isJunctionTable =
      allColumnsResult.rows[0]?.column_count <= 5 && !hasUserColumn && tableName.includes('_')

    return {
      hasUserColumn,
      hasOrgColumn,
      isJunctionTable,
      userColumn: hasUserColumn ? 'user_id' : undefined,
      orgColumn: hasOrgColumn ? 'organization_id' : undefined,
    }
  }

  /**
   * Drop ALL policies for a table - nuclear option that always works
   */
  private async dropExistingPolicies(tableName: string): Promise<void> {
    try {
      // Method 1: Get all policies and drop them one by one with CASCADE
      const result = await this.pool.query(
        'SELECT policyname FROM pg_policies WHERE tablename = $1',
        [tableName],
      )

      console.log(chalk.gray(`      Dropping ${result.rows.length} existing policies`))

      // Drop each policy with CASCADE to handle dependencies
      for (const row of result.rows) {
        try {
          await this.pool.query(`DROP POLICY "${row.policyname}" ON "${tableName}" CASCADE`)
          console.log(chalk.gray(`        ✓ Dropped ${row.policyname}`))
        } catch (error: any) {
          // If normal drop fails, try with IF EXISTS
          try {
            await this.pool.query(`DROP POLICY IF EXISTS "${row.policyname}" ON "${tableName}"`)
            console.log(chalk.gray(`        ✓ Dropped ${row.policyname} (with IF EXISTS)`))
          } catch (secondError) {
            console.warn(
              chalk.yellow(`        ⚠ Could not drop policy ${row.policyname}: ${error.message}`),
            )
          }
        }
      }

      // Method 2: Verify all policies are actually gone
      const verification = await this.pool.query(
        'SELECT COUNT(*) as remaining FROM pg_policies WHERE tablename = $1',
        [tableName],
      )

      const remaining = parseInt(verification.rows[0]?.remaining || '0')
      if (remaining > 0) {
        console.warn(
          chalk.yellow(`      ⚠ Warning: ${remaining} policies still exist on ${tableName}`),
        )

        // Nuclear option: Disable and re-enable RLS to clear all policies
        await this.pool.query(`ALTER TABLE "${tableName}" DISABLE ROW LEVEL SECURITY`)
        await this.pool.query(`ALTER TABLE "${tableName}" ENABLE ROW LEVEL SECURITY`)
        console.log(chalk.yellow(`        Cleared all policies by resetting RLS on ${tableName}`))
      } else {
        console.log(chalk.gray('        ✓ All policies successfully dropped'))
      }
    } catch (error: any) {
      console.warn(
        chalk.yellow(`      Warning: Error dropping policies for ${tableName}: ${error.message}`),
      )
      console.log(chalk.yellow('      Attempting nuclear reset...'))

      // Last resort: Reset RLS entirely
      try {
        await this.pool.query(`ALTER TABLE "${tableName}" DISABLE ROW LEVEL SECURITY`)
        await this.pool.query(`ALTER TABLE "${tableName}" ENABLE ROW LEVEL SECURITY`)
        console.log(chalk.yellow(`        ✓ Nuclear reset successful for ${tableName}`))
      } catch (resetError: any) {
        console.error(chalk.red(`        ❌ Nuclear reset failed: ${resetError.message}`))
        throw resetError
      }
    }
  }

  /**
   * Apply individual policy to table
   */
  private async applyPolicyToTable(tableName: string, perm: PermissionConfig): Promise<void> {
    const actions =
      perm.action === 'all' ? ['SELECT', 'INSERT', 'UPDATE', 'DELETE'] : [perm.action.toUpperCase()]

    for (const action of actions) {
      const policyName = `${perm.permission_name}_${action.toLowerCase()}`
      const condition = this.buildRLSCondition(perm)

      let policySQL = `CREATE POLICY "${policyName}" ON "${tableName}" FOR ${action} TO authenticated`

      // Different syntax for different actions
      if (action === 'INSERT') {
        // INSERT policies only use WITH CHECK
        policySQL += ` WITH CHECK (${condition})`
      } else if (action === 'UPDATE') {
        // UPDATE policies use both USING and WITH CHECK
        policySQL += ` USING (${condition}) WITH CHECK (${condition})`
      } else {
        // SELECT and DELETE use only USING
        policySQL += ` USING (${condition})`
      }

      await this.pool.query(policySQL)
    }
  }

  /**
   * Build RLS condition from permission config with table-specific overrides
   */
  private buildRLSCondition(perm: PermissionConfig): string {
    const conditions: string[] = []

    // Role condition with hierarchy support
    const allowedRoles = this.ROLE_HIERARCHY[perm.required_role] || [perm.required_role]
    const roleCondition = allowedRoles.map((role) => `'${role}'`).join(', ')
    conditions.push(`(auth.jwt() ->> 'user_role')::app_role_enum IN (${roleCondition})`)

    // Plan condition with hierarchy support (if specified)
    if (perm.required_plan) {
      const allowedPlans = this.PLAN_HIERARCHY[perm.required_plan] || [perm.required_plan]
      const planCondition = allowedPlans.map((plan) => `'${plan}'`).join(', ')
      conditions.push(`(auth.jwt() ->> 'plan')::app_plan_enum IN (${planCondition})`)
    }

    // Check for table-specific overrides
    const override = this.TABLE_OVERRIDES[perm.table_name]

    // Ownership condition with override support
    if (perm.requires_ownership) {
      if (override?.userColumn) {
        conditions.push(`${override.userColumn} = auth.uid()`)
      } else {
        conditions.push('user_id = auth.uid()')
      }
    }

    // Organization condition with override support
    if (perm.requires_org_membership) {
      const orgColumn = override?.orgColumn || 'organization_id'
      conditions.push(`${orgColumn} = (auth.jwt() ->> 'organization_id')::uuid`)
    }

    // Condition template with override support
    if (perm.condition_template) {
      // Check for table-specific custom condition first
      const customCondition = override?.customConditions?.[perm.condition_template]
      if (customCondition) {
        conditions.push(`(${customCondition})`)
      } else {
        const template = this.CONDITION_TEMPLATES[perm.condition_template]
        if (template) {
          conditions.push(`(${template})`)
        } else {
          console.warn(`⚠️  Unknown condition template: ${perm.condition_template}`)
          conditions.push('FALSE') // Fail-safe
        }
      }
    }

    // Join conditions with AND, default to FALSE if no conditions
    return conditions.length > 0 ? conditions.join(' AND ') : 'FALSE'
  }

  /**
   * Validate that RLS is working correctly
   */
  async validateRLSSetup(): Promise<{
    tablesWithoutRLS: string[]
    tablesWithoutPolicies: string[]
    successCount: number
  }> {
    const tablesWithoutRLS: string[] = []
    const tablesWithoutPolicies: string[] = []
    let successCount = 0

    // Check all public tables
    const result = await this.pool.query(`
    SELECT 
      t.tablename,
      CASE WHEN c.relrowsecurity THEN true ELSE false END as has_rls,
      COALESCE(policy_count.count, 0) as policy_count
    FROM pg_tables t
    LEFT JOIN pg_class c ON c.relname = t.tablename
    LEFT JOIN (
      SELECT tablename, COUNT(*) as count
      FROM pg_policies
      GROUP BY tablename
    ) policy_count ON policy_count.tablename = t.tablename
    WHERE t.schemaname = 'public'
      AND c.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
  `)

    for (const row of result.rows) {
      if (!row.has_rls) {
        tablesWithoutRLS.push(row.tablename)
      } else if (row.policy_count === 0) {
        tablesWithoutPolicies.push(row.tablename)
      } else {
        successCount++
      }
    }

    return { tablesWithoutRLS, tablesWithoutPolicies, successCount }
  }
}

/**
 * Main function to apply RLS policies (called from pre-migration checks)
 */
export async function applyRLSPolicies(): Promise<void> {
  const applier = new SimpleRLSPolicyApplier(pool)
  await applier.applyRLSPolicies()
}

/**
 * Validation function to check RLS setup
 */
export async function validateRLSSetup(): Promise<void> {
  console.log(chalk.cyan('🔍 Validating RLS setup...'))

  const applier = new SimpleRLSPolicyApplier(pool)
  const validation = await applier.validateRLSSetup()

  if (validation.tablesWithoutRLS.length > 0) {
    console.log(chalk.yellow('⚠️  Tables without RLS enabled:'))
    validation.tablesWithoutRLS.forEach((table) => {
      console.log(chalk.gray(`   • ${table}`))
    })
  }

  if (validation.tablesWithoutPolicies.length > 0) {
    console.log(chalk.yellow('⚠️  Tables without RLS policies:'))
    validation.tablesWithoutPolicies.forEach((table) => {
      console.log(chalk.gray(`   • ${table}`))
    })
  }

  if (validation.tablesWithoutRLS.length === 0 && validation.tablesWithoutPolicies.length === 0) {
    console.log(chalk.green(`✅ RLS properly configured on ${validation.successCount} tables`))
  }
}
