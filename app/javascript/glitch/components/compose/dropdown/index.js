//  Package imports  //
import React from 'react';
import PropTypes from 'prop-types';

//  Mastodon imports  //
import IconButton from '../../../../mastodon/components/icon_button';

const iconStyle = {
  height     : null,
  lineHeight : '27px',
};

export default class ComposeDropdown extends React.PureComponent {

  static propTypes = {
    title: PropTypes.string.isRequired,
    icon: PropTypes.string,
    highlight: PropTypes.bool,
    disabled: PropTypes.bool,
    children: PropTypes.arrayOf(PropTypes.node).isRequired,
  };

  state = {
    open: false,
  };

  onGlobalClick = (e) => {
    if (e.target !== this.node && !this.node.contains(e.target) && this.state.open) {
      this.setState({ open: false });
    }
  };

  componentDidMount () {
    window.addEventListener('click', this.onGlobalClick);
    window.addEventListener('touchstart', this.onGlobalClick);
  }
  componentWillUnmount () {
    window.removeEventListener('click', this.onGlobalClick);
    window.removeEventListener('touchstart', this.onGlobalClick);
  }

  onToggleDropdown = () => {
    if (this.props.disabled) return;
    this.setState({ open: !this.state.open });
  };

  setRef = (c) => {
    this.node = c;
  };

  render () {
    const { open } = this.state;
    let { highlight, title, icon, disabled } = this.props;

    if (!icon) icon = 'ellipsis-h';

    return (
      <div ref={this.setRef} className={`advanced-options-dropdown ${open ?  'open' : ''} ${highlight ? 'active' : ''} `}>
        <div className='advanced-options-dropdown__value'>
          <IconButton
            className={'inverted'}
            title={title}
            icon={icon} active={open || highlight}
            size={18}
            style={iconStyle}
            disabled={disabled}
            onClick={this.onToggleDropdown}
          />
        </div>
        <div className='advanced-options-dropdown__dropdown'>
          {this.props.children}
        </div>
      </div>
    );
  }

}
