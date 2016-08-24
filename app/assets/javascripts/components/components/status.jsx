import ImmutablePropTypes from 'react-immutable-proptypes';

const Status = React.createClass({
  propTypes: {
    status: ImmutablePropTypes.map.isRequired
  },

  render: function() {
    var content = { __html: this.props.status.get('content') };

    return (
      <div style={{ padding: '5px' }}>
        <div><strong>{this.props.status.getIn(['account', 'username'])}</strong></div>
        <div dangerouslySetInnerHTML={content} />
      </div>
    );
  }
});

export default Status;
