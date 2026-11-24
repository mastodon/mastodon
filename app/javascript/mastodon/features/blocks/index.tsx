import { FormattedMessage } from 'react-intl';

import { Route, Switch, useRouteMatch } from 'react-router-dom';

import { Column } from '@/mastodon/components/column';
import { ColumnHeader } from '@/mastodon/components/column_header';
import { TabLink, TabList } from '@/mastodon/components/tab_list';

import AccountBlocks from './accounts';
import DomainBlocks from './domains';

const Blocks: React.FC<{ multiColumn: boolean }> = ({ multiColumn }) => {
  const { path } = useRouteMatch();

  return (
    <Column bindToDocument={!multiColumn}>
      <ColumnHeader
        withBackButton={multiColumn && 'auto'}
        title={
          <FormattedMessage id='column.blocked' defaultMessage='Blocked' />
        }
      />

      <TabList>
        <TabLink exact to='/blocks'>
          <FormattedMessage
            id='column.blocked_accounts'
            defaultMessage='Blocked Accounts'
          />
        </TabLink>
        <TabLink exact to='/blocks/domains'>
          <FormattedMessage
            id='column.domain_blocks'
            defaultMessage='Blocked Domains'
          />
        </TabLink>
      </TabList>

      <Switch>
        <Route exact path={path} component={AccountBlocks} />
        <Route exact path={`${path}/domains`} component={DomainBlocks} />
      </Switch>
    </Column>
  );
};

// eslint-disable-next-line import/no-default-export
export default Blocks;
