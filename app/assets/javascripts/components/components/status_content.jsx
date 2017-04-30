import ImmutablePropTypes from 'react-immutable-proptypes';
import escapeTextContentForBrowser from 'escape-html';
import PropTypes from 'prop-types';
import emojify from '../emoji';
import { isRtl } from '../rtl';
import { FormattedMessage } from 'react-intl';
import Permalink from './permalink';

const loadScriptOnce = require('load-script-once');
// const MathJax = require('react-mathjax');
// const reactStringReplace = require('react-string-replace')

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

class StatusContent extends React.PureComponent {

  constructor (props, context) {
    super(props, context);
    this.state = {
      hidden: true
    };
    this.onMentionClick = this.onMentionClick.bind(this);
    this.onHashtagClick = this.onHashtagClick.bind(this);
    this.handleMouseDown = this.handleMouseDown.bind(this)
    this.handleMouseUp = this.handleMouseUp.bind(this);
    this.handleSpoilerClick = this.handleSpoilerClick.bind(this);
  };

  componentDidMount () {
    const node  = ReactDOM.findDOMNode(this);
    const links = node.querySelectorAll('a');

    for (var i = 0; i < links.length; ++i) {
      let link    = links[i];
      let mention = this.props.status.get('mentions').find(item => link.href === item.get('url'));
      let media   = this.props.status.get('media_attachments').find(item => link.href === item.get('text_url') || (item.get('remote_url').length > 0 && link.href === item.get('remote_url')));

      if (mention) {
        link.addEventListener('click', this.onMentionClick.bind(this, mention), false);
        link.setAttribute('title', mention.get('acct'));
      } else if (link.textContent[0] === '#' || (link.previousSibling && link.previousSibling.textContent && link.previousSibling.textContent[link.previousSibling.textContent.length - 1] === '#')) {
        link.addEventListener('click', this.onHashtagClick.bind(this, link.text), false);
      } else if (media) {
        link.innerHTML = '<i class="fa fa-fw fa-photo"></i>';
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
              }
		      skipStartupTypeset: true,
		      showProcessingMessages: false,
		      messageStyle: "none",
		      showMathMenu: false,
		      showMathMenuMSIE: false,
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

  onMentionClick (mention, e) {
    if (e.button === 0) {
      e.preventDefault();
      this.context.router.push(`/accounts/${mention.get('id')}`);
    }
  }

  onHashtagClick (hashtag, e) {
    hashtag = hashtag.replace(/^#/, '').toLowerCase();

    if (e.button === 0) {
      e.preventDefault();
      this.context.router.push(`/timelines/tag/${hashtag}`);
    }
  }

  handleMouseDown (e) {
    this.startXY = [e.clientX, e.clientY];
  }

  handleMouseUp (e) {
    const [ startX, startY ] = this.startXY;
    const [ deltaX, deltaY ] = [Math.abs(e.clientX - startX), Math.abs(e.clientY - startY)];

    if (e.target.localName === 'a' || (e.target.parentNode && e.target.parentNode.localName === 'a')) {
      return;
    }

    if (deltaX + deltaY < 5 && e.button === 0) {
      this.props.onClick();
    }

    this.startXY = null;
  }

  handleSpoilerClick (e) {
    e.preventDefault();
    this.setState({ hidden: !this.state.hidden });
  }

  render () {
    const { status } = this.props;
    const { hidden } = this.state;

    const content = { __html: emojify(status.get('content')) };
    const spoilerContent = { __html: emojify(escapeTextContentForBrowser(status.get('spoiler_text', ''))) };
    const directionStyle = { direction: 'ltr' };

    if (isRtl(status.get('content'))) {
      directionStyle.direction = 'rtl';
    }

    if (status.get('spoiler_text').length > 0) {
      let mentionsPlaceholder = '';

      const mentionLinks = status.get('mentions').map(item => (
        <Permalink to={`/accounts/${item.get('id')}`} href={item.get('url')} key={item.get('id')} className='mention'>
          @<span>{item.get('username')}</span>
        </Permalink>
      )).reduce((aggregate, item) => [...aggregate, item, ' '], [])

      const toggleText = hidden ? <FormattedMessage id='status.show_more' defaultMessage='Show more' /> : <FormattedMessage id='status.show_less' defaultMessage='Show less' />;

      if (hidden) {
        mentionsPlaceholder = <div>{mentionLinks}</div>;
      }

      return (
        <div className='status__content' onMouseDown={this.handleMouseDown} onMouseUp={this.handleMouseUp}>
          <p style={{ marginBottom: hidden && status.get('mentions').size === 0 ? '0px' : '' }} >
            <span dangerouslySetInnerHTML={spoilerContent} />  <a tabIndex='0' className='status__content__spoiler-link' role='button' onClick={this.handleSpoilerClick}>{toggleText}</a>
          </p>

          {mentionsPlaceholder}

          <div style={{ display: hidden ? 'none' : 'block', ...directionStyle }} dangerouslySetInnerHTML={content} />
        </div>
      );
    } else if (this.props.onClick) {
      return (
        <div
          className='status__content'
          style={{ ...directionStyle }}
          onMouseDown={this.handleMouseDown}
          onMouseUp={this.handleMouseUp}
          dangerouslySetInnerHTML={content}
        />
      );
    } else {
      return (
        <div
          className='status__content status__content--no-action'
          style={{ ...directionStyle }}
          dangerouslySetInnerHTML={content}
        />
      );
    }
  }

}

StatusContent.contextTypes = {
  router: PropTypes.object
};

StatusContent.propTypes = {
  status: ImmutablePropTypes.map.isRequired,
  onClick: PropTypes.func
};

export default StatusContent;
