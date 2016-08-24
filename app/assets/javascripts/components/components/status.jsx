import ImmutablePropTypes from 'react-immutable-proptypes';

const Status = React.createClass({
  propTypes: {
    status: ImmutablePropTypes.map.isRequired
  },

  render: function() {
    console.log(this.props.status.toJS());

    return (
      <div style={{ height: '100px' }}>
        {this.props.status.getIn(['account', 'username'])}: {this.props.status.get('content')}
      </div>
    );
  }
});

export default Status;
