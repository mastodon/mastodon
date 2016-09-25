import PureRenderMixin    from 'react-addons-pure-render-mixin';
import IconButton         from '../../../components/icon_button';
import ImmutablePropTypes from 'react-immutable-proptypes';

const ActionBar = React.createClass({
  
  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    onReply: React.PropTypes.func.isRequired,
    onReblog: React.PropTypes.func.isRequired,
    onFavourite: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { status } = this.props;

    return (
      <div style={{ background: '#2f3441', display: 'flex', flexDirection: 'row', borderTop: '1px solid #363c4b', borderBottom: '1px solid #363c4b', padding: '10px 0' }}>
        <div style={{ flex: '1 1 auto', textAlign: 'center' }}><IconButton title='Reply' icon='reply' onClick={this.props.onReply.bind(this, status)} /></div>
        <div style={{ flex: '1 1 auto', textAlign: 'center' }}><IconButton active={status.get('reblogged')} title='Reblog' icon='retweet' onClick={this.props.onReblog.bind(this, status)} /></div>
        <div style={{ flex: '1 1 auto', textAlign: 'center' }}><IconButton active={status.get('favourited')} title='Favourite' icon='star' onClick={this.props.onFavourite.bind(this, status)} /></div>
      </div>
    );
  }

});

export default ActionBar;
