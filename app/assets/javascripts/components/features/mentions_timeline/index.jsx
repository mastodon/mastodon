import { connect }         from 'react-redux';
import PureRenderMixin     from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column              from '../ui/components/column';
import { refreshTimeline } from '../../actions/timelines';

const MentionsTimeline = React.createClass({

  propTypes: {
    dispatch: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    this.props.dispatch(refreshTimeline('mentions'));
  },

  render () {
    return (
      <Column icon='at' heading='Mentions'>
        <StatusListContainer type='mentions' />
      </Column>
    );
  },

});

export default connect()(MentionsTimeline);
