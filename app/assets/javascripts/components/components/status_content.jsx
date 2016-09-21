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
    const node = ReactDOM.findDOMNode(this);

    this.props.status.get('mentions').forEach(mention => {
      const links = node.querySelector(`a[href="${mention.get('url')}"]`);
      links.addEventListener('click', this.onLinkClick.bind(this, mention));
    });
  },

  onLinkClick (mention, e) {
    if (e.button === 0) {
      e.preventDefault();
      this.context.router.push(`/accounts/${mention.get('id')}`);
    }
    
    e.stopPropagation();
  },

  render () {
    const content = { __html: this.props.status.get('content') };
    return <div className='status__content' dangerouslySetInnerHTML={content} />;
  },

});

export default StatusContent;
