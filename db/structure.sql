--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
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


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: bot_collaborators; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE bot_collaborators (
    id integer NOT NULL,
    user_id integer NOT NULL,
    bot_id integer NOT NULL,
    collaborator_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    confirmed_at timestamp without time zone
);


--
-- Name: bot_collaborators_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bot_collaborators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bot_collaborators_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bot_collaborators_id_seq OWNED BY bot_collaborators.id;


--
-- Name: bot_instances; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE bot_instances (
    id integer NOT NULL,
    token character varying NOT NULL,
    uid character varying,
    bot_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    provider character varying NOT NULL,
    state character varying DEFAULT 'pending'::character varying NOT NULL,
    instance_attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    CONSTRAINT valid_provider_on_bot_instances CHECK ((((((provider)::text = 'slack'::text) OR ((provider)::text = 'kik'::text)) OR ((provider)::text = 'facebook'::text)) OR ((provider)::text = 'telegram'::text))),
    CONSTRAINT validate_attributes_name CHECK (((((((((instance_attributes ->> 'name'::text) IS NOT NULL) AND (length((instance_attributes ->> 'name'::text)) > 0)) AND ((provider)::text = 'facebook'::text)) AND ((state)::text = 'enabled'::text)) OR (((state)::text = 'pending'::text) AND (instance_attributes IS NOT NULL))) OR (((state)::text = 'disabled'::text) AND (instance_attributes IS NOT NULL))) OR ((provider)::text <> 'facebook'::text)))
);


--
-- Name: bot_instances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bot_instances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bot_instances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bot_instances_id_seq OWNED BY bot_instances.id;


--
-- Name: bot_users; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE bot_users (
    id integer NOT NULL,
    uid character varying NOT NULL,
    user_attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    membership_type character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    bot_instance_id integer NOT NULL,
    provider character varying NOT NULL,
    last_interacted_with_bot_at timestamp without time zone,
    bot_interaction_count integer DEFAULT 0 NOT NULL,
    CONSTRAINT valid_provider_on_bot_users CHECK ((((((provider)::text = 'slack'::text) OR ((provider)::text = 'kik'::text)) OR ((provider)::text = 'facebook'::text)) OR ((provider)::text = 'telegram'::text)))
);


--
-- Name: bot_users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bot_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bot_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bot_users_id_seq OWNED BY bot_users.id;


--
-- Name: bots; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE bots (
    id integer NOT NULL,
    name character varying NOT NULL,
    uid character varying NOT NULL,
    provider character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    webhook_url character varying,
    webhook_status boolean DEFAULT false,
    webhooks_enabled boolean DEFAULT false NOT NULL,
    first_received_event_at timestamp without time zone,
    CONSTRAINT valid_provider_on_bots CHECK ((((((provider)::text = 'slack'::text) OR ((provider)::text = 'kik'::text)) OR ((provider)::text = 'facebook'::text)) OR ((provider)::text = 'telegram'::text)))
);


--
-- Name: bots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bots_id_seq OWNED BY bots.id;


--
-- Name: dashboard_events; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE dashboard_events (
    id integer NOT NULL,
    dashboard_id integer NOT NULL,
    event_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: dashboard_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dashboard_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dashboard_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dashboard_events_id_seq OWNED BY dashboard_events.id;


--
-- Name: dashboards; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE dashboards (
    id integer NOT NULL,
    name character varying NOT NULL,
    provider character varying NOT NULL,
    "default" boolean DEFAULT false NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    uid character varying NOT NULL,
    regex character varying,
    bot_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    dashboard_type character varying NOT NULL,
    CONSTRAINT regex_not_null_when_dashboard_type_custom CHECK (((((dashboard_type)::text = 'custom'::text) AND ((regex IS NOT NULL) AND ((regex)::text <> ''::text))) OR ((dashboard_type)::text <> 'custom'::text))),
    CONSTRAINT valid_dashboard_type_on_dashboards CHECK (((((((provider)::text = 'slack'::text) AND ((((((((dashboard_type)::text = 'bots-installed'::text) OR ((dashboard_type)::text = 'bots-uninstalled'::text)) OR ((dashboard_type)::text = 'new-users'::text)) OR ((dashboard_type)::text = 'messages'::text)) OR ((dashboard_type)::text = 'messages-to-bot'::text)) OR ((dashboard_type)::text = 'messages-from-bot'::text)) OR ((dashboard_type)::text = 'custom'::text))) OR (((provider)::text = 'facebook'::text) AND ((((((((((((dashboard_type)::text = 'new-users'::text) OR ((dashboard_type)::text = 'messages-to-bot'::text)) OR ((dashboard_type)::text = 'messages-from-bot'::text)) OR ((dashboard_type)::text = 'user-actions'::text)) OR ((dashboard_type)::text = 'get-started'::text)) OR ((dashboard_type)::text = 'image-uploaded'::text)) OR ((dashboard_type)::text = 'audio-uploaded'::text)) OR ((dashboard_type)::text = 'video-uploaded'::text)) OR ((dashboard_type)::text = 'file-uploaded'::text)) OR ((dashboard_type)::text = 'location-sent'::text)) OR ((dashboard_type)::text = 'custom'::text)))) OR (((provider)::text = 'kik'::text) AND (((((((((((dashboard_type)::text = 'new-users'::text) OR ((dashboard_type)::text = 'messages-to-bot'::text)) OR ((dashboard_type)::text = 'messages-from-bot'::text)) OR ((dashboard_type)::text = 'image-uploaded'::text)) OR ((dashboard_type)::text = 'link-uploaded'::text)) OR ((dashboard_type)::text = 'video-uploaded'::text)) OR ((dashboard_type)::text = 'scanned-data'::text)) OR ((dashboard_type)::text = 'sticker-uploaded'::text)) OR ((dashboard_type)::text = 'friend-picker-chosen'::text)) OR ((dashboard_type)::text = 'custom'::text)))) OR ((provider)::text = 'telegram'::text))),
    CONSTRAINT valid_provider_on_dashboards CHECK ((((((provider)::text = 'slack'::text) OR ((provider)::text = 'kik'::text)) OR ((provider)::text = 'facebook'::text)) OR ((provider)::text = 'telegram'::text)))
);


--
-- Name: dashboards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE dashboards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dashboards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE dashboards_id_seq OWNED BY dashboards.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE events (
    id integer NOT NULL,
    event_type character varying NOT NULL,
    bot_instance_id integer NOT NULL,
    bot_user_id integer,
    is_for_bot boolean DEFAULT false NOT NULL,
    "boolean" boolean DEFAULT false NOT NULL,
    event_attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    provider character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_im boolean DEFAULT false NOT NULL,
    is_from_bot boolean DEFAULT false NOT NULL,
    text text,
    has_been_delivered boolean DEFAULT false,
    has_been_read boolean DEFAULT false,
    CONSTRAINT valid_event_type_on_events CHECK ((((((event_type)::text = ANY (ARRAY[('user_added'::character varying)::text, ('bot_disabled'::character varying)::text, ('added_to_channel'::character varying)::text, ('message'::character varying)::text, ('message_reaction'::character varying)::text])) AND ((provider)::text = 'slack'::text)) OR ((((event_type)::text = ANY (ARRAY[('message'::character varying)::text, ('messaging_postbacks'::character varying)::text, ('messaging_optins'::character varying)::text, ('account_linking'::character varying)::text])) AND ((provider)::text = 'facebook'::text)) AND (bot_user_id IS NOT NULL))) OR ((((event_type)::text = 'message'::text) AND ((provider)::text = 'kik'::text)) AND (bot_user_id IS NOT NULL)))),
    CONSTRAINT valid_provider_on_events CHECK ((((((provider)::text = 'slack'::text) OR ((provider)::text = 'kik'::text)) OR ((provider)::text = 'facebook'::text)) OR ((provider)::text = 'telegram'::text))),
    CONSTRAINT validate_attributes_channel CHECK ((((((((event_attributes ->> 'channel'::text) IS NOT NULL) AND (length((event_attributes ->> 'channel'::text)) > 0)) AND ((provider)::text = 'slack'::text)) AND (((event_type)::text = 'message'::text) OR ((event_type)::text = 'message_reaction'::text))) OR ((((provider)::text = 'slack'::text) AND (((event_type)::text <> 'message'::text) AND ((event_type)::text <> 'message_reaction'::text))) AND (event_attributes IS NOT NULL))) OR ((provider)::text = ANY (ARRAY[('facebook'::character varying)::text, ('kik'::character varying)::text])))),
    CONSTRAINT validate_attributes_chat_id CHECK (((((((event_attributes ->> 'chat_id'::text) IS NOT NULL) AND (length((event_attributes ->> 'chat_id'::text)) > 0)) AND ((provider)::text = 'kik'::text)) AND ((event_type)::text = 'message'::text)) OR ((provider)::text = ANY (ARRAY[('facebook'::character varying)::text, ('slack'::character varying)::text])))),
    CONSTRAINT validate_attributes_id CHECK (((((((event_attributes ->> 'id'::text) IS NOT NULL) AND (length((event_attributes ->> 'id'::text)) > 0)) AND ((provider)::text = 'kik'::text)) AND ((event_type)::text = 'message'::text)) OR ((provider)::text = ANY (ARRAY[('facebook'::character varying)::text, ('slack'::character varying)::text])))),
    CONSTRAINT validate_attributes_mid CHECK ((((((((event_attributes ->> 'mid'::text) IS NOT NULL) AND (length((event_attributes ->> 'mid'::text)) > 0)) AND ((provider)::text = 'facebook'::text)) AND ((event_type)::text = 'message'::text)) OR ((((provider)::text = 'facebook'::text) AND ((event_type)::text <> 'message'::text)) AND (event_attributes IS NOT NULL))) OR ((provider)::text = ANY (ARRAY[('slack'::character varying)::text, ('kik'::character varying)::text])))),
    CONSTRAINT validate_attributes_reaction CHECK ((((((((event_attributes ->> 'reaction'::text) IS NOT NULL) AND (length((event_attributes ->> 'reaction'::text)) > 0)) AND ((provider)::text = 'slack'::text)) AND ((event_type)::text = 'message_reaction'::text)) OR ((((provider)::text = 'slack'::text) AND ((event_type)::text <> 'message_reaction'::text)) AND (event_attributes IS NOT NULL))) OR ((provider)::text = ANY (ARRAY[('facebook'::character varying)::text, ('kik'::character varying)::text])))),
    CONSTRAINT validate_attributes_seq CHECK ((((((((event_attributes ->> 'seq'::text) IS NOT NULL) AND (length((event_attributes ->> 'seq'::text)) > 0)) AND ((provider)::text = 'facebook'::text)) AND ((event_type)::text = 'message'::text)) OR ((((provider)::text = 'facebook'::text) AND ((event_type)::text <> 'message'::text)) AND (event_attributes IS NOT NULL))) OR ((provider)::text = ANY (ARRAY[('slack'::character varying)::text, ('kik'::character varying)::text])))),
    CONSTRAINT validate_attributes_sub_type CHECK ((((((((event_attributes ->> 'sub_type'::text) IS NOT NULL) AND (length((event_attributes ->> 'sub_type'::text)) > 0)) AND ((event_attributes ->> 'sub_type'::text) = ANY (ARRAY['text'::text, 'link'::text, 'picture'::text, 'video'::text, 'start-chatting'::text, 'scan-data'::text, 'sticker'::text, 'is-typing'::text, 'friend-picker'::text]))) AND ((provider)::text = 'kik'::text)) AND ((event_type)::text = 'message'::text)) OR ((provider)::text = ANY (ARRAY[('facebook'::character varying)::text, ('slack'::character varying)::text])))),
    CONSTRAINT validate_attributes_timestamp CHECK ((((((((event_attributes ->> 'timestamp'::text) IS NOT NULL) AND (length((event_attributes ->> 'timestamp'::text)) > 0)) AND ((provider)::text = 'slack'::text)) AND (((event_type)::text = 'message'::text) OR ((event_type)::text = 'message_reaction'::text))) OR ((((provider)::text = 'slack'::text) AND (((event_type)::text <> 'message'::text) AND ((event_type)::text <> 'message_reaction'::text))) AND (event_attributes IS NOT NULL))) OR ((provider)::text = ANY (ARRAY[('facebook'::character varying)::text, ('kik'::character varying)::text]))))
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: messages; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE messages (
    id integer NOT NULL,
    provider character varying,
    message_attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    text text,
    attachments text,
    bot_instance_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    success boolean DEFAULT false,
    response jsonb DEFAULT '{}'::jsonb,
    notification_id integer,
    scheduled_at timestamp without time zone,
    sent_at timestamp without time zone,
    CONSTRAINT validate_attributes_channel_user CHECK (((((((provider)::text = 'slack'::text) AND ((message_attributes ->> 'channel'::text) IS NOT NULL)) AND (length((message_attributes ->> 'channel'::text)) > 0)) AND ((message_attributes ->> 'user'::text) IS NULL)) OR (((((((provider)::text = 'slack'::text) OR ((provider)::text = 'facebook'::text)) OR ((provider)::text = 'kik'::text)) AND ((message_attributes ->> 'user'::text) IS NOT NULL)) AND (length((message_attributes ->> 'user'::text)) > 0)) AND ((message_attributes ->> 'channel'::text) IS NULL)))),
    CONSTRAINT validate_attributes_team_id CHECK (((((((provider)::text = 'slack'::text) AND ((message_attributes ->> 'team_id'::text) IS NOT NULL)) AND (length((message_attributes ->> 'team_id'::text)) > 0)) OR ((provider)::text = 'facebook'::text)) OR ((provider)::text = 'kik'::text)))
);


--
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE messages_id_seq OWNED BY messages.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE notifications (
    id integer NOT NULL,
    content text NOT NULL,
    bot_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scheduled_at character varying,
    uid character varying NOT NULL,
    recurring boolean DEFAULT false NOT NULL
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
-- Name: queries; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE queries (
    id integer NOT NULL,
    field character varying NOT NULL,
    method character varying NOT NULL,
    value character varying,
    query_set_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    min_value character varying,
    max_value character varying,
    provider character varying NOT NULL,
    CONSTRAINT validate_field CHECK ((((((provider)::text = 'slack'::text) AND (((((((field)::text = 'nickname'::text) OR ((field)::text = 'email'::text)) OR ((field)::text = 'full_name'::text)) OR ((field)::text = 'interaction_count'::text)) OR ((field)::text = 'interacted_at'::text)) OR ((field)::text = 'user_created_at'::text))) OR (((provider)::text = 'facebook'::text) AND (((((((field)::text = 'first_name'::text) OR ((field)::text = 'last_name'::text)) OR ((field)::text = 'gender'::text)) OR ((field)::text = 'interaction_count'::text)) OR ((field)::text = 'interacted_at'::text)) OR ((field)::text = 'user_created_at'::text)))) OR (((provider)::text = 'kik'::text) AND ((((((field)::text = 'first_name'::text) OR ((field)::text = 'last_name'::text)) OR ((field)::text = 'interaction_count'::text)) OR ((field)::text = 'interacted_at'::text)) OR ((field)::text = 'user_created_at'::text))))),
    CONSTRAINT validate_method CHECK (((((((((provider)::text = 'slack'::text) AND ((((field)::text = 'nickname'::text) OR ((field)::text = 'email'::text)) OR ((field)::text = 'full_name'::text))) AND (((method)::text = 'equals_to'::text) OR ((method)::text = 'contains'::text))) OR (((((provider)::text = 'facebook'::text) OR ((provider)::text = 'kik'::text)) AND (((field)::text = 'first_name'::text) OR ((field)::text = 'last_name'::text))) AND (((method)::text = 'equals_to'::text) OR ((method)::text = 'contains'::text)))) OR ((((provider)::text = 'facebook'::text) AND ((field)::text = 'gender'::text)) AND (((method)::text = 'equals_to'::text) OR ((method)::text = 'contains'::text)))) OR ((((((provider)::text = 'slack'::text) OR ((provider)::text = 'facebook'::text)) OR ((provider)::text = 'kik'::text)) AND ((field)::text = 'interaction_count'::text)) AND (((((method)::text = 'equals_to'::text) OR ((method)::text = 'between'::text)) OR ((method)::text = 'greater_than'::text)) OR ((method)::text = 'lesser_than'::text)))) OR ((((((provider)::text = 'slack'::text) OR ((provider)::text = 'facebook'::text)) OR ((provider)::text = 'kik'::text)) AND (((field)::text = 'interacted_at'::text) OR ((field)::text = 'user_created_at'::text))) AND ((((method)::text = 'between'::text) OR ((method)::text = 'greater_than'::text)) OR ((method)::text = 'lesser_than'::text)))))
);


--
-- Name: queries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE queries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: queries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE queries_id_seq OWNED BY queries.id;


--
-- Name: query_sets; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE query_sets (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    notification_id integer,
    instances_scope character varying NOT NULL,
    time_zone character varying NOT NULL,
    bot_id integer
);


--
-- Name: query_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE query_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: query_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE query_sets_id_seq OWNED BY query_sets.id;


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
    key character varying NOT NULL,
    value character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
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
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying NOT NULL,
    encrypted_password character varying NOT NULL,
    first_name character varying,
    last_name character varying,
    full_name character varying,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0 NOT NULL,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip inet,
    last_sign_in_ip inet,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    timezone character varying NOT NULL,
    timezone_utc_offset integer NOT NULL,
    mixpanel_properties jsonb DEFAULT '{}'::jsonb NOT NULL,
    api_key character varying,
    email_preferences jsonb DEFAULT '{}'::jsonb,
    tracking_attributes jsonb DEFAULT '{}'::jsonb,
    invitation_token character varying,
    invitation_created_at timestamp without time zone,
    invitation_sent_at timestamp without time zone,
    invitation_accepted_at timestamp without time zone,
    invitation_limit integer,
    invited_by_id integer,
    invited_by_type character varying,
    signed_up_at timestamp without time zone,
    invited_to_slack_at timestamp without time zone,
    slack_invite_response jsonb,
    site_admin boolean DEFAULT false
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
-- Name: webhook_events; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE webhook_events (
    id integer NOT NULL,
    code integer,
    elapsed_time numeric(15,10) DEFAULT 0.0,
    bot_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb
);


--
-- Name: webhook_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE webhook_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: webhook_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE webhook_events_id_seq OWNED BY webhook_events.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bot_collaborators ALTER COLUMN id SET DEFAULT nextval('bot_collaborators_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bot_instances ALTER COLUMN id SET DEFAULT nextval('bot_instances_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bot_users ALTER COLUMN id SET DEFAULT nextval('bot_users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bots ALTER COLUMN id SET DEFAULT nextval('bots_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dashboard_events ALTER COLUMN id SET DEFAULT nextval('dashboard_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY dashboards ALTER COLUMN id SET DEFAULT nextval('dashboards_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages ALTER COLUMN id SET DEFAULT nextval('messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications ALTER COLUMN id SET DEFAULT nextval('notifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY queries ALTER COLUMN id SET DEFAULT nextval('queries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY query_sets ALTER COLUMN id SET DEFAULT nextval('query_sets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY settings ALTER COLUMN id SET DEFAULT nextval('settings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY webhook_events ALTER COLUMN id SET DEFAULT nextval('webhook_events_id_seq'::regclass);


--
-- Name: bot_collaborators_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY bot_collaborators
    ADD CONSTRAINT bot_collaborators_pkey PRIMARY KEY (id);


--
-- Name: bot_instances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY bot_instances
    ADD CONSTRAINT bot_instances_pkey PRIMARY KEY (id);


--
-- Name: bot_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY bot_users
    ADD CONSTRAINT bot_users_pkey PRIMARY KEY (id);


--
-- Name: bots_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY bots
    ADD CONSTRAINT bots_pkey PRIMARY KEY (id);


--
-- Name: dashboard_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY dashboard_events
    ADD CONSTRAINT dashboard_events_pkey PRIMARY KEY (id);


--
-- Name: dashboards_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY dashboards
    ADD CONSTRAINT dashboards_pkey PRIMARY KEY (id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- Name: notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: queries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY queries
    ADD CONSTRAINT queries_pkey PRIMARY KEY (id);


--
-- Name: query_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY query_sets
    ADD CONSTRAINT query_sets_pkey PRIMARY KEY (id);


--
-- Name: settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webhook_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY webhook_events
    ADD CONSTRAINT webhook_events_pkey PRIMARY KEY (id);


--
-- Name: bot_instances_team_id_uid; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX bot_instances_team_id_uid ON bot_instances USING btree (uid, ((instance_attributes -> 'team_id'::text))) WHERE ((((provider)::text = 'slack'::text) AND ((state)::text = 'enabled'::text)) AND (uid IS NOT NULL));


--
-- Name: events_channel_timestamp_message_slack; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX events_channel_timestamp_message_slack ON events USING btree (((event_attributes -> 'timestamp'::text)), ((event_attributes -> 'channel'::text))) WHERE (((provider)::text = 'slack'::text) AND ((event_type)::text = 'message'::text));


--
-- Name: events_id_kik; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX events_id_kik ON events USING btree (((event_attributes -> 'id'::text))) WHERE (((provider)::text = 'kik'::text) AND ((event_type)::text = 'message'::text));


--
-- Name: events_mid_seq_facebook; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX events_mid_seq_facebook ON events USING btree (((event_attributes -> 'mid'::text)), ((event_attributes -> 'seq'::text))) WHERE (((provider)::text = 'facebook'::text) AND ((event_type)::text = 'message'::text));


--
-- Name: index_bot_collaborators_on_bot_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_bot_collaborators_on_bot_id ON bot_collaborators USING btree (bot_id);


--
-- Name: index_bot_collaborators_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_bot_collaborators_on_user_id ON bot_collaborators USING btree (user_id);


--
-- Name: index_bot_collaborators_on_user_id_and_bot_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_bot_collaborators_on_user_id_and_bot_id ON bot_collaborators USING btree (user_id, bot_id);


--
-- Name: index_bot_instances_on_bot_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_bot_instances_on_bot_id ON bot_instances USING btree (bot_id);


--
-- Name: index_bot_instances_on_token; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_bot_instances_on_token ON bot_instances USING btree (token);


--
-- Name: index_bot_users_on_bot_instance_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_bot_users_on_bot_instance_id ON bot_users USING btree (bot_instance_id);


--
-- Name: index_bot_users_on_uid_and_bot_instance_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_bot_users_on_uid_and_bot_instance_id ON bot_users USING btree (uid, bot_instance_id);


--
-- Name: index_bots_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_bots_on_uid ON bots USING btree (uid);


--
-- Name: index_dashboard_events_on_dashboard_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_dashboard_events_on_dashboard_id ON dashboard_events USING btree (dashboard_id);


--
-- Name: index_dashboard_events_on_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_dashboard_events_on_event_id ON dashboard_events USING btree (event_id);


--
-- Name: index_dashboard_events_on_event_id_and_dashboard_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_dashboard_events_on_event_id_and_dashboard_id ON dashboard_events USING btree (event_id, dashboard_id);


--
-- Name: index_dashboards_on_bot_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_dashboards_on_bot_id ON dashboards USING btree (bot_id);


--
-- Name: index_dashboards_on_name_and_bot_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_dashboards_on_name_and_bot_id ON dashboards USING btree (name, bot_id);


--
-- Name: index_dashboards_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_dashboards_on_uid ON dashboards USING btree (uid);


--
-- Name: index_dashboards_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_dashboards_on_user_id ON dashboards USING btree (user_id);


--
-- Name: index_events_on_bot_instance_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_events_on_bot_instance_id ON events USING btree (bot_instance_id);


--
-- Name: index_events_on_bot_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_events_on_bot_user_id ON events USING btree (bot_user_id);


--
-- Name: index_events_on_event_type; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_events_on_event_type ON events USING btree (event_type);


--
-- Name: index_messages_on_bot_instance_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_messages_on_bot_instance_id ON messages USING btree (bot_instance_id);


--
-- Name: index_messages_on_notification_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_messages_on_notification_id ON messages USING btree (notification_id);


--
-- Name: index_notifications_on_bot_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_notifications_on_bot_id ON notifications USING btree (bot_id);


--
-- Name: index_notifications_on_uid; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_notifications_on_uid ON notifications USING btree (uid);


--
-- Name: index_queries_on_query_set_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_queries_on_query_set_id ON queries USING btree (query_set_id);


--
-- Name: index_query_sets_on_bot_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_query_sets_on_bot_id ON query_sets USING btree (bot_id);


--
-- Name: index_query_sets_on_notification_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_query_sets_on_notification_id ON query_sets USING btree (notification_id);


--
-- Name: index_settings_on_key; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_settings_on_key ON settings USING btree (key);


--
-- Name: index_users_on_api_key; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_users_on_api_key ON users USING btree (api_key) WHERE (api_key IS NOT NULL);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_invitation_token; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_users_on_invitation_token ON users USING btree (invitation_token);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_03b178e1df; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY webhook_events
    ADD CONSTRAINT fk_rails_03b178e1df FOREIGN KEY (bot_id) REFERENCES bots(id) ON DELETE CASCADE;


--
-- Name: fk_rails_6897853d8c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bot_instances
    ADD CONSTRAINT fk_rails_6897853d8c FOREIGN KEY (bot_id) REFERENCES bots(id);


--
-- Name: fk_rails_6931938b29; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notifications
    ADD CONSTRAINT fk_rails_6931938b29 FOREIGN KEY (bot_id) REFERENCES bots(id);


--
-- Name: fk_rails_6e79174e50; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_rails_6e79174e50 FOREIGN KEY (bot_user_id) REFERENCES bot_users(id);


--
-- Name: fk_rails_8c888664b2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bot_collaborators
    ADD CONSTRAINT fk_rails_8c888664b2 FOREIGN KEY (bot_id) REFERENCES bots(id);


--
-- Name: fk_rails_8cb1930a1d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY dashboards
    ADD CONSTRAINT fk_rails_8cb1930a1d FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_9fc3b26d0b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT fk_rails_9fc3b26d0b FOREIGN KEY (bot_instance_id) REFERENCES bot_instances(id);


--
-- Name: fk_rails_cbba591a9a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT fk_rails_cbba591a9a FOREIGN KEY (notification_id) REFERENCES notifications(id);


--
-- Name: fk_rails_d232307517; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bot_users
    ADD CONSTRAINT fk_rails_d232307517 FOREIGN KEY (bot_instance_id) REFERENCES bot_instances(id);


--
-- Name: fk_rails_d9f77fff58; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bot_collaborators
    ADD CONSTRAINT fk_rails_d9f77fff58 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: fk_rails_dbec2a54ad; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY dashboards
    ADD CONSTRAINT fk_rails_dbec2a54ad FOREIGN KEY (bot_id) REFERENCES bots(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20160421235326');

INSERT INTO schema_migrations (version) VALUES ('20160422202903');

INSERT INTO schema_migrations (version) VALUES ('20160422204548');

INSERT INTO schema_migrations (version) VALUES ('20160422225034');

INSERT INTO schema_migrations (version) VALUES ('20160422230945');

INSERT INTO schema_migrations (version) VALUES ('20160422232133');

INSERT INTO schema_migrations (version) VALUES ('20160424150625');

INSERT INTO schema_migrations (version) VALUES ('20160424151249');

INSERT INTO schema_migrations (version) VALUES ('20160424153627');

INSERT INTO schema_migrations (version) VALUES ('20160424154450');

INSERT INTO schema_migrations (version) VALUES ('20160424154957');

INSERT INTO schema_migrations (version) VALUES ('20160424155854');

INSERT INTO schema_migrations (version) VALUES ('20160424161341');

INSERT INTO schema_migrations (version) VALUES ('20160424162744');

INSERT INTO schema_migrations (version) VALUES ('20160424201054');

INSERT INTO schema_migrations (version) VALUES ('20160424222520');

INSERT INTO schema_migrations (version) VALUES ('20160425163211');

INSERT INTO schema_migrations (version) VALUES ('20160425164622');

INSERT INTO schema_migrations (version) VALUES ('20160425212125');

INSERT INTO schema_migrations (version) VALUES ('20160425215210');

INSERT INTO schema_migrations (version) VALUES ('20160425220237');

INSERT INTO schema_migrations (version) VALUES ('20160425223534');

INSERT INTO schema_migrations (version) VALUES ('20160426205144');

INSERT INTO schema_migrations (version) VALUES ('20160426223507');

INSERT INTO schema_migrations (version) VALUES ('20160427035933');

INSERT INTO schema_migrations (version) VALUES ('20160427042824');

INSERT INTO schema_migrations (version) VALUES ('20160427135316');

INSERT INTO schema_migrations (version) VALUES ('20160429171046');

INSERT INTO schema_migrations (version) VALUES ('20160509161456');

INSERT INTO schema_migrations (version) VALUES ('20160509172149');

INSERT INTO schema_migrations (version) VALUES ('20160509173152');

INSERT INTO schema_migrations (version) VALUES ('20160511094756');

INSERT INTO schema_migrations (version) VALUES ('20160511102827');

INSERT INTO schema_migrations (version) VALUES ('20160511104446');

INSERT INTO schema_migrations (version) VALUES ('20160512144506');

INSERT INTO schema_migrations (version) VALUES ('20160516132302');

INSERT INTO schema_migrations (version) VALUES ('20160517081106');

INSERT INTO schema_migrations (version) VALUES ('20160523173810');

INSERT INTO schema_migrations (version) VALUES ('20160524012151');

INSERT INTO schema_migrations (version) VALUES ('20160524092941');

INSERT INTO schema_migrations (version) VALUES ('20160524174311');

INSERT INTO schema_migrations (version) VALUES ('20160525051124');

INSERT INTO schema_migrations (version) VALUES ('20160525051648');

INSERT INTO schema_migrations (version) VALUES ('20160525082031');

INSERT INTO schema_migrations (version) VALUES ('20160525091112');

INSERT INTO schema_migrations (version) VALUES ('20160525102056');

INSERT INTO schema_migrations (version) VALUES ('20160526025128');

INSERT INTO schema_migrations (version) VALUES ('20160527025054');

INSERT INTO schema_migrations (version) VALUES ('20160527030332');

INSERT INTO schema_migrations (version) VALUES ('20160530052718');

INSERT INTO schema_migrations (version) VALUES ('20160601030853');

INSERT INTO schema_migrations (version) VALUES ('20160601031106');

INSERT INTO schema_migrations (version) VALUES ('20160601140725');

INSERT INTO schema_migrations (version) VALUES ('20160603020800');

INSERT INTO schema_migrations (version) VALUES ('20160603142732');

INSERT INTO schema_migrations (version) VALUES ('20160603155423');

INSERT INTO schema_migrations (version) VALUES ('20160603155535');

INSERT INTO schema_migrations (version) VALUES ('20160606041533');

INSERT INTO schema_migrations (version) VALUES ('20160608080843');

INSERT INTO schema_migrations (version) VALUES ('20160608082053');

INSERT INTO schema_migrations (version) VALUES ('20160608085523');

INSERT INTO schema_migrations (version) VALUES ('20160608091950');

INSERT INTO schema_migrations (version) VALUES ('20160608100732');

INSERT INTO schema_migrations (version) VALUES ('20160608110017');

INSERT INTO schema_migrations (version) VALUES ('20160616234620');

INSERT INTO schema_migrations (version) VALUES ('20160620162429');

INSERT INTO schema_migrations (version) VALUES ('20160620213719');

INSERT INTO schema_migrations (version) VALUES ('20160621155032');

INSERT INTO schema_migrations (version) VALUES ('20160622234825');

INSERT INTO schema_migrations (version) VALUES ('20160623000848');

INSERT INTO schema_migrations (version) VALUES ('20160630194618');

INSERT INTO schema_migrations (version) VALUES ('20160630202830');

INSERT INTO schema_migrations (version) VALUES ('20160706164507');

INSERT INTO schema_migrations (version) VALUES ('20160706193135');

INSERT INTO schema_migrations (version) VALUES ('20160802121411');

INSERT INTO schema_migrations (version) VALUES ('20160802123303');

INSERT INTO schema_migrations (version) VALUES ('20160804152603');

INSERT INTO schema_migrations (version) VALUES ('20160805225619');

INSERT INTO schema_migrations (version) VALUES ('20160805231130');

INSERT INTO schema_migrations (version) VALUES ('20160805231725');

INSERT INTO schema_migrations (version) VALUES ('20160808061328');

INSERT INTO schema_migrations (version) VALUES ('20160811171418');

INSERT INTO schema_migrations (version) VALUES ('20160816102343');

INSERT INTO schema_migrations (version) VALUES ('20160816102648');

INSERT INTO schema_migrations (version) VALUES ('20160816103209');

INSERT INTO schema_migrations (version) VALUES ('20160816143700');

INSERT INTO schema_migrations (version) VALUES ('20160818200451');

INSERT INTO schema_migrations (version) VALUES ('20160818202212');

INSERT INTO schema_migrations (version) VALUES ('20160818202734');

INSERT INTO schema_migrations (version) VALUES ('20160818205031');

INSERT INTO schema_migrations (version) VALUES ('20160823044836');

INSERT INTO schema_migrations (version) VALUES ('20160823052121');

INSERT INTO schema_migrations (version) VALUES ('20160823053730');

INSERT INTO schema_migrations (version) VALUES ('20160823214743');

INSERT INTO schema_migrations (version) VALUES ('20160824201210');

INSERT INTO schema_migrations (version) VALUES ('20160829225652');

INSERT INTO schema_migrations (version) VALUES ('20160830132256');

INSERT INTO schema_migrations (version) VALUES ('20160902183523');

INSERT INTO schema_migrations (version) VALUES ('20160902224101');

INSERT INTO schema_migrations (version) VALUES ('20160902234106');

INSERT INTO schema_migrations (version) VALUES ('20160906013944');

INSERT INTO schema_migrations (version) VALUES ('20160906040717');

INSERT INTO schema_migrations (version) VALUES ('20160919061700');

INSERT INTO schema_migrations (version) VALUES ('20160919065157');

INSERT INTO schema_migrations (version) VALUES ('20161004235348');

