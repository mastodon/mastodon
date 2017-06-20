import React from 'react';
import { List } from 'immutable';
import { storiesOf } from '@storybook/react';
import { action } from '@storybook/addon-actions';
import AutosuggestTextarea from 'mastodon/components/autosuggest_textarea';

const props = {
  onChange: action('changed'),
  onPaste: action('pasted'),
  onSuggestionSelected: action('suggestionsSelected'),
  onSuggestionsClearRequested: action('suggestionsClearRequested'),
  onSuggestionsFetchRequested: action('suggestionsFetchRequested'),
  suggestions: List([]),
};

storiesOf('AutosuggestTextarea', module)
  .add('default state', () => <AutosuggestTextarea value='' {...props} />)
  .add('with text', () => <AutosuggestTextarea value='Hello' {...props} />);
