import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Button             from '../../../components/button';

const ActionBar = React.createClass({

  propTypes: {
    account: ImmutablePropTypes.map.isRequired,
    me: React.PropTypes.number.isRequired,
    onFollow: React.PropTypes.func.isRequired,
    onUnfollow: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  render () {
    const { account, me } = this.props;
    
    let infoText     = '';
    let actionButton = '';

    if (account.get('id') === me) {
      infoText = 'This is you!';
    } else {
      if (account.getIn(['relationship', 'following'])) {
        actionButton = <Button text='Unfollow' onClick={this.props.onUnfollow} />
      } else {
        actionButton = <Button text='Follow' onClick={this.props.onFollow} />
      }

      if (account.getIn(['relationship', 'followed_by'])) {
        infoText = 'Follows you!';
      }
    }

    return (
      <div style={{ borderTop: '1px solid #363c4b', borderBottom: '1px solid #363c4b', padding: '10px', lineHeight: '36px' }}>
        {actionButton} <span style={{ color: '#616b86', fontWeight: '500', textTransform: 'uppercase' }}>{infoText}</span>
      </div>
    );
  },

});

export default ActionBar;
