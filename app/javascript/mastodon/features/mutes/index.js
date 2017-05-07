import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import { ScrollContainer } from 'react-router-scroll';
import Column from '../ui/components/column';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import AccountContainer from '../../containers/account_container';
import { fetchMutes, expandMutes } from '../../actions/mutes';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  heading: { id: 'column.mutes', defaultMessage: 'Muted users' }
});

const mapStateToProps = state => ({
  accountIds: state.getIn(['user_lists', 'mutes', 'items'])
});

class Mutes extends ImmutablePureComponent {

  constructor (props, context) {
    super(props, context);
    this.handleScroll = this.handleScroll.bind(this);
  }

  componentWillMount () {
    this.props.dispatch(fetchMutes());
  }

  handleScroll (e) {
    const { scrollTop, scrollHeight, clientHeight } = e.target;

    if (scrollTop === scrollHeight - clientHeight) {
      this.props.dispatch(expandMutes());
    }
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
      <Column icon='volume-off' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />
        <ScrollContainer scrollKey='mutes'>
          <div className='scrollable mutes' onScroll={this.handleScroll}>
            {accountIds.map(id =>
              <AccountContainer key={id} id={id} />
            )}
          </div>
        </ScrollContainer>
      </Column>
    );
  }

}

Mutes.propTypes = {
  params: PropTypes.object.isRequired,
  dispatch: PropTypes.func.isRequired,
  accountIds: ImmutablePropTypes.list,
  intl: PropTypes.object.isRequired
};

export default connect(mapStateToProps)(injectIntl(Mutes));
