const AccountRoute = React.createClass({

  render() {
    return (
      <div>
        {this.props.params.account_id}
      </div>
    )
  }

});

export default AccountRoute;
