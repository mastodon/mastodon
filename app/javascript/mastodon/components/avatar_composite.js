import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { autoPlayGif } from '../initial_state';

export default class AvatarComposite extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    accounts: ImmutablePropTypes.list.isRequired,
    animate: PropTypes.bool,
    size: PropTypes.number.isRequired,
  };

  static defaultProps = {
    animate: autoPlayGif,
  };

  renderItem (account, size, index) {
    const { animate } = this.props;

    let width  = 50;
    let height = 100;
    let top    = 'auto';
    let left   = 'auto';
    let bottom = 'auto';
    let right  = 'auto';

    if (size === 1) {
      width = 100;
    }

    if (size === 4 || (size === 3 && index > 0)) {
      height = 50;
    }

    if (size === 2) {
      if (index === 0) {
        right = '0px';
      } else {
        left = '0px';
      }
    } else if (size === 3) {
      if (index === 0) {
        right = '0px';
      } else if (index > 0) {
        left = '0px';
      }

      if (index === 1) {
        bottom = '0px';
      } else if (index > 1) {
        top = '0px';
      }
    } else if (size === 4) {
      if (index === 0 || index === 2) {
        right = '0px';
      }

      if (index === 1 || index === 3) {
        left = '0px';
      }

      if (index < 2) {
        bottom = '0px';
      } else {
        top = '0px';
      }
    }

    const style = {
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: `${width}%`,
      height: `${height}%`,
      backgroundSize: 'cover',
      backgroundImage: `url(${account.get(animate ? 'avatar' : 'avatar_static')})`,
    };

    return (
      <div key={account.get('id')} style={style} />
    );
  }

  render() {
    const { account, accounts, size } = this.props;

    const baseStyle = {
      backgroundImage: `url(${account.get('avatar_static')})`,
    };

    return (
      <div className='account__avatar-overlay'>
        <div className='account__avatar-overlay-base' style={baseStyle} />
        <div className='account__avatar-overlay-overlay account__avatar-composite' >
          {accounts.take(4).map((dm_account, i) => this.renderItem(dm_account, accounts.size, i))}
        </div>
      </div>
    );
  }

}
