import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Avatar             from '../../../components/avatar';
import IconButton         from '../../../components/icon_button';
import DisplayName        from '../../../components/display_name';

const ReplyIndicator = React.createClass({

  propTypes: {
    status: ImmutablePropTypes.map.isRequired,
    onCancel: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  handleClick () {
    this.props.onCancel();
  },

  render () {
    let content = { __html: this.props.status.get('content') };

    return (
      <div style={{ background: '#9baec8', padding: '10px' }}>
        <div style={{ overflow: 'hidden', marginBottom: '5px' }}>
          <div style={{ float: 'right', lineHeight: '24px' }}><IconButton title='Cancel' icon='times' onClick={this.handleClick} /></div>

          <a href={this.props.status.getIn(['account', 'url'])} className='reply-indicator__display-name' style={{ display: 'block', maxWidth: '100%', paddingRight: '25px', color: '#282c37', textDecoration: 'none', overflow: 'hidden', lineHeight: '24px' }}>
            <div style={{ float: 'left', marginRight: '5px' }}><Avatar size={24} src={this.props.status.getIn(['account', 'avatar'])} /></div>
            <DisplayName account={this.props.status.get('account')} />
          </a>
        </div>

        <div className='reply-indicator__content' dangerouslySetInnerHTML={content} />
      </div>
    );
  }

});

export default ReplyIndicator;
