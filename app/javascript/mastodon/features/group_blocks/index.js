import React from 'react';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { debounce } from 'lodash';
import LoadingIndicator from '../../components/loading_indicator';
import {
  fetchGroup,
  fetchGroupBlocks,
  expandGroupBlocks,
  groupUnblock,
} from 'mastodon/actions/groups';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import AccountContainer from '../../containers/account_container';
import Column from 'mastodon/components/column';
import ColumnHeader from '../../components/column_header';
import ScrollableList from '../../components/scrollable_list';
import MissingIndicator from 'mastodon/components/missing_indicator';

const messages = defineMessages({
  group_mod_unblock: { id: 'status.group_mod_unblock', defaultMessage: 'Unblock from group' },
  heading: { id: 'column.group_blocks', defaultMessage: 'Users blocked from this group' },
});

const mapStateToProps = (state, { params: { id } }) => {
  return {
    group: state.getIn(['groups', id]),
    accountIds: state.getIn(['user_lists', 'group_blocks', id, 'items']),
    hasMore: !!state.getIn(['user_lists', 'group_blocks', id, 'next']),
    isLoading: state.getIn(['user_lists', 'group_blocks', id, 'isLoading'], true),
  };
};

export default @connect(mapStateToProps)
@injectIntl
class GroupBlocks extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.shape({
      id: PropTypes.string,
    }).isRequired,
    dispatch: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
    hasMore: PropTypes.bool,
    isLoading: PropTypes.bool,
    group: ImmutablePropTypes.map,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  _load () {
    const { params: { id }, group, dispatch } = this.props;

    if (!group) dispatch(fetchGroup(id));
    dispatch(fetchGroupBlocks(id));
  }

  componentDidMount () {
    this._load();
  }

  componentDidUpdate (prevProps) {
    const { params: { id } } = this.props;

    if (prevProps.params.id !== id) {
      this._load();
    }
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandGroupBlocks(this.props.params.id));
  }, 300, { leading: true });

  handleUnblock = (account) => {
    const { params: { id }, dispatch } = this.props;
    dispatch(groupUnblock(id, account.get('id')));
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  render () {
    const { params: { id }, accountIds, hasMore, group, multiColumn, isLoading, intl } = this.props;

    if (!group) {
      return (
        <Column>
          <MissingIndicator />
        </Column>
      );
    }

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    let emptyMessage = <FormattedMessage id='group.blocks.empty' defaultMessage='Nobody is currently blocked from interacting with this group.' />;

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.heading)}>
        <ColumnHeader
          icon='ban'
          title={intl.formatMessage(messages.heading)}
          onClick={this.handleHeaderClick}
          multiColumn={multiColumn}
          showBackButton
        />

        <ScrollableList
          scrollKey={`group_members-${id}`}
          hasMore={hasMore}
          isLoading={isLoading}
          onLoadMore={this.handleLoadMore}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        >
          {accountIds.map(id => (
            <AccountContainer
              key={id}
              id={id}
              withNote={false}
              actionIcon='times'
              actionTitle={intl.formatMessage(messages.group_mod_unblock)}
              onActionClick={this.handleUnblock}
            />
          ))}
        </ScrollableList>
      </Column>
    );
  }

}
