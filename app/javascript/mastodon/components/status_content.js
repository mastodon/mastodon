import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { FormattedMessage } from 'react-intl';
import Permalink from './permalink';
import classnames from 'classnames';
import PollContainer from 'mastodon/containers/poll_container';
import Icon from 'mastodon/components/icon';
import { autoPlayGif } from 'mastodon/initial_state';
import { getLocale  } from 'mastodon/locales';
import googleLogo from 'images/google_logo.svg';
import LoadingIndicator from './loading_indicator';
import api from '../api';

const MAX_HEIGHT = 642; // 20px * 32 (+ 2px padding at the top)

export default class StatusContent extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    expanded: PropTypes.bool,
    showThread: PropTypes.bool,
    onExpandedToggle: PropTypes.func,
    onClick: PropTypes.func,
    collapsable: PropTypes.bool,
    onCollapsedToggle: PropTypes.func,
    quote: PropTypes.bool,
  };

  state = {
    hidden: true,
    hideTranslation: true,
    translation: null,
    translationStatus: null,
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
        link.setAttribute('title', link.href);
        link.classList.add('unhandled-link');
      }

      link.setAttribute('target', '_blank');
      link.setAttribute('rel', 'noopener noreferrer');
    }

    if (this.props.status.get('collapsed', null) === null) {
      let collapsed =
          this.props.collapsable
          && this.props.onClick
          && node.clientHeight > MAX_HEIGHT
          && this.props.status.get('spoiler_text').length === 0;

      if(this.props.onCollapsedToggle) this.props.onCollapsedToggle(collapsed);

      this.props.status.set('collapsed', collapsed);
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
  }

  handleMouseLeave = ({ currentTarget }) => {
    if (autoPlayGif) {
      return;
    }

    const emojis = currentTarget.querySelectorAll('.custom-emoji');

    for (var i = 0; i < emojis.length; i++) {
      let emoji = emojis[i];
      emoji.src = emoji.getAttribute('data-static');
    }
  }

  componentDidMount () {
    this._updateStatusLinks();
  }

  componentDidUpdate () {
    this._updateStatusLinks();
  }

  onMentionClick = (mention, e) => {
    if (this.context.router && e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.history.push(`/@${mention.get('acct')}`);
    }
  }

  onHashtagClick = (hashtag, e) => {
    hashtag = hashtag.replace(/^#/, '');

    if (this.context.router && e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.history.push(`/tags/${hashtag}`);
    }
  }

  handleMouseDown = (e) => {
    this.startXY = [e.clientX, e.clientY];
  }

  handleMouseUp = (e) => {
    if (!this.startXY) {
      return;
    }

    const [ startX, startY ] = this.startXY;
    const [ deltaX, deltaY ] = [Math.abs(e.clientX - startX), Math.abs(e.clientY - startY)];

    let element = e.target;
    while (element) {
      if (element.localName === 'button' || element.localName === 'a' || element.localName === 'label') {
        return;
      }
      element = element.parentNode;
    }

    if (deltaX + deltaY < 5 && e.button === 0 && this.props.onClick) {
      this.props.onClick();
    }

    this.startXY = null;
  }

  handleSpoilerClick = (e) => {
    e.preventDefault();

    if (this.props.onExpandedToggle) {
      // The parent manages the state
      this.props.onExpandedToggle();
    } else {
      this.setState({ hidden: !this.state.hidden });
    }
  }

  handleTranslationClick = (e) => {
    e.preventDefault();
    const translationServiceEndpoint = '/translate/';

    if (this.state.hideTranslation === true && this.state.translation === null) {
      const { status } = this.props;

      const innerText = (html) => {
        let template = document.createElement('template');
        template.innerHTML = `<fragment>${html}<fragment/>`;
        return template.content.firstChild.innerText.trim()
      }

      const content = status.get('content').length === 0 ? '' : innerText(status.get('content'));

      let locale = getLocale().localeData[0].locale;
      if (locale === 'zh') {
        const domLang = document.documentElement.lang;
        locale = domLang === 'zh-CN' ? 'zh-cn' : 'zh-tw';
      }

      this.setState({ translationStatus: 'fetching' });
      api().post(
        translationServiceEndpoint,
        {
          data: {
            text: content === '' ? 'Nothing to translate' : content,
            to: locale,
          },
        })
        .then(res => {
          this.setState({
            translation: res.data.text,
            translationStatus: 'succeed',
            hideTranslation: false,
          });
        })
        .catch(() => {
          this.setState({
            translationStatus: 'failed',
            hideTranslation: true,
          });
        });
    } else {
      this.setState({ hideTranslation: !this.state.hideTranslation });
    }
  }

  setRef = (c) => {
    this.node = c;
  }

  render () {
    const { status, quote } = this.props;

    const hidden = this.props.onExpandedToggle ? !this.props.expanded : this.state.hidden;
    const renderReadMore = this.props.onClick && status.get('collapsed');
    const renderViewThread = this.props.showThread && status.get('in_reply_to_id') && status.get('in_reply_to_account_id') === status.getIn(['account', 'id']);
    const renderShowPoll = !!status.get('poll');

    const addHashtagMarkup = (html) => {
      let template = document.createElement('template');
      template.innerHTML = `<fragment>${html}<fragment/>`;
      template.content.firstChild.querySelectorAll('.hashtag').forEach((e)=>{
        e.innerHTML = e.innerHTML.replace('#', '<span class="hash_char">#</span>');
      });
      return template.content.firstChild.innerHTML;
    };

    const content = { __html: addHashtagMarkup(status.get('contentHtml')) };
    const spoilerContent = { __html: addHashtagMarkup(status.get('spoilerHtml')) };

    const classNames = classnames('status__content', {
      'status__content--with-action': this.props.onClick && this.context.router,
      'status__content--with-spoiler': status.get('spoiler_text').length > 0,
      'status__content--collapsed': renderReadMore,
    });

    const showThreadButton = (
      <button className='status__content__read-more-button' onClick={this.props.onClick}>
        <FormattedMessage id='status.show_thread' defaultMessage='Show thread' />
      </button>
    );

    const toggleTranslation = !this.state.hideTranslation ? <FormattedMessage id='status.hide_translation' defaultMessage='Hide translation' /> : <FormattedMessage id='status.show_translation' defaultMessage='Translate toot' />;

    const readMoreButton = (
      <button className='status__content__read-more-button' onClick={this.props.onClick} key='read-more'>
        <FormattedMessage id='status.read_more' defaultMessage='Read more' /><Icon id='angle-right' fixedWidth />
      </button>
    );

    const translationContainer = (
      getLocale().localeData[0].locale !== status.get('language') ?
      (<React.Fragment>
        <button
          tabIndex='-1' className={'status__content__show-translation-button'}
          onClick={this.handleTranslationClick.bind(this)}
        >{toggleTranslation} <Icon id='language ' fixedWidth /></button>

        {/* error message */}
        <div className='translation-content__wrapper'>
          <section
            className={`translation-content__failed ${this.state.translationStatus === 'failed' ? 'display' : 'hidden'}`}
          >
            <p><FormattedMessage id='status.translation_failed' defaultMessage='Fetch translation failed' /></p>
          </section>
          <section
            className={`translation-content__loading ${this.state.translationStatus === 'fetching' ? 'display' : 'hidden'}`}
          >
            <LoadingIndicator />
            {/* <p>Fetching translation, please wait</p> */}
          </section>
          <section
            className={`translation-content__succeed ${this.state.translationStatus === 'succeed' && !this.state.hideTranslation ? 'display' : 'hidden'}`}
          >
            <p className='translation-content__powered-by'>
              <FormattedMessage
                id='status.translation_by' defaultMessage='Translation powered by {google}'
                values={{
                  google: <img alt='Google' draggable='false' src={googleLogo} />,
                }}
              />
            </p>
            <p className='translation-content'>{this.state.translation}</p>
          </section>
        </div>
      </React.Fragment>) : null
    );

    const showPollButton = (
      <button className='status__content__read-more-button' onClick={this.props.onClick} key='show-poll'>
        <FormattedMessage id='status.show_poll' defaultMessage='Show poll' /><Icon id='angle-right' fixedWidth />
      </button>
    );

    const pollContainer = (
      <PollContainer pollId={status.get('poll')} />
    );

    if (status.get('spoiler_text').length > 0) {
      let mentionsPlaceholder = '';

      const mentionLinks = status.get('mentions').map(item => (
        <Permalink to={`/@${item.get('acct')}`} href={item.get('url')} key={item.get('id')} className='mention'>
          @<span>{item.get('username')}</span>
        </Permalink>
      )).reduce((aggregate, item) => [...aggregate, item, ' '], []);

      const toggleText = hidden ? <FormattedMessage id='status.show_more' defaultMessage='Show more' /> : <FormattedMessage id='status.show_less' defaultMessage='Show less' />;

      if (hidden) {
        mentionsPlaceholder = <div>{mentionLinks}</div>;
      }

      return (
        <div className={classNames} ref={this.setRef} tabIndex='0' onMouseDown={this.handleMouseDown} onMouseUp={this.handleMouseUp} onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave}>
          <p style={{ marginBottom: hidden && status.get('mentions').isEmpty() ? '0px' : null }}>
            <span dangerouslySetInnerHTML={spoilerContent} className='translate' />
            {' '}
            <button tabIndex='0' className={`status__content__spoiler-link ${hidden ? 'status__content__spoiler-link--show-more' : 'status__content__spoiler-link--show-less'}`} onClick={this.handleSpoilerClick}>{toggleText}</button>
          </p>

          {mentionsPlaceholder}

          <div tabIndex={!hidden ? 0 : null} className={`status__content__text ${!hidden ? 'status__content__text--visible' : ''} translate`} dangerouslySetInnerHTML={content} />

          {!hidden ? translationContainer : null}

          {!hidden && renderShowPoll && quote ? showPollButton : pollContainer}

          {renderViewThread && showThreadButton}
        </div>
      );
    } else if (this.props.onClick) {
      const output = [
        <div className={classNames} ref={this.setRef} tabIndex='0' onMouseDown={this.handleMouseDown} onMouseUp={this.handleMouseUp} key='status-content' onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave}>
          <div className='status__content__text status__content__text--visible translate' dangerouslySetInnerHTML={content} />

          {translationContainer}

          {renderShowPoll && quote ? showPollButton : pollContainer}

          {renderViewThread && showThreadButton}
        </div>,
      ];

      if (renderReadMore) {
        output.push(readMoreButton);
      }

      return output;
    } else {
      return (
        <div className={classNames} ref={this.setRef} tabIndex='0' onMouseEnter={this.handleMouseEnter} onMouseLeave={this.handleMouseLeave}>
          <div className='status__content__text status__content__text--visible translate' dangerouslySetInnerHTML={content} />

          {translationContainer}

          {renderShowPoll && quote ? showPollButton : pollContainer}

          {renderViewThread && showThreadButton}
        </div>
      );
    }
  }

}
