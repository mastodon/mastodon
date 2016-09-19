import IconButton      from '../../../components/icon_button';
import PureRenderMixin from 'react-addons-pure-render-mixin';

const FollowForm = React.createClass({

  propTypes: {
    text: React.PropTypes.string.isRequired,
    is_submitting: React.PropTypes.bool,
    onChange: React.PropTypes.func.isRequired,
    onSubmit: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  handleChange (e) {
    this.props.onChange(e.target.value);
  },

  handleKeyUp (e) {
    if (e.keyCode === 13) {
      this.props.onSubmit();
    }
  },

  handleSubmit () {
    this.props.onSubmit();
  },

  render () {
    return (
      <div style={{ display: 'flex', lineHeight: '20px', padding: '10px', background: '#373b4a' }}>
        <input type='text' disabled={this.props.is_submitting} placeholder='username@domain' value={this.props.text} onKeyUp={this.handleKeyUp} onChange={this.handleChange} className='follow-form__input' style={{ flex: '1 1 auto', boxSizing: 'border-box', display: 'block', border: 'none', padding: '10px', fontFamily: 'Roboto', color: '#282c37', fontSize: '14px', margin: '0' }} />
        <div style={{ padding: '10px', paddingRight: '0' }}><IconButton title='Follow' size={20} icon='user-plus' onClick={this.handleSubmit} disabled={this.props.is_submitting} /></div>
      </div>
    );
  }

});

export default FollowForm;
