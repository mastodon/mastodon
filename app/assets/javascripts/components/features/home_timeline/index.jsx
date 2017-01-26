import PureRenderMixin from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import { defineMessages, injectIntl } from 'react-intl';
import ColumnSettingsContainer from './containers/column_settings_container';

const messages = defineMessages({
  title: { id: 'column.home', defaultMessage: 'Home' }
});

const HomeTimeline = React.createClass({

  propTypes: {
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

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

export default injectIntl(HomeTimeline);
