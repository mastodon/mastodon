import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ReactSwipeableViews from 'react-swipeable-views';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import IconButton from 'mastodon/components/icon_button';
import Icon from 'mastodon/components/icon';
import { defineMessages, injectIntl, FormattedMessage, FormattedDate } from 'react-intl';
import { autoPlayGif } from 'mastodon/initial_state';
import elephantUIPlane from 'mastodon/../images/elephant_ui_plane.svg';
import { mascot } from 'mastodon/initial_state';
import unicodeMapping from 'mastodon/features/emoji/emoji_unicode_mapping_light';
import classNames from 'classnames';
import EmojiPickerDropdown from 'mastodon/features/compose/containers/emoji_picker_dropdown_container';
import AnimatedNumber from 'mastodon/components/animated_number';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
  previous: { id: 'lightbox.previous', defaultMessage: 'Previous' },
  next: { id: 'lightbox.next', defaultMessage: 'Next' },
});

class Content extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    announcement: ImmutablePropTypes.map.isRequired,
  };

  setRef = c => {
    this.node = c;
  }

  componentDidMount () {
    this._updateLinks();
    this._updateEmojis();
  }

  componentDidUpdate () {
    this._updateLinks();
    this._updateEmojis();
  }

  _updateEmojis () {
    const node = this.node;

    if (!node || autoPlayGif) {
      return;
    }

    const emojis = node.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];

      if (emoji.classList.contains('status-emoji')) {
        continue;
      }

      emoji.classList.add('status-emoji');

      emoji.addEventListener('mouseenter', this.handleEmojiMouseEnter, false);
      emoji.addEventListener('mouseleave', this.handleEmojiMouseLeave, false);
    }
  }

  _updateLinks () {
    const node = this.node;

    if (!node) {
      return;
    }

    const links = node.querySelectorAll('a');

    for (var i = 0; i < links.length; ++i) {
      let link = links[i];

      if (link.classList.contains('status-link')) {
        continue;
      }

      link.classList.add('status-link');

      let mention = this.props.announcement.get('mentions').find(item => link.href === item.get('url'));

      if (mention) {
        link.addEventListener('click', this.onMentionClick.bind(this, mention), false);
        link.setAttribute('title', mention.get('acct'));
      } else if (link.textContent[0] === '#' || (link.previousSibling && link.previousSibling.textContent && link.previousSibling.textContent[link.previousSibling.textContent.length - 1] === '#')) {
        link.addEventListener('click', this.onHashtagClick.bind(this, link.text), false);
      } else {
        link.setAttribute('title', link.href);
        link.classList.add('unhandled-link');
      }

      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');
    }
  }

  onMentionClick = (mention, e) => {
    if (this.context.router && e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.history.push(`/accounts/${mention.get('id')}`);
    }
  }

  onHashtagClick = (hashtag, e) => {
    hashtag = hashtag.replace(/^#/, '');

    if (this.context.router && e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.history.push(`/timelines/tag/${hashtag}`);
    }
  }

  handleEmojiMouseEnter = ({ target }) => {
    target.src = target.getAttribute('data-original');
  }

  handleEmojiMouseLeave = ({ target }) => {
    target.src = target.getAttribute('data-static');
  }

  render () {
    const { announcement } = this.props;

    return (
      <div
        className='announcements__item__content'
        ref={this.setRef}
        dangerouslySetInnerHTML={{ __html: announcement.get('contentHtml') }}
      />
    );
  }

}

const assetHost = process.env.CDN_HOST || '';

class Emoji extends React.PureComponent {

  static propTypes = {
    emoji: PropTypes.string.isRequired,
    emojiMap: ImmutablePropTypes.map.isRequired,
    hovered: PropTypes.bool.isRequired,
  };

  render () {
    const { emoji, emojiMap, hovered } = this.props;

    if (unicodeMapping[emoji]) {
      const { filename, shortCode } = unicodeMapping[this.props.emoji];
      const title = shortCode ? `:${shortCode}:` : '';

      return (
        <img
          draggable='false'
          className='emojione'
          alt={emoji}
          title={title}
          src={`${assetHost}/emoji/${filename}.svg`}
        />
      );
    } else if (emojiMap.get(emoji)) {
      const filename  = (autoPlayGif || hovered) ? emojiMap.getIn([emoji, 'url']) : emojiMap.getIn([emoji, 'static_url']);
      const shortCode = `:${emoji}:`;

      return (
        <img
          draggable='false'
          className='emojione custom-emoji'
          alt={shortCode}
          title={shortCode}
          src={filename}
        />
      );
    } else {
      return null;
    }
  }

}

class Reaction extends ImmutablePureComponent {

  static propTypes = {
    announcementId: PropTypes.string.isRequired,
    reaction: ImmutablePropTypes.map.isRequired,
    addReaction: PropTypes.func.isRequired,
    removeReaction: PropTypes.func.isRequired,
    emojiMap: ImmutablePropTypes.map.isRequired,
  };

  state = {
    hovered: false,
  };

  handleClick = () => {
    const { reaction, announcementId, addReaction, removeReaction } = this.props;

    if (reaction.get('me')) {
      removeReaction(announcementId, reaction.get('name'));
    } else {
      addReaction(announcementId, reaction.get('name'));
    }
  }

  handleMouseEnter = () => this.setState({ hovered: true })

  handleMouseLeave = () => this.setState({ hovered: false })

  render () {
    const { reaction } = this.props;

    let shortCode = reaction.get('name');

    if (unicodeMapping[shortCode]) {
      shortCode = unicodeMapping[shortCode].shortCode;
    }

    return (
      <button className={classNames('reactions-bar__item', { active: reaction.get('me') })} onClick={this.handleClick} onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave} title={`:${shortCode}:`}>
        <span className='reactions-bar__item__emoji'><Emoji hovered={this.state.hovered} emoji={reaction.get('name')} emojiMap={this.props.emojiMap} /></span>
        <span className='reactions-bar__item__count'><AnimatedNumber value={reaction.get('count')} /></span>
      </button>
    );
  }

}

class ReactionsBar extends ImmutablePureComponent {

  static propTypes = {
    announcementId: PropTypes.string.isRequired,
    reactions: ImmutablePropTypes.list.isRequired,
    addReaction: PropTypes.func.isRequired,
    removeReaction: PropTypes.func.isRequired,
    emojiMap: ImmutablePropTypes.map.isRequired,
  };

  handleEmojiPick = data => {
    const { addReaction, announcementId } = this.props;
    addReaction(announcementId, data.native.replace(/:/g, ''));
  }

  render () {
    const { reactions } = this.props;
    const visibleReactions = reactions.filter(x => x.get('count') > 0);

    return (
      <div className={classNames('reactions-bar', { 'reactions-bar--empty': visibleReactions.isEmpty() })}>
        {visibleReactions.map(reaction => (
          <Reaction
            key={reaction.get('name')}
            reaction={reaction}
            announcementId={this.props.announcementId}
            addReaction={this.props.addReaction}
            removeReaction={this.props.removeReaction}
            emojiMap={this.props.emojiMap}
          />
        ))}

        {visibleReactions.size < 8 && <EmojiPickerDropdown onPickEmoji={this.handleEmojiPick} button={<Icon id='plus' />} />}
      </div>
    );
  }

}

class Announcement extends ImmutablePureComponent {

  static propTypes = {
    announcement: ImmutablePropTypes.map.isRequired,
    emojiMap: ImmutablePropTypes.map.isRequired,
    addReaction: PropTypes.func.isRequired,
    removeReaction: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { announcement } = this.props;
    const startsAt = announcement.get('starts_at') && new Date(announcement.get('starts_at'));
    const endsAt = announcement.get('ends_at') && new Date(announcement.get('ends_at'));
    const now = new Date();
    const hasTimeRange = startsAt && endsAt;
    const skipYear = hasTimeRange && startsAt.getFullYear() === endsAt.getFullYear() && endsAt.getFullYear() === now.getFullYear();
    const skipEndDate = hasTimeRange && startsAt.getDate() === endsAt.getDate() && startsAt.getMonth() === endsAt.getMonth() && startsAt.getFullYear() === endsAt.getFullYear();
    const skipTime = announcement.get('all_day');

    return (
      <div className='announcements__item'>
        <strong className='announcements__item__range'>
          <FormattedMessage id='announcement.announcement' defaultMessage='Announcement' />
          {hasTimeRange && <span> · <FormattedDate value={startsAt} hour12={false} year={(skipYear || startsAt.getFullYear() === now.getFullYear()) ? undefined : 'numeric'} month='short' day='2-digit' hour={skipTime ? undefined : '2-digit'} minute={skipTime ? undefined : '2-digit'} /> - <FormattedDate value={endsAt} hour12={false} year={(skipYear || endsAt.getFullYear() === now.getFullYear()) ? undefined : 'numeric'} month={skipEndDate ? undefined : 'short'} day={skipEndDate ? undefined : '2-digit'} hour={skipTime ? undefined : '2-digit'} minute={skipTime ? undefined : '2-digit'} /></span>}
        </strong>

        <Content announcement={announcement} />

        <ReactionsBar
          reactions={announcement.get('reactions')}
          announcementId={announcement.get('id')}
          addReaction={this.props.addReaction}
          removeReaction={this.props.removeReaction}
          emojiMap={this.props.emojiMap}
        />
      </div>
    );
  }

}

export default @injectIntl
class Announcements extends ImmutablePureComponent {

  static propTypes = {
    announcements: ImmutablePropTypes.list,
    emojiMap: ImmutablePropTypes.map.isRequired,
    addReaction: PropTypes.func.isRequired,
    removeReaction: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    index: 0,
  };

  handleChangeIndex = index => {
    this.setState({ index: index % this.props.announcements.size });
  }

  handleNextClick = () => {
    this.setState({ index: (this.state.index + 1) % this.props.announcements.size });
  }

  handlePrevClick = () => {
    this.setState({ index: (this.props.announcements.size + this.state.index - 1) % this.props.announcements.size });
  }

  render () {
    const { announcements, intl } = this.props;
    const { index } = this.state;

    if (announcements.isEmpty()) {
      return null;
    }

    return (
      <div className='announcements'>
        <img className='announcements__mastodon' alt='' draggable='false' src={mascot || elephantUIPlane} />

        <div className='announcements__container'>
          <ReactSwipeableViews animateHeight index={index} onChangeIndex={this.handleChangeIndex}>
            {announcements.map(announcement => (
              <Announcement
                key={announcement.get('id')}
                announcement={announcement}
                emojiMap={this.props.emojiMap}
                addReaction={this.props.addReaction}
                removeReaction={this.props.removeReaction}
                intl={intl}
              />
            ))}
          </ReactSwipeableViews>

          <div className='announcements__pagination'>
            <IconButton disabled={announcements.size === 1} title={intl.formatMessage(messages.previous)} icon='chevron-left' onClick={this.handlePrevClick} size={13} />
            <span>{index + 1} / {announcements.size}</span>
            <IconButton disabled={announcements.size === 1} title={intl.formatMessage(messages.next)} icon='chevron-right' onClick={this.handleNextClick} size={13} />
          </div>
        </div>
      </div>
    );
  }

}
