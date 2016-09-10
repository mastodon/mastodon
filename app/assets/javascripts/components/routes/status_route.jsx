const StatusRoute = React.createClass({

  render() {
    return (
      <div>
        {this.props.params.status_id}
      </div>
    )
  }

});

export default StatusRoute;
