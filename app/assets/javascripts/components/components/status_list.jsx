import Status             from './status';
import ImmutablePropTypes from 'react-immutable-proptypes';

const StatusList = React.createClass({
  propTypes: {
    statuses: ImmutablePropTypes.list.isRequired
  },

  render: function() {
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
