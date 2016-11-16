import { connect }         from 'react-redux';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column from '../ui/components/column';
import { refreshTimeline } from '../../actions/timelines';
import { injectIntl } from 'react-intl';

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
      <Column icon='at' heading={intl.formatMessage({ id: 'column.mentions', defaultMessage: 'Mentions' })}>
        <StatusListContainer {...this.props} type='mentions' />
      </Column>
    );
  },

});

export default connect()(injectIntl(MentionsTimeline));
