import path from 'path'
import { fileURLToPath } from 'url'
import dotenv from 'dotenv'

// Convert `import.meta.url` to a usable directory path
const __dirname = path.dirname(fileURLToPath(import.meta.url))

// Resolve the root .env path (adjust if your structure is different)
const envPath = path.resolve(__dirname, '../../.env')

// Load the environment variables
const result = dotenv.config({ path: envPath, override: true })

if (result.error) {
  throw result.error // Or handle gracefully
}

export const env = result.parsed as Record<string, string>
