import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { autoPlayGif } from '../initial_state';

export default class AvatarComposite extends React.PureComponent {

  static propTypes = {
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
        right = '2px';
      } else {
        left = '2px';
      }
    } else if (size === 3) {
      if (index === 0) {
        right = '2px';
      } else if (index > 0) {
        left = '2px';
      }

      if (index === 1) {
        bottom = '2px';
      } else if (index > 1) {
        top = '2px';
      }
    } else if (size === 4) {
      if (index === 0 || index === 2) {
        right = '2px';
      }

      if (index === 1 || index === 3) {
        left = '2px';
      }

      if (index < 2) {
        bottom = '2px';
      } else {
        top = '2px';
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
    const { accounts, size } = this.props;

    return (
      <div className='account__avatar-composite' style={{ width: `${size}px`, height: `${size}px` }}>
        {accounts.take(4).map((account, i) => this.renderItem(account, accounts.size, i))}
      </div>
    );
  }

}
