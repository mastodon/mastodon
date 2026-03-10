import type { ReactNode } from 'react';
import { createContext, useContext, useMemo, useState } from 'react';

import type { ApiCollectionJSON } from '@/mastodon/api_types/collections';

export interface CollectionEditorState {
  id: string | undefined;
  name: string;
  setName: React.Dispatch<React.SetStateAction<string>>;
  description: string;
  setDescription: React.Dispatch<React.SetStateAction<string>>;
  topic: string;
  setTopic: React.Dispatch<React.SetStateAction<string>>;
  language: string | null;
  setLanguage: React.Dispatch<React.SetStateAction<string | null>>;
  discoverable: boolean;
  setDiscoverable: React.Dispatch<React.SetStateAction<boolean>>;
  sensitive: boolean;
  setSensitive: React.Dispatch<React.SetStateAction<boolean>>;
  accountIds: string[];
  setAccountIds: React.Dispatch<React.SetStateAction<string[]>>;
}

const CollectionEditorStateContext =
  createContext<CollectionEditorState | null>(null);

export function useCollectionEditorState() {
  const state = useContext(CollectionEditorStateContext);

  if (state === null) {
    throw new Error(
      'useCollectionEditorState hook must be used within CollectionStateProvider',
    );
  }

  return state;
}

const onlyExistingIds = (id?: string): id is string => !!id;

const getCollectionItemIds = (items: ApiCollectionJSON['items']) =>
  items.map((item) => item.account_id).filter(onlyExistingIds);

export const CollectionEditorStateProvider: React.FC<{
  collection: ApiCollectionJSON | undefined;
  children: ReactNode;
}> = ({ collection, children }) => {
  const {
    id,
    name: initialName = '',
    description: initialDescription = '',
    tag: initialTopic,
    language: initialLanguage = '',
    discoverable: initialDiscoverable = true,
    sensitive: initialSensitive = false,
    items = [],
  } = collection ?? {};

  const isEditMode = !!id;

  const [name, setName] = useState(initialName);
  const [description, setDescription] = useState(initialDescription);
  const [topic, setTopic] = useState(initialTopic?.name ?? '');
  const [language, setLanguage] = useState(initialLanguage);
  const [discoverable, setDiscoverable] = useState(initialDiscoverable);
  const [sensitive, setSensitive] = useState(initialSensitive);

  const [addedAccountIds, setAccountIds] = useState<string[]>([]);

  // In edit mode, we're bypassing state and just return collection items directly,
  // since they're edited "live", saving after each addition/deletion
  const accountIds = useMemo(
    () => (isEditMode ? getCollectionItemIds(items) : addedAccountIds),
    [isEditMode, items, addedAccountIds],
  );

  const collectionEditorState = useMemo(
    () => ({
      id,
      name,
      setName,
      description,
      setDescription,
      topic,
      setTopic,
      language,
      setLanguage,
      discoverable,
      setDiscoverable,
      sensitive,
      setSensitive,
      accountIds,
      setAccountIds,
    }),
    [
      accountIds,
      description,
      discoverable,
      id,
      language,
      name,
      sensitive,
      topic,
    ],
  );

  return (
    <CollectionEditorStateContext.Provider value={collectionEditorState}>
      {children}
    </CollectionEditorStateContext.Provider>
  );
};
