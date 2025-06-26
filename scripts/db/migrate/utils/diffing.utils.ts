// scripts/db/migrate/utils/diffing.utils.ts
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import chalk from 'chalk'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

// Go up from scripts/db/migrate/tasks/ to project root (4 levels up)
const projectRoot = path.resolve(__dirname, '../../../../')

export interface DiffResult {
  hasChanges: boolean
  sourceFile: string
  diffFile?: string
  changesSummary?: {
    added: number
    modified: number
    removed: number
  }
}

export interface DiffConfig {
  dir: string // Directory where comments are stored, e.g., 'comments' | 'cron'
  name: string // e.g., 'table-comments', 'cron-jobs'
  sourceFileName: string // e.g., 'table-comments.sql', 'cron-jobs.sql'
  generateHeader: () => string // Function to generate file header
  extractContent: (line: string) => string | null // Extract identifier from line
  contentEquals: (line1: string, line2: string) => boolean // Compare content
}

/**
 * Generic diffing utility that can be used for any SQL-based content
 */
export class GenericDiffer {
  private config: DiffConfig
  private commentsDir: string
  private sourceFile: string
  private newFile: string
  private diffFile: string

  constructor(config: DiffConfig) {
    this.config = config
    this.commentsDir = path.join(projectRoot, `supabase/${config.dir}`)
    this.sourceFile = path.join(this.commentsDir, config.sourceFileName)
    this.newFile = path.join(this.commentsDir, `${config.name}-new.sql`)
    this.diffFile = path.join(this.commentsDir, `${config.name}-diff.sql`)
  }

  /**
   * Ensure comments directory exists
   */
  private ensureDirectory(): void {
    if (!fs.existsSync(this.commentsDir)) {
      fs.mkdirSync(this.commentsDir, { recursive: true })
      console.log(chalk.gray(`Created comments directory: ${this.commentsDir}`))
    }
  }

  /**
   * Generate SQL file content with header
   */
  generateContent(contentLines: string[]): string {
    const header = this.config.generateHeader()
    return header + contentLines.join('\n') + '\n'
  }

  /**
   * Read existing source file
   */
  private readExistingContent(): string | null {
    try {
      if (fs.existsSync(this.sourceFile)) {
        return fs.readFileSync(this.sourceFile, 'utf8')
      }
      return null
    } catch (error) {
      console.error(`Error reading existing ${this.config.name} file:`, error)
      return null
    }
  }

  /**
   * Generate diff between old and new content
   */
  private generateDiff(oldContent: string | null, newContent: string): string | null {
    // If no old content exists, everything is new
    if (!oldContent) {
      console.log(chalk.yellow(`No existing ${this.config.name} file found - all content is new`))
      return newContent
    }

    // Filter out header/comment lines for comparison
    const oldLines = oldContent
      .split('\n')
      .filter((line) => line.trim() && !line.startsWith('--') && this.config.extractContent(line))
    const newLines = newContent
      .split('\n')
      .filter((line) => line.trim() && !line.startsWith('--') && this.config.extractContent(line))

    const addedLines: string[] = []
    const removedLines: string[] = []
    const modifiedLines: string[] = []

    // Find added/modified lines
    newLines.forEach((newLine) => {
      const newId = this.config.extractContent(newLine)
      if (!newId) return

      const oldLine = oldLines.find((line) => {
        const oldId = this.config.extractContent(line)
        return oldId === newId
      })

      if (!oldLine) {
        addedLines.push(newLine)
      } else if (!this.config.contentEquals(oldLine, newLine)) {
        modifiedLines.push(`-- OLD: ${oldLine}`)
        modifiedLines.push(`-- NEW: ${newLine}`)
        modifiedLines.push(newLine) // Include the new version
      }
    })

    // Find removed lines
    oldLines.forEach((oldLine) => {
      const oldId = this.config.extractContent(oldLine)
      if (!oldId) return

      const newLine = newLines.find((line) => {
        const newId = this.config.extractContent(line)
        return newId === oldId
      })
      if (!newLine) {
        removedLines.push(`-- REMOVED: ${oldLine}`)
      }
    })

    // If no changes, return null
    if (addedLines.length === 0 && removedLines.length === 0 && modifiedLines.length === 0) {
      return null
    }

    // Generate diff content
    let diffContent = `-- ============================================================================
-- ${this.config.name.toUpperCase()} DIFF
-- Generated: ${new Date().toISOString()}
-- Purpose: Changes to ${this.config.name} since last migration
-- ============================================================================

`

    if (addedLines.length > 0) {
      diffContent += `-- ============================================================================
-- ADDED ${this.config.name.toUpperCase()}
-- ============================================================================

${addedLines.join('\n')}

`
    }

    if (modifiedLines.length > 0) {
      diffContent += `-- ============================================================================
-- MODIFIED ${this.config.name.toUpperCase()}
-- ============================================================================

${modifiedLines.join('\n')}

`
    }

    if (removedLines.length > 0) {
      diffContent += `-- ============================================================================
-- REMOVED ${this.config.name.toUpperCase()}
-- ============================================================================

${removedLines.join('\n')}

`
    }

    return diffContent
  }

  /**
   * Process and diff content
   */
  async processDiff(newContent: string): Promise<DiffResult> {
    console.log(chalk.cyan(`📝 Processing ${this.config.name}...`))

    this.ensureDirectory()

    try {
      // Write new content file
      fs.writeFileSync(this.newFile, newContent)
      console.log(chalk.gray(`Written new ${this.config.name} to: ${this.newFile}`))

      // Read existing content
      const existingContent = this.readExistingContent()

      // Generate diff
      const diffContent = this.generateDiff(existingContent, newContent)

      if (diffContent) {
        // Write diff file
        fs.writeFileSync(this.diffFile, diffContent)
        console.log(chalk.yellow(`📋 ${this.config.name} changed - git will show the diff`))

        // Auto-update source of truth
        this.updateSourceFile()

        // Clean up temporary files
        this.cleanupTempFiles()

        return {
          hasChanges: true,
          sourceFile: this.sourceFile,
          diffFile: this.diffFile,
        }
      } else {
        console.log(chalk.green(`✓ No changes in ${this.config.name}`))

        // Clean up temp files
        this.cleanupTempFiles()

        return {
          hasChanges: false,
          sourceFile: this.sourceFile,
        }
      }
    } catch (error) {
      console.error(chalk.red(`Error processing ${this.config.name}:`), error)
      throw error
    }
  }

  /**
   * Update the source file automatically
   */
  private updateSourceFile(): void {
    if (fs.existsSync(this.newFile)) {
      // Move new content to source (auto-update source of truth)
      fs.renameSync(this.newFile, this.sourceFile)
      console.log(chalk.green(`✓ Auto-updated ${this.config.sourceFileName} with latest changes`))
    }
  }

  /**
   * Clean up temporary files
   */
  private cleanupTempFiles(): void {
    // Clean up diff file - git handles diffing
    if (fs.existsSync(this.diffFile)) {
      fs.unlinkSync(this.diffFile)
      console.log(chalk.gray(`Cleaned up temporary ${this.config.name} diff file`))
    }
  }

  /**
   * Initialize source file if it doesn't exist
   */
  async initializeSourceFile(initialContent: string): Promise<void> {
    if (!fs.existsSync(this.sourceFile)) {
      console.log(chalk.cyan(`🔨 Initializing ${this.config.name} file...`))

      this.ensureDirectory()

      const content = this.generateContent([initialContent])

      fs.writeFileSync(this.sourceFile, content)
      console.log(chalk.green(`✓ Initialized: ${this.sourceFile}`))
    }
  }
}

/**
 * Factory function to create diffing configs
 */
export function createDiffConfig(
  dir: string,
  name: string,
  sourceFileName: string,
  options: {
    generateHeader: () => string
    extractContent: (line: string) => string | null
    contentEquals?: (line1: string, line2: string) => boolean
  },
): DiffConfig {
  return {
    dir,
    name,
    sourceFileName,
    generateHeader: options.generateHeader,
    extractContent: options.extractContent,
    contentEquals: options.contentEquals || ((line1, line2) => line1 === line2),
  }
}
