import { connect }         from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import { refreshTimeline } from '../../actions/timelines';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  title: { id: 'column.mentions', defaultMessage: 'Mentions' }
});

const MentionsTimeline = React.createClass({

  propTypes: {
    dispatch: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(refreshTimeline('mentions'));
  },

  render () {
    const { intl } = this.props;

    return (
      <Column icon='at' heading={intl.formatMessage(messages.title)}>
        <StatusListContainer {...this.props} type='mentions' />
      </Column>
    );
  },

});

export default connect()(injectIntl(MentionsTimeline));
