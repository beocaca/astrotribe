-- ============================================================================
-- CRON JOBS
-- Generated: 2025-06-26T08:27:19.763Z
-- Purpose: Single source of truth for cron job configurations
-- ============================================================================

-- Job ID: 1 | Schedule: 0 0 * * 0
DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM cron.job 
    WHERE command = 'SELECT public.execute_weekly_maintenance()'
  ) THEN
    PERFORM cron.schedule(
      'execute_weekly_maintenance',
      '0 0 * * 0',
      'SELECT public.execute_weekly_maintenance()'
    );
  END IF;
END $$;

-- Job ID: 2 | Schedule: 0 0 * * 0
DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM cron.job 
    WHERE command = 'SELECT public.gather_database_stats()'
  ) THEN
    PERFORM cron.schedule(
      'gather_database_stats',
      '0 0 * * 0',
      'SELECT public.gather_database_stats()'
    );
  END IF;
END $$;

-- Job ID: 3 | Schedule: 0 3 1 * *
DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM cron.job 
    WHERE command = 'SELECT public.cleanup_table_stats()'
  ) THEN
    PERFORM cron.schedule(
      'cleanup_table_stats',
      '0 3 1 * *',
      'SELECT public.cleanup_table_stats()'
    );
  END IF;
END $$;

-- Job ID: 4 | Schedule: 0 1 * * 0
DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM cron.job 
    WHERE command = 'SELECT public.perform_weekly_maintenance()'
  ) THEN
    PERFORM cron.schedule(
      'perform_weekly_maintenance',
      '0 1 * * 0',
      'SELECT public.perform_weekly_maintenance()'
    );
  END IF;
END $$;

-- Job ID: 7 | Schedule: 30 2 * * *
DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM cron.job 
    WHERE command = 'CALL public.compute_company_relationships()'
  ) THEN
    PERFORM cron.schedule(
      'compute_company_relationships',
      '30 2 * * *',
      'CALL public.compute_company_relationships()'
    );
  END IF;
END $$;

-- Job ID: 8 | Schedule: 30 2 * * *
DO $$ 
BEGIN 
  IF NOT EXISTS (
    SELECT 1 FROM cron.job 
    WHERE command = 'SELECT public.compute_organization_relationships()'
  ) THEN
    PERFORM cron.schedule(
      'compute_organization_relationships',
      '30 2 * * *',
      'SELECT public.compute_organization_relationships()'
    );
  END IF;
END $$;

