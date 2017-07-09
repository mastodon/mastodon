import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import escapeTextContentForBrowser from 'escape-html';
import PropTypes from 'prop-types';
import emojify from '../emoji';
import { isRtl } from '../rtl';
import { FormattedMessage } from 'react-intl';
import Permalink from './permalink';

const loadScriptOnce = require('load-script-once');

function mapAlternate(array, fn1, fn2, thisArg) {
    var fn = fn1, output = [];
    for (var i=0; i<array.length; i++){
	output[i] = fn.call(thisArg, array[i], i, array);
	fn = fn === fn1 ? fn2 : fn1;
    }
    return output;
}

const componentToString = c => {
    let aDom = document.createElement('span');
    var finished = false;
    ReactDOM.render(c, aDom, () => {
	finished = true;
    });
    while(finished == false) { }
    
    const s = aDom.outerHTML;
    console.log([aDom,s]);
    result = s;

    return s;
};

const mathjaxify = str => {
    var s = mapAlternate(str.split(/\$\$/g),
	x => x,
	x => componentToString(<MathJax.Context><MathJax.Node>{x}</MathJax.Node></MathJax.Context>)).join("");
    s = mapAlternate(s.split(/\$/g),
	x => x,
	x => componentToString(<MathJax.Context><MathJax.Node inline>{x}</MathJax.Node></MathJax.Context>)).join("");
    s = s.replace(/\\\((.*?)\\\)/g,
	componentToString(<MathJax.Context><MathJax.Node inline>{"$1"}</MathJax.Node></MathJax.Context>))
    .replace(/\\\[(.*?)\\\]/g,
	componentToString(<MathJax.Context><MathJax.Node>{"$1"}</MathJax.Node></MathJax.Context>));
    console.log(s);
    return s;
};

const isMathjaxifyable = str => {
    return [ /\$\$(.*?)\$\$/g, /\$(.*?)\$/g, /\\\((.*?)\\\)/g, /\\\[(.*?)\\\]/g]
    .map( r => str.match(r))
    .reduce((prev, elem) => prev || elem, false);
}

export default class StatusContent extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    status: ImmutablePropTypes.map.isRequired,
    expanded: PropTypes.bool,
    onExpandedToggle: PropTypes.func,
    onHeightUpdate: PropTypes.func,
    onClick: PropTypes.func,
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
        link.setAttribute('target', '_blank');
        link.setAttribute('rel', 'noopener');
        link.setAttribute('title', link.href);
      }
    }
    loadScriptOnce('https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js?config=TeX-AMS-MML_HTMLorMML,Safe',
	               (err, script) => {
	                 if (err) {
	                 } else {
		               const options = {
		                 tex2jax: {
			               inlineMath: [ ['$','$'], ['\\(','\\)'] ]
		                 },
                         TeX: {
                           extensions: ["AMScd.js"]
                         },
		                 skipStartupTypeset: true,
		                 showProcessingMessages: false,
		                 messageStyle: "none",
		                 showMathMenu: true,
		                 showMathMenuMSIE: true,
		                 "SVG": {
			               font:
			               "TeX"
			               // "STIX-Web"
			               // "Asana-Math"
			               // "Neo-Euler"
			               // "Gyre-Pagella"
			               // "Gyre-Termes"
			               // "Latin-Modern"
		                 },
		                 "HTML-CSS": {
			               availableFonts: ["TeX"],
			               preferredFont: "TeX",
			               webFont: "TeX"
		                 }
		               };
		               MathJax.Hub.Config(options);
		               MathJax.Hub.Queue(["Typeset", MathJax.Hub, node]);
	                 }
	               });
  }

  componentDidUpdate () {
    if (this.props.onHeightUpdate) {
      this.props.onHeightUpdate();
    }
  }

  onMentionClick = (mention, e) => {
    if (e.button === 0) {
      e.preventDefault();
      this.context.router.history.push(`/accounts/${mention.get('id')}`);
    }
  }

  onHashtagClick = (hashtag, e) => {
    hashtag = hashtag.replace(/^#/, '').toLowerCase();

    if (e.button === 0) {
      e.preventDefault();
      this.context.router.history.push(`/timelines/tag/${hashtag}`);
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

    if (e.target.localName === 'button' || e.target.localName === 'a' || (e.target.parentNode && (e.target.parentNode.localName === 'button' || e.target.parentNode.localName === 'a'))) {
      return;
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

  setRef = (c) => {
    this.node = c;
  }

  render () {
    const { status } = this.props;

    const hidden = this.props.onExpandedToggle ? !this.props.expanded : this.state.hidden;

    const content = { __html: emojify(status.get('content')) };
    const spoilerContent = { __html: emojify(escapeTextContentForBrowser(status.get('spoiler_text', ''))) };
    const directionStyle = { direction: 'ltr' };

    if (isRtl(status.get('search_index'))) {
      directionStyle.direction = 'rtl';
    }

    if (status.get('spoiler_text').length > 0) {
      let mentionsPlaceholder = '';

      const mentionLinks = status.get('mentions').map(item => (
        <Permalink to={`/accounts/${item.get('id')}`} href={item.get('url')} key={item.get('id')} className='mention'>
          @<span>{item.get('username')}</span>
        </Permalink>
      )).reduce((aggregate, item) => [...aggregate, item, ' '], []);

      const toggleText = hidden ? <FormattedMessage id='status.show_more' defaultMessage='Show more' /> : <FormattedMessage id='status.show_less' defaultMessage='Show less' />;

      if (hidden) {
        mentionsPlaceholder = <div>{mentionLinks}</div>;
      }

      return (
        <div className='status__content status__content--with-action' ref={this.setRef} onMouseDown={this.handleMouseDown} onMouseUp={this.handleMouseUp}>
          <p style={{ marginBottom: hidden && status.get('mentions').isEmpty() ? '0px' : null }}>
            <span dangerouslySetInnerHTML={spoilerContent} />
            {' '}
            <button tabIndex='0' className='status__content__spoiler-link' onClick={this.handleSpoilerClick}>{toggleText}</button>
          </p>

          {mentionsPlaceholder}

          <div className={`status__content__text ${!hidden ? 'status__content__text--visible' : ''}`} style={directionStyle} dangerouslySetInnerHTML={content} />
        </div>
      );
    } else if (this.props.onClick) {
      return (
        <div
          ref={this.setRef}
          className='status__content status__content--with-action'
          style={directionStyle}
          onMouseDown={this.handleMouseDown}
          onMouseUp={this.handleMouseUp}
          dangerouslySetInnerHTML={content}
        />
      );
    } else {
      return (
        <div
          ref={this.setRef}
          className='status__content'
          style={directionStyle}
          dangerouslySetInnerHTML={content}
        />
      );
    }
  }

}
