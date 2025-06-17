import Pool from 'pg-pool'
import { env } from '../env.js'

export default new Pool({
  connectionString: env.DATABASE_URL,
  ssl: env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false,
})
