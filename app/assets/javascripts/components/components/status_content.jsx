import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import emojify from '../emoji';

const StatusContent = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    onClick: React.PropTypes.func
  },

  mixins: [PureRenderMixin],

  componentDidMount () {
    const node  = ReactDOM.findDOMNode(this);
    const links = node.querySelectorAll('a');
    const spoilers = node.querySelectorAll('.spoiler');

    for (var i = 0; i < spoilers.length; ++i) {
      let spoiler    = spoilers[i];
      spoiler.addEventListener('click', this.onSpoilerClick.bind(this, spoiler), true);
    }

    for (var i = 0; i < links.length; ++i) {
      let link    = links[i];
      let mention = this.props.status.get('mentions').find(item => link.href === item.get('url'));

      if (mention) {
        link.addEventListener('click', this.onMentionClick.bind(this, mention), false);
      } else if (link.textContent[0] === '#' || (link.previousSibling && link.previousSibling.textContent && link.previousSibling.textContent[link.previousSibling.textContent.length - 1] === '#')) {
        link.addEventListener('click', this.onHashtagClick.bind(this, link.text), false);
      } else {
        link.setAttribute('target', '_blank');
        link.setAttribute('rel', 'noopener');
      }
    }
  },

  onMentionClick (mention, e) {
    if (e.button === 0) {
      e.preventDefault();
      this.context.router.push(`/accounts/${mention.get('id')}`);
    }
  },

  onHashtagClick (hashtag, e) {
    hashtag = hashtag.replace(/^#/, '').toLowerCase();

    if (e.button === 0) {
      e.preventDefault();
      this.context.router.push(`/timelines/tag/${hashtag}`);
    }
  },

  onSpoilerClick (spoiler, e) {
    if (e.button === 0) {
      //only toggle if we're not clicking a visible link
      var hasClass = $(spoiler).hasClass('spoiler-on');
      if (hasClass || e.target === spoiler) {
        e.stopPropagation();
        e.preventDefault();
        $(spoiler).siblings(".spoiler").andSelf().toggleClass('spoiler-on', !hasClass);
      }
    }
  },

  handleMouseDown (e) {
    this.startXY = [e.clientX, e.clientY];
  },

  handleMouseUp (e) {
    const [ startX, startY ] = this.startXY;
    const [ deltaX, deltaY ] = [Math.abs(e.clientX - startX), Math.abs(e.clientY - startY)];

    if (e.target.localName === 'a' || (e.target.parentNode && e.target.parentNode.localName === 'a')) {
      return;
    }

    if (deltaX + deltaY < 5) {
      this.props.onClick();
    }

    this.startXY = null;
  },

  render () {
    const { status } = this.props;

    const content = { __html: emojify(status.get('content')) };

    return (
      <div
        className='status__content'
        style={{ cursor: 'pointer' }}
        dangerouslySetInnerHTML={content}
        onMouseDown={this.handleMouseDown}
        onMouseUp={this.handleMouseUp}
      />
    );
  },

});

export default StatusContent;
