import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
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
import createStream from '../../stream';

const messages = defineMessages({
  title: { id: 'column.public', defaultMessage: 'Federated timeline' }
});

const mapStateToProps = state => ({
  hasUnread: state.getIn(['timelines', 'public', 'unread']) > 0,
  accessToken: state.getIn(['meta', 'access_token'])
});

let subscription;

const PublicTimeline = React.createClass({

  propTypes: {
    dispatch: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired,
    accessToken: React.PropTypes.string.isRequired,
    hasUnread: React.PropTypes.bool
  },

  mixins: [PureRenderMixin],

  componentDidMount () {
    const { dispatch, accessToken } = this.props;

    dispatch(refreshTimeline('public'));

    if (typeof subscription !== 'undefined') {
      return;
    }

    subscription = createStream(accessToken, 'public', {

      connected () {
        dispatch(connectTimeline('public'));
      },

      reconnected () {
        dispatch(connectTimeline('public'));
      },

      disconnected () {
        dispatch(disconnectTimeline('public'));
      },

      received (data) {
        switch(data.event) {
        case 'update':
          dispatch(updateTimeline('public', JSON.parse(data.payload)));
          break;
        case 'delete':
          dispatch(deleteFromTimelines(data.payload));
          break;
        }
      }

    });
  },

  componentWillUnmount () {
    // if (typeof subscription !== 'undefined') {
    //   subscription.close();
    //   subscription = null;
    // }
  },

  render () {
    const { intl, hasUnread } = this.props;

    return (
      <Column icon='globe' active={hasUnread} heading={intl.formatMessage(messages.title)}>
        <ColumnBackButtonSlim />
        <StatusListContainer type='public' emptyMessage={<FormattedMessage id='empty_column.public' defaultMessage='There is nothing here! Write something publicly, or manually follow users from other instances to fill it up' />} />
      </Column>
    );
  },

});

export default connect(mapStateToProps)(injectIntl(PublicTimeline));
