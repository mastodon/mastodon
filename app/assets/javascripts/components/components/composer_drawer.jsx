import CharacterCounter from './character_counter';
import Button           from './button';
import { publish }      from '../actions/statuses';

const ComposerDrawer = React.createClass({

  propTypes: {
    onSubmit: React.PropTypes.func.isRequired
  },

  getInitialState() {
    return {
      text: ''
    };
  },

  handleChange (e) {
    this.setState({ text: e.target.value });
  },

  handleKeyUp (e) {
    if (e.keyCode === 13 && e.ctrlKey) {
      this.handleSubmit();
    }
  },

  handleSubmit () {
    this.props.onSubmit(this.state.text, null);
  },

  render () {
    return (
      <div style={{ width: '230px', background: '#454b5e', margin: '10px 0', padding: '10px' }}>
        <textarea placeholder='What is on your mind?' value={this.state.text} onKeyUp={this.handleKeyUp} onChange={this.handleChange} style={{ display: 'block', boxSizing: 'border-box', width: '100%', height: '100px', background: '#fff', resize: 'none', border: 'none', color: '#282c37', padding: '10px', fontFamily: 'Roboto', fontSize: '14px' }} />

        <div style={{ marginTop: '10px', overflow: 'hidden' }}>
          <div style={{ float: 'right' }}><Button text='Publish' onClick={this.handleSubmit} /></div>
          <div style={{ float: 'right', marginRight: '16px', lineHeight: '36px' }}><CharacterCounter text={this.state.text} /></div>
        </div>
      </div>
    );
  }

});

export default ComposerDrawer;
