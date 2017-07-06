import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import escapeTextContentForBrowser from 'escape-html';
import PropTypes from 'prop-types';
import emojify from '../emoji';
import { isRtl } from '../rtl';
import { FormattedMessage } from 'react-intl';
import Permalink from './permalink';

export default class StatusContent extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    expanded: PropTypes.oneOf([true, false, null]),
    setExpansion: PropTypes.func,
    onHeightUpdate: PropTypes.func,
    media: PropTypes.element,
    mediaIcon: PropTypes.string,
    parseClick: PropTypes.func,
  };

  state = {
    hidden: true,
  };

  componentDidMount () {
    const node  = this.node;
    const links = node.querySelectorAll('a');

    for (var i = 0; i < links.length; ++i) {
      let link    = links[i];
      let mention = this.props.status.get('mentions').find(item => link.href === item.get('url'));

      if (mention) {
        link.addEventListener('click', this.onMentionClick.bind(this, mention), false);
        link.setAttribute('title', mention.get('acct'));
      } else if (link.textContent[0] === '#' || (link.previousSibling && link.previousSibling.textContent && link.previousSibling.textContent[link.previousSibling.textContent.length - 1] === '#')) {
        link.addEventListener('click', this.onHashtagClick.bind(this, link.text), false);
      } else {
        link.addEventListener('click', this.onLinkClick.bind(this), false);
        link.setAttribute('target', '_blank');
        link.setAttribute('rel', 'noopener');
        link.setAttribute('title', link.href);
      }
    }
  }

  componentDidUpdate () {
    if (this.props.onHeightUpdate) {
      this.props.onHeightUpdate();
    }
  }

  onLinkClick = (e) => {
    if (this.props.expanded === false) {
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

  handleMouseDown = (e) => {
    this.startXY = [e.clientX, e.clientY];
  }

  handleMouseUp = (e) => {
    const { parseClick } = this.props;

    if (!this.startXY) {
      return;
    }

    const [ startX, startY ] = this.startXY;
    const [ deltaX, deltaY ] = [Math.abs(e.clientX - startX), Math.abs(e.clientY - startY)];

    if (e.target.localName === 'button' || e.target.localName === 'a' || (e.target.parentNode && (e.target.parentNode.localName === 'button' || e.target.parentNode.localName === 'a'))) {
      return;
    }

    if (deltaX + deltaY < 5 && e.button === 0 && parseClick) {
      parseClick(e);
    }

    this.startXY = null;
  }

  handleSpoilerClick = (e) => {
    e.preventDefault();

    if (this.props.setExpansion) {
      this.props.setExpansion(this.props.expanded ? null : true);
    } else {
      this.setState({ hidden: !this.state.hidden });
    }
  }

  setRef = (c) => {
    this.node = c;
  }

  render () {
    const { status, media, mediaIcon } = this.props;

    const hidden = (
      this.props.setExpansion ?
      !this.props.expanded :
      this.state.hidden
    );

    const content = { __html: emojify(status.get('content')) };
    const spoilerContent = {
      __html: emojify(escapeTextContentForBrowser(
        status.get('spoiler_text', '')
      )),
    };
    const directionStyle = { direction: 'ltr' };

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
        <div className='status__content status__content--with-action' ref={this.setRef}>
          <p
            style={{ marginBottom: hidden && status.get('mentions').isEmpty() ? '0px' : null }}
            onMouseDown={this.handleMouseDown}
            onMouseUp={this.handleMouseUp}
          >
            <span dangerouslySetInnerHTML={spoilerContent} />
            {' '}
            <button tabIndex='0' className='status__content__spoiler-link' onClick={this.handleSpoilerClick}>
              {toggleText}
            </button>
          </p>

          {mentionsPlaceholder}

          <div className={`status__content__spoiler ${!hidden ? 'status__content__spoiler--visible' : ''}`}>
            <div
              style={directionStyle}
              onMouseDown={this.handleMouseDown}
              onMouseUp={this.handleMouseUp}
              dangerouslySetInnerHTML={content}
            />
            {media}
          </div>

        </div>
      );
    } else if (this.props.parseClick) {
      return (
        <div
          ref={this.setRef}
          className='status__content status__content--with-action'
          style={directionStyle}
        >
          <div
            onMouseDown={this.handleMouseDown}
            onMouseUp={this.handleMouseUp}
            dangerouslySetInnerHTML={content}
          />
          {media}
        </div>
      );
    } else {
      return (
        <div
          ref={this.setRef}
          className='status__content'
          style={directionStyle}
        >
          <div dangerouslySetInnerHTML={content} />
          {media}
        </div>
      );
    }
  }

}
