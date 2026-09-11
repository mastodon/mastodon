import type {
  ApiInstanceJSON,
  ApiExtendedDescriptionJSON,
  ApiDomainBlockJSON,
} from 'mastodon/api_types/instance';

export type Server = ApiInstanceJSON;

export const createServerFromServerJSON = (obj: ApiInstanceJSON): Server => obj;

export type ExtendedDescription = ApiExtendedDescriptionJSON;

export const createExtendedDescriptionFromServerJSON = (
  obj: ApiExtendedDescriptionJSON,
): ExtendedDescription => obj;

export type DomainBlock = ApiDomainBlockJSON;

export const createDomainBlockFromServerJSON = (
  obj: ApiDomainBlockJSON,
): DomainBlock => obj;
