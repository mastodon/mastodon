import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { debounce } from 'lodash';

import RefreshIcon from '@/material-icons/400-24px/refresh.svg?react';
import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import { Icon }  from 'flavours/glitch/components/icon';

import { fetchReblogs, expandReblogs } from '../../actions/interactions';
import ColumnHeader from '../../components/column_header';
import { LoadingIndicator } from '../../components/loading_indicator';
import ScrollableList from '../../components/scrollable_list';
import AccountContainer from '../../containers/account_container';
import Column from '../ui/components/column';

const messages = defineMessages({
  heading: { id: 'column.reblogged_by', defaultMessage: 'Boosted by' },
  refresh: { id: 'refresh', defaultMessage: 'Refresh' },
});

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['user_lists', 'reblogged_by', props.params.statusId, 'items']),
  hasMore: !!state.getIn(['user_lists', 'reblogged_by', props.params.statusId, 'next']),
  isLoading: state.getIn(['user_lists', 'reblogged_by', props.params.statusId, 'isLoading'], true),
});

class Reblogs extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  UNSAFE_componentWillMount () {
    if (!this.props.accountIds) {
      this.props.dispatch(fetchReblogs(this.props.params.statusId));
    }
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  setRef = c => {
    this.column = c;
  };

  handleRefresh = () => {
    this.props.dispatch(fetchReblogs(this.props.params.statusId));
  };

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandReblogs(this.props.params.statusId));
  }, 300, { leading: true });

  render () {
    const { intl, accountIds, hasMore, isLoading, multiColumn } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='status.reblogs.empty' defaultMessage='No one has boosted this post yet. When someone does, they will show up here.' />;

    return (
      <Column ref={this.setRef}>
        <ColumnHeader
          icon='retweet'
          iconComponent={RepeatIcon}
          title={intl.formatMessage(messages.heading)}
          onClick={this.handleHeaderClick}
          showBackButton
          multiColumn={multiColumn}
          extraButton={(
            <button type='button' className='column-header__button' title={intl.formatMessage(messages.refresh)} aria-label={intl.formatMessage(messages.refresh)} onClick={this.handleRefresh}><Icon id='refresh' icon={RefreshIcon} /></button>
          )}
        />

        <ScrollableList
          scrollKey='reblogs'
          onLoadMore={this.handleLoadMore}
          hasMore={hasMore}
          isLoading={isLoading}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        >
          {accountIds.map(id =>
            <AccountContainer key={id} id={id} withNote={false} />,
          )}
        </ScrollableList>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Reblogs));
