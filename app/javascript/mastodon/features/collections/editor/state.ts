import type {
  ApiCollectionJSON,
  ApiCreateCollectionPayload,
} from '@/mastodon/api_types/collections';

/**
 * Temporary editor state across creation steps,
 * kept in location state
 */
export type TempCollectionState =
  | Partial<ApiCreateCollectionPayload>
  | undefined;

/**
 * Resolve initial editor state. Temporary location state
 * trumps stored data, otherwise initial values are returned.
 */
export function getCollectionEditorState(
  collection: ApiCollectionJSON | null | undefined,
  locationState: TempCollectionState,
) {
  const {
    id,
    name = '',
    description = '',
    tag,
    language = '',
    discoverable = true,
    sensitive = false,
    items,
  } = collection ?? {};

  const collectionItemIds =
    items?.map((item) => item.account_id).filter(onlyExistingIds) ?? [];

  const initialItemIds = (
    locationState?.account_ids ?? collectionItemIds
  ).filter(onlyExistingIds);

  return {
    id,
    initialItemIds,
    initialName: locationState?.name ?? name,
    initialDescription: locationState?.description ?? description,
    initialTopic: locationState?.tag_name ?? tag?.name ?? '',
    initialLanguage: locationState?.language ?? language,
    initialDiscoverable: locationState?.discoverable ?? discoverable,
    initialSensitive: locationState?.sensitive ?? sensitive,
  };
}

const onlyExistingIds = (id?: string): id is string => !!id;
