import { storiesOf } from '@kadira/storybook';
import LoadingIndicator from '../../app/assets/javascripts/components/components/loading_indicator.jsx'
import { IntlProvider } from 'react-intl';

storiesOf('LoadingIndicator', module)
  .add('default state', () => <IntlProvider><LoadingIndicator /></IntlProvider>);
