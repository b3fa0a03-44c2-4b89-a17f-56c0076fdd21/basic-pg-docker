
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA users;
CREATE SCHEMA utils;
CREATE SCHEMA vendors;

ALTER SCHEMA users OWNER TO master;
ALTER SCHEMA utils OWNER TO master;
ALTER SCHEMA vendors OWNER TO master;

GRANT USAGE ON SCHEMA public TO anon;

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
CREATE EXTENSION IF NOT EXISTS btree_gist WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


CREATE FUNCTION public.generate_id(length integer) RETURNS text
    LANGUAGE sql
    AS $$

  select translate(encode(gen_random_bytes(length), 'base64'), '+/=', '');

$$;


ALTER FUNCTION public.generate_id(length integer) OWNER TO master;


SET default_tablespace = '';

SET default_with_oids = false;


CREATE FUNCTION public.set_modified_on() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare

begin

  new.modified_on = now();

  return new;
end
$$;


ALTER FUNCTION public.set_modified_on() OWNER TO master;

CREATE TABLE users.profile (
    id text DEFAULT public.generate_id(8) NOT NULL,
    email text NOT NULL,
    password text NOT NULL,
    first_name text,
    last_name text,
    created_at timestamp with time zone DEFAULT now(),
    modified_on timestamp with time zone
);


ALTER TABLE users.profile OWNER TO master;
ALTER TABLE ONLY users.profile ADD CONSTRAINT users_pkey PRIMARY KEY (id);
CREATE TRIGGER set_modified_on BEFORE INSERT OR UPDATE ON users.profile FOR EACH ROW EXECUTE PROCEDURE public.set_modified_on();
ALTER TABLE ONLY users.profile ADD CONSTRAINT users_email_key UNIQUE (email);

CREATE TYPE users.role_enum AS ENUM (
    'admin',
    'support',
    'clinician',
    'customer'
);

CREATE TABLE users.roles (
    user_id text NOT NULL,
    role users.role_enum DEFAULT 'customer'::users.role_enum NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    modified_on timestamp with time zone
);


ALTER TABLE users.roles OWNER TO master;

ALTER TABLE ONLY users.roles ADD CONSTRAINT user_id_role_pkey PRIMARY KEY (user_id, role);
CREATE TRIGGER set_modified_on BEFORE INSERT OR UPDATE ON users.roles FOR EACH ROW EXECUTE PROCEDURE public.set_modified_on();
ALTER TABLE ONLY users.roles ADD CONSTRAINT user_id_fkey FOREIGN KEY (user_id) REFERENCES users.profile(id);




-- CREATE TABLE users.magic_tokens (
--     user_id text NOT NULL,
--     created_at timestamp with time zone DEFAULT now() NOT NULL,
--     modified_on timestamp with time zone NOT NULL,
-- -- add more columns here
-- );

-- ALTER TABLE users.magic_tokens OWNER TO master;
-- CREATE TRIGGER set_modified_on BEFORE INSERT OR UPDATE ON private.magic_tokens FOR EACH ROW EXECUTE PROCEDURE public.set_modified_on();

-- ALTER TABLE ONLY users.magic_tokens
--     ADD CONSTRAINT users_magic_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES users.users(id);

-- Add other appropriate indices here
