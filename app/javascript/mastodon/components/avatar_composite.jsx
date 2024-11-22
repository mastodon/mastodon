import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import ImmutablePropTypes from 'react-immutable-proptypes';

import { autoPlayGif } from '../initial_state';

import { Avatar } from './avatar';

export default class AvatarComposite extends PureComponent {

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
        right = '1px';
      } else {
        left = '1px';
      }
    } else if (size === 3) {
      if (index === 0) {
        right = '1px';
      } else if (index > 0) {
        left = '1px';
      }

      if (index === 1) {
        bottom = '1px';
      } else if (index > 1) {
        top = '1px';
      }
    } else if (size === 4) {
      if (index === 0 || index === 2) {
        right = '1px';
      }

      if (index === 1 || index === 3) {
        left = '1px';
      }

      if (index < 2) {
        bottom = '1px';
      } else {
        top = '1px';
      }
    }

    const style = {
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: `${width}%`,
      height: `${height}%`,
    };

    return (
      <div key={account.get('id')} style={style}>
        <Avatar account={account} animate={animate} />
      </div>
    );
  }

  render() {
    const { accounts, size } = this.props;

    return (
      <div className='account__avatar-composite' style={{ width: `${size}px`, height: `${size}px` }}>
        {accounts.take(4).map((account, i) => this.renderItem(account, Math.min(accounts.size, 4), i))}

        {accounts.size > 4 && (
          <span className='account__avatar-composite__label'>
            +{accounts.size - 4}
          </span>
        )}
      </div>
    );
  }

}
