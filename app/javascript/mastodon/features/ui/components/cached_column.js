import React from 'react';
import PropTypes from 'prop-types';

export default class CachedColumn extends React.Component {

  static propTypes = {
    component: PropTypes.func.isRequired,
    children: PropTypes.node,
    visible: PropTypes.bool,
  }

  constructor (props) {
    super(props);
    this.state = {
      mounting: props.visible,
    };
  }

  updateMountingState = () => {
    this.setState((prevState, props) => ({
      mounting: props.visible,
    }));
  }

  setTimer () {
    if (this.timer !== null) clearTimeout(this.timer);
    this.timer = setTimeout(this.updateMountingState, 5 * 60 * 1000);
  }

  clearTimer () {
    if (this.state.timer) {
      clearTimeout(this.state.timer);
      this.timer = null;
    }
  }

  componentWillUnmount () {
    this.clearTimer();
  }

  componentWillReceiveProps (nextProps) {
    if (this.props.visible !== nextProps.visible) {
      if (nextProps.visible) {
        this.clearTimer();
        this.updateMountingState();
      } else {
        this.setTimer();
      }
    }
  }

  render () {
    const { component: Component, children, visible, ...other } = this.props;
    const { mounting } = this.state;

    if (visible || mounting) {
      return <Component visible={visible} {...other}>{children}</Component>;
    } else {
      return null;
    }
  }

}
