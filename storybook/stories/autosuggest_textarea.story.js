import React from 'react';
import { List } from 'immutable'
import { action, storiesOf } from '@kadira/storybook';
import AutosuggestTextarea from 'mastodon/components/autosuggest_textarea'

const props = {
  onChange: action('changed'),
  onPaste: action('pasted'),
  onSuggestionSelected: action('suggestionsSelected'),
  onSuggestionsClearRequested: action('suggestionsClearRequested'),
  onSuggestionsFetchRequested: action('suggestionsFetchRequested'),
  suggestions: List([])
}

storiesOf('AutosuggestTextarea', module)
  .add('default state', () => <AutosuggestTextarea value='' {...props} />)
  .add('with text', () => <AutosuggestTextarea value='Hello' {...props} />)
