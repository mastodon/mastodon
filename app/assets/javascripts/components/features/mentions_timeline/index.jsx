import PureRenderMixin     from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column              from '../ui/components/column';

const MentionsTimeline = React.createClass({

  mixins: [PureRenderMixin],

  render () {
    return (
      <Column icon='at' heading='Mentions'>
        <StatusListContainer type='mentions' />
      </Column>
    );
  },

});

export default MentionsTimeline;
