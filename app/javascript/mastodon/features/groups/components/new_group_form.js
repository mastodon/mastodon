import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { changeGroupEditorTitle, submitGroupEditor } from 'mastodon/actions/groups';
import IconButton from 'mastodon/components/icon_button';
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  label: { id: 'groups.new.title_placeholder', defaultMessage: 'New group name' },
  title: { id: 'groups.new.create', defaultMessage: 'Create a new group' },
});

const mapStateToProps = state => ({
  value: state.getIn(['groupEditor', 'displayName']),
  disabled: state.getIn(['groupEditor', 'isSubmitting']),
});

const mapDispatchToProps = dispatch => ({
  onChange: value => dispatch(changeGroupEditorTitle(value)),
  onSubmit: () => dispatch(submitGroupEditor(true)),
});

export default @connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class NewGroupForm extends React.PureComponent {

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
