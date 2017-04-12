import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

const messages = defineMessages({
  placeholder: { id: 'search.placeholder', defaultMessage: 'Search' }
});

const Search = React.createClass({

  propTypes: {
    value: React.PropTypes.string.isRequired,
    submitted: React.PropTypes.bool,
    onChange: React.PropTypes.func.isRequired,
    onSubmit: React.PropTypes.func.isRequired,
    onClear: React.PropTypes.func.isRequired,
    onShow: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  handleChange (e) {
    this.props.onChange(e.target.value);
  },

  handleClear (e) {
    e.preventDefault();
    this.props.onClear();
  },

  handleFocus () {
    this.props.onShow();
  },

  handleSubmit (e) {
    e.preventDefault();
    this.props.onSubmit();
  },

  render () {
    const { intl, value, submitted } = this.props;
    const hasValue = value.length > 0 || submitted;

    return (
      <form role='search' className='search' onSubmit={this.handleSubmit}>
        <input
          className='search__input'
          type='text'
          required={true}
          placeholder={intl.formatMessage(messages.placeholder)}
          value={value}
          onChange={this.handleChange}
          onFocus={this.handleFocus}
        />

        <button type='submit' className='search__icon'>
          <i className={`fa fa-search ${hasValue ? '' : 'active'}`} />
          <i className={`fa fa-times-circle ${hasValue ? 'active' : ''}`} onClick={this.handleClear} />
        </button>
      </form>
    );
  }

});

export default injectIntl(Search);
