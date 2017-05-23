import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import { fetchFavouritedStatuses, expandFavouritedStatuses } from '../../actions/favourites';
import Column from '../ui/components/column';
import StatusList from '../../components/status_list';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  heading: { id: 'column.favourites', defaultMessage: 'Favourites' },
});

const mapStateToProps = state => ({
  statusIds: state.getIn(['status_lists', 'favourites', 'items']),
  loaded: state.getIn(['status_lists', 'favourites', 'loaded']),
  me: state.getIn(['meta', 'me']),
});

class Favourites extends ImmutablePureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list.isRequired,
    loaded: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    me: PropTypes.number.isRequired,
  };

  componentWillMount () {
    this.props.dispatch(fetchFavouritedStatuses());
  }

  handleScrollToBottom = () => {
    this.props.dispatch(expandFavouritedStatuses());
  }

  render () {
    const { statusIds, loaded, intl, me } = this.props;

    if (!loaded) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    return (
      <Column icon='star' heading={intl.formatMessage(messages.heading)}>
        <ColumnBackButtonSlim />
        <StatusList {...this.props} scrollKey='favourited_statuses' onScrollToBottom={this.handleScrollToBottom} />
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Favourites));
