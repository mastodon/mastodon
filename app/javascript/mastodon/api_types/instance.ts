import type { ApiAccountJSON } from './accounts';

export interface ApiTermsOfServiceJSON {
  effective_date: string;
  effective: boolean;
  succeeded_by: string | null;
  content: string;
}

export interface ApiPrivacyPolicyJSON {
  updated_at: string;
  content: string;
}

interface ApiBaseRuleJSON {
  text: string;
  hint: string;
}

export interface ApiRuleJSON {
  id: string;
  text: string;
  hint: string;
  translations?: Record<string, ApiBaseRuleJSON>;
}

export interface ApiExtendedDescriptionJSON {
  updated_at: string;
  content: string;
}

export interface ApiDomainBlockJSON {
  domain: string;
  digest: string;
  severity: string;
  comment: string;
}

export type ApiTranslationLanguagesJSON = Record<string, string[]>;

export interface ApiInstanceJSON {
  domain: string;
  title: string;
  version: string;
  source_url: string;
  description: string;
  languages: string[];
  usage: {
    users: {
      active_month: number;
    };
  };
  thumbnail: {
    url: string;
    blurhash?: string;
    description: string;
    versions?: Record<string, string>;
  };
  contact: {
    email: string | null;
    account: ApiAccountJSON | null;
  };
  api_versions: {
    mastodon: number;
  };
  registrations: {
    enabled: boolean;
    approval_required: boolean;
    reason_required: boolean | null;
    message: string | null;
    min_age: string | null;
    url: string | null;
  };
  rules: ApiRuleJSON[];
  configuration: {
    urls: {
      streaming: string;
      status: string | null;
      about: string;
      privacy_policy: string | null;
      terms_of_service: string | null;
    };

    vapid: {
      public_key: string;
    };

    accounts: {
      max_display_name_length: number;
      max_note_length: number;
      max_avatar_description_length: number;
      max_header_description_length: number;
      max_featured_tags: number;
      max_pinned_statuses: number;
      max_profile_fields: number;
      profile_field_name_limit: number;
      profile_field_value_limit: number;
    };

    statuses: {
      max_characters: number;
      max_media_attachments: number;
      characters_reserved_per_url: number;
    };

    media_attachments: {
      description_limit: number;
      image_matrix_limit: number;
      image_size_limit: number;
      supported_mime_types: string[];
      video_frame_rate_limit: number;
      video_matrix_limit: number;
      video_size_limit: number;
    };

    polls: {
      max_options: number;
      max_characters_per_option: number;
      min_expiration: number;
      max_expiration: number;
    };

    translation: {
      enabled: boolean;
    };

    timeline_access: {
      live_feeds: {
        local: string;
        remote: string;
      };

      hashtag_feeds: {
        local: string;
        remote: string;
      };

      trending_link_feeds: {
        local: string;
        remote: string;
      };
    };

    limited_federation: boolean;
  };
}
