# Table Comments Management

This directory contains the table comments management system.

## Files

- `table-comments.sql` - **Source of truth** for all table comments
- `table-comments-new.sql` - Temporary file created during migration (auto-deleted)
- `table-comments-diff.sql` - Diff file showing changes (auto-deleted)

## Workflow (Testing Phase - Manual)

1. During `pnpm run db:migrate`, comments are extracted from database
2. If changes detected, a diff file is created: `table-comments-diff.sql`
3. **MANUAL**: Review the diff and copy relevant changes to your migration file
4. **MANUAL**: Update `table-comments.sql` with the changes
5. **MANUAL**: Delete the diff file when done
6. After testing phase (~10 migrations), this will be automated

## Adding/Updating Comments

To add or update table comments:

1. Add comments directly in your migration file:
   ```sql
   COMMENT ON TABLE user_profiles IS 'domain:auth | purpose:Core user identity | access:critical | frequency:high-read,medium-write';
   ```

2. Run the migration - the system will automatically detect and sync changes

## Comment Structure

All comments must follow this format:
```
domain:{domains} | purpose:{description} | access:{level} | frequency:{read-pattern},{write-pattern}
```

### Access Levels
- `public` - Customer-facing APIs, no special security
- `internal` - Application-only access, standard security  
- `protected` - Admin/sensitive data, enhanced security
- `critical` - Auth/payments/compliance, maximum security

### Frequency Patterns
- `high` - 1000+ operations/day
- `medium` - 100-1000 operations/day  
- `low` - <100 operations/day
