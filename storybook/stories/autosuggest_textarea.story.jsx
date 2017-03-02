import { storiesOf } from '@kadira/storybook';
import AutosuggestTextarea from '../../app/assets/javascripts/components/components/autosuggest_textarea.jsx'

storiesOf('AutosuggestTextarea', module)
  .add('default state', () => <AutosuggestTextarea value='' suggestions={[]} />)
  .add('with text', () => <AutosuggestTextarea value='Hello' suggestions={[]} />)
