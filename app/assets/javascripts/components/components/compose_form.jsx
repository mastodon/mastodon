import CharacterCounter   from './character_counter';
import Button             from './button';
import PureRenderMixin    from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ReplyIndicator     from './reply_indicator';

const ComposeForm = React.createClass({

  propTypes: {
    text: React.PropTypes.string.isRequired,
    is_submitting: React.PropTypes.bool,
    in_reply_to: ImmutablePropTypes.map,
    onChange: React.PropTypes.func.isRequired,
    onSubmit: React.PropTypes.func.isRequired,
    onCancelReply: React.PropTypes.func.isRequired
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
    let replyArea = '';

    if (this.props.in_reply_to) {
      replyArea = <ReplyIndicator status={this.props.in_reply_to} onCancel={this.props.onCancelReply} />;
    }

    return (
      <div style={{ marginBottom: '30px', padding: '10px' }}>
        {replyArea}

        <textarea disabled={this.props.is_submitting} placeholder='What is on your mind?' value={this.props.text} onKeyUp={this.handleKeyUp} onChange={this.handleChange} className='compose-form__textarea' style={{ display: 'block', boxSizing: 'border-box', width: '100%', height: '100px', resize: 'none', border: 'none', color: '#282c37', padding: '10px', fontFamily: 'Roboto', fontSize: '14px', margin: '0' }} />

        <div style={{ marginTop: '10px', overflow: 'hidden' }}>
          <div style={{ float: 'right' }}><Button text='Publish' onClick={this.handleSubmit} disabled={this.props.is_submitting} /></div>
          <div style={{ float: 'right', marginRight: '16px', lineHeight: '36px' }}><CharacterCounter text={this.props.text} /></div>
        </div>
      </div>
    );
  }

});

export default ComposeForm;
