import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';

class SettingsItem extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    item: PropTypes.array.isRequired,
    id: PropTypes.string.isRequired,
    dependsOn: PropTypes.array,
    dependsOnNot: PropTypes.array,
    children: PropTypes.element.isRequired,
    onChange: PropTypes.func.isRequired,
  };

  handleChange = (e) => {
    const { item, onChange } = this.props;
    onChange(item, e);
  }

  render () {
    const { settings, item, id, children, dependsOn, dependsOnNot } = this.props;
    let enabled = true;

    if (dependsOn) {
      for (let i = 0; i < dependsOn.length; i++) {
        enabled = enabled && settings.getIn(dependsOn[i]);
      }
    }
    if (dependsOnNot) {
      for (let i = 0; i < dependsOnNot.length; i++) {
        enabled = enabled && !settings.getIn(dependsOnNot[i]);
      }
    }

    return (
      <label htmlFor={id}>
        <input
          id={id}
          type='checkbox'
          checked={settings.getIn(item)}
          onChange={this.handleChange}
          disabled={!enabled}
        />
        {children}
      </label>
    );
  }

}

export default class SettingsModal extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    toggleSetting: PropTypes.func.isRequired,
    onClose: PropTypes.func.isRequired,
  };

  state = {
    currentIndex: 0,
  };

  General = () => {
    return (
      <div>
        <h1><FormattedMessage id='settings.general' defaultMessage='General' /></h1>
        <SettingsItem
          settings={this.props.settings}
          item={['stretch']}
          id='mastodon-settings--stretch'
          onChange={this.props.toggleSetting}
        >
          <FormattedMessage id='settings.wide_view' defaultMessage='Wide view (Desktop mode only)' />
        </SettingsItem>
      </div>
    );
  }

  CollapsedStatuses = () => {
    return (
      <div>
        <h1><FormattedMessage id='settings.collapsed_statuses' defaultMessage='Collapsed toots' /></h1>
        <SettingsItem
          settings={this.props.settings}
          item={['collapsed', 'enabled']}
          id='mastodon-settings--collapsed-enabled'
          onChange={this.props.toggleSetting}
        >
          <FormattedMessage id='settings.enable_collapsed' defaultMessage='Enable collapsed toots' />
        </SettingsItem>
        <section>
          <h2><FormattedMessage id='settings.auto_collapse' defaultMessage='Automatic collapsing' /></h2>
          <SettingsItem
            settings={this.props.settings}
            item={['collapsed', 'auto', 'all']}
            id='mastodon-settings--collapsed-auto-all'
            onChange={this.props.toggleSetting}
            dependsOn={[['collapsed', 'enabled']]}
          >
            <FormattedMessage id='settings.auto_collapse_all' defaultMessage='Everything' />
          </SettingsItem>
          <SettingsItem
            settings={this.props.settings}
            item={['collapsed', 'auto', 'notifications']}
            id='mastodon-settings--collapsed-auto-notifications'
            onChange={this.props.toggleSetting}
            dependsOn={[['collapsed', 'enabled']]}
            dependsOnNot={[['collapsed', 'auto', 'all']]}
          >
            <FormattedMessage id='settings.auto_collapse_notifications' defaultMessage='Notifications' />
          </SettingsItem>
          <SettingsItem
            settings={this.props.settings}
            item={['collapsed', 'auto', 'lengthy']}
            id='mastodon-settings--collapsed-auto-lengthy'
            onChange={this.props.toggleSetting}
            dependsOn={[['collapsed', 'enabled']]}
            dependsOnNot={[['collapsed', 'auto', 'all']]}
          >
            <FormattedMessage id='settings.auto_collapse_lengthy' defaultMessage='Lengthy toots' />
          </SettingsItem>
          <SettingsItem
            settings={this.props.settings}
            item={['collapsed', 'auto', 'replies']}
            id='mastodon-settings--collapsed-auto-replies'
            onChange={this.props.toggleSetting}
            dependsOn={[['collapsed', 'enabled']]}
            dependsOnNot={[['collapsed', 'auto', 'all']]}
          >
            <FormattedMessage id='settings.auto_collapse_replies' defaultMessage='Replies' />
          </SettingsItem>
          <SettingsItem
            settings={this.props.settings}
            item={['collapsed', 'auto', 'media']}
            id='mastodon-settings--collapsed-auto-media'
            onChange={this.props.toggleSetting}
            dependsOn={[['collapsed', 'enabled']]}
            dependsOnNot={[['collapsed', 'auto', 'all']]}
          >
            <FormattedMessage id='settings.auto_collapse_media' defaultMessage='Toots with media' />
          </SettingsItem>
        </section>
        <section>
          <h2><FormattedMessage id='settings.image_backgrounds' defaultMessage='Image backgrounds' /></h2>
          <SettingsItem
            settings={this.props.settings}
            item={['collapsed', 'backgrounds', 'user_backgrounds']}
            id='mastodon-settings--collapsed-user-backgrouns'
            onChange={this.props.toggleSetting}
            dependsOn={[['collapsed', 'enabled']]}
          >
            <FormattedMessage id='settings.image_backgrounds_users' defaultMessage='Give collapsed toots an image background' />
          </SettingsItem>
          <SettingsItem
            settings={this.props.settings}
            item={['collapsed', 'backgrounds', 'preview_images']}
            id='mastodon-settings--collapsed-preview-images'
            onChange={this.props.toggleSetting}
            dependsOn={[['collapsed', 'enabled']]}
          >
            <FormattedMessage id='settings.image_backgrounds_media' defaultMessage='Preview collapsed toot media' />
          </SettingsItem>
        </section>
      </div>
    );
  }

  Media = () => {
    return (
      <div>
        <h1><FormattedMessage id='settings.media' defaultMessage='Media' /></h1>
        <SettingsItem
          settings={this.props.settings}
          item={['media', 'letterbox']}
          id='mastodon-settings--media-letterbox'
          onChange={this.props.toggleSetting}
        >
          <FormattedMessage id='settings.media_letterbox' defaultMessage='Letterbox media' />
        </SettingsItem>
      </div>
    );
  }

  navigateTo = (e) =>
    this.setState({ currentIndex: +e.currentTarget.getAttribute('data-mastodon-navigation_index') });

  render () {

    const { General, CollapsedStatuses, Media, navigateTo } = this;
    const { onClose } = this.props;
    const { currentIndex } = this.state;

    return (
      <div className='modal-root__modal settings-modal'>

        <nav className='settings-modal__navigation'>
          <a onClick={navigateTo} role='button' data-mastodon-navigation_index='0' tabIndex='0' className={`settings-modal__navigation-item${currentIndex === 0 ? ' active' : ''}`}>
            <FormattedMessage id='settings.general' defaultMessage='General' />
          </a>
          <a onClick={navigateTo} role='button' data-mastodon-navigation_index='1' tabIndex='0' className={`settings-modal__navigation-item${currentIndex === 1 ? ' active' : ''}`}>
            <FormattedMessage id='settings.collapsed_statuses' defaultMessage='Collapsed toots' />
          </a>
          <a onClick={navigateTo} role='button' data-mastodon-navigation_index='2' tabIndex='0' className={`settings-modal__navigation-item${currentIndex === 2 ? ' active' : ''}`}>
            <FormattedMessage id='settings.media' defaultMessage='Media' />
          </a>
          <a href='/settings/preferences' className='settings-modal__navigation-item'>
            <i className='fa fa-fw fa-cog' /> <FormattedMessage id='settings.preferences' defaultMessage='User preferences' />
          </a>
          <a onClick={onClose} role='button' tabIndex='0' className='settings-modal__navigation-close'>
            <FormattedMessage id='settings.close' defaultMessage='Close' />
          </a>

        </nav>

        <div className='settings-modal__content'>
          {
            [
              <General />,
              <CollapsedStatuses />,
              <Media />,
            ][currentIndex] || <General />
          }
        </div>

      </div>
    );
  }

}
