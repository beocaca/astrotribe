
-- ========================================
-- ✅ RECREATE CORE BUSINESS TABLES
-- ========================================



-- =============================================================================
-- SECTION 17: ADD GRANTS
-- =============================================================================

-- Status History permissions
GRANT SELECT, INSERT ON public.status_history TO anon, authenticated;
GRANT ALL ON public.status_history TO service_role;

-- Status Registry permissions  
GRANT SELECT ON public.statuses TO anon, authenticated;
GRANT ALL ON public.statuses TO service_role;

-- Function permissions
GRANT EXECUTE ON FUNCTION public.update_status(text, uuid, text, text, jsonb) TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.update_status_batch(text, uuid[], text, text, jsonb) TO authenticated, service_role;

GRANT ALL ON TABLE "public"."topics" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."user_topics" TO "anon", "authenticated", "service_role";


-- Grant all permissions to all roles for all new tables
GRANT ALL ON TABLE "public"."opportunities" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."news" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."organizations" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."content_sources" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."people" TO "anon", "authenticated", "service_role";
GRANT ALL ON TABLE "public"."organization_people" TO "anon", "authenticated", "service_role";


grant delete on table "public"."permission_configs" to "anon";

grant insert on table "public"."permission_configs" to "anon";

grant references on table "public"."permission_configs" to "anon";

grant select on table "public"."permission_configs" to "anon";

grant trigger on table "public"."permission_configs" to "anon";

grant truncate on table "public"."permission_configs" to "anon";

grant update on table "public"."permission_configs" to "anon";

grant delete on table "public"."permission_configs" to "authenticated";

grant insert on table "public"."permission_configs" to "authenticated";

grant references on table "public"."permission_configs" to "authenticated";

grant select on table "public"."permission_configs" to "authenticated";

grant trigger on table "public"."permission_configs" to "authenticated";

grant truncate on table "public"."permission_configs" to "authenticated";

grant update on table "public"."permission_configs" to "authenticated";

grant delete on table "public"."permission_configs" to "service_role";

grant insert on table "public"."permission_configs" to "service_role";

grant references on table "public"."permission_configs" to "service_role";

grant select on table "public"."permission_configs" to "service_role";

grant trigger on table "public"."permission_configs" to "service_role";

grant truncate on table "public"."permission_configs" to "service_role";

grant update on table "public"."permission_configs" to "service_role";
grant delete on table "public"."topic_clusters" to "anon";
grant insert on table "public"."topic_clusters" to "anon";
grant references on table "public"."topic_clusters" to "anon";
grant select on table "public"."topic_clusters" to "anon";
grant trigger on table "public"."topic_clusters" to "anon";
grant truncate on table "public"."topic_clusters" to "anon";
grant update on table "public"."topic_clusters" to "anon";
grant delete on table "public"."topic_clusters" to "authenticated";
grant insert on table "public"."topic_clusters" to "authenticated";
grant references on table "public"."topic_clusters" to "authenticated";
grant select on table "public"."topic_clusters" to "authenticated";
grant trigger on table "public"."topic_clusters" to "authenticated";
grant truncate on table "public"."topic_clusters" to "authenticated";
grant update on table "public"."topic_clusters" to "authenticated";
grant delete on table "public"."topic_clusters" to "service_role";
grant insert on table "public"."topic_clusters" to "service_role";
grant references on table "public"."topic_clusters" to "service_role";
grant select on table "public"."topic_clusters" to "service_role";
grant trigger on table "public"."topic_clusters" to "service_role";
grant truncate on table "public"."topic_clusters" to "service_role";
grant update on table "public"."topic_clusters" to "service_role";
