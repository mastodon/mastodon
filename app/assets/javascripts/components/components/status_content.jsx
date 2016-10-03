import ImmutablePropTypes from 'react-immutable-proptypes';
import PureRenderMixin    from 'react-addons-pure-render-mixin';

const StatusContent = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  propTypes: {
    status: ImmutablePropTypes.map.isRequired
  },

  mixins: [PureRenderMixin],

  componentDidMount () {
    const node  = ReactDOM.findDOMNode(this);
    const links = node.querySelectorAll('a');

    for (var i = 0; i < links.length; ++i) {
      let link    = links[i];
      let mention = this.props.status.get('mentions').find(item => link.href === item.get('url'));

      if (mention) {
        link.addEventListener('click', this.onMentionClick.bind(this, mention));
      } else {
        link.setAttribute('target', '_blank');
        link.setAttribute('rel', 'noopener');
        link.addEventListener('click', this.onNormalClick.bind(this));
      }
    }
  },

  onMentionClick (mention, e) {
    if (e.button === 0) {
      e.preventDefault();
      this.context.router.push(`/accounts/${mention.get('id')}`);
    }

    e.stopPropagation();
  },

  onNormalClick (e) {
    e.stopPropagation();
  },

  render () {
    const content = { __html: this.props.status.get('content') };
    return <div className='status__content' dangerouslySetInnerHTML={content} />;
  },

});

export default StatusContent;
