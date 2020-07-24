import React from 'react';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import { fetchMentions } from '../../actions/interactions';
import { injectIntl, FormattedMessage } from 'react-intl';
import AccountContainer from '../../containers/account_container';
import Column from '../ui/components/column';
import ScrollableList from '../../components/scrollable_list';
import ColumnHeader from '../../components/column_header';

const mapStateToProps = (state, props) => ({
  accountIds: state.getIn(['user_lists', 'mentioned_by', props.params.statusId]),
});

export default @connect(mapStateToProps)
@injectIntl
class Mentions extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    shouldUpdateScroll: PropTypes.func,
    accountIds: ImmutablePropTypes.list,
    multiColumn: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  componentWillMount () {
    if (!this.props.accountIds) {
      this.props.dispatch(fetchMentions(this.props.params.statusId));
    }
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.statusId !== this.props.params.statusId && nextProps.params.statusId) {
      this.props.dispatch(fetchMentions(nextProps.params.statusId));
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

    const emptyMessage = <FormattedMessage id='empty_column.mentions' defaultMessage='No one has mentioned this toot.' />;

    return (
      <Column bindToDocument={!multiColumn}>
        <ColumnHeader
          showBackButton
          multiColumn={multiColumn}
        />

        <ScrollableList
          scrollKey='mentions'
          shouldUpdateScroll={shouldUpdateScroll}
          emptyMessage={emptyMessage}
          bindToDocument={!multiColumn}
        >
          {accountIds.map(id =>
            <AccountContainer key={id} id={id} withNote={false} />,
          )}
        </ScrollableList>
      </Column>
    );
  }

}
