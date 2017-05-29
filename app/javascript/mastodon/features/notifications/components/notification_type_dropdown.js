import React from 'react';
import Dropdown, { DropdownTrigger, DropdownContent } from 'react-simple-dropdown';
import PropTypes from 'prop-types';
import { injectIntl, defineMessages } from 'react-intl';
import IconButton from '../../../components/icon_button';

const messages = defineMessages({
  all: { id: 'notifications.type.all', defaultMessage: 'All' },
  mention: { id: 'notifications.type.mention', defaultMessage: 'Mention' },
  status: { id: 'notifications.type.status', defaultMessage: 'Reblog' },
  follow: { id: 'notifications.type.follow', defaultMessage: 'Follow' },
  follow_request: { id: 'notifications.type.follow_request', defaultMessage: 'Follow Request' },
  favourite: { id: 'notifications.type.favourite', defaultMessage: 'Favourite' },
  change_notification: { id: 'notifications.change', defaultMessage: 'Change Notification Type' }
});

const iconStyle = {
  lineHeight: '27px',
  height: null
};

class NotificationTypeDropdown extends React.Component {
  static propTypes = {
    onClick: PropTypes.func.isRequired
  };

  state = {
    open: false,
  };

  setRef = (c) => {
    this.dropdown = c;
  }

  mixins: [PureRenderMixin]

  handleToggle = () => {
    this.setState({ open: !this.state.open });
  }

  handleClick = (value, e) => {
    e.preventDefault();
    this.setState({ open: false });
    console.log(this.dropdown);
    this.dropdown.hide();
    this.props.onClick(value);
  }

  onHideDropdown = () => {
    this.setState({active: false});
  }

  render () {
    const { value, onClick, intl } = this.props;
    const { open } = this.state;

    const options = [
      { icon: 'globe', value: '', shortText: intl.formatMessage(messages.all) },
      { icon: 'at', value: 'Mention', shortText: intl.formatMessage(messages.mention) },
      { icon: 'retweet', value: 'Status', shortText: intl.formatMessage(messages.status) },
      { icon: 'user-plus', value: 'Follow', shortText: intl.formatMessage(messages.follow) },
      { icon: 'handshake-o', value: 'FollowRequest', shortText: intl.formatMessage(messages.follow_request) },
      { icon: 'star', value: 'Favourite', shortText: intl.formatMessage(messages.favourite) }
    ];

    const valueOption = options.find(item => item.value === value);

    return (
      <Dropdown ref={this.setRef} className='column-icon-change notification-type-dropdown' onShow={this.onShowDropdown} onHide={this.onHideDropdown}>
        <DropdownTrigger className='notification-filter-button' title={intl.formatMessage(messages.change_notification)}>
            <IconButton icon='filter' title={intl.formatMessage(messages.change_notification)} size={18} active={open} inverted onClick={this.handleToggle} style={iconStyle} />
        </DropdownTrigger>
        <DropdownContent className='notification-type-dropdown__dropdown'>
          {options.map(item =>
            <div role='button' tabIndex='0' key={item.value} onClick={this.handleClick.bind(this, item.value)} className={`notification-type-dropdown__option ${item.value === value ? 'active' : ''}`}>
              <div className='notification-type-dropdown__option__icon'><i className={`fa fa-fw fa-${item.icon}`} /></div>
              <div className='notification-type-dropdown__option__content'>
                <strong>{item.shortText}</strong>
              </div>
            </div>
          )}
        </DropdownContent>
      </Dropdown>
    );
  }

}

export default injectIntl(NotificationTypeDropdown);
