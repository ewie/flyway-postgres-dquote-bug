--
-- PostgreSQL database dump
--

-- Dumped from database version 13.4 (Debian 13.4-1.pgdg100+1)
-- Dumped by pg_dump version 13.4 (Debian 13.4-1.pgdg100+1)

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: "my_table; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."""my_table" (
    id integer NOT NULL
);


ALTER TABLE public."""my_table" OWNER TO postgres;

--
-- Name: "my_table_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."""my_table_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."""my_table_id_seq" OWNER TO postgres;

--
-- Name: "my_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."""my_table_id_seq" OWNED BY public."""my_table".id;


--
-- Name: "my_table id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."""my_table" ALTER COLUMN id SET DEFAULT nextval('public."""my_table_id_seq"'::regclass);


--
-- Data for Name: "my_table; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."""my_table" (id) FROM stdin;
\.


--
-- Name: "my_table_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."""my_table_id_seq"', 1, false);


--
-- PostgreSQL database dump complete
--

