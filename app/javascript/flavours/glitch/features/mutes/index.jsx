import PropTypes from 'prop-types';

import { defineMessages, FormattedMessage } from 'react-intl';

import { Helmet } from '@unhead/react/helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { ImmutablePureComponent } from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { debounce } from 'lodash';

import VolumeOffIcon from '@/material-icons/400-24px/volume_off.svg?react';
import { fetchMutes, expandMutes } from '@/flavours/glitch/actions/mutes';
import { Account } from '@/flavours/glitch/components/account';
import { Column } from '@/flavours/glitch/components/column';
import { injectIntl } from '@/flavours/glitch/components/intl';
import { LoadingIndicator } from '@/flavours/glitch/components/loading_indicator';
import ScrollableList from '@/flavours/glitch/components/scrollable_list';
import { ColumnHeader as LegacyColumnHeader } from '@/flavours/glitch/components/column/header';
import { isRedesignEnabled } from '@/flavours/glitch/utils/environment';
import { ColumnHeader } from '@/flavours/glitch/components/column_header';


const messages = defineMessages({
  heading: { id: 'column.muted_accounts', defaultMessage: 'Muted Accounts' },
});

const mapStateToProps = state => ({
  accountIds: state.getIn(['user_lists', 'mutes', 'items']),
  hasMore: !!state.getIn(['user_lists', 'mutes', 'next']),
  isLoading: state.getIn(['user_lists', 'mutes', 'isLoading'], true),
});

class Mutes extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
    accountIds: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  componentDidMount () {
    this.props.dispatch(fetchMutes());
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandMutes());
  }, 300, { leading: true });

  render () {
    const { intl, hasMore, accountIds, multiColumn, isLoading } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.mutes' defaultMessage="You haven't muted any users yet." />;

    return (
      <Column bindToDocument={!multiColumn}>
        {isRedesignEnabled() ? (
          <ColumnHeader
            withBackButton
            title={intl.formatMessage(messages.heading)}
          />
        ) : (
          <LegacyColumnHeader icon='volume-off' iconComponent={VolumeOffIcon} title={intl.formatMessage(messages.heading)} showBackButton />
        )}
        <ScrollableList
          scrollKey='mutes'
          onLoadMore={this.handleLoadMore}
          hasMore={hasMore}
          isLoading={isLoading}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        >
          {accountIds.map(id =>
            <Account key={id} id={id} defaultAction='mute' />,
          )}
        </ScrollableList>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Mutes));
