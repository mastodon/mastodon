import { connect }        from 'react-redux';
import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';

const mapStateToProps = (state, props) => ({

});

const Subscriptions = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    //
  },

  render () {
    return <div>Subscriptions</div>;
  }

});

export default connect(mapStateToProps)(Subscriptions);
