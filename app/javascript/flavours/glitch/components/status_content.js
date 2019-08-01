import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { isRtl } from 'flavours/glitch/util/rtl';
import { FormattedMessage } from 'react-intl';
import Permalink from './permalink';
import classnames from 'classnames';
import { autoPlayGif } from 'flavours/glitch/util/initial_state';
import { decode as decodeIDNA } from 'flavours/glitch/util/idna';

// Regex matching what "looks like a link", that is, something that starts with
// an optional "http://" or "https://" scheme and then what could look like a
// domain main, that is, at least two sequences of characters not including spaces
// and separated by "." or an homoglyph. The idea is not to match valid URLs or
// domain names, but what could be confused for a valid URL or domain name,
// especially to the untrained eye.

const h_confusables = 'h\u13c2\u1d58d\u1d4f1\u1d691\u0068\uff48\u1d525\u210e\u1d489\u1d629\u0570\u1d4bd\u1d65d\u1d421\u1d5c1\u1d5f5\u04bb\u1d559';
const t_confusables = 't\u1d42d\u1d5cd\u1d531\u1d565\u1d4c9\u1d669\u1d4fd\u1d69d\u0074\u1d461\u1d601\u1d495\u1d635\u1d599';
const p_confusables = 'p\u0440\u03c1\u1d52d\u1d631\u1d665\u1d429\uff50\u1d6e0\u1d45d\u1d561\u1d595\u1d71a\u1d699\u1d78e\u2ca3\u1d754\u1d6d2\u1d491\u1d7c8\u1d746\u1d4c5\u1d70c\u1d5c9\u0070\u1d780\u03f1\u1d5fd\u2374\u1d7ba\u1d4f9';
const s_confusables = 's\u1d530\u118c1\u1d494\u1d634\u1d4c8\u1d668\uabaa\u1d42c\u1d5cc\u1d460\u1d600\ua731\u0073\uff53\u1d564\u0455\u1d598\u1d4fc\u1d69c\u10448\u01bd';
const column_confusables = ':\u0903\u0a83\u0703\u1803\u05c3\u0704\u0589\u1809\ua789\u16ec\ufe30\u02d0\u2236\u02f8\u003a\uff1a\u205a\ua4fd';
const slash_confusables = '/\u2041\u2f03\u2044\u2cc6\u27cb\u30ce\u002f\u2571\u31d3\u3033\u1735\u2215\u29f8\u1d23a\u4e3f';
const dot_confusables = '.\u002e\u0660\u06f0\u0701\u0702\u2024\ua4f8\ua60e\u10a50\u1d16d';

const linkRegex = new RegExp(`^\\s*(([${h_confusables}][${t_confusables}][${t_confusables}][${p_confusables}][${s_confusables}]?[${column_confusables}][${slash_confusables}][${slash_confusables}]))?[^:/\\n ]+([${dot_confusables}][^:/\\n ]+)+`);

const textMatchesTarget = (text, origin, host) => {
  return (text === origin || text === host
          || text.startsWith(origin + '/') || text.startsWith(host + '/')
          || 'www.' + text === host || ('www.' + text).startsWith(host + '/'));
}

// If `checkUrlLike` is true, consider only URL-like link texts to be misleading
const isLinkMisleading = (link, checkUrlLike = true) => {
  let linkTextParts = [];

  // Reconstruct visible text, as we do not have much control over how links
  // from remote software look, and we can't rely on `innerText` because the
  // `invisible` class does not set `display` to `none`.

  const walk = (node) => {
    switch (node.nodeType) {
    case Node.TEXT_NODE:
      linkTextParts.push(node.textContent);
      break;
    case Node.ELEMENT_NODE:
      if (node.classList.contains('invisible')) return;
      const children = node.childNodes;
      for (let i = 0; i < children.length; i++) {
        walk(children[i]);
      }
      break;
    }
  };

  walk(link);

  const linkText = linkTextParts.join('');
  const targetURL = new URL(link.href);

  // The following may not work with international domain names
  if (textMatchesTarget(linkText, targetURL.origin, targetURL.host) || textMatchesTarget(linkText.toLowerCase(), targetURL.origin, targetURL.host)) {
    return false;
  }

  // The link hasn't been recognized, maybe it features an international domain name
  const hostname = decodeIDNA(targetURL.hostname).normalize('NFKC');
  const host = targetURL.host.replace(targetURL.hostname, hostname);
  const origin = targetURL.origin.replace(targetURL.host, host);
  const text = linkText.normalize('NFKC');
  if (textMatchesTarget(text, origin, host) || textMatchesTarget(text.toLowerCase(), origin, host)) {
    return false;
  }

  // If the link text looks like an URL or auto-generated link, it is misleading
  return !checkUrlLike || linkRegex.test(linkText);
};

export default class StatusContent extends React.PureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    expanded: PropTypes.bool,
    collapsed: PropTypes.bool,
    onExpandedToggle: PropTypes.func,
    media: PropTypes.element,
    mediaIcon: PropTypes.string,
    parseClick: PropTypes.func,
    disabled: PropTypes.bool,
    onUpdate: PropTypes.func,
    linkRewriting: PropTypes.string,
  };

  static defaultProps = {
    linkRewriting: 'tag',
  };

  state = {
    hidden: true,
  };

  _updateStatusLinks () {
    const node = this.contentsNode;
    const { linkRewriting } = this.props;

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

      let mention = this.props.status.get('mentions').find(item => link.href === item.get('url'));

      if (mention) {
        link.addEventListener('click', this.onMentionClick.bind(this, mention), false);
        link.setAttribute('title', mention.get('acct'));
      } else if (link.textContent[0] === '#' || (link.previousSibling && link.previousSibling.textContent && link.previousSibling.textContent[link.previousSibling.textContent.length - 1] === '#')) {
        link.addEventListener('click', this.onHashtagClick.bind(this, link.text), false);
      } else {
        link.addEventListener('click', this.onLinkClick.bind(this), false);
        link.setAttribute('title', link.href);
        link.classList.add('unhandled-link');

        if (linkRewriting === 'rewrite' && isLinkMisleading(link)) {
          // Rewrite misleading links entirely

          while (link.firstChild) {
            link.removeChild(link.firstChild);
          }

          const prefix = (link.href.match(/https?:\/\/(www\.)?/) || [''])[0];
          const text   = link.href.substr(prefix.length, 30);
          const suffix = link.href.substr(prefix.length + 30);
          const cutoff = !!suffix;

          const prefixTag = document.createElement('span');
          prefixTag.classList.add('invisible');
          prefixTag.textContent = prefix;
          link.appendChild(prefixTag);

          const textTag = document.createElement('span');
          if (cutoff) {
            textTag.classList.add('ellipsis');
          }
          textTag.textContent = text;
          link.appendChild(textTag);

          const suffixTag = document.createElement('span');
          suffixTag.classList.add('invisible');
          suffixTag.textContent = suffix;
          link.appendChild(suffixTag);
        } else if (linkRewriting === 'tag' && isLinkMisleading(link, false)) {
          // Add a tag besides the link to display its origin

          const tag = document.createElement('span');
          tag.classList.add('link-origin-tag');
          tag.textContent = `[${new URL(link.href).host}]`;
          link.insertAdjacentText('beforeend', ' ');
          link.insertAdjacentElement('beforeend', tag);
        }
      }

      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener');
    }
  }

  _updateStatusEmojis () {
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

  componentDidMount () {
    this._updateStatusLinks();
    this._updateStatusEmojis();
  }

  componentDidUpdate () {
    this._updateStatusLinks();
    this._updateStatusEmojis();
    if (this.props.onUpdate) this.props.onUpdate();
  }

  onLinkClick = (e) => {
    if (this.props.collapsed) {
      if (this.props.parseClick) this.props.parseClick(e);
    }
  }

  onMentionClick = (mention, e) => {
    if (this.props.parseClick) {
      this.props.parseClick(e, `/accounts/${mention.get('id')}`);
    }
  }

  onHashtagClick = (hashtag, e) => {
    hashtag = hashtag.replace(/^#/, '').toLowerCase();

    if (this.props.parseClick) {
      this.props.parseClick(e, `/timelines/tag/${hashtag}`);
    }
  }

  handleEmojiMouseEnter = ({ target }) => {
    target.src = target.getAttribute('data-original');
  }

  handleEmojiMouseLeave = ({ target }) => {
    target.src = target.getAttribute('data-static');
  }

  handleMouseDown = (e) => {
    this.startXY = [e.clientX, e.clientY];
  }

  handleMouseUp = (e) => {
    const { parseClick, disabled } = this.props;

    if (disabled || !this.startXY) {
      return;
    }

    const [ startX, startY ] = this.startXY;
    const [ deltaX, deltaY ] = [Math.abs(e.clientX - startX), Math.abs(e.clientY - startY)];

    let element = e.target;
    while (element) {
      if (element.localName === 'button' || element.localName === 'video' || element.localName === 'a' || element.localName === 'label') {
        return;
      }
      element = element.parentNode;
    }

    if (deltaX + deltaY < 5 && e.button === 0 && parseClick) {
      parseClick(e);
    }

    this.startXY = null;
  }

  handleSpoilerClick = (e) => {
    e.preventDefault();

    if (this.props.onExpandedToggle) {
      this.props.onExpandedToggle();
    } else {
      this.setState({ hidden: !this.state.hidden });
    }
  }

  setRef = (c) => {
    this.node = c;
  }

  setContentsRef = (c) => {
    this.contentsNode = c;
  }

  render () {
    const {
      status,
      media,
      mediaIcon,
      parseClick,
      disabled,
      linkRewriting,
    } = this.props;

    const hidden = this.props.onExpandedToggle ? !this.props.expanded : this.state.hidden;

    const content = { __html: status.get('contentHtml') };
    const spoilerContent = { __html: status.get('spoilerHtml') };
    const directionStyle = { direction: 'ltr' };
    const classNames = classnames('status__content', {
      'status__content--with-action': parseClick && !disabled,
      'status__content--with-spoiler': status.get('spoiler_text').length > 0,
    });

    if (isRtl(status.get('search_index'))) {
      directionStyle.direction = 'rtl';
    }

    if (status.get('spoiler_text').length > 0) {
      let mentionsPlaceholder = '';

      const mentionLinks = status.get('mentions').map(item => (
        <Permalink
          to={`/accounts/${item.get('id')}`}
          href={item.get('url')}
          key={item.get('id')}
          className='mention'
        >
          @<span>{item.get('username')}</span>
        </Permalink>
      )).reduce((aggregate, item) => [...aggregate, item, ' '], []);

      const toggleText = hidden ? [
        <FormattedMessage
          id='status.show_more'
          defaultMessage='Show more'
          key='0'
        />,
        mediaIcon ? (
          <i
            className={
              `fa fa-fw fa-${mediaIcon} status__content__spoiler-icon`
            }
            aria-hidden='true'
            key='1'
          />
        ) : null,
      ] : [
        <FormattedMessage
          id='status.show_less'
          defaultMessage='Show less'
          key='0'
        />,
      ];

      if (hidden) {
        mentionsPlaceholder = <div>{mentionLinks}</div>;
      }

      return (
        <div className={classNames} tabIndex='0' onMouseDown={this.handleMouseDown} onMouseUp={this.handleMouseUp} ref={this.setRef}>
          <p
            style={{ marginBottom: hidden && status.get('mentions').isEmpty() ? '0px' : null }}
          >
            <span dangerouslySetInnerHTML={spoilerContent} lang={status.get('language')} />
            {' '}
            <button tabIndex='0' className='status__content__spoiler-link' onClick={this.handleSpoilerClick}>
              {toggleText}
            </button>
          </p>

          {mentionsPlaceholder}

          <div className={`status__content__spoiler ${!hidden ? 'status__content__spoiler--visible' : ''}`}>
            <div
              ref={this.setContentsRef}
              key={`contents-${linkRewriting}`}
              style={directionStyle}
              tabIndex={!hidden ? 0 : null}
              dangerouslySetInnerHTML={content}
              className='status__content__text'
              lang={status.get('language')}
            />
            {media}
          </div>

        </div>
      );
    } else if (parseClick) {
      return (
        <div
          className={classNames}
          style={directionStyle}
          onMouseDown={this.handleMouseDown}
          onMouseUp={this.handleMouseUp}
          tabIndex='0'
          ref={this.setRef}
        >
          <div
            ref={this.setContentsRef}
            key={`contents-${linkRewriting}`}
            dangerouslySetInnerHTML={content}
            lang={status.get('language')}
            className='status__content__text'
            tabIndex='0'
          />
          {media}
        </div>
      );
    } else {
      return (
        <div
          className='status__content'
          style={directionStyle}
          tabIndex='0'
          ref={this.setRef}
        >
          <div ref={this.setContentsRef} key={`contents-${linkRewriting}`} className='status__content__text' dangerouslySetInnerHTML={content} lang={status.get('language')} tabIndex='0' />
          {media}
        </div>
      );
    }
  }

}
