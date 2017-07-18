//  Package imports  //
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';

import './stylesheet';

//  Our imports  //
import SettingsItem from './item';

const messages = defineMessages({
  layout_auto: {  id: 'layout.auto', defaultMessage: 'Auto' },
  layout_desktop: { id: 'layout.desktop', defaultMessage: 'Desktop' },
  layout_mobile: { id: 'layout.single', defaultMessage: 'Mobile' },
});

@injectIntl
export default class Settings extends React.PureComponent {

  static propTypes = {
    settings: ImmutablePropTypes.map.isRequired,
    toggleSetting: PropTypes.func.isRequired,
    changeSetting: PropTypes.func.isRequired,
    onClose: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    currentIndex: 0,
  };

  General = () => {
    const { intl } = this.props;
    return (
      <div>
        <h1><FormattedMessage id='settings.general' defaultMessage='General' /></h1>
        <SettingsItem
          settings={this.props.settings}
          item={['layout']}
          id='mastodon-settings--layout'
          options={[
            { value: 'auto', message: intl.formatMessage(messages.layout_auto) },
            { value: 'multiple', message: intl.formatMessage(messages.layout_desktop) },
            { value: 'single', message: intl.formatMessage(messages.layout_mobile) },
          ]}
          onChange={this.props.changeSetting}
        >
          <FormattedMessage id='settings.layout' defaultMessage='Layout:' />
        </SettingsItem>

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
        <SettingsItem
          settings={this.props.settings}
          item={['media', 'fullwidth']}
          id='mastodon-settings--media-fullwidth'
          onChange={this.props.toggleSetting}
        >
          <FormattedMessage id='settings.media_fullwidth' defaultMessage='Full-width media previews' />
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
