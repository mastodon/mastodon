import PureRenderMixin    from 'react-addons-pure-render-mixin';
import IconButton         from '../../../components/icon_button';
import ImmutablePropTypes from 'react-immutable-proptypes';
import DropdownMenu       from '../../../components/dropdown_menu';

const ActionBar = React.createClass({

  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    onReply: React.PropTypes.func.isRequired,
    onReblog: React.PropTypes.func.isRequired,
    onFavourite: React.PropTypes.func.isRequired,
    onDelete: React.PropTypes.func.isRequired,
    me: React.PropTypes.number.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { status, me } = this.props;

    let menu = [];

    if (me === status.getIn(['account', 'id'])) {
      menu.push({ text: 'Delete', action: () => this.props.onDelete(status) });
    }

    return (
      <div style={{ background: '#2f3441', display: 'flex', flexDirection: 'row', borderTop: '1px solid #363c4b', borderBottom: '1px solid #363c4b', padding: '10px 0' }}>
        <div style={{ flex: '1 1 auto', textAlign: 'center' }}><IconButton title='Reply' icon='reply' onClick={() => this.props.onReply(status)} /></div>
        <div style={{ flex: '1 1 auto', textAlign: 'center' }}><IconButton active={status.get('reblogged')} title='Reblog' icon='retweet' onClick={() => this.props.onReblog(status)} /></div>
        <div style={{ flex: '1 1 auto', textAlign: 'center' }}><IconButton active={status.get('favourited')} title='Favourite' icon='star' onClick={() => this.props.onFavourite(status)} /></div>
        <div style={{ flex: '1 1 auto', textAlign: 'center' }}><DropdownMenu size={18} icon='ellipsis-h' items={menu} /></div>
      </div>
    );
  }

});

export default ActionBar;
