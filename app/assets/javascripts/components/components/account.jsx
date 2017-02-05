import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar from './avatar';
import DisplayName from './display_name';
import Permalink from './permalink';
import IconButton from './icon_button';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  requested: { id: 'account.requested', defaultMessage: 'Awaiting approval' },
  unblock: { id: 'account.unblock', defaultMessage: 'Unblock' }
});

const outerStyle = {
  padding: '10px',
  borderBottom: '1px solid #363c4b'
};

const itemStyle = {
  flex: '1 1 auto',
  display: 'block',
  color: '#9baec8',
  overflow: 'hidden',
  textDecoration: 'none',
  fontSize: '14px'
};

const noteStyle = {
  paddingTop: '5px',
  fontSize: '12px',
  color: '#616b86'
};

const buttonsStyle = {
  padding: '10px',
  height: '18px'
};

const Account = React.createClass({

  propTypes: {
    account: ImmutablePropTypes.map.isRequired,
    me: React.PropTypes.number.isRequired,
    onFollow: React.PropTypes.func.isRequired,
    onBlock: React.PropTypes.func.isRequired,
    withNote: React.PropTypes.bool,
    intl: React.PropTypes.object.isRequired
  },

  getDefaultProps () {
    return {
      withNote: false
    };
  },

  mixins: [PureRenderMixin],

  handleFollow () {
    this.props.onFollow(this.props.account);
  },

  handleBlock () {
    this.props.onBlock(this.props.account);
  },

  render () {
    const { account, me, withNote, intl } = this.props;

    if (!account) {
      return <div />;
    }

    let note, buttons;

    if (account.get('note').length > 0 && withNote) {
      note = <div style={noteStyle}>{account.get('note')}</div>;
    }

    if (account.get('id') !== me && account.get('relationship', null) !== null) {
      const following = account.getIn(['relationship', 'following']);
      const requested = account.getIn(['relationship', 'requested']);
      const blocking  = account.getIn(['relationship', 'blocking']);

      if (requested) {
        buttons = <IconButton disabled={true} icon='hourglass' title={intl.formatMessage(messages.requested)} />
      } else if (blocking) {
        buttons = <IconButton active={true} icon='unlock-alt' title={intl.formatMessage(messages.unblock)} onClick={this.handleBlock} />;
      } else {
        buttons = <IconButton icon={following ? 'user-times' : 'user-plus'} title={intl.formatMessage(following ? messages.unfollow : messages.follow)} onClick={this.handleFollow} active={following} />;
      }
    }

    return (
      <div style={outerStyle}>
        <div style={{ display: 'flex' }}>
          <Permalink key={account.get('id')} style={itemStyle} className='account__display-name' href={account.get('url')} to={`/accounts/${account.get('id')}`}>
            <div style={{ float: 'left', marginLeft: '12px', marginRight: '10px' }}><Avatar src={account.get('avatar')} size={36} /></div>
            <DisplayName account={account} />
          </Permalink>

          <div style={buttonsStyle}>
            {buttons}
          </div>
        </div>

        {note}
      </div>
    );
  }

});

export default injectIntl(Account);
