import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { isRtl } from 'flavours/glitch/util/rtl';
import { FormattedMessage } from 'react-intl';
import Permalink from './permalink';
import classnames from 'classnames';

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
  };

  state = {
    hidden: true,
  };

  _updateStatusLinks () {
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

      let mention = this.props.status.get('mentions').find(item => link.href === item.get('url'));

      if (mention) {
        link.addEventListener('click', this.onMentionClick.bind(this, mention), false);
        link.setAttribute('title', mention.get('acct'));
      } else if (link.textContent[0] === '#' || (link.previousSibling && link.previousSibling.textContent && link.previousSibling.textContent[link.previousSibling.textContent.length - 1] === '#')) {
        link.addEventListener('click', this.onHashtagClick.bind(this, link.text), false);
      } else {
        link.addEventListener('click', this.onLinkClick.bind(this), false);
        link.setAttribute('title', link.href);
      }

      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener');
    }
  }

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

  render () {
    const {
      status,
      media,
      mediaIcon,
      parseClick,
      disabled,
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
        <div className={classNames} tabIndex='0' onMouseDown={this.handleMouseDown} onMouseUp={this.handleMouseUp}>
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
              ref={this.setRef}
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
        >
          <div
            ref={this.setRef}
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
        >
          <div ref={this.setRef} className='status__content__text' dangerouslySetInnerHTML={content} lang={status.get('language')} tabIndex='0' />
          {media}
        </div>
      );
    }
  }

}
