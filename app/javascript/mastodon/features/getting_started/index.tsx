import { useIntl } from 'react-intl';

import { Helmet } from 'react-helmet';

import { Column } from 'mastodon/components/column';

import { NavigationPanel } from '../navigation_panel';
import { LinkFooter } from '../ui/components/link_footer';

const GettingStarted: React.FC = () => {
  const intl = useIntl();
  return (
    <Column>
      <NavigationPanel multiColumn />

      <LinkFooter multiColumn />

      <Helmet>
        <title>
          {intl.formatMessage({
            id: 'getting_started.heading',
            defaultMessage: 'Getting started',
          })}
        </title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default GettingStarted;
