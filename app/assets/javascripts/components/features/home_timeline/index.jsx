import { connect } from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import { refreshTimeline } from '../../actions/timelines';
import { defineMessages, injectIntl } from 'react-intl';
import ColumnSettingsContainer from './containers/column_settings_container';

const messages = defineMessages({
  title: { id: 'column.home', defaultMessage: 'Home' }
});

const HomeTimeline = React.createClass({

  propTypes: {
    dispatch: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(refreshTimeline('home'));
  },

  render () {
    const { intl } = this.props;

    return (
      <Column icon='home' heading={intl.formatMessage(messages.title)}>
        <ColumnSettingsContainer />
        <StatusListContainer {...this.props} type='home' />
      </Column>
    );
  },

});

export default connect()(injectIntl(HomeTimeline));
