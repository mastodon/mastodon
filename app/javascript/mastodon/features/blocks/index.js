import React from 'react';
import { connect } from 'react-redux';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { debounce } from 'lodash';
import PropTypes from 'prop-types';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import AccountContainer from '../../containers/account_container';
import { fetchBlocks, expandBlocks } from '../../actions/blocks';
import ScrollableList from '../../components/scrollable_list';

const messages = defineMessages({
  heading: { id: 'column.blocks', defaultMessage: 'Blocked users' },
});

const mapStateToProps = state => ({
  accountIds: state.getIn(['user_lists', 'blocks', 'items']),
});

export default @connect(mapStateToProps)
@injectIntl
class Blocks extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    accountIds: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
  };

  componentWillMount () {
    this.props.dispatch(fetchBlocks());
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandBlocks());
  }, 300, { leading: true });

  render () {
    const { intl, accountIds, shouldUpdateScroll } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.blocks' defaultMessage="You haven't blocked any users yet." />;

    return (
      <Column icon='ban' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />
        <ScrollableList
          scrollKey='blocks'
          onLoadMore={this.handleLoadMore}
          shouldUpdateScroll={shouldUpdateScroll}
          emptyMessage={emptyMessage}
        >
          {accountIds.map(id =>
            <AccountContainer key={id} id={id} />
          )}
        </ScrollableList>
      </Column>
    );
  }

}
