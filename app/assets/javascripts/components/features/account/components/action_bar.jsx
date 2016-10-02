import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Button             from '../../../components/button';

const ActionBar = React.createClass({

  propTypes: {
    account: ImmutablePropTypes.map.isRequired,
    me: React.PropTypes.number.isRequired,
    onFollow: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { account, me } = this.props;

    let infoText     = '';
    let buttonText   = '';

    if (account.get('id') === me) {
      buttonText = 'This is you!';
    } else {
      if (account.getIn(['relationship', 'following'])) {
        buttonText = 'Unfollow';
      } else {
        buttonText = 'Follow';
      }

      if (account.getIn(['relationship', 'followed_by'])) {
        infoText = 'Follows you!';
      }
    }

    return (
      <div style={{ borderTop: '1px solid #363c4b', borderBottom: '1px solid #363c4b', padding: '10px', lineHeight: '36px', overflow: 'hidden', flex: '0 0 auto' }}>
        <Button text={buttonText} onClick={this.props.onFollow} disabled={account.get('id') === me} /> <span style={{ color: '#616b86', fontWeight: '500', textTransform: 'uppercase', float: 'right', display: 'block' }}>{infoText}</span>
      </div>
    );
  },

});

export default ActionBar;
