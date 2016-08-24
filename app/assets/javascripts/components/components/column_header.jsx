const ColumnHeader = React.createClass({
  propTypes: {
    type: React.PropTypes.string
  },

  render: function() {
    return (
      <div style={{ padding: '15px', fontSize: '16px', background: '#2f3441', flex: '0 0 auto' }}>
        {this.props.type}
      </div>
    );
  }
});

export default ColumnHeader;
