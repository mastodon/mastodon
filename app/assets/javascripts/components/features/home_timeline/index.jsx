import PureRenderMixin     from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column              from '../ui/components/column';

const HomeTimeline = React.createClass({

  mixins: [PureRenderMixin],

  render () {
    return (
      <Column icon='home' heading='Home'>
        <StatusListContainer type='home' />
      </Column>
    );
  },

});

export default HomeTimeline;
