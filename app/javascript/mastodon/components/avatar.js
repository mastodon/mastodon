import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { autoPlayGif } from '../initial_state';
import classNames from 'classnames';

export default class Avatar extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map,
    size: PropTypes.number.isRequired,
    style: PropTypes.object,
    inline: PropTypes.bool,
    animate: PropTypes.bool,
  };

  static defaultProps = {
    animate: autoPlayGif,
    size: 20,
    inline: false,
  };

  state = {
    hovering: false,
  };

  handleMouseEnter = () => {
    if (this.props.animate) return;
    this.setState({ hovering: true });
  }

  handleMouseLeave = () => {
    if (this.props.animate) return;
    this.setState({ hovering: false });
  }

  render () {
    const { account, size, animate, inline } = this.props;
    const { hovering } = this.state;

    const style = {
      ...this.props.style,
      width: `${size}px`,
      height: `${size}px`,
    };

    let src;

    if (hovering || animate) {
      src = account?.get('avatar');
    } else {
      src = account?.get('avatar_static');
    }

    return (
      <div className={classNames('account__avatar', { 'account__avatar-inline': inline })} onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave} style={style}>
        {src && <img src={src} alt={account?.get('acct')} />}
      </div>
    );
  }

}
