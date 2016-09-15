import { connect }        from 'react-redux';
import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';

const mapStateToProps = (state, props) => ({

});

const Settings = React.createClass({

  propTypes: {
    params: React.PropTypes.object.isRequired,
    dispatch: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  componentWillMount () {
    //
  },

  render () {
    return <div>Settings</div>;
  }

});

export default connect(mapStateToProps)(Settings);
