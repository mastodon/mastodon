import { apiRequestGet } from 'mastodon/api';
import type {
  ApiTermsOfServiceJSON,
  ApiPrivacyPolicyJSON,
  ApiInstanceJSON,
  ApiExtendedDescriptionJSON,
  ApiTranslationLanguagesJSON,
  ApiDomainBlockJSON,
} from 'mastodon/api_types/instance';

export const apiGetTermsOfService = (version?: string) =>
  apiRequestGet<ApiTermsOfServiceJSON>(
    version
      ? `v1/instance/terms_of_service/${version}`
      : 'v1/instance/terms_of_service',
  );

export const apiGetPrivacyPolicy = () =>
  apiRequestGet<ApiPrivacyPolicyJSON>('v1/instance/privacy_policy');

export const apiGetInstance = () =>
  apiRequestGet<ApiInstanceJSON>('v2/instance');

export const apiGetExtendedDescription = () =>
  apiRequestGet<ApiExtendedDescriptionJSON>('v1/instance/extended_description');

export const apiGetTranslationLanguages = () =>
  apiRequestGet<ApiTranslationLanguagesJSON>(
    'v1/instance/translation_languages',
  );

export const apiGetDomainBlocks = () =>
  apiRequestGet<ApiDomainBlockJSON[]>('v1/instance/domain_blocks');
