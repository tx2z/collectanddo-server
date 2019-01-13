--
-- PostgreSQL database dump
--

-- Dumped from database version 10.5 (Debian 10.5-2.pgdg90+1)
-- Dumped by pg_dump version 10.5 (Debian 10.5-2.pgdg90+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE collectanddo; Type: COMMENT; Schema: -; Owner: collectanddo
--

COMMENT ON DATABASE collectanddo IS 'default administrative connection database';


--
-- Name: hdb_catalog; Type: SCHEMA; Schema: -; Owner: collectanddo
--

CREATE SCHEMA hdb_catalog;


ALTER SCHEMA hdb_catalog OWNER TO collectanddo;

--
-- Name: hdb_views; Type: SCHEMA; Schema: -; Owner: collectanddo
--

CREATE SCHEMA hdb_views;


ALTER SCHEMA hdb_views OWNER TO collectanddo;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: hdb_table_oid_check(); Type: FUNCTION; Schema: hdb_catalog; Owner: collectanddo
--

CREATE FUNCTION hdb_catalog.hdb_table_oid_check() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
  BEGIN
    IF (EXISTS (SELECT 1 FROM information_schema.tables st WHERE st.table_schema = NEW.table_schema AND st.table_name = NEW.table_name)) THEN
      return NEW;
    ELSE
      RAISE foreign_key_violation using message = 'table_schema, table_name not in information_schema.tables';
      return NULL;
    END IF;
  END;
$$;


ALTER FUNCTION hdb_catalog.hdb_table_oid_check() OWNER TO collectanddo;

--
-- Name: inject_table_defaults(text, text, text, text); Type: FUNCTION; Schema: hdb_catalog; Owner: collectanddo
--

CREATE FUNCTION hdb_catalog.inject_table_defaults(view_schema text, view_name text, tab_schema text, tab_name text) RETURNS void
    LANGUAGE plpgsql
    AS $$
    DECLARE
        r RECORD;
    BEGIN
      FOR r IN SELECT column_name, column_default FROM information_schema.columns WHERE table_schema = tab_schema AND table_name = tab_name AND column_default IS NOT NULL LOOP
          EXECUTE format('ALTER VIEW %I.%I ALTER COLUMN %I SET DEFAULT %s;', view_schema, view_name, r.column_name, r.column_default);
      END LOOP;
    END;
$$;


ALTER FUNCTION hdb_catalog.inject_table_defaults(view_schema text, view_name text, tab_schema text, tab_name text) OWNER TO collectanddo;

--
-- Name: jwt_server__insert__public__user(); Type: FUNCTION; Schema: hdb_views; Owner: collectanddo
--

CREATE FUNCTION hdb_views.jwt_server__insert__public__user() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
  DECLARE r "public"."user"%ROWTYPE;
  DECLARE conflict_clause jsonb;
  DECLARE action text;
  DECLARE constraint_name text;
  DECLARE set_expression text;
  BEGIN
    conflict_clause = current_setting('hasura.conflict_clause')::jsonb;
    IF ('true') THEN
      CASE
        WHEN conflict_clause = 'null'::jsonb THEN INSERT INTO "public"."user" VALUES (NEW.*) RETURNING * INTO r;
        ELSE
          action = conflict_clause ->> 'action';
          constraint_name = quote_ident(conflict_clause ->> 'constraint');
          set_expression = conflict_clause ->> 'set_expression';
          IF action is NOT NULL THEN
            CASE
              WHEN action = 'ignore'::text AND constraint_name IS NULL THEN
                INSERT INTO "public"."user" VALUES (NEW.*) ON CONFLICT DO NOTHING RETURNING * INTO r;
              WHEN action = 'ignore'::text AND constraint_name is NOT NULL THEN
                EXECUTE 'INSERT INTO "public"."user" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO NOTHING RETURNING *' INTO r USING NEW;
              ELSE
                EXECUTE 'INSERT INTO "public"."user" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO UPDATE ' || set_expression || ' RETURNING *' INTO r USING NEW;
            END CASE;
            ELSE
              RAISE internal_error using message = 'action is not found'; RETURN NULL;
          END IF;
      END CASE;
      IF r IS NULL THEN RETURN null; ELSE RETURN r; END IF;
     ELSE RAISE check_violation using message = 'insert check constraint failed'; RETURN NULL;
     END IF;
  END $_$;


ALTER FUNCTION hdb_views.jwt_server__insert__public__user() OWNER TO collectanddo;

--
-- Name: user__insert__public__event(); Type: FUNCTION; Schema: hdb_views; Owner: collectanddo
--

CREATE FUNCTION hdb_views.user__insert__public__event() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
  DECLARE r "public"."event"%ROWTYPE;
  DECLARE conflict_clause jsonb;
  DECLARE action text;
  DECLARE constraint_name text;
  DECLARE set_expression text;
  BEGIN
    conflict_clause = current_setting('hasura.conflict_clause')::jsonb;
    IF (((((NEW."user_id") = (((current_setting('hasura.user')::json->>'x-hasura-user-id'))::integer)) OR (((NEW."user_id") IS NULL) AND ((((current_setting('hasura.user')::json->>'x-hasura-user-id'))::integer) IS NULL))) AND ('true')) AND ('true')) THEN
      CASE
        WHEN conflict_clause = 'null'::jsonb THEN INSERT INTO "public"."event" VALUES (NEW.*) RETURNING * INTO r;
        ELSE
          action = conflict_clause ->> 'action';
          constraint_name = quote_ident(conflict_clause ->> 'constraint');
          set_expression = conflict_clause ->> 'set_expression';
          IF action is NOT NULL THEN
            CASE
              WHEN action = 'ignore'::text AND constraint_name IS NULL THEN
                INSERT INTO "public"."event" VALUES (NEW.*) ON CONFLICT DO NOTHING RETURNING * INTO r;
              WHEN action = 'ignore'::text AND constraint_name is NOT NULL THEN
                EXECUTE 'INSERT INTO "public"."event" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO NOTHING RETURNING *' INTO r USING NEW;
              ELSE
                EXECUTE 'INSERT INTO "public"."event" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO UPDATE ' || set_expression || ' RETURNING *' INTO r USING NEW;
            END CASE;
            ELSE
              RAISE internal_error using message = 'action is not found'; RETURN NULL;
          END IF;
      END CASE;
      IF r IS NULL THEN RETURN null; ELSE RETURN r; END IF;
     ELSE RAISE check_violation using message = 'insert check constraint failed'; RETURN NULL;
     END IF;
  END $_$;


ALTER FUNCTION hdb_views.user__insert__public__event() OWNER TO collectanddo;

--
-- Name: user__insert__public__group(); Type: FUNCTION; Schema: hdb_views; Owner: collectanddo
--

CREATE FUNCTION hdb_views.user__insert__public__group() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
  DECLARE r "public"."group"%ROWTYPE;
  DECLARE conflict_clause jsonb;
  DECLARE action text;
  DECLARE constraint_name text;
  DECLARE set_expression text;
  BEGIN
    conflict_clause = current_setting('hasura.conflict_clause')::jsonb;
    IF (((((NEW."user_id") = (((current_setting('hasura.user')::json->>'x-hasura-user-id'))::integer)) OR (((NEW."user_id") IS NULL) AND ((((current_setting('hasura.user')::json->>'x-hasura-user-id'))::integer) IS NULL))) AND ('true')) AND ('true')) THEN
      CASE
        WHEN conflict_clause = 'null'::jsonb THEN INSERT INTO "public"."group" VALUES (NEW.*) RETURNING * INTO r;
        ELSE
          action = conflict_clause ->> 'action';
          constraint_name = quote_ident(conflict_clause ->> 'constraint');
          set_expression = conflict_clause ->> 'set_expression';
          IF action is NOT NULL THEN
            CASE
              WHEN action = 'ignore'::text AND constraint_name IS NULL THEN
                INSERT INTO "public"."group" VALUES (NEW.*) ON CONFLICT DO NOTHING RETURNING * INTO r;
              WHEN action = 'ignore'::text AND constraint_name is NOT NULL THEN
                EXECUTE 'INSERT INTO "public"."group" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO NOTHING RETURNING *' INTO r USING NEW;
              ELSE
                EXECUTE 'INSERT INTO "public"."group" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO UPDATE ' || set_expression || ' RETURNING *' INTO r USING NEW;
            END CASE;
            ELSE
              RAISE internal_error using message = 'action is not found'; RETURN NULL;
          END IF;
      END CASE;
      IF r IS NULL THEN RETURN null; ELSE RETURN r; END IF;
     ELSE RAISE check_violation using message = 'insert check constraint failed'; RETURN NULL;
     END IF;
  END $_$;


ALTER FUNCTION hdb_views.user__insert__public__group() OWNER TO collectanddo;

--
-- Name: user__insert__public__rel_todo_group(); Type: FUNCTION; Schema: hdb_views; Owner: collectanddo
--

CREATE FUNCTION hdb_views.user__insert__public__rel_todo_group() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
  DECLARE r "public"."rel_todo_group"%ROWTYPE;
  DECLARE conflict_clause jsonb;
  DECLARE action text;
  DECLARE constraint_name text;
  DECLARE set_expression text;
  BEGIN
    conflict_clause = current_setting('hasura.conflict_clause')::jsonb;
    IF ('true') THEN
      CASE
        WHEN conflict_clause = 'null'::jsonb THEN INSERT INTO "public"."rel_todo_group" VALUES (NEW.*) RETURNING * INTO r;
        ELSE
          action = conflict_clause ->> 'action';
          constraint_name = quote_ident(conflict_clause ->> 'constraint');
          set_expression = conflict_clause ->> 'set_expression';
          IF action is NOT NULL THEN
            CASE
              WHEN action = 'ignore'::text AND constraint_name IS NULL THEN
                INSERT INTO "public"."rel_todo_group" VALUES (NEW.*) ON CONFLICT DO NOTHING RETURNING * INTO r;
              WHEN action = 'ignore'::text AND constraint_name is NOT NULL THEN
                EXECUTE 'INSERT INTO "public"."rel_todo_group" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO NOTHING RETURNING *' INTO r USING NEW;
              ELSE
                EXECUTE 'INSERT INTO "public"."rel_todo_group" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO UPDATE ' || set_expression || ' RETURNING *' INTO r USING NEW;
            END CASE;
            ELSE
              RAISE internal_error using message = 'action is not found'; RETURN NULL;
          END IF;
      END CASE;
      IF r IS NULL THEN RETURN null; ELSE RETURN r; END IF;
     ELSE RAISE check_violation using message = 'insert check constraint failed'; RETURN NULL;
     END IF;
  END $_$;


ALTER FUNCTION hdb_views.user__insert__public__rel_todo_group() OWNER TO collectanddo;

--
-- Name: user__insert__public__todo(); Type: FUNCTION; Schema: hdb_views; Owner: collectanddo
--

CREATE FUNCTION hdb_views.user__insert__public__todo() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
  DECLARE r "public"."todo"%ROWTYPE;
  DECLARE conflict_clause jsonb;
  DECLARE action text;
  DECLARE constraint_name text;
  DECLARE set_expression text;
  BEGIN
    conflict_clause = current_setting('hasura.conflict_clause')::jsonb;
    IF (((((NEW."user_id") = (((current_setting('hasura.user')::json->>'x-hasura-user-id'))::integer)) OR (((NEW."user_id") IS NULL) AND ((((current_setting('hasura.user')::json->>'x-hasura-user-id'))::integer) IS NULL))) AND ('true')) AND ('true')) THEN
      CASE
        WHEN conflict_clause = 'null'::jsonb THEN INSERT INTO "public"."todo" VALUES (NEW.*) RETURNING * INTO r;
        ELSE
          action = conflict_clause ->> 'action';
          constraint_name = quote_ident(conflict_clause ->> 'constraint');
          set_expression = conflict_clause ->> 'set_expression';
          IF action is NOT NULL THEN
            CASE
              WHEN action = 'ignore'::text AND constraint_name IS NULL THEN
                INSERT INTO "public"."todo" VALUES (NEW.*) ON CONFLICT DO NOTHING RETURNING * INTO r;
              WHEN action = 'ignore'::text AND constraint_name is NOT NULL THEN
                EXECUTE 'INSERT INTO "public"."todo" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO NOTHING RETURNING *' INTO r USING NEW;
              ELSE
                EXECUTE 'INSERT INTO "public"."todo" VALUES ($1.*) ON CONFLICT ON CONSTRAINT ' || constraint_name ||
                           ' DO UPDATE ' || set_expression || ' RETURNING *' INTO r USING NEW;
            END CASE;
            ELSE
              RAISE internal_error using message = 'action is not found'; RETURN NULL;
          END IF;
      END CASE;
      IF r IS NULL THEN RETURN null; ELSE RETURN r; END IF;
     ELSE RAISE check_violation using message = 'insert check constraint failed'; RETURN NULL;
     END IF;
  END $_$;


ALTER FUNCTION hdb_views.user__insert__public__todo() OWNER TO collectanddo;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: event_invocation_logs; Type: TABLE; Schema: hdb_catalog; Owner: collectanddo
--

CREATE TABLE hdb_catalog.event_invocation_logs (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    event_id text,
    status integer,
    request json,
    response json,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE hdb_catalog.event_invocation_logs OWNER TO collectanddo;

--
-- Name: event_log; Type: TABLE; Schema: hdb_catalog; Owner: collectanddo
--

CREATE TABLE hdb_catalog.event_log (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    trigger_id text NOT NULL,
    trigger_name text NOT NULL,
    payload jsonb NOT NULL,
    delivered boolean DEFAULT false NOT NULL,
    error boolean DEFAULT false NOT NULL,
    tries integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    locked boolean DEFAULT false NOT NULL,
    next_retry_at timestamp without time zone
);


ALTER TABLE hdb_catalog.event_log OWNER TO collectanddo;

--
-- Name: event_triggers; Type: TABLE; Schema: hdb_catalog; Owner: collectanddo
--

CREATE TABLE hdb_catalog.event_triggers (
    id text DEFAULT public.gen_random_uuid() NOT NULL,
    name text,
    type text NOT NULL,
    schema_name text NOT NULL,
    table_name text NOT NULL,
    configuration json,
    comment text
);


ALTER TABLE hdb_catalog.event_triggers OWNER TO collectanddo;

--
-- Name: hdb_check_constraint; Type: VIEW; Schema: hdb_catalog; Owner: collectanddo
--

CREATE VIEW hdb_catalog.hdb_check_constraint AS
 SELECT (n.nspname)::text AS table_schema,
    (ct.relname)::text AS table_name,
    (r.conname)::text AS constraint_name,
    pg_get_constraintdef(r.oid, true) AS "check"
   FROM ((pg_constraint r
     JOIN pg_class ct ON ((r.conrelid = ct.oid)))
     JOIN pg_namespace n ON ((ct.relnamespace = n.oid)))
  WHERE (r.contype = 'c'::"char");


ALTER TABLE hdb_catalog.hdb_check_constraint OWNER TO collectanddo;

--
-- Name: hdb_foreign_key_constraint; Type: VIEW; Schema: hdb_catalog; Owner: collectanddo
--

CREATE VIEW hdb_catalog.hdb_foreign_key_constraint AS
 SELECT (q.table_schema)::text AS table_schema,
    (q.table_name)::text AS table_name,
    (q.constraint_name)::text AS constraint_name,
    (min(q.constraint_oid))::integer AS constraint_oid,
    min((q.ref_table_table_schema)::text) AS ref_table_table_schema,
    min((q.ref_table)::text) AS ref_table,
    json_object_agg(ac.attname, afc.attname) AS column_mapping,
    min((q.confupdtype)::text) AS on_update,
    min((q.confdeltype)::text) AS on_delete
   FROM ((( SELECT ctn.nspname AS table_schema,
            ct.relname AS table_name,
            r.conrelid AS table_id,
            r.conname AS constraint_name,
            r.oid AS constraint_oid,
            cftn.nspname AS ref_table_table_schema,
            cft.relname AS ref_table,
            r.confrelid AS ref_table_id,
            r.confupdtype,
            r.confdeltype,
            unnest(r.conkey) AS column_id,
            unnest(r.confkey) AS ref_column_id
           FROM ((((pg_constraint r
             JOIN pg_class ct ON ((r.conrelid = ct.oid)))
             JOIN pg_namespace ctn ON ((ct.relnamespace = ctn.oid)))
             JOIN pg_class cft ON ((r.confrelid = cft.oid)))
             JOIN pg_namespace cftn ON ((cft.relnamespace = cftn.oid)))
          WHERE (r.contype = 'f'::"char")) q
     JOIN pg_attribute ac ON (((q.column_id = ac.attnum) AND (q.table_id = ac.attrelid))))
     JOIN pg_attribute afc ON (((q.ref_column_id = afc.attnum) AND (q.ref_table_id = afc.attrelid))))
  GROUP BY q.table_schema, q.table_name, q.constraint_name;


ALTER TABLE hdb_catalog.hdb_foreign_key_constraint OWNER TO collectanddo;

--
-- Name: hdb_permission; Type: TABLE; Schema: hdb_catalog; Owner: collectanddo
--

CREATE TABLE hdb_catalog.hdb_permission (
    table_schema text NOT NULL,
    table_name text NOT NULL,
    role_name text NOT NULL,
    perm_type text NOT NULL,
    perm_def jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false,
    CONSTRAINT hdb_permission_perm_type_check CHECK ((perm_type = ANY (ARRAY['insert'::text, 'select'::text, 'update'::text, 'delete'::text])))
);


ALTER TABLE hdb_catalog.hdb_permission OWNER TO collectanddo;

--
-- Name: hdb_permission_agg; Type: VIEW; Schema: hdb_catalog; Owner: collectanddo
--

CREATE VIEW hdb_catalog.hdb_permission_agg AS
 SELECT hdb_permission.table_schema,
    hdb_permission.table_name,
    hdb_permission.role_name,
    json_object_agg(hdb_permission.perm_type, hdb_permission.perm_def) AS permissions
   FROM hdb_catalog.hdb_permission
  GROUP BY hdb_permission.table_schema, hdb_permission.table_name, hdb_permission.role_name;


ALTER TABLE hdb_catalog.hdb_permission_agg OWNER TO collectanddo;

--
-- Name: hdb_primary_key; Type: VIEW; Schema: hdb_catalog; Owner: collectanddo
--

CREATE VIEW hdb_catalog.hdb_primary_key AS
 SELECT tc.table_schema,
    tc.table_name,
    tc.constraint_name,
    json_agg(constraint_column_usage.column_name) AS columns
   FROM (information_schema.table_constraints tc
     JOIN ( SELECT x.tblschema AS table_schema,
            x.tblname AS table_name,
            x.colname AS column_name,
            x.cstrname AS constraint_name
           FROM ( SELECT DISTINCT nr.nspname,
                    r.relname,
                    a.attname,
                    c.conname
                   FROM pg_namespace nr,
                    pg_class r,
                    pg_attribute a,
                    pg_depend d,
                    pg_namespace nc,
                    pg_constraint c
                  WHERE ((nr.oid = r.relnamespace) AND (r.oid = a.attrelid) AND (d.refclassid = ('pg_class'::regclass)::oid) AND (d.refobjid = r.oid) AND (d.refobjsubid = a.attnum) AND (d.classid = ('pg_constraint'::regclass)::oid) AND (d.objid = c.oid) AND (c.connamespace = nc.oid) AND (c.contype = 'c'::"char") AND (r.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])) AND (NOT a.attisdropped))
                UNION ALL
                 SELECT nr.nspname,
                    r.relname,
                    a.attname,
                    c.conname
                   FROM pg_namespace nr,
                    pg_class r,
                    pg_attribute a,
                    pg_namespace nc,
                    pg_constraint c
                  WHERE ((nr.oid = r.relnamespace) AND (r.oid = a.attrelid) AND (nc.oid = c.connamespace) AND (r.oid =
                        CASE c.contype
                            WHEN 'f'::"char" THEN c.confrelid
                            ELSE c.conrelid
                        END) AND (a.attnum = ANY (
                        CASE c.contype
                            WHEN 'f'::"char" THEN c.confkey
                            ELSE c.conkey
                        END)) AND (NOT a.attisdropped) AND (c.contype = ANY (ARRAY['p'::"char", 'u'::"char", 'f'::"char"])) AND (r.relkind = ANY (ARRAY['r'::"char", 'p'::"char"])))) x(tblschema, tblname, colname, cstrname)) constraint_column_usage ON ((((tc.constraint_name)::text = (constraint_column_usage.constraint_name)::text) AND ((tc.table_schema)::text = (constraint_column_usage.table_schema)::text) AND ((tc.table_name)::text = (constraint_column_usage.table_name)::text))))
  WHERE ((tc.constraint_type)::text = 'PRIMARY KEY'::text)
  GROUP BY tc.table_schema, tc.table_name, tc.constraint_name;


ALTER TABLE hdb_catalog.hdb_primary_key OWNER TO collectanddo;

--
-- Name: hdb_query_template; Type: TABLE; Schema: hdb_catalog; Owner: collectanddo
--

CREATE TABLE hdb_catalog.hdb_query_template (
    template_name text NOT NULL,
    template_defn jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false
);


ALTER TABLE hdb_catalog.hdb_query_template OWNER TO collectanddo;

--
-- Name: hdb_relationship; Type: TABLE; Schema: hdb_catalog; Owner: collectanddo
--

CREATE TABLE hdb_catalog.hdb_relationship (
    table_schema text NOT NULL,
    table_name text NOT NULL,
    rel_name text NOT NULL,
    rel_type text,
    rel_def jsonb NOT NULL,
    comment text,
    is_system_defined boolean DEFAULT false,
    CONSTRAINT hdb_relationship_rel_type_check CHECK ((rel_type = ANY (ARRAY['object'::text, 'array'::text])))
);


ALTER TABLE hdb_catalog.hdb_relationship OWNER TO collectanddo;

--
-- Name: hdb_table; Type: TABLE; Schema: hdb_catalog; Owner: collectanddo
--

CREATE TABLE hdb_catalog.hdb_table (
    table_schema text NOT NULL,
    table_name text NOT NULL,
    is_system_defined boolean DEFAULT false
);


ALTER TABLE hdb_catalog.hdb_table OWNER TO collectanddo;

--
-- Name: hdb_unique_constraint; Type: VIEW; Schema: hdb_catalog; Owner: collectanddo
--

CREATE VIEW hdb_catalog.hdb_unique_constraint AS
 SELECT tc.table_name,
    tc.constraint_schema AS table_schema,
    tc.constraint_name,
    json_agg(kcu.column_name) AS columns
   FROM (information_schema.table_constraints tc
     JOIN information_schema.key_column_usage kcu USING (constraint_schema, constraint_name))
  WHERE ((tc.constraint_type)::text = 'UNIQUE'::text)
  GROUP BY tc.table_name, tc.constraint_schema, tc.constraint_name;


ALTER TABLE hdb_catalog.hdb_unique_constraint OWNER TO collectanddo;

--
-- Name: hdb_version; Type: TABLE; Schema: hdb_catalog; Owner: collectanddo
--

CREATE TABLE hdb_catalog.hdb_version (
    version text NOT NULL,
    upgraded_on timestamp with time zone NOT NULL
);


ALTER TABLE hdb_catalog.hdb_version OWNER TO collectanddo;

--
-- Name: remote_schemas; Type: TABLE; Schema: hdb_catalog; Owner: collectanddo
--

CREATE TABLE hdb_catalog.remote_schemas (
    id bigint NOT NULL,
    name text,
    definition json,
    comment text
);


ALTER TABLE hdb_catalog.remote_schemas OWNER TO collectanddo;

--
-- Name: remote_schemas_id_seq; Type: SEQUENCE; Schema: hdb_catalog; Owner: collectanddo
--

CREATE SEQUENCE hdb_catalog.remote_schemas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hdb_catalog.remote_schemas_id_seq OWNER TO collectanddo;

--
-- Name: remote_schemas_id_seq; Type: SEQUENCE OWNED BY; Schema: hdb_catalog; Owner: collectanddo
--

ALTER SEQUENCE hdb_catalog.remote_schemas_id_seq OWNED BY hdb_catalog.remote_schemas.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: collectanddo
--

CREATE TABLE public."user" (
    id integer NOT NULL,
    name text NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public."user" OWNER TO collectanddo;

--
-- Name: jwt_server__insert__public__user; Type: VIEW; Schema: hdb_views; Owner: collectanddo
--

CREATE VIEW hdb_views.jwt_server__insert__public__user AS
 SELECT "user".id,
    "user".name,
    "user".created,
    "user".updated
   FROM public."user";


ALTER TABLE hdb_views.jwt_server__insert__public__user OWNER TO collectanddo;

--
-- Name: event; Type: TABLE; Schema: public; Owner: collectanddo
--

CREATE TABLE public.event (
    id integer NOT NULL,
    title text,
    content text,
    start timestamp with time zone NOT NULL,
    "end" timestamp with time zone NOT NULL,
    group_id integer NOT NULL,
    user_id integer DEFAULT 1 NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.event OWNER TO collectanddo;

--
-- Name: user__insert__public__event; Type: VIEW; Schema: hdb_views; Owner: collectanddo
--

CREATE VIEW hdb_views.user__insert__public__event AS
 SELECT event.id,
    event.title,
    event.content,
    event.start,
    event."end",
    event.group_id,
    event.user_id,
    event.created,
    event.updated
   FROM public.event;


ALTER TABLE hdb_views.user__insert__public__event OWNER TO collectanddo;

--
-- Name: group; Type: TABLE; Schema: public; Owner: collectanddo
--

CREATE TABLE public."group" (
    id integer NOT NULL,
    title text NOT NULL,
    content text,
    color text,
    user_id integer DEFAULT 1 NOT NULL,
    created timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public."group" OWNER TO collectanddo;

--
-- Name: user__insert__public__group; Type: VIEW; Schema: hdb_views; Owner: collectanddo
--

CREATE VIEW hdb_views.user__insert__public__group AS
 SELECT "group".id,
    "group".title,
    "group".content,
    "group".color,
    "group".user_id,
    "group".created,
    "group".updated
   FROM public."group";


ALTER TABLE hdb_views.user__insert__public__group OWNER TO collectanddo;

--
-- Name: rel_todo_group; Type: TABLE; Schema: public; Owner: collectanddo
--

CREATE TABLE public.rel_todo_group (
    id integer NOT NULL,
    todo_id integer NOT NULL,
    group_id integer NOT NULL
);


ALTER TABLE public.rel_todo_group OWNER TO collectanddo;

--
-- Name: user__insert__public__rel_todo_group; Type: VIEW; Schema: hdb_views; Owner: collectanddo
--

CREATE VIEW hdb_views.user__insert__public__rel_todo_group AS
 SELECT rel_todo_group.id,
    rel_todo_group.todo_id,
    rel_todo_group.group_id
   FROM public.rel_todo_group;


ALTER TABLE hdb_views.user__insert__public__rel_todo_group OWNER TO collectanddo;

--
-- Name: todo; Type: TABLE; Schema: public; Owner: collectanddo
--

CREATE TABLE public.todo (
    id integer NOT NULL,
    title text NOT NULL,
    content text,
    url text,
    done boolean DEFAULT false NOT NULL,
    user_id integer DEFAULT 1 NOT NULL,
    event_id integer,
    created timestamp with time zone DEFAULT now() NOT NULL,
    updated timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.todo OWNER TO collectanddo;

--
-- Name: user__insert__public__todo; Type: VIEW; Schema: hdb_views; Owner: collectanddo
--

CREATE VIEW hdb_views.user__insert__public__todo AS
 SELECT todo.id,
    todo.title,
    todo.content,
    todo.url,
    todo.done,
    todo.user_id,
    todo.event_id,
    todo.created,
    todo.updated
   FROM public.todo;


ALTER TABLE hdb_views.user__insert__public__todo OWNER TO collectanddo;

--
-- Name: event_id_seq; Type: SEQUENCE; Schema: public; Owner: collectanddo
--

CREATE SEQUENCE public.event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_id_seq OWNER TO collectanddo;

--
-- Name: event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: collectanddo
--

ALTER SEQUENCE public.event_id_seq OWNED BY public.event.id;


--
-- Name: group_id_seq; Type: SEQUENCE; Schema: public; Owner: collectanddo
--

CREATE SEQUENCE public.group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.group_id_seq OWNER TO collectanddo;

--
-- Name: group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: collectanddo
--

ALTER SEQUENCE public.group_id_seq OWNED BY public."group".id;


--
-- Name: rel_todo_group_id_seq; Type: SEQUENCE; Schema: public; Owner: collectanddo
--

CREATE SEQUENCE public.rel_todo_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.rel_todo_group_id_seq OWNER TO collectanddo;

--
-- Name: rel_todo_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: collectanddo
--

ALTER SEQUENCE public.rel_todo_group_id_seq OWNED BY public.rel_todo_group.id;


--
-- Name: todo_id_seq; Type: SEQUENCE; Schema: public; Owner: collectanddo
--

CREATE SEQUENCE public.todo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.todo_id_seq OWNER TO collectanddo;

--
-- Name: todo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: collectanddo
--

ALTER SEQUENCE public.todo_id_seq OWNED BY public.todo.id;


--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: collectanddo
--

CREATE SEQUENCE public.user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO collectanddo;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: collectanddo
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: remote_schemas id; Type: DEFAULT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.remote_schemas ALTER COLUMN id SET DEFAULT nextval('hdb_catalog.remote_schemas_id_seq'::regclass);


--
-- Name: jwt_server__insert__public__user id; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.jwt_server__insert__public__user ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Name: jwt_server__insert__public__user created; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.jwt_server__insert__public__user ALTER COLUMN created SET DEFAULT now();


--
-- Name: jwt_server__insert__public__user updated; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.jwt_server__insert__public__user ALTER COLUMN updated SET DEFAULT now();


--
-- Name: user__insert__public__event id; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__event ALTER COLUMN id SET DEFAULT nextval('public.event_id_seq'::regclass);


--
-- Name: user__insert__public__event user_id; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__event ALTER COLUMN user_id SET DEFAULT 1;


--
-- Name: user__insert__public__event created; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__event ALTER COLUMN created SET DEFAULT now();


--
-- Name: user__insert__public__event updated; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__event ALTER COLUMN updated SET DEFAULT now();


--
-- Name: user__insert__public__group id; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__group ALTER COLUMN id SET DEFAULT nextval('public.group_id_seq'::regclass);


--
-- Name: user__insert__public__group user_id; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__group ALTER COLUMN user_id SET DEFAULT 1;


--
-- Name: user__insert__public__group created; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__group ALTER COLUMN created SET DEFAULT now();


--
-- Name: user__insert__public__group updated; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__group ALTER COLUMN updated SET DEFAULT now();


--
-- Name: user__insert__public__rel_todo_group id; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__rel_todo_group ALTER COLUMN id SET DEFAULT nextval('public.rel_todo_group_id_seq'::regclass);


--
-- Name: user__insert__public__todo id; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__todo ALTER COLUMN id SET DEFAULT nextval('public.todo_id_seq'::regclass);


--
-- Name: user__insert__public__todo done; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__todo ALTER COLUMN done SET DEFAULT false;


--
-- Name: user__insert__public__todo user_id; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__todo ALTER COLUMN user_id SET DEFAULT 1;


--
-- Name: user__insert__public__todo created; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__todo ALTER COLUMN created SET DEFAULT now();


--
-- Name: user__insert__public__todo updated; Type: DEFAULT; Schema: hdb_views; Owner: collectanddo
--

ALTER TABLE ONLY hdb_views.user__insert__public__todo ALTER COLUMN updated SET DEFAULT now();


--
-- Name: event id; Type: DEFAULT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public.event ALTER COLUMN id SET DEFAULT nextval('public.event_id_seq'::regclass);


--
-- Name: group id; Type: DEFAULT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public."group" ALTER COLUMN id SET DEFAULT nextval('public.group_id_seq'::regclass);


--
-- Name: rel_todo_group id; Type: DEFAULT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public.rel_todo_group ALTER COLUMN id SET DEFAULT nextval('public.rel_todo_group_id_seq'::regclass);


--
-- Name: todo id; Type: DEFAULT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public.todo ALTER COLUMN id SET DEFAULT nextval('public.todo_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Data for Name: event_invocation_logs; Type: TABLE DATA; Schema: hdb_catalog; Owner: collectanddo
--

COPY hdb_catalog.event_invocation_logs (id, event_id, status, request, response, created_at) FROM stdin;
\.


--
-- Data for Name: event_log; Type: TABLE DATA; Schema: hdb_catalog; Owner: collectanddo
--

COPY hdb_catalog.event_log (id, schema_name, table_name, trigger_id, trigger_name, payload, delivered, error, tries, created_at, locked, next_retry_at) FROM stdin;
\.


--
-- Data for Name: event_triggers; Type: TABLE DATA; Schema: hdb_catalog; Owner: collectanddo
--

COPY hdb_catalog.event_triggers (id, name, type, schema_name, table_name, configuration, comment) FROM stdin;
\.


--
-- Data for Name: hdb_permission; Type: TABLE DATA; Schema: hdb_catalog; Owner: collectanddo
--

COPY hdb_catalog.hdb_permission (table_schema, table_name, role_name, perm_type, perm_def, comment, is_system_defined) FROM stdin;
public	rel_todo_group	user	insert	{"set": {}, "check": {}, "columns": ["group_id", "id", "todo_id"]}	\N	f
public	rel_todo_group	user	select	{"filter": {}, "columns": ["todo_id", "group_id", "id"], "allow_aggregations": true}	\N	f
public	rel_todo_group	user	update	{"filter": {}, "columns": ["group_id", "id", "todo_id"]}	\N	f
public	rel_todo_group	user	delete	{"filter": {}}	\N	f
public	event	user	insert	{"set": {"user_id": "x-hasura-USER-ID"}, "check": {"user_id": {"_eq": "X-HASURA-USER-ID"}}, "columns": ["id", "title", "content", "start", "end", "group_id", "user_id", "created", "updated"]}	\N	f
public	event	user	select	{"filter": {"user_id": {"_eq": "X-HASURA-USER-ID"}}, "columns": ["content", "created", "end", "group_id", "id", "start", "title", "updated", "user_id"], "allow_aggregations": true}	\N	f
public	event	user	update	{"filter": {"user_id": {"_eq": "X-HASURA-USER-ID"}}, "columns": ["content", "end", "group_id", "start", "title", "updated", "user_id"]}	\N	f
public	event	user	delete	{"filter": {"user_id": {"_eq": "X-HASURA-USER-ID"}}}	\N	f
public	user	jwt_server	insert	{"set": {}, "check": {}, "columns": ["name"]}	\N	f
public	user	user	select	{"filter": {"id": {"_eq": "X-HASURA-USER-ID"}}, "columns": ["id", "name", "created", "updated"], "allow_aggregations": true}	\N	f
public	user	jwt_server	select	{"filter": {}, "columns": ["id"], "allow_aggregations": false}	\N	f
public	user	user	update	{"filter": {"id": {"_eq": "X-HASURA-USER-ID"}}, "columns": ["name", "updated"]}	\N	f
public	user	user	delete	{"filter": {"id": {"_eq": "X-HASURA-USER-ID"}}}	\N	f
public	group	user	insert	{"set": {"user_id": "x-hasura-USER-ID"}, "check": {"user_id": {"_eq": "X-HASURA-USER-ID"}}, "columns": ["color", "content", "created", "id", "title", "updated"]}	\N	f
public	group	user	select	{"filter": {"user_id": {"_eq": "X-HASURA-USER-ID"}}, "columns": ["color", "content", "created", "id", "title", "updated", "user_id"], "allow_aggregations": true}	\N	f
public	group	user	update	{"filter": {"user_id": {"_eq": "X-HASURA-USER-ID"}}, "columns": ["color", "content", "title", "updated", "user_id"]}	\N	f
public	group	user	delete	{"filter": {"user_id": {"_eq": "X-HASURA-USER-ID"}}}	\N	f
public	todo	user	insert	{"set": {"user_id": "x-hasura-USER-ID"}, "check": {"user_id": {"_eq": "X-HASURA-USER-ID"}}, "columns": ["id", "title", "content", "url", "done", "user_id", "event_id", "created", "updated"]}	\N	f
public	todo	user	select	{"filter": {"user_id": {"_eq": "X-HASURA-USER-ID"}}, "columns": ["content", "created", "done", "event_id", "id", "title", "updated", "url", "user_id"], "allow_aggregations": true}	\N	f
public	todo	user	update	{"filter": {"user_id": {"_eq": "X-HASURA-USER-ID"}}, "columns": ["content", "done", "event_id", "title", "updated", "url", "user_id"]}	\N	f
public	todo	user	delete	{"filter": {"user_id": {"_eq": "X-HASURA-USER-ID"}}}	\N	f
\.


--
-- Data for Name: hdb_query_template; Type: TABLE DATA; Schema: hdb_catalog; Owner: collectanddo
--

COPY hdb_catalog.hdb_query_template (template_name, template_defn, comment, is_system_defined) FROM stdin;
\.


--
-- Data for Name: hdb_relationship; Type: TABLE DATA; Schema: hdb_catalog; Owner: collectanddo
--

COPY hdb_catalog.hdb_relationship (table_schema, table_name, rel_name, rel_type, rel_def, comment, is_system_defined) FROM stdin;
hdb_catalog	hdb_table	detail	object	{"manual_configuration": {"remote_table": {"name": "tables", "schema": "information_schema"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	primary_key	object	{"manual_configuration": {"remote_table": {"name": "hdb_primary_key", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	columns	array	{"manual_configuration": {"remote_table": {"name": "columns", "schema": "information_schema"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	foreign_key_constraints	array	{"manual_configuration": {"remote_table": {"name": "hdb_foreign_key_constraint", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	relationships	array	{"manual_configuration": {"remote_table": {"name": "hdb_relationship", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	permissions	array	{"manual_configuration": {"remote_table": {"name": "hdb_permission_agg", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	check_constraints	array	{"manual_configuration": {"remote_table": {"name": "hdb_check_constraint", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	hdb_table	unique_constraints	array	{"manual_configuration": {"remote_table": {"name": "hdb_unique_constraint", "schema": "hdb_catalog"}, "column_mapping": {"table_name": "table_name", "table_schema": "table_schema"}}}	\N	t
hdb_catalog	event_log	trigger	object	{"manual_configuration": {"remote_table": {"name": "event_triggers", "schema": "hdb_catalog"}, "column_mapping": {"trigger_id": "id"}}}	\N	t
hdb_catalog	event_triggers	events	array	{"manual_configuration": {"remote_table": {"name": "event_log", "schema": "hdb_catalog"}, "column_mapping": {"id": "trigger_id"}}}	\N	t
hdb_catalog	event_invocation_logs	event	object	{"foreign_key_constraint_on": "event_id"}	\N	t
hdb_catalog	event_log	logs	array	{"foreign_key_constraint_on": {"table": {"name": "event_invocation_logs", "schema": "hdb_catalog"}, "column": "event_id"}}	\N	t
public	rel_todo_group	group	object	{"foreign_key_constraint_on": "group_id"}	\N	f
public	rel_todo_group	todo	object	{"foreign_key_constraint_on": "todo_id"}	\N	f
public	event	group	object	{"foreign_key_constraint_on": "group_id"}	\N	f
public	event	done_todos	array	{"foreign_key_constraint_on": {"table": "todo", "column": "event_id"}}	\N	f
public	group	group_todos	array	{"foreign_key_constraint_on": {"table": "rel_todo_group", "column": "group_id"}}	\N	f
public	group	events	array	{"foreign_key_constraint_on": {"table": "event", "column": "group_id"}}	\N	f
public	todo	event	object	{"foreign_key_constraint_on": "event_id"}	\N	f
public	todo	todo_groups	array	{"foreign_key_constraint_on": {"table": "rel_todo_group", "column": "todo_id"}}	\N	f
\.


--
-- Data for Name: hdb_table; Type: TABLE DATA; Schema: hdb_catalog; Owner: collectanddo
--

COPY hdb_catalog.hdb_table (table_schema, table_name, is_system_defined) FROM stdin;
hdb_catalog	hdb_table	t
information_schema	tables	t
information_schema	schemata	t
information_schema	views	t
hdb_catalog	hdb_primary_key	t
information_schema	columns	t
hdb_catalog	hdb_foreign_key_constraint	t
hdb_catalog	hdb_relationship	t
hdb_catalog	hdb_permission_agg	t
hdb_catalog	hdb_check_constraint	t
hdb_catalog	hdb_unique_constraint	t
hdb_catalog	hdb_query_template	t
hdb_catalog	event_triggers	t
hdb_catalog	event_log	t
hdb_catalog	event_invocation_logs	t
hdb_catalog	remote_schemas	t
public	rel_todo_group	f
public	event	f
public	user	f
public	group	f
public	todo	f
\.


--
-- Data for Name: hdb_version; Type: TABLE DATA; Schema: hdb_catalog; Owner: collectanddo
--

COPY hdb_catalog.hdb_version (version, upgraded_on) FROM stdin;
7	2019-01-07 18:15:55.332506+00
\.


--
-- Data for Name: remote_schemas; Type: TABLE DATA; Schema: hdb_catalog; Owner: collectanddo
--

COPY hdb_catalog.remote_schemas (id, name, definition, comment) FROM stdin;
\.


--
-- Data for Name: event; Type: TABLE DATA; Schema: public; Owner: collectanddo
--

COPY public.event (id, title, content, start, "end", group_id, user_id, created, updated) FROM stdin;
\.


--
-- Data for Name: group; Type: TABLE DATA; Schema: public; Owner: collectanddo
--

COPY public."group" (id, title, content, color, user_id, created, updated) FROM stdin;
\.


--
-- Data for Name: rel_todo_group; Type: TABLE DATA; Schema: public; Owner: collectanddo
--

COPY public.rel_todo_group (id, todo_id, group_id) FROM stdin;
\.


--
-- Data for Name: todo; Type: TABLE DATA; Schema: public; Owner: collectanddo
--

COPY public.todo (id, title, content, url, done, user_id, event_id, created, updated) FROM stdin;
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: collectanddo
--

COPY public."user" (id, name, created, updated) FROM stdin;
1	admin	2019-01-12 15:09:57.546431+00	2019-01-12 15:09:57.546431+00
\.


--
-- Name: remote_schemas_id_seq; Type: SEQUENCE SET; Schema: hdb_catalog; Owner: collectanddo
--

SELECT pg_catalog.setval('hdb_catalog.remote_schemas_id_seq', 1, false);


--
-- Name: event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: collectanddo
--

SELECT pg_catalog.setval('public.event_id_seq', 1, false);


--
-- Name: group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: collectanddo
--

SELECT pg_catalog.setval('public.group_id_seq', 1, false);


--
-- Name: rel_todo_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: collectanddo
--

SELECT pg_catalog.setval('public.rel_todo_group_id_seq', 1, false);


--
-- Name: todo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: collectanddo
--

SELECT pg_catalog.setval('public.todo_id_seq', 4, true);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: collectanddo
--

SELECT pg_catalog.setval('public.user_id_seq', 1, true);


--
-- Name: event_invocation_logs event_invocation_logs_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.event_invocation_logs
    ADD CONSTRAINT event_invocation_logs_pkey PRIMARY KEY (id);


--
-- Name: event_log event_log_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.event_log
    ADD CONSTRAINT event_log_pkey PRIMARY KEY (id);


--
-- Name: event_triggers event_triggers_name_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.event_triggers
    ADD CONSTRAINT event_triggers_name_key UNIQUE (name);


--
-- Name: event_triggers event_triggers_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.event_triggers
    ADD CONSTRAINT event_triggers_pkey PRIMARY KEY (id);


--
-- Name: hdb_permission hdb_permission_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.hdb_permission
    ADD CONSTRAINT hdb_permission_pkey PRIMARY KEY (table_schema, table_name, role_name, perm_type);


--
-- Name: hdb_query_template hdb_query_template_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.hdb_query_template
    ADD CONSTRAINT hdb_query_template_pkey PRIMARY KEY (template_name);


--
-- Name: hdb_relationship hdb_relationship_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.hdb_relationship
    ADD CONSTRAINT hdb_relationship_pkey PRIMARY KEY (table_schema, table_name, rel_name);


--
-- Name: hdb_table hdb_table_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.hdb_table
    ADD CONSTRAINT hdb_table_pkey PRIMARY KEY (table_schema, table_name);


--
-- Name: remote_schemas remote_schemas_name_key; Type: CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.remote_schemas
    ADD CONSTRAINT remote_schemas_name_key UNIQUE (name);


--
-- Name: remote_schemas remote_schemas_pkey; Type: CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.remote_schemas
    ADD CONSTRAINT remote_schemas_pkey PRIMARY KEY (id);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: group group_pkey; Type: CONSTRAINT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT group_pkey PRIMARY KEY (id);


--
-- Name: rel_todo_group rel_todo_group_pkey; Type: CONSTRAINT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public.rel_todo_group
    ADD CONSTRAINT rel_todo_group_pkey PRIMARY KEY (id);


--
-- Name: todo todo_pkey; Type: CONSTRAINT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public.todo
    ADD CONSTRAINT todo_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: event_invocation_logs_event_id_idx; Type: INDEX; Schema: hdb_catalog; Owner: collectanddo
--

CREATE INDEX event_invocation_logs_event_id_idx ON hdb_catalog.event_invocation_logs USING btree (event_id);


--
-- Name: event_log_trigger_id_idx; Type: INDEX; Schema: hdb_catalog; Owner: collectanddo
--

CREATE INDEX event_log_trigger_id_idx ON hdb_catalog.event_log USING btree (trigger_id);


--
-- Name: hdb_version_one_row; Type: INDEX; Schema: hdb_catalog; Owner: collectanddo
--

CREATE UNIQUE INDEX hdb_version_one_row ON hdb_catalog.hdb_version USING btree (((version IS NOT NULL)));


--
-- Name: hdb_table hdb_table_oid_check; Type: TRIGGER; Schema: hdb_catalog; Owner: collectanddo
--

CREATE TRIGGER hdb_table_oid_check BEFORE INSERT OR UPDATE ON hdb_catalog.hdb_table FOR EACH ROW EXECUTE PROCEDURE hdb_catalog.hdb_table_oid_check();


--
-- Name: jwt_server__insert__public__user jwt_server__insert__public__user; Type: TRIGGER; Schema: hdb_views; Owner: collectanddo
--

CREATE TRIGGER jwt_server__insert__public__user INSTEAD OF INSERT ON hdb_views.jwt_server__insert__public__user FOR EACH ROW EXECUTE PROCEDURE hdb_views.jwt_server__insert__public__user();


--
-- Name: user__insert__public__event user__insert__public__event; Type: TRIGGER; Schema: hdb_views; Owner: collectanddo
--

CREATE TRIGGER user__insert__public__event INSTEAD OF INSERT ON hdb_views.user__insert__public__event FOR EACH ROW EXECUTE PROCEDURE hdb_views.user__insert__public__event();


--
-- Name: user__insert__public__group user__insert__public__group; Type: TRIGGER; Schema: hdb_views; Owner: collectanddo
--

CREATE TRIGGER user__insert__public__group INSTEAD OF INSERT ON hdb_views.user__insert__public__group FOR EACH ROW EXECUTE PROCEDURE hdb_views.user__insert__public__group();


--
-- Name: user__insert__public__rel_todo_group user__insert__public__rel_todo_group; Type: TRIGGER; Schema: hdb_views; Owner: collectanddo
--

CREATE TRIGGER user__insert__public__rel_todo_group INSTEAD OF INSERT ON hdb_views.user__insert__public__rel_todo_group FOR EACH ROW EXECUTE PROCEDURE hdb_views.user__insert__public__rel_todo_group();


--
-- Name: user__insert__public__todo user__insert__public__todo; Type: TRIGGER; Schema: hdb_views; Owner: collectanddo
--

CREATE TRIGGER user__insert__public__todo INSTEAD OF INSERT ON hdb_views.user__insert__public__todo FOR EACH ROW EXECUTE PROCEDURE hdb_views.user__insert__public__todo();


--
-- Name: event_invocation_logs event_invocation_logs_event_id_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.event_invocation_logs
    ADD CONSTRAINT event_invocation_logs_event_id_fkey FOREIGN KEY (event_id) REFERENCES hdb_catalog.event_log(id);


--
-- Name: hdb_permission hdb_permission_table_schema_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.hdb_permission
    ADD CONSTRAINT hdb_permission_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name);


--
-- Name: hdb_relationship hdb_relationship_table_schema_fkey; Type: FK CONSTRAINT; Schema: hdb_catalog; Owner: collectanddo
--

ALTER TABLE ONLY hdb_catalog.hdb_relationship
    ADD CONSTRAINT hdb_relationship_table_schema_fkey FOREIGN KEY (table_schema, table_name) REFERENCES hdb_catalog.hdb_table(table_schema, table_name);


--
-- Name: event event_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_group_id_fkey FOREIGN KEY (group_id) REFERENCES public."group"(id);


--
-- Name: event event_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: group group_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public."group"
    ADD CONSTRAINT group_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- Name: rel_todo_group rel_todo_group_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public.rel_todo_group
    ADD CONSTRAINT rel_todo_group_group_id_fkey FOREIGN KEY (group_id) REFERENCES public."group"(id);


--
-- Name: rel_todo_group rel_todo_group_todo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public.rel_todo_group
    ADD CONSTRAINT rel_todo_group_todo_id_fkey FOREIGN KEY (todo_id) REFERENCES public.todo(id);


--
-- Name: todo todo_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public.todo
    ADD CONSTRAINT todo_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.event(id);


--
-- Name: todo todo_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: collectanddo
--

ALTER TABLE ONLY public.todo
    ADD CONSTRAINT todo_user_id_fkey FOREIGN KEY (user_id) REFERENCES public."user"(id);


--
-- PostgreSQL database dump complete
--

