import React from 'react';
import IconButton from '../../../components/icon_button';

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

export default class AdvancedOptionsDropdown extends React.PureComponent {
  onToggleDropdown = () => {
      this.setState({ open: !this.state.open });
  };

  onGlobalClick = (e) => {
    if (e.target !== this.node && !this.node.contains(e.target) && this.state.open) {
      this.setState({ open: false });
    }
  }

  componentDidMount () {
    window.addEventListener('click', this.onGlobalClick);
    window.addEventListener('touchstart', this.onGlobalClick);
  }

  componentWillUnmount () {
    window.removeEventListener('click', this.onGlobalClick);
    window.removeEventListener('touchstart', this.onGlobalClick);
  }

  state = {
    open: false,
  };

  setRef = (c) => {
    this.node = c;
  }

  render () {
    const { open } = this.state;

    const options = [
      { icon: 'wifi', shortText: 'Local-only', longText: 'bla' },
    ];
    const optionElems = options.map((option) => {
      return <div role='button' className='advanced-options-dropdown__option'>
        <div className='advanced-options-dropdown__option__icon'>
          <IconButton icon={option.icon} />
        </div>
        <div className='advanced-options-dropdown__option__content'>
          <strong>{option.shortText}</strong>
          {option.longText}
        </div>
      </div>;
    });
    return <div ref={this.setRef} className={`advanced-options-dropdown ${open ? 'active' : ''}`}>
      <div className='advanced-options-dropdown__value'>
        <IconButton className='advanced-options-dropdown__value'
          icon='ellipsis-h' active={open}
          size={18} inverted
          style={iconStyle}
          onClick={this.onToggleDropdown} />
      </div>
      <div className='advanced-options-dropdown__dropdown'>
        {optionElems}
      </div>
    </div>;
  }
}