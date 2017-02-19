import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import {
  refreshTimeline,
  updateTimeline,
  deleteFromTimelines
} from '../../actions/timelines';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import createStream from '../../stream';

const messages = defineMessages({
  title: { id: 'column.community', defaultMessage: 'Local' }
});

const mapStateToProps = state => ({
  accessToken: state.getIn(['meta', 'access_token'])
});

const CommunityTimeline = React.createClass({

  propTypes: {
    dispatch: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired,
    accessToken: React.PropTypes.string.isRequired
  },

  mixins: [PureRenderMixin],

  componentDidMount () {
    const { dispatch, accessToken } = this.props;

    dispatch(refreshTimeline('community'));

    this.subscription = createStream(accessToken, 'public:local', {

      received (data) {
        switch(data.event) {
        case 'update':
          dispatch(updateTimeline('community', JSON.parse(data.payload)));
          break;
        case 'delete':
          dispatch(deleteFromTimelines(data.payload));
          break;
        }
      }

    });
  },

  componentWillUnmount () {
    if (typeof this.subscription !== 'undefined') {
      this.subscription.close();
      this.subscription = null;
    }
  },

  render () {
    const { intl } = this.props;

    return (
      <Column icon='users' heading={intl.formatMessage(messages.title)}>
        <ColumnBackButtonSlim />
        <StatusListContainer type='community' emptyMessage={<FormattedMessage id='empty_column.community' defaultMessage='The local timeline is empty. Write something publicly to get the ball rolling!' />} />
      </Column>
    );
  },

});

export default connect(mapStateToProps)(injectIntl(CommunityTimeline));
