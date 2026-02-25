import PropTypes from 'prop-types';

import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';

import classNames from 'classnames';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import AlternateEmailIcon from '@/material-icons/400-24px/alternate_email.svg?react';
import RepeatIcon from '@/material-icons/400-24px/repeat.svg?react';
import { Hotkeys } from 'mastodon/components/hotkeys';
import { ContentWarning } from 'mastodon/components/content_warning';
import { FilterWarning } from 'mastodon/components/filter_warning';
import { Icon }  from 'mastodon/components/icon';
import { PictureInPicturePlaceholder } from 'mastodon/components/picture_in_picture_placeholder';
import { withOptionalRouter, WithOptionalRouterPropTypes } from 'mastodon/utils/react_router';

import Card from '../features/status/components/card';
// We use the component (and not the container) since we do not want
// to use the progress bar to show download progress
import Bundle from '../features/ui/components/bundle';
import { MediaGallery, Video, Audio } from '../features/ui/util/async-components';
import { SensitiveMediaContext } from '../features/ui/util/sensitive_media_context';
import { displayMedia } from '../initial_state';

import { StatusHeader } from './status/header'
import { LinkedDisplayName } from './display_name';
import { getHashtagBarForStatus } from './hashtag_bar';
import StatusActionBar from './status_action_bar';
import StatusContent from './status_content';
import { StatusThreadLabel } from './status_thread_label';

const domParser = new DOMParser();

const messages = defineMessages({
  public_short: { id: 'privacy.public.short', defaultMessage: 'Public' },
  unlisted_short: { id: 'privacy.unlisted.short', defaultMessage: 'Quiet public' },
  private_short: { id: 'privacy.private.short', defaultMessage: 'Followers' },
  direct_short: { id: 'privacy.direct.short', defaultMessage: 'Specific people' },
  edited: { id: 'status.edited', defaultMessage: 'Edited {date}' },
  quote_noun: { id: 'status.quote_noun', defaultMessage: 'Quote', description: 'Quote as a noun' },
  contains_quote: { id: 'status.contains_quote', defaultMessage: 'Contains quote' },
  quote_cancel: { id: 'status.quote.cancel', defaultMessage: 'Cancel quote' },
});

export const textForScreenReader = ({intl, status, rebloggedByText = false, isQuote = false}) => {
  const displayName = status.getIn(['account', 'display_name']);

  const spoilerText = status.getIn(['translation', 'spoiler_text']) || status.get('spoiler_text');
  const contentHtml = status.getIn(['translation', 'contentHtml']) || status.get('contentHtml');
  const contentText = domParser.parseFromString(contentHtml, 'text/html').documentElement.textContent;

  const values = [
    isQuote ? intl.formatMessage(messages.quote_noun) : undefined,
    displayName.length === 0 ? status.getIn(['account', 'acct']).split('@')[0] : displayName,
    spoilerText && status.get('hidden') ? spoilerText : contentText,
    !!status.get('quote') ? intl.formatMessage(messages.contains_quote) : undefined,
    intl.formatDate(status.get('created_at'), { hour: '2-digit', minute: '2-digit', month: 'short', day: 'numeric' }),
    status.getIn(['account', 'acct']),
    rebloggedByText,
  ].filter(val => !!val);

  return values.join(', ');
};

export const defaultMediaVisibility = (status) => {
  if (!status) {
    return undefined;
  }

  if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
    status = status.get('reblog');
  }

  return !status.get('matched_media_filters') && (displayMedia !== 'hide_all' && !status.get('sensitive') || displayMedia === 'show_all');
};

class Status extends ImmutablePureComponent {

  static contextType = SensitiveMediaContext;

  static propTypes = {
    status: ImmutablePropTypes.map,
    account: ImmutablePropTypes.record,
    children: PropTypes.node,
    previousId: PropTypes.string,
    nextInReplyToId: PropTypes.string,
    rootId: PropTypes.string,
    onClick: PropTypes.func,
    onReply: PropTypes.func,
    onFavourite: PropTypes.func,
    onReblog: PropTypes.func,
    onQuote: PropTypes.func,
    onDelete: PropTypes.func,
    onDirect: PropTypes.func,
    onMention: PropTypes.func,
    onPin: PropTypes.func,
    onOpenMedia: PropTypes.func,
    onOpenVideo: PropTypes.func,
    onBlock: PropTypes.func,
    onAddFilter: PropTypes.func,
    onEmbed: PropTypes.func,
    onHeightChange: PropTypes.func,
    onToggleHidden: PropTypes.func,
    onToggleCollapsed: PropTypes.func,
    onTranslate: PropTypes.func,
    onInteractionModal: PropTypes.func,
    muted: PropTypes.bool,
    hidden: PropTypes.bool,
    unread: PropTypes.bool,
    featured: PropTypes.bool,
    showThread: PropTypes.bool,
    showActions: PropTypes.bool,
    isQuotedPost: PropTypes.bool,
    shouldHighlightOnMount: PropTypes.bool,
    getScrollPosition: PropTypes.func,
    updateScrollBottom: PropTypes.func,
    cacheMediaWidth: PropTypes.func,
    cachedMediaWidth: PropTypes.number,
    scrollKey: PropTypes.string,
    skipPrepend: PropTypes.bool,
    avatarSize: PropTypes.number,
    deployPictureInPicture: PropTypes.func,
    unfocusable: PropTypes.bool,
    headerRenderFn: PropTypes.func,
    pictureInPicture: ImmutablePropTypes.contains({
      inUse: PropTypes.bool,
      available: PropTypes.bool,
    }),
    contextType: PropTypes.string,
    ...WithOptionalRouterPropTypes,
  };

  // Avoid checking props that are functions (and whose equality will always
  // evaluate to false. See react-immutable-pure-component for usage.
  updateOnProps = [
    'status',
    'account',
    'muted',
    'hidden',
    'unread',
    'pictureInPicture',
    'headerRenderFn',
  ];

  state = {
    showMedia: defaultMediaVisibility(this.props.status) && !(this.context?.hideMediaByDefault),
    showDespiteFilter: undefined,
  };

  componentDidUpdate (prevProps) {
    // This will potentially cause a wasteful redraw, but in most cases `Status` components are used
    // with a `key` directly depending on their `id`, preventing re-use of the component across
    // different IDs.
    // But just in case this does change, reset the state on status change.

    if (this.props.status?.get('id') !== prevProps.status?.get('id')) {
      this.setState({
        showMedia: defaultMediaVisibility(this.props.status) && !(this.context?.hideMediaByDefault),
        showDespiteFilter: undefined,
      });
    }
  }

  handleToggleMediaVisibility = () => {
    this.setState({ showMedia: !this.state.showMedia });
  };

  handleClick = e => {
    e.preventDefault();

    if (e?.button === 0 && !(e?.ctrlKey || e?.metaKey)) {
      this._openStatus();
    } else if (e?.button === 1 || (e?.button === 0 && (e?.ctrlKey || e?.metaKey))) {
      this._openStatus(true);
    }
  };

  handleHeaderClick = e => {
    // Only handle clicks on the empty space above the content
    if (e.target !== e.currentTarget && e.detail >= 1) {
      return;
    }

    this.handleClick(e);
  };

  handleExpandedToggle = () => {
    this.props.onToggleHidden(this._properStatus());
  };

  handleCollapsedToggle = isCollapsed => {
    this.props.onToggleCollapsed(this._properStatus(), isCollapsed);
  };

  handleTranslate = () => {
    this.props.onTranslate(this._properStatus());
  };

  getAttachmentAspectRatio () {
    const attachments = this._properStatus().get('media_attachments');

    if (attachments.getIn([0, 'type']) === 'video') {
      return `${attachments.getIn([0, 'meta', 'original', 'width'])} / ${attachments.getIn([0, 'meta', 'original', 'height'])}`;
    } else if (attachments.getIn([0, 'type']) === 'audio') {
      return '16 / 9';
    } else {
      return (attachments.size === 1 && attachments.getIn([0, 'meta', 'small', 'aspect'])) ? attachments.getIn([0, 'meta', 'small', 'aspect']) : '3 / 2';
    }
  }

  renderLoadingMediaGallery = () => {
    return (
      <div className='media-gallery' style={{ aspectRatio: this.getAttachmentAspectRatio() }} />
    );
  };

  renderLoadingVideoPlayer = () => {
    return (
      <div className='video-player' style={{ aspectRatio: this.getAttachmentAspectRatio() }} />
    );
  };

  renderLoadingAudioPlayer = () => {
    return (
      <div className='audio-player' style={{ aspectRatio: this.getAttachmentAspectRatio() }} />
    );
  };

  handleOpenVideo = (options) => {
    const status = this._properStatus();
    const lang = status.getIn(['translation', 'language']) || status.get('language');
    this.props.onOpenVideo(status.get('id'), status.getIn(['media_attachments', 0]), lang, options);
  };

  handleOpenMedia = (media, index) => {
    const status = this._properStatus();
    const lang = status.getIn(['translation', 'language']) || status.get('language');
    this.props.onOpenMedia(status.get('id'), media, index, lang);
  };

  handleHotkeyOpenMedia = e => {
    const { onOpenMedia, onOpenVideo } = this.props;
    const status = this._properStatus();

    e.preventDefault();

    if (status.get('media_attachments').size > 0) {
      const lang = status.getIn(['translation', 'language']) || status.get('language');
      if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        onOpenVideo(status.get('id'), status.getIn(['media_attachments', 0]), lang, { startTime: 0 });
      } else {
        onOpenMedia(status.get('id'), status.get('media_attachments'), 0, lang);
      }
    }
  };

  handleDeployPictureInPicture = (type, mediaProps) => {
    const { deployPictureInPicture } = this.props;
    const status = this._properStatus();

    deployPictureInPicture(status, type, mediaProps);
  };

  handleHotkeyReply = e => {
    e.preventDefault();
    this.props.onReply(this._properStatus());
  };

  handleHotkeyFavourite = () => {
    this.props.onFavourite(this._properStatus());
  };

  handleHotkeyBoost = e => {
    this.props.onReblog(this._properStatus(), e);
  };

  handleHotkeyQuote = () => {
    this.props.onQuote(this._properStatus());
  };

  handleHotkeyMention = e => {
    e.preventDefault();
    this.props.onMention(this._properStatus().get('account'));
  };

  handleHotkeyOpen = () => {
    this._openStatus();
  };

  _openStatus = (newTab = false) => {
    if (this.props.onClick) {
      this.props.onClick();
      return;
    }

    const { history } = this.props;
    const status = this._properStatus();

    if (!history) {
      return;
    }

    const path = `/@${status.getIn(['account', 'acct'])}/${status.get('id')}`;

    if (newTab) {
      window.open(path, '_blank', 'noopener');
    } else {
      if (history.location.pathname.replace('/deck/', '/') === path) {
        history.replace(path);
      } else {
        history.push(path);
      }
    }
  };

  handleHotkeyOpenProfile = () => {
    this._openProfile();
  };

  _openProfile = (proper = true) => {
    const { history } = this.props;
    const status = proper ? this._properStatus() : this.props.status;

    if (!history) {
      return;
    }

    history.push(`/@${status.getIn(['account', 'acct'])}`);
  };

  handleHotkeyToggleHidden = () => {
    const { onToggleHidden } = this.props;
    const status = this._properStatus();

    if (this.props.status.get('matched_filters')) {
      const expandedBecauseOfCW = !status.get('hidden') || status.get('spoiler_text').length === 0;
      const expandedBecauseOfFilter = this.state.showDespiteFilter;

      if (expandedBecauseOfFilter && !expandedBecauseOfCW) {
        onToggleHidden(status);
      } else if (expandedBecauseOfFilter && expandedBecauseOfCW) {
        onToggleHidden(status);
        this.handleFilterToggle();
      } else  {
        this.handleFilterToggle();
      }
    } else {
      onToggleHidden(status);
    }
  };

  handleHotkeyToggleSensitive = () => {
    this.handleToggleMediaVisibility();
  };

  handleFilterToggle = () => {
    this.setState(state => ({ ...state, showDespiteFilter: !state.showDespiteFilter }));
  };

  _properStatus () {
    const { status } = this.props;

    if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
      return status.get('reblog');
    } else {
      return status;
    }
  }

  handleRef = c => {
    this.node = c;
  };

  render () {
    const {
      intl,
      hidden,
      featured,
      unfocusable,
      unread,
      showThread,
      showActions = true,
      isQuotedPost = false,
      scrollKey,
      pictureInPicture,
      previousId,
      nextInReplyToId,
      rootId,
      skipPrepend,
      avatarSize = 46,
      children,
    } = this.props;

    let { status, account, ...other } = this.props;

    if (status === null) {
      return null;
    }

    const handlers = this.props.muted ? {} : {
      reply: this.handleHotkeyReply,
      favourite: this.handleHotkeyFavourite,
      boost: this.handleHotkeyBoost,
      quote: this.handleHotkeyQuote,
      mention: this.handleHotkeyMention,
      open: this.handleHotkeyOpen,
      openProfile: this.handleHotkeyOpenProfile,
      toggleHidden: this.handleHotkeyToggleHidden,
      toggleSensitive: this.handleHotkeyToggleSensitive,
      openMedia: this.handleHotkeyOpenMedia,
      onTranslate: this.handleTranslate,
    };

    let media, prepend, rebloggedByText;

    const connectUp = previousId && previousId === status.get('in_reply_to_id');
    const connectToRoot = rootId && rootId === status.get('in_reply_to_id');
    const connectReply = nextInReplyToId && nextInReplyToId === status.get('id');
    const matchedFilters = status.get('matched_filters');

    if (status.get('reblog', null) !== null && typeof status.get('reblog') === 'object') {
      const name = (
        <LinkedDisplayName
          displayProps={{
            account: status.get('account'),
            variant: 'simple'
          }}
          className='status__display-name muted'
        />
      )

      prepend = (
        <div className='status__prepend'>
          <div className='status__prepend__icon'><Icon id='retweet' icon={RepeatIcon} /></div>
          <FormattedMessage id='status.reblogged_by' defaultMessage='{name} boosted' values={{ name }} />
        </div>
      );

      rebloggedByText = intl.formatMessage({ id: 'status.reblogged_by', defaultMessage: '{name} boosted' }, { name: status.getIn(['account', 'acct']) });

      account = status.get('account');
      status  = status.get('reblog');
    } else if (status.get('visibility') === 'direct') {
      prepend = (
        <div className='status__prepend'>
          <div className='status__prepend__icon'><Icon id='at' icon={AlternateEmailIcon} /></div>
          <FormattedMessage id='status.direct_indicator' defaultMessage='Private mention' />
        </div>
      );
    } else if (showThread && status.get('in_reply_to_id')) {
      prepend = (
        <StatusThreadLabel accountId={status.getIn(['account', 'id'])} inReplyToAccountId={status.get('in_reply_to_account_id')} />
      );
    }

    const expanded = (!matchedFilters || this.state.showDespiteFilter) && (!status.get('hidden') || status.get('spoiler_text').length === 0);

    if (hidden) {
      return (
        <Hotkeys handlers={handlers} focusable={!unfocusable}>
          <div ref={this.handleRef} className={classNames('status__wrapper', { focusable: !this.props.muted })} tabIndex={unfocusable ? null : 0}>
            <span>{status.getIn(['account', 'display_name']) || status.getIn(['account', 'username'])}</span>
            {status.get('spoiler_text').length > 0 && (<span>{status.get('spoiler_text')}</span>)}
            {expanded && <span>{status.get('content')}</span>}
          </div>
        </Hotkeys>
      );
    }

    if (pictureInPicture.get('inUse')) {
      media = <PictureInPicturePlaceholder aspectRatio={this.getAttachmentAspectRatio()} />;
    } else if (status.get('media_attachments').size > 0) {
      const language = status.getIn(['translation', 'language']) || status.get('language');

      if (['image', 'gifv', 'unknown'].includes(status.getIn(['media_attachments', 0, 'type'])) || status.get('media_attachments').size > 1) {
        media = (
          <Bundle fetchComponent={MediaGallery} loading={this.renderLoadingMediaGallery}>
            {Component => (
              <Component
                media={status.get('media_attachments')}
                lang={language}
                sensitive={status.get('sensitive')}
                height={110}
                onOpenMedia={this.handleOpenMedia}
                cacheWidth={this.props.cacheMediaWidth}
                defaultWidth={this.props.cachedMediaWidth}
                visible={this.state.showMedia}
                onToggleVisibility={this.handleToggleMediaVisibility}
                matchedFilters={status.get('matched_media_filters')}
              />
            )}
          </Bundle>
        );
      } else if (status.getIn(['media_attachments', 0, 'type']) === 'audio') {
        const attachment = status.getIn(['media_attachments', 0]);
        const description = attachment.getIn(['translation', 'description']) || attachment.get('description');

        media = (
          <Bundle fetchComponent={Audio} loading={this.renderLoadingAudioPlayer} >
            {Component => (
              <Component
                src={attachment.get('url')}
                alt={description}
                lang={language}
                poster={attachment.get('preview_url') || status.getIn(['account', 'avatar_static'])}
                backgroundColor={attachment.getIn(['meta', 'colors', 'background'])}
                foregroundColor={attachment.getIn(['meta', 'colors', 'foreground'])}
                accentColor={attachment.getIn(['meta', 'colors', 'accent'])}
                duration={attachment.getIn(['meta', 'original', 'duration'], 0)}
                deployPictureInPicture={pictureInPicture.get('available') ? this.handleDeployPictureInPicture : undefined}
                sensitive={status.get('sensitive')}
                blurhash={attachment.get('blurhash')}
                visible={this.state.showMedia}
                onToggleVisibility={this.handleToggleMediaVisibility}
                matchedFilters={status.get('matched_media_filters')}
              />
            )}
          </Bundle>
        );
      } else if (status.getIn(['media_attachments', 0, 'type']) === 'video') {
        const attachment = status.getIn(['media_attachments', 0]);
        const description = attachment.getIn(['translation', 'description']) || attachment.get('description');

        media = (
          <Bundle fetchComponent={Video} loading={this.renderLoadingVideoPlayer} >
            {Component => (
              <Component
                preview={attachment.get('preview_url')}
                frameRate={attachment.getIn(['meta', 'original', 'frame_rate'])}
                aspectRatio={`${attachment.getIn(['meta', 'original', 'width'])} / ${attachment.getIn(['meta', 'original', 'height'])}`}
                blurhash={attachment.get('blurhash')}
                src={attachment.get('url')}
                alt={description}
                lang={language}
                sensitive={status.get('sensitive')}
                onOpenVideo={this.handleOpenVideo}
                deployPictureInPicture={pictureInPicture.get('available') ? this.handleDeployPictureInPicture : undefined}
                visible={this.state.showMedia}
                onToggleVisibility={this.handleToggleMediaVisibility}
                matchedFilters={status.get('matched_media_filters')}
              />
            )}
          </Bundle>
        );
      }
    } else if (status.get('card') && !status.get('quote')) {
      media = (
        <Card
          key={`${status.get('id')}-${status.get('edited_at')}`}
          card={status.get('card')}
          sensitive={status.get('sensitive')}
        />
      );
    }

    const {statusContentProps, hashtagBar} = getHashtagBarForStatus(status);

    const header = this.props.headerRenderFn
      ? this.props.headerRenderFn({ status, account, avatarSize, messages, onHeaderClick: this.handleHeaderClick, featured })
      : (
        <StatusHeader
          status={status}
          account={account}
          avatarSize={avatarSize}
          onHeaderClick={this.handleHeaderClick}
        />
      );

    return (
      <Hotkeys handlers={handlers} focusable={!unfocusable}>
        <div className={classNames('status__wrapper', `status__wrapper-${status.get('visibility')}`, { 'status__wrapper-reply': !!status.get('in_reply_to_id'), unread, focusable: !this.props.muted })} tabIndex={this.props.muted || unfocusable ? null : 0} data-featured={featured ? 'true' : null} aria-label={textForScreenReader({intl, status, rebloggedByText, isQuote: isQuotedPost})} ref={this.handleRef} data-nosnippet={status.getIn(['account', 'noindex'], true) || undefined}>
          {!skipPrepend && prepend}

          <div
            className={
              classNames('status', `status-${status.get('visibility')}`,
              {
                'status-reply': !!status.get('in_reply_to_id'),
                'status--in-thread': !!rootId,
                'status--first-in-thread': previousId && (!connectUp || connectToRoot), muted: this.props.muted,
                'status--is-quote': isQuotedPost,
                'status--has-quote': !!status.get('quote'),
                'status--highlighted-entry': this.props.shouldHighlightOnMount,
              })
            }
            data-id={status.get('id')}
          >
            {(connectReply || connectUp || connectToRoot) && <div className={classNames('status__line', { 'status__line--full': connectReply, 'status__line--first': !status.get('in_reply_to_id') && !connectToRoot })} />}

            {header}

            {matchedFilters && <FilterWarning title={matchedFilters.join(', ')} expanded={this.state.showDespiteFilter} onClick={this.handleFilterToggle} />}

            {(!matchedFilters || this.state.showDespiteFilter) && <ContentWarning status={status} expanded={expanded} onClick={this.handleExpandedToggle} />}

            {expanded && (
              <>
                <StatusContent
                  status={status}
                  onClick={this.handleClick}
                  onTranslate={this.handleTranslate}
                  collapsible
                  onCollapsedToggle={this.handleCollapsedToggle}
                  {...statusContentProps}
                />

                {media}
                {hashtagBar}

                {children}
              </>
            )}

            {(showActions && !isQuotedPost) &&
              <StatusActionBar scrollKey={scrollKey} status={status} account={account}  {...other} />
            }
          </div>
        </div>
      </Hotkeys>
    );
  }

}

export default withOptionalRouter(injectIntl(Status));
