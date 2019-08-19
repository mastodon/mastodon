import React from 'react';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import { fetchReblogs } from '../../actions/interactions';
import { FormattedMessage } from 'react-intl';
import AccountContainer from '../../containers/account_container';
import Column from '../ui/components/column';
import ColumnBackButton from '../../components/column_back_button';
import ScrollableList from '../../components/scrollable_list';

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['user_lists', 'reblogged_by', props.params.statusId]),
});

export default @connect(mapStateToProps)
class Reblogs extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    accountIds: ImmutablePropTypes.list,
    multiColumn: PropTypes.bool,
  };

  componentWillMount () {
    this.props.dispatch(fetchReblogs(this.props.params.statusId));
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.statusId !== this.props.params.statusId && nextProps.params.statusId) {
      this.props.dispatch(fetchReblogs(nextProps.params.statusId));
    }
  }

  render () {
    const { shouldUpdateScroll, accountIds, multiColumn } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='status.reblogs.empty' defaultMessage='No one has boosted this toot yet. When someone does, they will show up here.' />;

    return (
      <Column>
        <ColumnBackButton multiColumn={multiColumn} />

        <ScrollableList
          scrollKey='reblogs'
          shouldUpdateScroll={shouldUpdateScroll}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        >
          {accountIds.map(id =>
            <AccountContainer key={id} id={id} withNote={false} />
          )}
        </ScrollableList>
      </Column>
    );
  }

}
