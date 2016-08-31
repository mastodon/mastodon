import Status             from './status';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin    from 'react-addons-pure-render-mixin';

const StatusList = React.createClass({

  propTypes: {
    statuses: ImmutablePropTypes.list.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    return (
      <div style={{ overflowY: 'scroll', flex: '1 1 auto' }}>
        <div>
          {this.props.statuses.map((status) => {
            return <Status key={status.get('id')} status={status} />;
          })}
        </div>
      </div>
    );
  }

});

export default StatusList;
