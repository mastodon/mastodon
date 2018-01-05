import classNames from 'classnames';
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { autoPlayGif } from 'flavours/glitch/util/initial_state';

export default class Avatar extends React.PureComponent {

  static propTypes = {
    account: ImmutablePropTypes.map.isRequired,
    className: PropTypes.string,
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
    const {
      account,
      animate,
      className,
      inline,
      size,
    } = this.props;
    const { hovering } = this.state;

    const src = account.get('avatar');
    const staticSrc = account.get('avatar_static');

    const computedClass = classNames('account__avatar', { 'account__avatar-inline': inline }, className);

    const style = {
      ...this.props.style,
      width: `${size}px`,
      height: `${size}px`,
      backgroundSize: `${size}px ${size}px`,
    };

    if (hovering || animate) {
      style.backgroundImage = `url(${src})`;
    } else {
      style.backgroundImage = `url(${staticSrc})`;
    }

    return (
      <div
        className={computedClass}
        onMouseEnter={this.handleMouseEnter}
        onMouseLeave={this.handleMouseLeave}
        style={style}
        data-avatar-of={`@${account.get('acct')}`}
      />
    );
  }

}
