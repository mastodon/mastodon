import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Button             from '../../../components/button';

const ActionBar = React.createClass({

  propTypes: {
    account: ImmutablePropTypes.map.isRequired,
    me: React.PropTypes.number.isRequired,
    onFollow: React.PropTypes.func.isRequired,
    onBlock: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { account, me } = this.props;

    let infoText     = '';
    let follow       = '';
    let buttonText   = '';
    let block        = '';
    let disabled     = false;

    if (account.get('id') === me) {
      buttonText = 'This is you!';
      disabled   = true;
    } else {
      let blockText = '';

      if (account.getIn(['relationship', 'blocking'])) {
        buttonText = 'Blocked';
        disabled   = true;
        blockText  = 'Unblock';
      } else {
        if (account.getIn(['relationship', 'following'])) {
          buttonText = 'Unfollow';
        } else {
          buttonText = 'Follow';
        }

        if (account.getIn(['relationship', 'followed_by'])) {
          infoText = 'Follows you!';
        }

        blockText = 'Block';
      }

      block = <Button text={blockText} onClick={this.props.onBlock} />;
    }

    if (!account.getIn(['relationship', 'blocking'])) {
      follow = <Button text={buttonText} onClick={this.props.onFollow} disabled={disabled} />;
    }

    return (
      <div style={{ borderTop: '1px solid #363c4b', borderBottom: '1px solid #363c4b', padding: '10px', lineHeight: '36px', overflow: 'hidden', flex: '0 0 auto' }}>
        {follow} {block}
        <span style={{ color: '#616b86', fontWeight: '500', textTransform: 'uppercase', float: 'right', display: 'block' }}>{infoText}</span>
      </div>
    );
  },

});

export default ActionBar;
