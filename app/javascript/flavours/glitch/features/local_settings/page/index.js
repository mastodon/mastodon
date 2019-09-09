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
  layout_auto_hint: {  id: 'layout.hint.auto', defaultMessage: 'Automatically chose layout based on “Enable advanced web interface” setting and screen size.' },
  layout_desktop: { id: 'layout.desktop', defaultMessage: 'Desktop' },
  layout_desktop_hint: { id: 'layout.hint.desktop', defaultMessage: 'Use multiple-column layout regardless of the “Enable advanced web interface” setting or screen size.' },
  layout_mobile: { id: 'layout.single', defaultMessage: 'Mobile' },
  layout_mobile_hint: { id: 'layout.hint.single', defaultMessage: 'Use single-column layout regardless of the “Enable advanced web interface” setting or screen size.' },
  side_arm_none: { id: 'settings.side_arm.none', defaultMessage: 'None' },
  side_arm_keep: { id: 'settings.side_arm_reply_mode.keep', defaultMessage: 'Keep secondary toot button to set privacy' },
  side_arm_copy: { id: 'settings.side_arm_reply_mode.copy', defaultMessage: 'Copy privacy setting of the toot being replied to' },
  side_arm_restrict: { id: 'settings.side_arm_reply_mode.restrict', defaultMessage: 'Restrict privacy setting to that of the toot being replied to' },
  regexp: { id: 'settings.content_warnings.regexp', defaultMessage: 'Regular expression' },
  filters_drop: { id: 'settings.filtering_behavior.drop', defaultMessage: 'Hide filtered toots completely' },
  filters_upstream: { id: 'settings.filtering_behavior.upstream', defaultMessage: 'Show "filtered" like vanilla Mastodon' },
  filters_hide: { id: 'settings.filtering_behavior.hide', defaultMessage: 'Show "filtered" and add a button to display why' },
  filters_cw: { id: 'settings.filtering_behavior.cw', defaultMessage: 'Still display the post, and add filtered words to content warning' },
  rewrite_mentions_no: { id: 'settings.rewrite_mentions_no', defaultMessage: 'Do not rewrite mentions' },
  rewrite_mentions_acct: { id: 'settings.rewrite_mentions_acct', defaultMessage: 'Rewrite with username and domain (when the account is remote)' },
  rewrite_mentions_username: { id: 'settings.rewrite_mentions_username', defaultMessage:  'Rewrite with username' },
});

export default @injectIntl
class LocalSettingsPage extends React.PureComponent {

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
          item={['show_reply_count']}
          id='mastodon-settings--reply-count'
          onChange={onChange}
        >
          <FormattedMessage id='settings.show_reply_counter' defaultMessage='Display an estimate of the reply count' />
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['hicolor_privacy_icons']}
          id='mastodon-settings--hicolor_privacy_icons'
          onChange={onChange}
        >
          <FormattedMessage id='settings.hicolor_privacy_icons' defaultMessage='High color privacy icons' />
          <span className='hint'><FormattedMessage id='settings.hicolor_privacy_icons.hint' defaultMessage="Display privacy icons in bright and easily distinguishable colors" /></span>
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['confirm_boost_missing_media_description']}
          id='mastodon-settings--confirm_boost_missing_media_description'
          onChange={onChange}
        >
          <FormattedMessage id='settings.confirm_boost_missing_media_description' defaultMessage='Show confirmation dialog before boosting toots lacking media descriptions' />
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['tag_misleading_links']}
          id='mastodon-settings--tag_misleading_links'
          onChange={onChange}
        >
          <FormattedMessage id='settings.tag_misleading_links' defaultMessage='Tag misleading links' />
          <span className='hint'><FormattedMessage id='settings.tag_misleading_links.hint' defaultMessage="Add a visual indication with the link target host to every link not mentioning it explicitly" /></span>
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['rewrite_mentions']}
          id='mastodon-settings--rewrite_mentions'
          options={[
            { value: 'no', message: intl.formatMessage(messages.rewrite_mentions_no) },
            { value: 'acct', message: intl.formatMessage(messages.rewrite_mentions_acct) },
            { value: 'username', message: intl.formatMessage(messages.rewrite_mentions_username) },
          ]}
          onChange={onChange}
        >
          <FormattedMessage id='settings.rewrite_mentions' defaultMessage='Rewrite mentions in displayed statuses' />
        </LocalSettingsPageItem>
        <section>
          <h2><FormattedMessage id='settings.notifications_opts' defaultMessage='Notifications options' /></h2>
          <LocalSettingsPageItem
            settings={settings}
            item={['notifications', 'tab_badge']}
            id='mastodon-settings--notifications-tab_badge'
            onChange={onChange}
          >
            <FormattedMessage id='settings.notifications.tab_badge' defaultMessage="Unread notifications badge" />
            <span className='hint'><FormattedMessage id='settings.notifications.tab_badge.hint' defaultMessage="Display a badge for unread notifications in the column icons when the notifications column isn't open" /></span>
          </LocalSettingsPageItem>
          <LocalSettingsPageItem
            settings={settings}
            item={['notifications', 'favicon_badge']}
            id='mastodon-settings--notifications-favicon_badge'
            onChange={onChange}
          >
            <FormattedMessage id='settings.notifications.favicon_badge' defaultMessage='Unread notifications favicon badge' />
            <span className='hint'><FormattedMessage id='settings.notifications.favicon_badge.hint' defaultMessage="Add a badge for unread notifications to the favicon" /></span>
          </LocalSettingsPageItem>
        </section>
        <section>
          <h2><FormattedMessage id='settings.layout_opts' defaultMessage='Layout options' /></h2>
          <LocalSettingsPageItem
            settings={settings}
            item={['layout']}
            id='mastodon-settings--layout'
            options={[
              { value: 'auto', message: intl.formatMessage(messages.layout_auto), hint: intl.formatMessage(messages.layout_auto_hint) },
              { value: 'multiple', message: intl.formatMessage(messages.layout_desktop), hint: intl.formatMessage(messages.layout_desktop_hint) },
              { value: 'single', message: intl.formatMessage(messages.layout_mobile), hint: intl.formatMessage(messages.layout_mobile_hint) },
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
            <span className='hint'><FormattedMessage id='settings.wide_view_hint' defaultMessage='Stretches columns to better fill the available space.' /></span>
          </LocalSettingsPageItem>
          <LocalSettingsPageItem
            settings={settings}
            item={['navbar_under']}
            id='mastodon-settings--navbar_under'
            onChange={onChange}
          >
            <FormattedMessage id='settings.navbar_under' defaultMessage='Navbar at the bottom (Mobile only)' />
          </LocalSettingsPageItem>
          <LocalSettingsPageItem
            settings={settings}
            item={['swipe_to_change_columns']}
            id='mastodon-settings--swipe_to_change_columns'
            onChange={onChange}
          >
            <FormattedMessage id='settings.swipe_to_change_columns' defaultMessage='Allow swiping to change columns (Mobile only)' />
          </LocalSettingsPageItem>
        </section>
      </div>
    ),
    ({ intl, onChange, settings }) => (
      <div className='glitch local-settings__page compose_box_opts'>
        <h1><FormattedMessage id='settings.compose_box_opts' defaultMessage='Compose box' /></h1>
        <LocalSettingsPageItem
          settings={settings}
          item={['always_show_spoilers_field']}
          id='mastodon-settings--always_show_spoilers_field'
          onChange={onChange}
        >
          <FormattedMessage id='settings.always_show_spoilers_field' defaultMessage='Always enable the Content Warning field' />
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['preselect_on_reply']}
          id='mastodon-settings--preselect_on_reply'
          onChange={onChange}
        >
          <FormattedMessage id='settings.preselect_on_reply' defaultMessage='Pre-select usernames on reply' />
          <span className='hint'><FormattedMessage id='settings.preselect_on_reply_hint' defaultMessage='When replying to a conversation with multiple participants, pre-select usernames past the first' /></span>
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['confirm_missing_media_description']}
          id='mastodon-settings--confirm_missing_media_description'
          onChange={onChange}
        >
          <FormattedMessage id='settings.confirm_missing_media_description' defaultMessage='Show confirmation dialog before sending toots lacking media descriptions' />
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['confirm_before_clearing_draft']}
          id='mastodon-settings--confirm_before_clearing_draft'
          onChange={onChange}
        >
          <FormattedMessage id='settings.confirm_before_clearing_draft' defaultMessage='Show confirmation dialog before overwriting the message being composed' />
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['show_content_type_choice']}
          id='mastodon-settings--show_content_type_choice'
          onChange={onChange}
        >
          <FormattedMessage id='settings.show_content_type_choice' defaultMessage='Show content-type choice when authoring toots' />
        </LocalSettingsPageItem>
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
        <LocalSettingsPageItem
          settings={settings}
          item={['side_arm_reply_mode']}
          id='mastodon-settings--side_arm_reply_mode'
          options={[
            { value: 'keep', message: intl.formatMessage(messages.side_arm_keep) },
            { value: 'copy', message: intl.formatMessage(messages.side_arm_copy) },
            { value: 'restrict', message: intl.formatMessage(messages.side_arm_restrict) },
          ]}
          onChange={onChange}
        >
          <FormattedMessage id='settings.side_arm_reply_mode' defaultMessage='When replying to a toot:' />
        </LocalSettingsPageItem>
      </div>
    ),
    ({ intl, onChange, settings }) => (
      <div className='glitch local-settings__page content_warnings'>
        <h1><FormattedMessage id='settings.content_warnings' defaultMessage='Content warnings' /></h1>
        <LocalSettingsPageItem
          settings={settings}
          item={['content_warnings', 'auto_unfold']}
          id='mastodon-settings--content_warnings-auto_unfold'
          onChange={onChange}
        >
          <FormattedMessage id='settings.enable_content_warnings_auto_unfold' defaultMessage='Automatically unfold content-warnings' />
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['content_warnings', 'filter']}
          id='mastodon-settings--content_warnings-auto_unfold'
          onChange={onChange}
          dependsOn={[['content_warnings', 'auto_unfold']]}
          placeholder={intl.formatMessage(messages.regexp)}
        >
          <FormattedMessage id='settings.content_warnings_filter' defaultMessage='Content warnings to not automatically unfold:' />
        </LocalSettingsPageItem>
      </div>
    ),
    ({ intl, onChange, settings }) => (
      <div className='glitch local-settings__page filters'>
        <h1><FormattedMessage id='settings.filters' defaultMessage='Filters' /></h1>
        <LocalSettingsPageItem
          settings={settings}
          item={['filtering_behavior']}
          id='mastodon-settings--filters-behavior'
          onChange={onChange}
          options={[
            { value: 'drop', message: intl.formatMessage(messages.filters_drop) },
            { value: 'upstream', message: intl.formatMessage(messages.filters_upstream) },
            { value: 'hide', message: intl.formatMessage(messages.filters_hide) },
            { value: 'content_warning', message: intl.formatMessage(messages.filters_cw) }
          ]}
        >
          <FormattedMessage id='settings.filtering_behavior' defaultMessage='Filtering behavior' />
        </LocalSettingsPageItem>
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
        <LocalSettingsPageItem
          settings={settings}
          item={['collapsed', 'show_action_bar']}
          id='mastodon-settings--collapsed-show-action-bar'
          onChange={onChange}
          dependsOn={[['collapsed', 'enabled']]}
        >
          <FormattedMessage id='settings.show_action_bar' defaultMessage='Show action buttons in collapsed toots' />
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
          <span className='hint'><FormattedMessage id='settings.media_letterbox_hint' defaultMessage='Scale down and letterbox media to fill the image containers instead of stretching and cropping them' /></span>
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['media', 'fullwidth']}
          id='mastodon-settings--media-fullwidth'
          onChange={onChange}
        >
          <FormattedMessage id='settings.media_fullwidth' defaultMessage='Full-width media previews' />
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['inline_preview_cards']}
          id='mastodon-settings--inline-preview-cards'
          onChange={onChange}
        >
          <FormattedMessage id='settings.inline_preview_cards' defaultMessage='Inline preview cards for external links' />
        </LocalSettingsPageItem>
        <LocalSettingsPageItem
          settings={settings}
          item={['media', 'reveal_behind_cw']}
          id='mastodon-settings--reveal-behind-cw'
          onChange={onChange}
        >
          <FormattedMessage id='settings.media_reveal_behind_cw' defaultMessage='Reveal sensitive media behind a CW by default' />
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
