import { useRef, useState } from 'react';

import type { Meta, StoryObj } from '@storybook/react-vite';
import { fn } from 'storybook/test';

import { accountFactoryImmutable } from '@/testing/factories';

import { TextArea } from '../form_fields';
import menuClasses from '../menu/styles.module.scss';

import { useAutosuggestMenu } from './hooks';
import { AutosuggestItem } from './items';
import { AutosuggestMenu } from './list';
import type {
  AccountSuggestion,
  EmojiSuggestion,
  HashtagSuggestion,
  Suggestion,
} from './types';

type SuggestTypes = Suggestion['type'];

const suggestionsMap = {
  account: [{ type: 'account', id: '1' }] satisfies AccountSuggestion[],
  emoji: [
    { type: 'emoji', id: '+1', native: '👍' },
    { type: 'emoji', id: '-1', native: '👎' },
    { type: 'emoji', id: 'smile', native: '🙂' },
  ] satisfies EmojiSuggestion[],
  hashtag: [
    { type: 'hashtag', name: 'Testing', id: '1', totalUses: 0 },
    { type: 'hashtag', name: 'Test', id: '2', totalUses: 10 },
  ] satisfies HashtagSuggestion[],
} satisfies Record<SuggestTypes, Suggestion[]>;

const fetchCb = fn().mockName('fetching token');
const selectCb = fn().mockName('selected item');
const clearCb = fn().mockName('cleared suggestions');

const meta = {
  title: 'Redesign/Autosuggest',
  render() {
    const [suggestions, setSuggestions] = useState<Suggestion[]>([]);
    const textareaRef = useRef<HTMLTextAreaElement>(null);

    const { onTextChange, suggestProps, sourceProps } = useAutosuggestMenu({
      suggestions,
      onSelect: selectCb,
      onFetch(token) {
        const newSuggestions = tokenToSuggestions(token);

        fetchCb(token, newSuggestions);
        setSuggestions(newSuggestions);
      },
      onClear() {
        clearCb();
        setSuggestions([]);
      },
    });

    return (
      <div>
        <TextArea {...sourceProps} onChange={onTextChange} ref={textareaRef} />
        <AutosuggestMenu
          {...suggestProps}
          reference={textareaRef.current}
          maxWidth={200}
        />
      </div>
    );
  },
  parameters: {
    state: {
      accounts: {
        '1': accountFactoryImmutable(),
      },
    },
    redesign: true,
  },
} satisfies Meta;

function tokenToSuggestions(token: string) {
  let suggestions: Suggestion[] = [];
  switch (token.charAt(0)) {
    case '@':
      suggestions = suggestionsMap.account;
      break;
    case ':':
      suggestions = suggestionsMap.emoji;
      break;
    case '#':
      suggestions = suggestionsMap.hashtag;
  }
  return suggestions;
}

export default meta;

type Story = StoryObj<typeof meta>;

export const Textarea: Story = {};

export const Static: Story = {
  render() {
    return (
      <div className={menuClasses.card} style={{ width: '300px' }}>
        {Object.values(suggestionsMap)
          .flat()
          .map((suggestion) => (
            <AutosuggestItem
              suggestion={suggestion}
              key={suggestion.id}
              className={menuClasses.item}
            />
          ))}
      </div>
    );
  },
};
