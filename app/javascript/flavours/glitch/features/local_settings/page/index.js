//  Package imports
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';

//  Our imports
import LocalSettingsPageItem from './item';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

const messages = defineMessages({
  layout_auto: {  id: 'layout.auto', defaultMessage: 'Auto' },
  layout_desktop: { id: 'layout.desktop', defaultMessage: 'Desktop' },
  layout_mobile: { id: 'layout.single', defaultMessage: 'Mobile' },
  side_arm_none: { id: 'settings.side_arm.none', defaultMessage: 'None' },
});

@injectIntl
export default class LocalSettingsPage extends React.PureComponent {

  static propTypes = {
    index    : PropTypes.number,
    intl     : PropTypes.object.isRequired,
    onChange : PropTypes.func.isRequired,
    settings : ImmutablePropTypes.map.isRequired,
  };

  pages = [
    ({ intl, onChange, settings }) => (
      <div className='glitch local-settings__page general'>
        <h1><FormattedMessage id='settings.general' defaultMessage='General' /></h1>
        <LocalSettingsPageItem
          settings={settings}
          item={['layout']}
          id='mastodon-settings--layout'
          options={[
            { value: 'auto', message: intl.formatMessage(messages.layout_auto) },
            { value: 'multiple', message: intl.formatMessage(messages.layout_desktop) },
            { value: 'single', message: intl.formatMessage(messages.layout_mobile) },
          ]}
          onChange={onChange}
        >
          <FormattedMessage id='settings.layout' defaultMessage='Layout:' />
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['stretch']}
          id='mastodon-settings--stretch'
          onChange={onChange}
        >
          <FormattedMessage id='settings.wide_view' defaultMessage='Wide view (Desktop mode only)' />
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['navbar_under']}
          id='mastodon-settings--navbar_under'
          onChange={onChange}
        >
          <FormattedMessage id='settings.navbar_under' defaultMessage='Navbar at the bottom (Mobile only)' />
        </LocalSettingsPageItem>
        <section>
          <h2><FormattedMessage id='settings.compose_box_opts' defaultMessage='Compose box options' /></h2>
          <LocalSettingsPageItem
            settings={settings}
            item={['side_arm']}
            id='mastodon-settings--side_arm'
            options={[
              { value: 'none', message: intl.formatMessage(messages.side_arm_none) },
              { value: 'direct', message: intl.formatMessage({ id: 'privacy.direct.short' }) },
              { value: 'private', message: intl.formatMessage({ id: 'privacy.private.short' }) },
              { value: 'unlisted', message: intl.formatMessage({ id: 'privacy.unlisted.short' }) },
              { value: 'public', message: intl.formatMessage({ id: 'privacy.public.short' }) },
            ]}
            onChange={onChange}
          >
            <FormattedMessage id='settings.side_arm' defaultMessage='Secondary toot button:' />
          </LocalSettingsPageItem>
        </section>
      </div>
    ),
    ({ onChange, settings }) => (
      <div className='glitch local-settings__page collapsed'>
        <h1><FormattedMessage id='settings.collapsed_statuses' defaultMessage='Collapsed toots' /></h1>
        <LocalSettingsPageItem
          settings={settings}
          item={['collapsed', 'enabled']}
          id='mastodon-settings--collapsed-enabled'
          onChange={onChange}
        >
          <FormattedMessage id='settings.enable_collapsed' defaultMessage='Enable collapsed toots' />
        </LocalSettingsPageItem>
        <section>
          <h2><FormattedMessage id='settings.auto_collapse' defaultMessage='Automatic collapsing' /></h2>
          <LocalSettingsPageItem
            settings={settings}
            item={['collapsed', 'auto', 'all']}
            id='mastodon-settings--collapsed-auto-all'
            onChange={onChange}
            dependsOn={[['collapsed', 'enabled']]}
          >
            <FormattedMessage id='settings.auto_collapse_all' defaultMessage='Everything' />
          </LocalSettingsPageItem>
          <LocalSettingsPageItem
            settings={settings}
            item={['collapsed', 'auto', 'notifications']}
            id='mastodon-settings--collapsed-auto-notifications'
            onChange={onChange}
            dependsOn={[['collapsed', 'enabled']]}
            dependsOnNot={[['collapsed', 'auto', 'all']]}
          >
            <FormattedMessage id='settings.auto_collapse_notifications' defaultMessage='Notifications' />
          </LocalSettingsPageItem>
          <LocalSettingsPageItem
            settings={settings}
            item={['collapsed', 'auto', 'lengthy']}
            id='mastodon-settings--collapsed-auto-lengthy'
            onChange={onChange}
            dependsOn={[['collapsed', 'enabled']]}
            dependsOnNot={[['collapsed', 'auto', 'all']]}
          >
            <FormattedMessage id='settings.auto_collapse_lengthy' defaultMessage='Lengthy toots' />
          </LocalSettingsPageItem>
          <LocalSettingsPageItem
            settings={settings}
            item={['collapsed', 'auto', 'reblogs']}
            id='mastodon-settings--collapsed-auto-reblogs'
            onChange={onChange}
            dependsOn={[['collapsed', 'enabled']]}
            dependsOnNot={[['collapsed', 'auto', 'all']]}
          >
            <FormattedMessage id='settings.auto_collapse_reblogs' defaultMessage='Boosts' />
          </LocalSettingsPageItem>
          <LocalSettingsPageItem
            settings={settings}
            item={['collapsed', 'auto', 'replies']}
            id='mastodon-settings--collapsed-auto-replies'
            onChange={onChange}
            dependsOn={[['collapsed', 'enabled']]}
            dependsOnNot={[['collapsed', 'auto', 'all']]}
          >
            <FormattedMessage id='settings.auto_collapse_replies' defaultMessage='Replies' />
          </LocalSettingsPageItem>
          <LocalSettingsPageItem
            settings={settings}
            item={['collapsed', 'auto', 'media']}
            id='mastodon-settings--collapsed-auto-media'
            onChange={onChange}
            dependsOn={[['collapsed', 'enabled']]}
            dependsOnNot={[['collapsed', 'auto', 'all']]}
          >
            <FormattedMessage id='settings.auto_collapse_media' defaultMessage='Toots with media' />
          </LocalSettingsPageItem>
        </section>
        <section>
          <h2><FormattedMessage id='settings.image_backgrounds' defaultMessage='Image backgrounds' /></h2>
          <LocalSettingsPageItem
            settings={settings}
            item={['collapsed', 'backgrounds', 'user_backgrounds']}
            id='mastodon-settings--collapsed-user-backgrouns'
            onChange={onChange}
            dependsOn={[['collapsed', 'enabled']]}
          >
            <FormattedMessage id='settings.image_backgrounds_users' defaultMessage='Give collapsed toots an image background' />
          </LocalSettingsPageItem>
          <LocalSettingsPageItem
            settings={settings}
            item={['collapsed', 'backgrounds', 'preview_images']}
            id='mastodon-settings--collapsed-preview-images'
            onChange={onChange}
            dependsOn={[['collapsed', 'enabled']]}
          >
            <FormattedMessage id='settings.image_backgrounds_media' defaultMessage='Preview collapsed toot media' />
          </LocalSettingsPageItem>
        </section>
      </div>
    ),
    ({ onChange, settings }) => (
      <div className='glitch local-settings__page media'>
        <h1><FormattedMessage id='settings.media' defaultMessage='Media' /></h1>
        <LocalSettingsPageItem
          settings={settings}
          item={['media', 'letterbox']}
          id='mastodon-settings--media-letterbox'
          onChange={onChange}
        >
          <FormattedMessage id='settings.media_letterbox' defaultMessage='Letterbox media' />
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['media', 'fullwidth']}
          id='mastodon-settings--media-fullwidth'
          onChange={onChange}
        >
          <FormattedMessage id='settings.media_fullwidth' defaultMessage='Full-width media previews' />
        </LocalSettingsPageItem>
      </div>
    ),
  ];

  render () {
    const { pages } = this;
    const { index, intl, onChange, settings } = this.props;
    const CurrentPage = pages[index] || pages[0];

    return <CurrentPage intl={intl} onChange={onChange} settings={settings} />;
  }

}
