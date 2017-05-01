--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accounts (
    id integer NOT NULL,
    username character varying DEFAULT ''::character varying NOT NULL,
    domain character varying,
    secret character varying DEFAULT ''::character varying NOT NULL,
    private_key text,
    public_key text DEFAULT ''::text NOT NULL,
    remote_url character varying DEFAULT ''::character varying NOT NULL,
    salmon_url character varying DEFAULT ''::character varying NOT NULL,
    hub_url character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    display_name character varying DEFAULT ''::character varying NOT NULL,
    uri character varying DEFAULT ''::character varying NOT NULL,
    url character varying,
    avatar_file_name character varying,
    avatar_content_type character varying,
    avatar_file_size integer,
    avatar_updated_at timestamp without time zone,
    header_file_name character varying,
    header_content_type character varying,
    header_file_size integer,
    header_updated_at timestamp without time zone,
    avatar_remote_url character varying,
    subscription_expires_at timestamp without time zone,
    silenced boolean DEFAULT false NOT NULL,
    suspended boolean DEFAULT false NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    header_remote_url character varying DEFAULT ''::character varying NOT NULL,
    statuses_count integer DEFAULT 0 NOT NULL,
    followers_count integer DEFAULT 0 NOT NULL,
    following_count integer DEFAULT 0 NOT NULL,
    last_webfingered_at timestamp without time zone
);


--
-- Name: accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accounts_id_seq OWNED BY accounts.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: block_mutes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE block_mutes (
    account_id integer NOT NULL,
    target_account_id integer NOT NULL,
    block boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: blocks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE blocks (
    id integer NOT NULL,
    account_id integer,
    target_account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    block boolean DEFAULT true,
    CONSTRAINT check_blocks_on_block CHECK ((block = true))
)
INHERITS (block_mutes);


--
-- Name: blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE blocks_id_seq OWNED BY blocks.id;


--
-- Name: domain_blocks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE domain_blocks (
    id integer NOT NULL,
    domain character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    severity integer DEFAULT 0,
    reject_media boolean
);


--
-- Name: domain_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE domain_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domain_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE domain_blocks_id_seq OWNED BY domain_blocks.id;


--
-- Name: favourites; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE favourites (
    id integer NOT NULL,
    account_id integer NOT NULL,
    status_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: favourites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE favourites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favourites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE favourites_id_seq OWNED BY favourites.id;


--
-- Name: follow_requests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE follow_requests (
    id integer NOT NULL,
    account_id integer NOT NULL,
    target_account_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: follow_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE follow_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: follow_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE follow_requests_id_seq OWNED BY follow_requests.id;


--
-- Name: follows; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE follows (
    id integer NOT NULL,
    account_id integer NOT NULL,
    target_account_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: follows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE follows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: follows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE follows_id_seq OWNED BY follows.id;


--
-- Name: imports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE imports (
    id integer NOT NULL,
    account_id integer NOT NULL,
    type integer NOT NULL,
    approved boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data_file_name character varying,
    data_content_type character varying,
    data_file_size integer,
    data_updated_at timestamp without time zone
);


--
-- Name: imports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE imports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: imports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE imports_id_seq OWNED BY imports.id;


--
-- Name: media_attachments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE media_attachments (
    id integer NOT NULL,
    status_id bigint,
    file_file_name character varying,
    file_content_type character varying,
    file_file_size integer,
    file_updated_at timestamp without time zone,
    remote_url character varying DEFAULT ''::character varying NOT NULL,
    account_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    shortcode character varying,
    type integer DEFAULT 0 NOT NULL,
    file_meta json
);


--
-- Name: media_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE media_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: media_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE media_attachments_id_seq OWNED BY media_attachments.id;


--
-- Name: mentions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mentions (
    id integer NOT NULL,
    account_id integer,
    status_id bigint,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: mentions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mentions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mentions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mentions_id_seq OWNED BY mentions.id;


--
-- Name: mutes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mutes (
    id integer NOT NULL,
    account_id integer,
    target_account_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    block boolean DEFAULT false,
    CONSTRAINT check_mutes_on_block CHECK ((block = false))
)
INHERITS (block_mutes);


--
-- Name: mutes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mutes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mutes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mutes_id_seq OWNED BY mutes.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE notifications (
    id integer NOT NULL,
    account_id integer,
    activity_id bigint,
    activity_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    from_account_id integer
);


--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notifications_id_seq OWNED BY notifications.id;


--
-- Name: oauth_access_grants; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_access_grants (
    id integer NOT NULL,
    resource_owner_id integer NOT NULL,
    application_id integer NOT NULL,
    token character varying NOT NULL,
    expires_in integer NOT NULL,
    redirect_uri text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone,
    scopes character varying
);


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_access_grants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_grants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_access_grants_id_seq OWNED BY oauth_access_grants.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_access_tokens (
    id integer NOT NULL,
    resource_owner_id integer,
    application_id integer,
    token character varying NOT NULL,
    refresh_token character varying,
    expires_in integer,
    revoked_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    scopes character varying
);


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_access_tokens_id_seq OWNED BY oauth_access_tokens.id;


--
-- Name: oauth_applications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE oauth_applications (
    id integer NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    secret character varying NOT NULL,
    redirect_uri text NOT NULL,
    scopes character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    superapp boolean DEFAULT false NOT NULL,
    website character varying
);


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE oauth_applications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oauth_applications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE oauth_applications_id_seq OWNED BY oauth_applications.id;


--
-- Name: preview_cards; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE preview_cards (
    id integer NOT NULL,
    status_id bigint,
    url character varying DEFAULT ''::character varying NOT NULL,
    title character varying,
    description character varying,
    image_file_name character varying,
    image_content_type character varying,
    image_file_size integer,
    image_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    type integer DEFAULT 0 NOT NULL,
    html text DEFAULT ''::text NOT NULL,
    author_name character varying DEFAULT ''::character varying NOT NULL,
    author_url character varying DEFAULT ''::character varying NOT NULL,
    provider_name character varying DEFAULT ''::character varying NOT NULL,
    provider_url character varying DEFAULT ''::character varying NOT NULL,
    width integer DEFAULT 0 NOT NULL,
    height integer DEFAULT 0 NOT NULL
);


--
-- Name: preview_cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE preview_cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: preview_cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE preview_cards_id_seq OWNED BY preview_cards.id;


--
-- Name: reports; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reports (
    id integer NOT NULL,
    account_id integer NOT NULL,
    target_account_id integer NOT NULL,
    status_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    comment text DEFAULT ''::text NOT NULL,
    action_taken boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    action_taken_by_account_id integer
);


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_id_seq OWNED BY reports.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE settings (
    id integer NOT NULL,
    var character varying NOT NULL,
    value text,
    thing_type character varying,
    thing_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE settings_id_seq OWNED BY settings.id;


--
-- Name: statuses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE statuses (
    id bigint NOT NULL,
    uri character varying,
    account_id integer NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    in_reply_to_id bigint,
    reblog_of_id bigint,
    url character varying,
    sensitive boolean DEFAULT false,
    visibility integer DEFAULT 0 NOT NULL,
    in_reply_to_account_id integer,
    application_id integer,
    spoiler_text text DEFAULT ''::text NOT NULL,
    reply boolean DEFAULT false,
    favourites_count integer DEFAULT 0 NOT NULL,
    reblogs_count integer DEFAULT 0 NOT NULL,
    language character varying DEFAULT 'en'::character varying NOT NULL
);


--
-- Name: statuses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE statuses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE statuses_id_seq OWNED BY statuses.id;


--
-- Name: statuses_tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE statuses_tags (
    status_id bigint NOT NULL,
    tag_id integer NOT NULL
);


--
-- Name: stream_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stream_entries (
    id integer NOT NULL,
    account_id integer,
    activity_id bigint,
    activity_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    hidden boolean DEFAULT false NOT NULL
);


--
-- Name: stream_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stream_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stream_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stream_entries_id_seq OWNED BY stream_entries.id;


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subscriptions (
    id integer NOT NULL,
    callback_url character varying DEFAULT ''::character varying NOT NULL,
    secret character varying,
    expires_at timestamp without time zone,
    confirmed boolean DEFAULT false NOT NULL,
    account_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_successful_delivery_at timestamp without time zone
);


--
-- Name: subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subscriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subscriptions_id_seq OWNED BY subscriptions.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    account_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    admin boolean DEFAULT false,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    locale character varying,
    encrypted_otp_secret character varying,
    encrypted_otp_secret_iv character varying,
    encrypted_otp_secret_salt character varying,
    consumed_timestep integer,
    otp_required_for_login boolean,
    last_emailed_at timestamp without time zone,
    otp_backup_codes character varying[],
    allowed_languages character varying[] DEFAULT '{}'::character varying[] NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: web_settings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_settings (
    id integer NOT NULL,
    user_id integer,
    data json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: web_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_settings_id_seq OWNED BY web_settings.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accounts ALTER COLUMN id SET DEFAULT nextval('accounts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY blocks ALTER COLUMN id SET DEFAULT nextval('blocks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY domain_blocks ALTER COLUMN id SET DEFAULT nextval('domain_blocks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY favourites ALTER COLUMN id SET DEFAULT nextval('favourites_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY follow_requests ALTER COLUMN id SET DEFAULT nextval('follow_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY follows ALTER COLUMN id SET DEFAULT nextval('follows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY imports ALTER COLUMN id SET DEFAULT nextval('imports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY media_attachments ALTER COLUMN id SET DEFAULT nextval('media_attachments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mentions ALTER COLUMN id SET DEFAULT nextval('mentions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY mutes ALTER COLUMN id SET DEFAULT nextval('mutes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_grants ALTER COLUMN id SET DEFAULT nextval('oauth_access_grants_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_access_tokens ALTER COLUMN id SET DEFAULT nextval('oauth_access_tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY oauth_applications ALTER COLUMN id SET DEFAULT nextval('oauth_applications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY preview_cards ALTER COLUMN id SET DEFAULT nextval('preview_cards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reports ALTER COLUMN id SET DEFAULT nextval('reports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY statuses ALTER COLUMN id SET DEFAULT nextval('statuses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stream_entries ALTER COLUMN id SET DEFAULT nextval('stream_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subscriptions ALTER COLUMN id SET DEFAULT nextval('subscriptions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_settings ALTER COLUMN id SET DEFAULT nextval('web_settings_id_seq'::regclass);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (id);


--
-- Name: domain_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY domain_blocks
    ADD CONSTRAINT domain_blocks_pkey PRIMARY KEY (id);


--
-- Name: favourites_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY favourites
    ADD CONSTRAINT favourites_pkey PRIMARY KEY (id);


--
-- Name: follow_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY follow_requests
    ADD CONSTRAINT follow_requests_pkey PRIMARY KEY (id);


--
-- Name: follows_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY follows
    ADD CONSTRAINT follows_pkey PRIMARY KEY (id);


--
-- Name: imports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY imports
    ADD CONSTRAINT imports_pkey PRIMARY KEY (id);


--
-- Name: media_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY media_attachments
    ADD CONSTRAINT media_attachments_pkey PRIMARY KEY (id);


--
-- Name: mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mentions
    ADD CONSTRAINT mentions_pkey PRIMARY KEY (id);


--
-- Name: mutes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mutes
    ADD CONSTRAINT mutes_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_grants_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_grants
    ADD CONSTRAINT oauth_access_grants_pkey PRIMARY KEY (id);


--
-- Name: oauth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_access_tokens
    ADD CONSTRAINT oauth_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: oauth_applications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY oauth_applications
    ADD CONSTRAINT oauth_applications_pkey PRIMARY KEY (id);


--
-- Name: preview_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY preview_cards
    ADD CONSTRAINT preview_cards_pkey PRIMARY KEY (id);


--
-- Name: reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY statuses
    ADD CONSTRAINT statuses_pkey PRIMARY KEY (id);


--
-- Name: stream_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stream_entries
    ADD CONSTRAINT stream_entries_pkey PRIMARY KEY (id);


--
-- Name: subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: web_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_settings
    ADD CONSTRAINT web_settings_pkey PRIMARY KEY (id);


--
-- Name: account_activity; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX account_activity ON notifications USING btree (account_id, activity_id, activity_type);


--
-- Name: hashtag_search_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX hashtag_search_index ON tags USING gin (to_tsvector('simple'::regconfig, (name)::text));


--
-- Name: index_accounts_on_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_url ON accounts USING btree (url);


--
-- Name: index_accounts_on_username_and_domain; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_accounts_on_username_and_domain ON accounts USING btree (username, domain);


--
-- Name: index_accounts_on_username_and_domain_lower; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_accounts_on_username_and_domain_lower ON accounts USING btree (lower((username)::text), lower((domain)::text));


--
-- Name: index_blocks_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_blocks_on_account_id_and_target_account_id ON blocks USING btree (account_id, target_account_id);


--
-- Name: index_domain_blocks_on_domain; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_domain_blocks_on_domain ON domain_blocks USING btree (domain);


--
-- Name: index_favourites_on_account_id_and_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_favourites_on_account_id_and_status_id ON favourites USING btree (account_id, status_id);


--
-- Name: index_favourites_on_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_favourites_on_status_id ON favourites USING btree (status_id);


--
-- Name: index_follow_requests_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_follow_requests_on_account_id_and_target_account_id ON follow_requests USING btree (account_id, target_account_id);


--
-- Name: index_follows_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_follows_on_account_id_and_target_account_id ON follows USING btree (account_id, target_account_id);


--
-- Name: index_media_attachments_on_shortcode; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_media_attachments_on_shortcode ON media_attachments USING btree (shortcode);


--
-- Name: index_media_attachments_on_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_media_attachments_on_status_id ON media_attachments USING btree (status_id);


--
-- Name: index_mentions_on_account_id_and_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_mentions_on_account_id_and_status_id ON mentions USING btree (account_id, status_id);


--
-- Name: index_mentions_on_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_mentions_on_status_id ON mentions USING btree (status_id);


--
-- Name: index_mutes_on_account_id_and_target_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_mutes_on_account_id_and_target_account_id ON mutes USING btree (account_id, target_account_id);


--
-- Name: index_notifications_on_activity_id_and_activity_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_notifications_on_activity_id_and_activity_type ON notifications USING btree (activity_id, activity_type);


--
-- Name: index_oauth_access_grants_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_grants_on_token ON oauth_access_grants USING btree (token);


--
-- Name: index_oauth_access_tokens_on_refresh_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_refresh_token ON oauth_access_tokens USING btree (refresh_token);


--
-- Name: index_oauth_access_tokens_on_resource_owner_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_oauth_access_tokens_on_resource_owner_id ON oauth_access_tokens USING btree (resource_owner_id);


--
-- Name: index_oauth_access_tokens_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_access_tokens_on_token ON oauth_access_tokens USING btree (token);


--
-- Name: index_oauth_applications_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_oauth_applications_on_uid ON oauth_applications USING btree (uid);


--
-- Name: index_preview_cards_on_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_preview_cards_on_status_id ON preview_cards USING btree (status_id);


--
-- Name: index_reports_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_on_account_id ON reports USING btree (account_id);


--
-- Name: index_reports_on_target_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_reports_on_target_account_id ON reports USING btree (target_account_id);


--
-- Name: index_settings_on_thing_type_and_thing_id_and_var; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_settings_on_thing_type_and_thing_id_and_var ON settings USING btree (thing_type, thing_id, var);


--
-- Name: index_statuses_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_statuses_on_account_id ON statuses USING btree (account_id);


--
-- Name: index_statuses_on_in_reply_to_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_statuses_on_in_reply_to_id ON statuses USING btree (in_reply_to_id);


--
-- Name: index_statuses_on_reblog_of_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_statuses_on_reblog_of_id ON statuses USING btree (reblog_of_id);


--
-- Name: index_statuses_on_uri; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_statuses_on_uri ON statuses USING btree (uri);


--
-- Name: index_statuses_tags_on_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_statuses_tags_on_status_id ON statuses_tags USING btree (status_id);


--
-- Name: index_statuses_tags_on_tag_id_and_status_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_statuses_tags_on_tag_id_and_status_id ON statuses_tags USING btree (tag_id, status_id);


--
-- Name: index_stream_entries_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stream_entries_on_account_id ON stream_entries USING btree (account_id);


--
-- Name: index_stream_entries_on_activity_id_and_activity_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_stream_entries_on_activity_id_and_activity_type ON stream_entries USING btree (activity_id, activity_type);


--
-- Name: index_subscriptions_on_account_id_and_callback_url; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_subscriptions_on_account_id_and_callback_url ON subscriptions USING btree (account_id, callback_url);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_tags_on_name ON tags USING btree (name);


--
-- Name: index_users_on_account_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_account_id ON users USING btree (account_id);


--
-- Name: index_users_on_allowed_languages; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_allowed_languages ON users USING gin (allowed_languages);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: index_web_settings_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_web_settings_on_user_id ON web_settings USING btree (user_id);


--
-- Name: search_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX search_index ON accounts USING gin ((((setweight(to_tsvector('simple'::regconfig, (display_name)::text), 'A'::"char") || setweight(to_tsvector('simple'::regconfig, (username)::text), 'B'::"char")) || setweight(to_tsvector('simple'::regconfig, (COALESCE(domain, ''::character varying))::text), 'C'::"char"))));


--
-- Name: fk_rails_256483a9ab; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY statuses
    ADD CONSTRAINT fk_rails_256483a9ab FOREIGN KEY (reblog_of_id) REFERENCES statuses(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO "schema_migrations" (version) VALUES
('20160220174730'),
('20160220211917'),
('20160221003140'),
('20160221003621'),
('20160222122600'),
('20160222143943'),
('20160223162837'),
('20160223164502'),
('20160223165723'),
('20160223165855'),
('20160223171800'),
('20160224223247'),
('20160227230233'),
('20160305115639'),
('20160306172223'),
('20160312193225'),
('20160314164231'),
('20160316103650'),
('20160322193748'),
('20160325130944'),
('20160826155805'),
('20160905150353'),
('20160919221059'),
('20160920003904'),
('20160926213048'),
('20161003142332'),
('20161003145426'),
('20161006213403'),
('20161009120834'),
('20161027172456'),
('20161104173623'),
('20161105130633'),
('20161116162355'),
('20161119211120'),
('20161122163057'),
('20161123093447'),
('20161128103007'),
('20161130142058'),
('20161130185319'),
('20161202132159'),
('20161203164520'),
('20161205214545'),
('20161221152630'),
('20161222201034'),
('20161222204147'),
('20170105224407'),
('20170109120109'),
('20170112154826'),
('20170114194937'),
('20170114203041'),
('20170119214911'),
('20170123162658'),
('20170123203248'),
('20170125145934'),
('20170127165745'),
('20170129000348'),
('20170205175257'),
('20170209184350'),
('20170214110202'),
('20170217012631'),
('20170301222600'),
('20170303212857'),
('20170304202101'),
('20170317193015'),
('20170318214217'),
('20170322021028'),
('20170322143850'),
('20170322162804'),
('20170330021336'),
('20170330163835'),
('20170330164118'),
('20170403172249'),
('20170405112956'),
('20170406215816'),
('20170409170753'),
('20170414080609'),
('20170414132105'),
('20170418160728'),
('20170423005413'),
('20170424112722'),
('20170425131920'),
('20170425202925'),
('20170507141759'),
('20170508000000');


