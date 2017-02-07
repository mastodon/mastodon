import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import {
  refreshTimeline,
  updateTimeline,
  deleteFromTimelines
} from '../../actions/timelines';
import { defineMessages, injectIntl } from 'react-intl';
import ColumnBackButtonSlim from '../../components/column_back_button_slim';
import createStream from '../../stream';

const messages = defineMessages({
  title: { id: 'column.public', defaultMessage: 'Public' }
});

const mapStateToProps = state => ({
  accessToken: state.getIn(['meta', 'access_token'])
});

const PublicTimeline = React.createClass({

  propTypes: {
    dispatch: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired,
    accessToken: React.PropTypes.string.isRequired
  },

  mixins: [PureRenderMixin],

  componentDidMount () {
    const { dispatch, accessToken } = this.props;

    dispatch(refreshTimeline('public'));

    this.subscription = createStream(accessToken, 'public', {

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
    if (typeof this.subscription !== 'undefined') {
      this.subscription.close();
      this.subscription = null;
    }
  },

  render () {
    const { intl } = this.props;

    return (
      <Column icon='globe' heading={intl.formatMessage(messages.title)}>
        <ColumnBackButtonSlim />
        <StatusListContainer type='public' />
      </Column>
    );
  },

});

export default connect(mapStateToProps)(injectIntl(PublicTimeline));
