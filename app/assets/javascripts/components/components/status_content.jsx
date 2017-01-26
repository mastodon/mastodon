import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import emojify from '../emoji';
import { FormattedMessage } from 'react-intl';

const StatusContent = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    onClick: React.PropTypes.func
  },

  getInitialState () {
    return {
      hidden: true
    };
  },

  mixins: [PureRenderMixin],

  componentDidMount () {
    const node  = ReactDOM.findDOMNode(this);
    const links = node.querySelectorAll('a');

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

  handleMouseDown (e) {
    this.startXY = [e.clientX, e.clientY];
  },

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
  },

  handleSpoilerClick () {
    this.setState({ hidden: !this.state.hidden });
  },

  render () {
    const { status } = this.props;
    const { hidden } = this.state;

    const content = { __html: emojify(status.get('content')) };
    const spoilerContent = { __html: emojify(status.get('spoiler_text', '')) };
    const spoilerStyle = {
      backgroundColor: '#616b86', 
      borderRadius: '4px',
      color: '#363c4b',
      fontWeight: '500',
      fontSize: '12px',
      padding: '0 4px',
      textTransform: 'uppercase'
    };


    if (status.get('spoiler_text').length > 0) {
      const toggleText = hidden ? <FormattedMessage id='status.show_more' defaultMessage='Show more' /> : <FormattedMessage id='status.show_less' defaultMessage='Show less' />;

      return (
        <div className='status__content' style={{ cursor: 'pointer' }} onMouseDown={this.handleMouseDown} onMouseUp={this.handleMouseUp}>
          <p style={{ marginBottom: hidden ? '0px' : '' }} >
            <span dangerouslySetInnerHTML={spoilerContent} /> <a style={spoilerStyle} onClick={this.handleSpoilerClick}>[{toggleText}]</a>
          </p>

          <div style={{ display: hidden ? 'none' : 'block' }} dangerouslySetInnerHTML={content} />
        </div>
      );
    } else {
      return (
        <div
          className='status__content'
          style={{ cursor: 'pointer' }}
          onMouseDown={this.handleMouseDown}
          onMouseUp={this.handleMouseUp}
          dangerouslySetInnerHTML={content}
        />
      );
    }
  },

});

export default StatusContent;
