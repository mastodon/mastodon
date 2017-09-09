import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import { ScrollContainer } from 'react-router-scroll';
import Column from '../ui/components/column';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import AccountContainer from '../../containers/account_container';
import { fetchFollowSuggestions } from '../../actions/accounts';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  heading: { id: 'column.suggestions', defaultMessage: 'Who to follow' },
});

const mapStateToProps = state => ({
  accountIds: state.getIn(['user_lists', 'suggestions']),
});

@connect(mapStateToProps)
@injectIntl
export default class Suggestions extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    accountIds: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
  };

  componentWillMount () {
    this.props.dispatch(fetchFollowSuggestions());
  }

  render () {
    const { intl, accountIds } = this.props;

    if (!accountIds) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column icon='search' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />
        <ScrollContainer scrollKey='suggestions'>
          <div className='scrollable'>
            {accountIds.map(id =>
              <AccountContainer key={id} id={id} />
            )}
          </div>
        </ScrollContainer>
      </Column>
    );
  }

}
