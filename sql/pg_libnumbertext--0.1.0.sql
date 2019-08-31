-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pg_libnumbertext" to load this file. \quit

--
-- Phone number type
--

CREATE TYPE phone_number;

CREATE FUNCTION numbertext(text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS 'pg_libnumbertext', 'numbertext';
