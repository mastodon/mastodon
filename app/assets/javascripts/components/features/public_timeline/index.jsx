import { connect }         from 'react-redux';
import PureRenderMixin     from 'react-addons-pure-render-mixin';
import StatusListContainer from '../ui/containers/status_list_container';
import Column              from '../ui/components/column';
import {
  refreshTimeline,
  updateTimeline
}                          from '../../actions/timelines';

const PublicTimeline = React.createClass({

  propTypes: {
    dispatch: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    const { dispatch } = this.props;

    dispatch(refreshTimeline('public'));

    if (typeof App !== 'undefined') {
      this.subscription = App.cable.subscriptions.create('PublicChannel', {

        received (data) {
          dispatch(updateTimeline('public', JSON.parse(data.message)));
        }

      });
    }
  },

  componentWillUnmount () {
    if (typeof this.subscription !== 'undefined') {
      this.subscription.unsubscribe();
    }
  },

  render () {
    return (
      <Column icon='globe' heading='Public'>
        <StatusListContainer type='public' />
      </Column>
    );
  },

});

export default connect()(PublicTimeline);
