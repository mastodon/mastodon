import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import { changeListEditorTitle, changeListEditorIsExclusive, submitListEditor } from '../../../actions/lists';
import IconButton from '../../../components/icon_button';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import Toggle from 'react-toggle';

const messages = defineMessages({
  title: { id: 'lists.edit.submit', defaultMessage: 'Change title' },
});

const mapStateToProps = state => ({
  value: state.getIn(['listEditor', 'title']),
  disabled: !state.getIn(['listEditor', 'isChanged']) || !state.getIn(['listEditor', 'title']),
});

const mapDispatchToProps = dispatch => ({
  onChange: value => dispatch(changeListEditorTitle(value)),
  onSubmit: () => dispatch(submitListEditor(false)),
  onToggle: value => dispatch(changeListEditorIsExclusive(value)),
});

export default @connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class ListForm extends React.PureComponent {

  static propTypes = {
    value: PropTypes.string.isRequired,
    disabled: PropTypes.bool,
    isExclusive: PropTypes.bool,
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

  handleToggle = e => {
    this.props.onToggle(e.target.checked);
  }

  render () {
    const { value, disabled, intl, isExclusive, hello } = this.props;

    const title = intl.formatMessage(messages.title);

    return (
      <form className='column-inline-form' onSubmit={this.handleSubmit}>
        <input
          className='setting-text'
          value={value}
          onChange={this.handleChange}
        />

        <label htmlFor='is-exclusive-checkbox'>
          <Toggle className='is-exclusive-checkbox' defaultChecked={isExclusive} onChange={this.handleToggle}/>
          <FormattedMessage id='lists.is-exclusive' defaultMessage='Exclusive?' />
        </label>

        <IconButton
          disabled={disabled}
          icon='check'
          title={title}
          onClick={this.handleClick}
        />
      </form>
    );
  }

}
