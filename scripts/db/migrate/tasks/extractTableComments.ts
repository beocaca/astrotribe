// scripts/db/migrate/tasks/extractTableComments.ts
import chalk from 'chalk'
import type { Pool } from 'pg'
import pool from '../../shared/clients/pg.client.js'
import { GenericDiffer, createDiffConfig, type DiffResult } from '../utils/diffing.utils'

interface TableComment {
  table_name: string
  comment: string | null
}

/**
 * Configuration for table comments diffing
 */
const tableCommentsDiffConfig = createDiffConfig(
  'comments',
  'table-comments',
  'table-comments.sql',
  {
    generateHeader:
      () => `-- ============================================================================
-- TABLE COMMENTS
-- Generated: ${new Date().toISOString()}
-- Purpose: Single source of truth for table comments
-- ============================================================================

`,
    extractContent: (line: string): string | null => {
      // Extract table name from COMMENT statement
      const match = line.match(/COMMENT ON TABLE public\.(\w+) IS/)
      return match && match[1] ? match[1] : null
    },
    contentEquals: (line1: string, line2: string) => {
      // Comments should match exactly
      return line1 === line2
    },
  },
)

/**
 * Extract all table comments from the database
 */
async function extractTableComments(): Promise<TableComment[]> {
  try {
    const result = await pool.query(`
      SELECT 
        t.tablename as table_name,
        obj_description(c.oid) as comment
      FROM pg_tables t
      LEFT JOIN pg_class c ON c.relname = t.tablename
      WHERE t.schemaname = 'public'
        AND c.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
      ORDER BY t.tablename;
    `)

    return result.rows
  } catch (error) {
    console.error('Error extracting table comments:', error)
    throw error
  }
}

/**
 * Generate SQL content from table comments
 */
function generateCommentsSQL(comments: TableComment[]): string {
  const commentStatements = comments
    .filter((tc) => tc.comment) // Only include tables with comments
    .map((tc) => {
      const escapedComment = tc.comment!.replace(/'/g, "''")
      return `COMMENT ON TABLE public.${tc.table_name} IS '${escapedComment}';`
    })

  return commentStatements.join('\n') + '\n'
}

/**
 * Process table comments and generate diff
 */
async function processTableComments(): Promise<DiffResult> {
  console.log(chalk.cyan('📝 Extracting table comments from database...'))

  const differ = new GenericDiffer(tableCommentsDiffConfig)

  try {
    // Extract current comments from database
    const comments = await extractTableComments()
    const newContent = differ.generateContent([generateCommentsSQL(comments)])

    // Process and diff
    return await differ.processDiff(newContent)
  } catch (error) {
    console.error(chalk.red('Error processing table comments:'), error)
    throw error
  }
}

/**
 * Initialize comments file if it doesn't exist
 */
async function initializeCommentsFile(): Promise<void> {
  const differ = new GenericDiffer(tableCommentsDiffConfig)

  const comments = await extractTableComments()
  const initialContent = generateCommentsSQL(comments)

  await differ.initializeSourceFile(initialContent)
}

/**
 * Validate that all tables have appropriate comments
 */
async function validateTableComments(): Promise<{
  tablesWithoutComments: string[]
  tablesWithInvalidComments: string[]
}> {
  const comments = await extractTableComments()
  const tablesWithoutComments: string[] = []
  const tablesWithInvalidComments: string[] = []

  const requiredFields = ['domain:', 'purpose:', 'access:', 'frequency:']

  comments.forEach((tc) => {
    if (!tc.comment) {
      tablesWithoutComments.push(tc.table_name)
    } else {
      // Check if comment has all required fields
      const missingFields = requiredFields.filter((field) => !tc.comment!.includes(field))
      if (missingFields.length > 0) {
        tablesWithInvalidComments.push(`${tc.table_name} (missing: ${missingFields.join(', ')})`)
      }
    }
  })

  return { tablesWithoutComments, tablesWithInvalidComments }
}

// Export functions for use in CI pipeline
export {
  processTableComments,
  initializeCommentsFile,
  validateTableComments,
  extractTableComments,
  generateCommentsSQL,
}
