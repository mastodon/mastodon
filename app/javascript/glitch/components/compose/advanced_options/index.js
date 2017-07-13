//  Package imports  //
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Toggle from 'react-toggle';
import { injectIntl, defineMessages } from 'react-intl';

//  Mastodon imports  //
import IconButton from '../../../../mastodon/components/icon_button';

const messages = defineMessages({
  local_only_short: { id: 'advanced-options.local-only.short', defaultMessage: 'Local-only' },
  local_only_long: { id: 'advanced-options.local-only.long', defaultMessage: 'Do not post to other instances' },
  advanced_options_icon_title: { id: 'advanced_options.icon_title', defaultMessage: 'Advanced options' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

class AdvancedOptionToggle extends React.PureComponent {

  static propTypes = {
    onChange: PropTypes.func.isRequired,
    active: PropTypes.bool.isRequired,
    name: PropTypes.string.isRequired,
    shortText: PropTypes.string.isRequired,
    longText: PropTypes.string.isRequired,
  }

  onToggle = () => {
    this.props.onChange(this.props.name);
  }

  render() {
    const { active, shortText, longText } = this.props;
    return (
      <div role='button' tabIndex='0' className='advanced-options-dropdown__option' onClick={this.onToggle}>
        <div className='advanced-options-dropdown__option__toggle'>
          <Toggle checked={active} onChange={this.onToggle} />
        </div>
        <div className='advanced-options-dropdown__option__content'>
          <strong>{shortText}</strong>
          {longText}
        </div>
      </div>
    );
  }

}

@injectIntl
export default class ComposeAdvancedOptions extends React.PureComponent {

  static propTypes = {
    values: ImmutablePropTypes.contains({
      do_not_federate: PropTypes.bool.isRequired,
    }).isRequired,
    onChange: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

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

  handleClick = (e) => {
    const option = e.currentTarget.getAttribute('data-index');
    e.preventDefault();
    this.props.onChange(option);
  }

  setRef = (c) => {
    this.node = c;
  }

  render () {
    const { open } = this.state;
    const { intl, values } = this.props;

    const options = [
      { icon: 'wifi', shortText: messages.local_only_short, longText: messages.local_only_long, key: 'do_not_federate' },
    ];

    const anyEnabled = values.some((enabled) => enabled);
    const optionElems = options.map((option) => {
      return (
        <AdvancedOptionToggle
          onChange={this.props.onChange}
          active={values.get(option.key)}
          key={option.key}
          name={option.key}
          shortText={intl.formatMessage(option.shortText)}
          longText={intl.formatMessage(option.longText)}
        />
      );
    });

    return (<div ref={this.setRef} className={`advanced-options-dropdown ${open ?  'open' : ''} ${anyEnabled ? 'active' : ''} `}>
      <div className='advanced-options-dropdown__value'>
        <IconButton
          className='advanced-options-dropdown__value'
          title={intl.formatMessage(messages.advanced_options_icon_title)}
          icon='ellipsis-h' active={open || anyEnabled}
          size={18}
          style={iconStyle}
          onClick={this.onToggleDropdown}
        />
      </div>
      <div className='advanced-options-dropdown__dropdown'>
        {optionElems}
      </div>
    </div>);
  }

}
