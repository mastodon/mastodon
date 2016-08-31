import CharacterCounter from './character_counter';
import Button           from './button';
import PureRenderMixin  from 'react-addons-pure-render-mixin';

const ComposerDrawer = React.createClass({

  propTypes: {
    text: React.PropTypes.string.isRequired,
    isSubmitting: React.PropTypes.boolean,
    onChange: React.PropTypes.func.isRequired,
    onSubmit: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  handleChange (e) {
    this.props.onChange(e.target.value);
  },

  handleKeyUp (e) {
    if (e.keyCode === 13 && e.ctrlKey) {
      this.props.onSubmit();
    }
  },

  handleSubmit () {
    this.props.onSubmit();
  },

  render () {
    return (
      <div style={{ width: '380px', boxSizing: 'border-box', background: '#454b5e', margin: '10px', marginRight: '0', padding: '10px' }}>
        <textarea disabled={this.props.isSubmitting} placeholder='What is on your mind?' value={this.props.text} onKeyUp={this.handleKeyUp} onChange={this.handleChange} style={{ display: 'block', boxSizing: 'border-box', width: '100%', height: '100px', background: '#fff', resize: 'none', border: 'none', color: '#282c37', padding: '10px', fontFamily: 'Roboto', fontSize: '14px' }} />

        <div style={{ marginTop: '10px', overflow: 'hidden' }}>
          <div style={{ float: 'right' }}><Button text='Publish' onClick={this.handleSubmit} disabled={this.props.isSubmitting} /></div>
          <div style={{ float: 'right', marginRight: '16px', lineHeight: '36px' }}><CharacterCounter text={this.props.text} /></div>
        </div>
      </div>
    );
  }

});

export default ComposerDrawer;
