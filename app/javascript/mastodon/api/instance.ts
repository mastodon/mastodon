import { apiRequestGet } from 'mastodon/api';
import type {
  ApiTermsOfServiceJSON,
  ApiPrivacyPolicyJSON,
} from 'mastodon/api_types/instance';

export const apiGetTermsOfService = () =>
  apiRequestGet<ApiTermsOfServiceJSON>('v1/instance/terms_of_service');

export const apiGetPrivacyPolicy = () =>
  apiRequestGet<ApiPrivacyPolicyJSON>('v1/instance/privacy_policy');
