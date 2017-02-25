import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import LoadingIndicator from '../../components/loading_indicator';
import { fetchFavouritedStatuses, expandFavouritedStatuses } from '../../actions/favourites';
import Column from '../ui/components/column';
import StatusList from '../../components/status_list';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  heading: { id: 'column.favourites', defaultMessage: 'Favourites' }
});

const mapStateToProps = state => ({
  statusIds: state.getIn(['status_lists', 'favourites', 'items']),
  loaded: state.getIn(['status_lists', 'favourites', 'loaded']),
  me: state.getIn(['meta', 'me'])
});

const Favourites = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired,
    statusIds: ImmutablePropTypes.list.isRequired,
    loaded: React.PropTypes.bool,
    intl: React.PropTypes.object.isRequired,
    me: React.PropTypes.number.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(fetchFavouritedStatuses());
  },

  handleScrollToBottom () {
    this.props.dispatch(expandFavouritedStatuses());
  },

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
        <StatusList statusIds={statusIds} me={me} onScrollToBottom={this.handleScrollToBottom} />
      </Column>
    );
  }

});

export default connect(mapStateToProps)(injectIntl(Favourites));
