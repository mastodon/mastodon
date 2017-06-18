import React from 'react';
import PropTypes from 'prop-types';
import { injectIntl, defineMessages } from 'react-intl';
import IconButton from '../../../components/icon_button';

const messages = defineMessages({
  public_short: { id: 'privacy.public.short', defaultMessage: 'Public' },
  public_long: { id: 'privacy.public.long', defaultMessage: 'Post to public timelines' },
  unlisted_short: { id: 'privacy.unlisted.short', defaultMessage: 'Unlisted' },
  unlisted_long: { id: 'privacy.unlisted.long', defaultMessage: 'Do not show in public timelines' },
  private_short: { id: 'privacy.private.short', defaultMessage: 'Followers-only' },
  private_long: { id: 'privacy.private.long', defaultMessage: 'Post to followers only' },
  direct_short: { id: 'privacy.direct.short', defaultMessage: 'Direct' },
  direct_long: { id: 'privacy.direct.long', defaultMessage: 'Post to mentioned users only' },
  change_privacy: { id: 'privacy.change', defaultMessage: 'Adjust status privacy' },
});

const iconStyle = {
  height: null,
  lineHeight: '27px',
};

class PrivacyDropdown extends React.PureComponent {

  static propTypes = {
    value: PropTypes.string.isRequired,
    onChange: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    open: false,
  };

  handleToggle = () => {
    this.setState({ open: !this.state.open });
  }

  handleClick = (e) => {
    const value = e.currentTarget.getAttribute('data-index');
    e.preventDefault();
    this.setState({ open: false });
    this.props.onChange(value);
  }

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

  setRef = (c) => {
    this.node = c;
  }

  render () {
    const { value, onChange, intl } = this.props;
    const { open } = this.state;

    const options = [
      { icon: 'globe', value: 'public', shortText: intl.formatMessage(messages.public_short), longText: intl.formatMessage(messages.public_long) },
      { icon: 'unlock-alt', value: 'unlisted', shortText: intl.formatMessage(messages.unlisted_short), longText: intl.formatMessage(messages.unlisted_long) },
      { icon: 'lock', value: 'private', shortText: intl.formatMessage(messages.private_short), longText: intl.formatMessage(messages.private_long) },
      { icon: 'envelope', value: 'direct', shortText: intl.formatMessage(messages.direct_short), longText: intl.formatMessage(messages.direct_long) },
    ];

    const valueOption = options.find(item => item.value === value);

    return (
      <div ref={this.setRef} className={`privacy-dropdown ${open ? 'active' : ''}`}>
        <div className='privacy-dropdown__value'><IconButton className='privacy-dropdown__value-icon' icon={valueOption.icon} title={intl.formatMessage(messages.change_privacy)} size={18} active={open} inverted onClick={this.handleToggle} style={iconStyle} /></div>
        <div className='privacy-dropdown__dropdown'>
          {open && options.map(item =>
            <div role='button' tabIndex='0' key={item.value} data-index={item.value} onClick={this.handleClick} className={`privacy-dropdown__option ${item.value === value ? 'active' : ''}`}>
              <div className='privacy-dropdown__option__icon'><i className={`fa fa-fw fa-${item.icon}`} /></div>
              <div className='privacy-dropdown__option__content'>
                <strong>{item.shortText}</strong>
                {item.longText}
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }

}

export default injectIntl(PrivacyDropdown);
