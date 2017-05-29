import React from 'react';
import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import Column from '../ui/components/column';
import {
  refreshTimeline,
  updateTimeline,
  deleteFromTimelines,
  connectTimeline,
  disconnectTimeline
} from '../../actions/timelines';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import SearchStatus from '../compose/components/search_status';
import SearchStatusListContainer from '../ui/containers/search_status_list_container';

const messages = defineMessages({
  title: { id: 'column.search', defaultMessage: 'Search toot' }
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'search', 'unread']) > 0,
  accessToken: state.getIn(['meta', 'access_token'])
});


let subscription;

const SearchTimeline = React.createClass({

  propTypes: {
    dispatch: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired,
    accessToken: React.PropTypes.string.isRequired,
    hasUnread: React.PropTypes.bool
  },

  mixins: [PureRenderMixin],

  componentDidMount () {
    const { dispatch, accessToken } = this.props;

    dispatch(refreshTimeline('search'));

    if (typeof subscription !== 'undefined') {
      return;
    }
  },

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.id !== this.props.params.id) {
      this.props.dispatch(refreshTimeline('search', nextProps.params.id));
      this._unsubscribe();
      this._subscribe(this.props.dispatch, nextProps.params.id);
    }
  },

  render () {
    const { intl, hasUnread } = this.props;

    return (
      <Column icon='search' active={hasUnread} heading={intl.formatMessage(messages.title)}>
        <ColumnBackButtonSlim />
        <SearchStatus />
        <SearchStatusListContainer {...this.props} type='search' scrollKey='search_timeline' emptyMessage={<FormattedMessage id='empty_column.search_timeline' defaultMessage='Result is nothing' />} />
      </Column>
    );
  },

});

export default connect(mapStateToProps)(injectIntl(SearchTimeline));
