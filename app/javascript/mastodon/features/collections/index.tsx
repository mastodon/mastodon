import { defineMessages, useIntl } from 'react-intl';

import { Route, Switch, useRouteMatch } from 'react-router-dom';

import { Helmet } from '@unhead/react/helmet';

import { TabLink, TabList } from '@/mastodon/components/tab_list';
import { Column } from 'mastodon/components/column';
import { ColumnHeader } from 'mastodon/components/column_header';
import { DisplayNameSimple } from 'mastodon/components/display_name/simple';
import { Scrollable } from 'mastodon/components/scrollable_list/components';
import { useAccount } from 'mastodon/hooks/useAccount';
import { useAccountId, useCurrentAccountId } from 'mastodon/hooks/useAccountId';

import { CollectionsCreatedByYou } from './overview/created_by_you';
import { CollectionsFeaturingYou } from './overview/featuring_you';
import classes from './styles.module.scss';

const messages = defineMessages({
  headingMe: {
    id: 'column.your_collections',
    defaultMessage: 'Your Collections',
  },
  headingOther: {
    id: 'column.other_collections',
    defaultMessage: "{name}'s Collections",
  },
  createdByYou: {
    id: 'collections.list.created_by_you',
    defaultMessage: 'Created by you',
  },
  createdByAuthor: {
    id: 'collections.list.created_by_author',
    defaultMessage: 'Created by {name}',
  },
  featuringYou: {
    id: 'collections.list.featuring_you',
    defaultMessage: 'Featuring you',
  },
});

export const Collections: React.FC<{
  multiColumn?: boolean;
}> = ({ multiColumn }) => {
  const intl = useIntl();
  const me = useCurrentAccountId();
  const accountId = useAccountId();
  const account = useAccount(accountId);
  const { path } = useRouteMatch();

  const isOwnCollectionsPage = accountId === me;

  const titleMessage = isOwnCollectionsPage
    ? messages.headingMe
    : messages.headingOther;

  const pageTitle = intl.formatMessage(titleMessage, {
    name: account?.get('display_name'),
  });
  const pageTitleHtml = intl.formatMessage(titleMessage, {
    name: <DisplayNameSimple account={account} />,
  });

  const createdByTabMessage = isOwnCollectionsPage
    ? messages.createdByYou
    : messages.createdByAuthor;

  return (
    <Column bindToDocument={!multiColumn} label={pageTitle}>
      <ColumnHeader showBackButton multiColumn={multiColumn} />

      <Scrollable>
        <header className={classes.header}>
          <h1 className={classes.heading}>{pageTitleHtml}</h1>
          <TabList plain>
            <TabLink exact to={`/@${account?.acct}/collections`}>
              {intl.formatMessage(createdByTabMessage, {
                name: <DisplayNameSimple account={account} />,
              })}
            </TabLink>
            {isOwnCollectionsPage && (
              <TabLink
                exact
                to={`/@${account?.acct}/collections/featuring-you`}
              >
                {intl.formatMessage(messages.featuringYou)}
              </TabLink>
            )}
          </TabList>
        </header>
        <Switch>
          <Route exact path={path} component={CollectionsCreatedByYou} />
          <Route
            exact
            path={`${path}/featuring-you`}
            component={CollectionsFeaturingYou}
          />
        </Switch>
      </Scrollable>

      <Helmet>
        <title>{pageTitle}</title>
        <meta name='robots' content='noindex' />
      </Helmet>
    </Column>
  );
};
