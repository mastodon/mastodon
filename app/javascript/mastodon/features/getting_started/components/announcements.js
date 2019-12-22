import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ReactSwipeableViews from 'react-swipeable-views';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import IconButton from 'mastodon/components/icon_button';
import { defineMessages, injectIntl, FormattedDate } from 'react-intl';
import { autoPlayGif } from 'mastodon/initial_state';
import elephantUIPlane from 'mastodon/../images/elephant_ui_plane.svg';
import { mascot } from 'mastodon/initial_state';

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

class Announcement extends ImmutablePureComponent {

  static propTypes = {
    announcement: ImmutablePropTypes.map.isRequired,
    dismissAnnouncement: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleDismissClick = () => {
    const { dismissAnnouncement, announcement } = this.props;
    dismissAnnouncement(announcement.get('id'));
  }

  render () {
    const { announcement, intl } = this.props;
    const startsAt = announcement.get('starts_at') && new Date(announcement.get('starts_at'));
    const endsAt = announcement.get('ends_at') && new Date(announcement.get('ends_at'));
    const now = new Date();
    const hasTimeRange = startsAt && endsAt;
    const skipYear = hasTimeRange && startsAt.getFullYear() === endsAt.getFullYear() && endsAt.getFullYear() === now.getFullYear();
    const skipEndDate = hasTimeRange && startsAt.getDate() === endsAt.getDate() && startsAt.getMonth() === endsAt.getMonth() && startsAt.getFullYear() === endsAt.getFullYear();
    const skipTime = announcement.get('all_day');

    return (
      <div className='announcements__item'>
        {hasTimeRange && <strong className='announcements__item__range'><FormattedDate value={startsAt} hour12={false} year={(skipYear || startsAt.getFullYear() === now.getFullYear()) ? undefined : 'numeric'} month='short' day='2-digit' hour={skipTime ? undefined : '2-digit'} minute={skipTime ? undefined : '2-digit'} /> - <FormattedDate value={endsAt} hour12={false} year={(skipYear || endsAt.getFullYear() === now.getFullYear()) ? undefined : 'numeric'} month={skipEndDate ? undefined : 'short'} day={skipEndDate ? undefined : '2-digit'} hour={skipTime ? undefined : '2-digit'} minute={skipTime ? undefined : '2-digit'} second={skipTime ? undefined : ''} /></strong>}
        <Content announcement={announcement} />
        <IconButton title={intl.formatMessage(messages.close)} icon='times' className='announcements__item__dismiss-icon' onClick={this.handleDismissClick} />
      </div>
    );
  }

}

export default @injectIntl
class Announcements extends ImmutablePureComponent {

  static propTypes = {
    announcements: ImmutablePropTypes.list,
    fetchAnnouncements: PropTypes.func.isRequired,
    dismissAnnouncement: PropTypes.func.isRequired,
    domain: PropTypes.string.isRequired,
    intl: PropTypes.object.isRequired,
  };

  state = {
    index: 0,
  };

  componentDidMount () {
    const { fetchAnnouncements } = this.props;
    fetchAnnouncements();
  }

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
    const { announcements, domain, intl } = this.props;
    const { index } = this.state;

    if (announcements.isEmpty()) {
      return null;
    }

    return (
      <div className='announcements'>
        <img className='announcements__mastodon' alt='' draggable='false' src={mascot || elephantUIPlane} />

        <div className='announcements__container'>
          <ReactSwipeableViews index={index} onChangeIndex={this.handleChangeIndex}>
            {announcements.map(announcement => (
              <Announcement
                key={announcement.get('id')}
                announcement={announcement}
                dismissAnnouncement={this.props.dismissAnnouncement}
                intl={intl}
              />
            ))}
          </ReactSwipeableViews>

          <div className='announcements__pagination'>
            <span className='announcements__pagination__domain'>{domain}</span>

            <IconButton disabled={announcements.size === 1} title={intl.formatMessage(messages.previous)} icon='chevron-left' onClick={this.handlePrevClick} size={13} />
            <span>{index + 1} / {announcements.size}</span>
            <IconButton disabled={announcements.size === 1} title={intl.formatMessage(messages.next)} icon='chevron-right' onClick={this.handleNextClick} size={13} />
          </div>
        </div>
      </div>
    );
  }

}
