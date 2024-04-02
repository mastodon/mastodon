import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl, defineMessages } from 'react-intl';

import classNames from 'classnames';

import Overlay from 'react-overlays/Overlay';

import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import LockIcon from '@/material-icons/400-24px/lock.svg?react';
import PublicIcon from '@/material-icons/400-24px/public.svg?react';
import QuietTimeIcon from '@/material-icons/400-24px/quiet_time.svg?react';
import { Icon }  from 'mastodon/components/icon';

import { PrivacyDropdownMenu } from './privacy_dropdown_menu';

const messages = defineMessages({
  public_short: { id: 'privacy.public.short', defaultMessage: 'Public' },
  public_long: { id: 'privacy.public.long', defaultMessage: 'Anyone on and off Mastodon' },
  unlisted_short: { id: 'privacy.unlisted.short', defaultMessage: 'Quiet public' },
  unlisted_long: { id: 'privacy.unlisted.long', defaultMessage: 'Fewer algorithmic fanfares' },
  private_short: { id: 'privacy.private.short', defaultMessage: 'Followers' },
  private_long: { id: 'privacy.private.long', defaultMessage: 'Only your followers' },
  direct_short: { id: 'privacy.direct.short', defaultMessage: 'Specific people' },
  direct_long: { id: 'privacy.direct.long', defaultMessage: 'Everyone mentioned in the post' },
  change_privacy: { id: 'privacy.change', defaultMessage: 'Change post privacy' },
  unlisted_extra: { id: 'privacy.unlisted.additional', defaultMessage: 'This behaves exactly like public, except the post will not appear in live feeds or hashtags, explore, or Mastodon search, even if you are opted-in account-wide.' },
});

class PrivacyDropdown extends PureComponent {

  static propTypes = {
    isUserTouching: PropTypes.func,
    onModalOpen: PropTypes.func,
    onModalClose: PropTypes.func,
    value: PropTypes.string.isRequired,
    onChange: PropTypes.func.isRequired,
    noDirect: PropTypes.bool,
    container: PropTypes.func,
    disabled: PropTypes.bool,
    intl: PropTypes.object.isRequired,
  };

  state = {
    open: false,
    placement: 'bottom',
  };

  handleToggle = () => {
    if (this.state.open && this.activeElement) {
      this.activeElement.focus({ preventScroll: true });
    }

    this.setState({ open: !this.state.open });
  };

  handleKeyDown = e => {
    switch(e.key) {
    case 'Escape':
      this.handleClose();
      break;
    }
  };

  handleMouseDown = () => {
    if (!this.state.open) {
      this.activeElement = document.activeElement;
    }
  };

  handleButtonKeyDown = (e) => {
    switch(e.key) {
    case ' ':
    case 'Enter':
      this.handleMouseDown();
      break;
    }
  };

  handleClose = () => {
    if (this.state.open && this.activeElement) {
      this.activeElement.focus({ preventScroll: true });
    }
    this.setState({ open: false });
  };

  handleChange = value => {
    this.props.onChange(value);
  };

  UNSAFE_componentWillMount () {
    const { intl: { formatMessage } } = this.props;

    this.options = [
      { icon: 'globe', iconComponent: PublicIcon, value: 'public', text: formatMessage(messages.public_short), meta: formatMessage(messages.public_long) },
      { icon: 'unlock', iconComponent: QuietTimeIcon,  value: 'unlisted', text: formatMessage(messages.unlisted_short), meta: formatMessage(messages.unlisted_long), extra: formatMessage(messages.unlisted_extra) },
      { icon: 'lock', iconComponent: LockIcon, value: 'private', text: formatMessage(messages.private_short), meta: formatMessage(messages.private_long) },
    ];

    if (!this.props.noDirect) {
      this.options.push(
        { icon: 'at', iconComponent: AlternateEmailIcon, value: 'direct', text: formatMessage(messages.direct_short), meta: formatMessage(messages.direct_long) },
      );
    }
  }

  setTargetRef = c => {
    this.target = c;
  };

  findTarget = () => {
    return this.target;
  };

  handleOverlayEnter = (state) => {
    this.setState({ placement: state.placement });
  };

  render () {
    const { value, container, disabled, intl } = this.props;
    const { open, placement } = this.state;

    const valueOption = this.options.find(item => item.value === value);

    return (
      <div ref={this.setTargetRef} onKeyDown={this.handleKeyDown}>
        <button
          type='button'
          title={intl.formatMessage(messages.change_privacy)}
          aria-expanded={open}
          onClick={this.handleToggle}
          onMouseDown={this.handleMouseDown}
          onKeyDown={this.handleButtonKeyDown}
          disabled={disabled}
          className={classNames('dropdown-button', { active: open })}
        >
          <Icon id={valueOption.icon} icon={valueOption.iconComponent} />
          <span className='dropdown-button__label'>{valueOption.text}</span>
        </button>

        <Overlay show={open} offset={[5, 5]} placement={placement} flip target={this.findTarget} container={container} popperConfig={{ strategy: 'fixed', onFirstUpdate: this.handleOverlayEnter }}>
          {({ props, placement }) => (
            <div {...props}>
              <div className={`dropdown-animation privacy-dropdown__dropdown ${placement}`}>
                <PrivacyDropdownMenu
                  items={this.options}
                  value={value}
                  onClose={this.handleClose}
                  onChange={this.handleChange}
                />
              </div>
            </div>
          )}
        </Overlay>
      </div>
    );
  }

}

export default injectIntl(PrivacyDropdown);
