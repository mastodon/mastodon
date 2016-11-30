import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin from 'react-addons-pure-render-mixin';
import emojify from '../emoji';

const hideContent = str => $('<p>').html(str).text().replace(/[^\s]/g, '█');

const StatusContent = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    onClick: React.PropTypes.func
  },

  // getInitialState () {
  //   return {
  //     visible: false
  //   };
  // },

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

      link.addEventListener('click', this.onNormalClick, false);
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

  onNormalClick (e) {
    e.stopPropagation();
  },

  render () {
    const { status, onClick } = this.props;

    const hidden  = false; // (status.get('sensitive') && !this.state.visible);
    const content = { __html: hidden ? hideContent(status.get('content')) : emojify(status.get('content')) };

    return <div className='status__content' style={{ cursor: 'pointer', color: hidden ? '#616b86' : null }} dangerouslySetInnerHTML={content} onClick={onClick} />;
  },

});

export default StatusContent;
