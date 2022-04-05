import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { changeCircleEditorTitle, submitCircleEditor } from '../../../actions/circles';
import IconButton from '../../../components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  label: { id: 'circles.new.title_placeholder', defaultMessage: 'New circle title' },
  title: { id: 'circles.new.create', defaultMessage: 'Add circle' },
});

const mapStateToProps = state => ({
  value: state.getIn(['circleEditor', 'title']),
  disabled: state.getIn(['circleEditor', 'isSubmitting']),
});

const mapDispatchToProps = dispatch => ({
  onChange: value => dispatch(changeCircleEditorTitle(value)),
  onSubmit: () => dispatch(submitCircleEditor(true)),
});

export default @connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class NewCircleForm extends React.PureComponent {

  static propTypes = {
    value: PropTypes.string.isRequired,
    disabled: PropTypes.bool,
    intl: PropTypes.object.isRequired,
    onChange: PropTypes.func.isRequired,
    onSubmit: PropTypes.func.isRequired,
  };

  handleChange = e => {
    this.props.onChange(e.target.value);
  }

  handleSubmit = e => {
    e.preventDefault();
    this.props.onSubmit();
  }

  handleClick = () => {
    this.props.onSubmit();
  }

  render () {
    const { value, disabled, intl } = this.props;

    const label = intl.formatMessage(messages.label);
    const title = intl.formatMessage(messages.title);

    return (
      <form className='column-inline-form' onSubmit={this.handleSubmit}>
        <label>
          <span style={{ display: 'none' }}>{label}</span>

          <input
            className='setting-text'
            value={value}
            disabled={disabled}
            onChange={this.handleChange}
            placeholder={label}
          />
        </label>

        <IconButton
          disabled={disabled || !value}
          icon='plus'
          title={title}
          onClick={this.handleClick}
        />
      </form>
    );
  }

}
