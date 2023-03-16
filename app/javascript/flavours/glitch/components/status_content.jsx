import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { FormattedMessage, injectIntl } from 'react-intl';
import Permalink from './permalink';
import { connect } from 'react-redux';
import classnames from 'classnames';
import Icon from 'flavours/glitch/components/icon';
import { autoPlayGif, languages as preloadedLanguages } from 'flavours/glitch/initial_state';
import { decode as decodeIDNA } from 'flavours/glitch/utils/idna';

const textMatchesTarget = (text, origin, host) => {
  return (text === origin || text === host
          || text.startsWith(origin + '/') || text.startsWith(host + '/')
          || 'www.' + text === host || ('www.' + text).startsWith(host + '/'));
};

const isLinkMisleading = (link) => {
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

  if (targetURL.protocol === 'magnet:') {
    return !linkText.startsWith('magnet:');
  }

  if (targetURL.protocol === 'xmpp:') {
    return !(linkText === targetURL.href || 'xmpp:' + linkText === targetURL.href);
  }

  // The following may not work with international domain names
  if (textMatchesTarget(linkText, targetURL.origin, targetURL.host) || textMatchesTarget(linkText.toLowerCase(), targetURL.origin, targetURL.host)) {
    return false;
  }

  // The link hasn't been recognized, maybe it features an international domain name
  const hostname = decodeIDNA(targetURL.hostname).normalize('NFKC');
  const host = targetURL.host.replace(targetURL.hostname, hostname);
  const origin = targetURL.origin.replace(targetURL.host, host);
  const text = linkText.normalize('NFKC');
  return !(textMatchesTarget(text, origin, host) || textMatchesTarget(text.toLowerCase(), origin, host));
};

class TranslateButton extends React.PureComponent {

  static propTypes = {
    translation: ImmutablePropTypes.map,
    onClick: PropTypes.func,
  };

  render () {
    const { translation, onClick } = this.props;

    if (translation) {
      const language     = preloadedLanguages.find(lang => lang[0] === translation.get('detected_source_language'));
      const languageName = language ? language[2] : translation.get('detected_source_language');
      const provider     = translation.get('provider');

      return (
        <div className='translate-button'>
          <div className='translate-button__meta'>
            <FormattedMessage id='status.translated_from_with' defaultMessage='Translated from {lang} using {provider}' values={{ lang: languageName, provider }} />
          </div>

          <button className='link-button' onClick={onClick}>
            <FormattedMessage id='status.show_original' defaultMessage='Show original' />
          </button>
        </div>
      );
    }

    return (
      <button className='status__content__read-more-button' onClick={onClick}>
        <FormattedMessage id='status.translate' defaultMessage='Translate' />
      </button>
    );
  }

}

const mapStateToProps = state => ({
  languages: state.getIn(['server', 'translationLanguages', 'items']),
});

export default @connect(mapStateToProps)
@injectIntl
class StatusContent extends React.PureComponent {

  static contextTypes = {
    identity: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    expanded: PropTypes.bool,
    collapsed: PropTypes.bool,
    onExpandedToggle: PropTypes.func,
    onTranslate: PropTypes.func,
    media: PropTypes.node,
    extraMedia: PropTypes.node,
    mediaIcons: PropTypes.arrayOf(PropTypes.string),
    parseClick: PropTypes.func,
    disabled: PropTypes.bool,
    onUpdate: PropTypes.func,
    tagLinks: PropTypes.bool,
    rewriteMentions: PropTypes.string,
    languages: ImmutablePropTypes.map,
    intl: PropTypes.object,
  };

  static defaultProps = {
    tagLinks: true,
    rewriteMentions: 'no',
  };

  state = {
    hidden: true,
  };

  _updateStatusLinks () {
    const node = this.contentsNode;
    const { tagLinks, rewriteMentions } = this.props;

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
        if (rewriteMentions !== 'no') {
          while (link.firstChild) link.removeChild(link.firstChild);
          link.appendChild(document.createTextNode('@'));
          const acctSpan = document.createElement('span');
          acctSpan.textContent = rewriteMentions === 'acct' ? mention.get('acct') : mention.get('username');
          link.appendChild(acctSpan);
        }
      } else if (link.textContent[0] === '#' || (link.previousSibling && link.previousSibling.textContent && link.previousSibling.textContent[link.previousSibling.textContent.length - 1] === '#')) {
        link.addEventListener('click', this.onHashtagClick.bind(this, link.text), false);
      } else {
        link.addEventListener('click', this.onLinkClick.bind(this), false);
        link.setAttribute('title', link.href);
        link.classList.add('unhandled-link');

        link.setAttribute('target', '_blank');
        link.setAttribute('rel', 'noopener nofollow noreferrer');

        try {
          if (tagLinks && isLinkMisleading(link)) {
            // Add a tag besides the link to display its origin

            const url = new URL(link.href);
            const tag = document.createElement('span');
            tag.classList.add('link-origin-tag');
            switch (url.protocol) {
            case 'xmpp:':
              tag.textContent = `[${url.href}]`;
              break;
            case 'magnet:':
              tag.textContent = '(magnet)';
              break;
            default:
              tag.textContent = `[${url.host}]`;
            }
            link.insertAdjacentText('beforeend', ' ');
            link.insertAdjacentElement('beforeend', tag);
          }
        } catch (e) {
          // The URL is invalid, remove the href just to be safe
          if (tagLinks && e instanceof TypeError) link.removeAttribute('href');
        }
      }
    }
  }

  handleMouseEnter = ({ currentTarget }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      emoji.src = emoji.getAttribute('data-original');
    }
  };

  handleMouseLeave = ({ currentTarget }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      emoji.src = emoji.getAttribute('data-static');
    }
  };

  componentDidMount () {
    this._updateStatusLinks();
  }

  componentDidUpdate () {
    this._updateStatusLinks();
    if (this.props.onUpdate) this.props.onUpdate();
  }

  onLinkClick = (e) => {
    if (this.props.collapsed) {
      if (this.props.parseClick) this.props.parseClick(e);
    }
  };

  onMentionClick = (mention, e) => {
    if (this.props.parseClick) {
      this.props.parseClick(e, `/@${mention.get('acct')}`);
    }
  };

  onHashtagClick = (hashtag, e) => {
    hashtag = hashtag.replace(/^#/, '');

    if (this.props.parseClick) {
      this.props.parseClick(e, `/tags/${hashtag}`);
    }
  };

  handleMouseDown = (e) => {
    this.startXY = [e.clientX, e.clientY];
  };

  handleMouseUp = (e) => {
    const { parseClick, disabled } = this.props;

    if (disabled || !this.startXY) {
      return;
    }

    const [ startX, startY ] = this.startXY;
    const [ deltaX, deltaY ] = [Math.abs(e.clientX - startX), Math.abs(e.clientY - startY)];

    let element = e.target;
    while (element !== e.currentTarget) {
      if (['button', 'video', 'a', 'label', 'canvas'].includes(element.localName) || element.getAttribute('role') === 'button') {
        return;
      }
      element = element.parentNode;
    }

    if (deltaX + deltaY < 5 && e.button === 0 && parseClick) {
      parseClick(e);
    }

    this.startXY = null;
  };

  handleSpoilerClick = (e) => {
    e.preventDefault();

    if (this.props.onExpandedToggle) {
      this.props.onExpandedToggle();
    } else {
      this.setState({ hidden: !this.state.hidden });
    }
  };

  handleTranslate = () => {
    this.props.onTranslate();
  };

  setContentsRef = (c) => {
    this.contentsNode = c;
  };

  render () {
    const {
      status,
      media,
      extraMedia,
      mediaIcons,
      parseClick,
      disabled,
      tagLinks,
      rewriteMentions,
      intl,
    } = this.props;

    const hidden = this.props.onExpandedToggle ? !this.props.expanded : this.state.hidden;
    const contentLocale = intl.locale.replace(/[_-].*/, '');
    const targetLanguages = this.props.languages?.get(status.get('language') || 'und');
    const renderTranslate = this.props.onTranslate && this.context.identity.signedIn && ['public', 'unlisted'].includes(status.get('visibility')) && status.get('contentHtml').length > 0 && targetLanguages?.includes(contentLocale);

    const content = { __html: status.get('translation') ? status.getIn(['translation', 'content']) : status.get('contentHtml') };
    const spoilerContent = { __html: status.get('spoilerHtml') };
    const lang = status.get('translation') ? intl.locale : status.get('language');
    const classNames = classnames('status__content', {
      'status__content--with-action': parseClick && !disabled,
      'status__content--with-spoiler': status.get('spoiler_text').length > 0,
    });

    const translateButton = renderTranslate && (
      <TranslateButton onClick={this.handleTranslate} translation={status.get('translation')} />
    );

    if (status.get('spoiler_text').length > 0) {
      let mentionsPlaceholder = '';

      const mentionLinks = status.get('mentions').map(item => (
        <Permalink
          to={`/@${item.get('acct')}`}
          href={item.get('url')}
          key={item.get('id')}
          className='mention'
        >
          @<span>{item.get('username')}</span>
        </Permalink>
      )).reduce((aggregate, item) => [...aggregate, item, ' '], []);

      let toggleText = null;
      if (hidden) {
        toggleText = [
          <FormattedMessage
            id='status.show_more'
            defaultMessage='Show more'
            key='0'
          />,
        ];
        if (mediaIcons) {
          mediaIcons.forEach((mediaIcon, idx) => {
            toggleText.push(
              <Icon
                fixedWidth
                className='status__content__spoiler-icon'
                id={mediaIcon}
                aria-hidden='true'
                key={`icon-${idx}`}
              />,
            );
          });
        }
      } else {
        toggleText = (
          <FormattedMessage
            id='status.show_less'
            defaultMessage='Show less'
            key='0'
          />
        );
      }

      if (hidden) {
        mentionsPlaceholder = <div>{mentionLinks}</div>;
      }

      return (
        <div className={classNames} tabIndex='0' onMouseDown={this.handleMouseDown} onMouseUp={this.handleMouseUp}>
          <p
            style={{ marginBottom: hidden && status.get('mentions').isEmpty() ? '0px' : null }}
          >
            <span dangerouslySetInnerHTML={spoilerContent} className='translate' lang={lang} />
            {' '}
            <button type='button' className='status__content__spoiler-link' onClick={this.handleSpoilerClick} aria-expanded={!hidden}>
              {toggleText}
            </button>
          </p>

          {mentionsPlaceholder}

          <div className={`status__content__spoiler ${!hidden ? 'status__content__spoiler--visible' : ''}`}>
            <div
              ref={this.setContentsRef}
              key={`contents-${tagLinks}`}
              tabIndex={!hidden ? 0 : null}
              dangerouslySetInnerHTML={content}
              className='status__content__text translate'
              onMouseEnter={this.handleMouseEnter}
              onMouseLeave={this.handleMouseLeave}
              lang={lang}
            />
            {!hidden && translateButton}
            {media}
          </div>

          {extraMedia}
        </div>
      );
    } else if (parseClick) {
      return (
        <div
          className={classNames}
          onMouseDown={this.handleMouseDown}
          onMouseUp={this.handleMouseUp}
          tabIndex='0'
        >
          <div
            ref={this.setContentsRef}
            key={`contents-${tagLinks}-${rewriteMentions}`}
            dangerouslySetInnerHTML={content}
            className='status__content__text translate'
            tabIndex='0'
            onMouseEnter={this.handleMouseEnter}
            onMouseLeave={this.handleMouseLeave}
            lang={lang}
          />
          {translateButton}
          {media}
          {extraMedia}
        </div>
      );
    } else {
      return (
        <div
          className='status__content'
          tabIndex='0'
        >
          <div
            ref={this.setContentsRef}
            key={`contents-${tagLinks}`}
            className='status__content__text translate'
            dangerouslySetInnerHTML={content}
            tabIndex='0'
            onMouseEnter={this.handleMouseEnter}
            onMouseLeave={this.handleMouseLeave}
            lang={lang}
          />
          {translateButton}
          {media}
          {extraMedia}
        </div>
      );
    }
  }

}
