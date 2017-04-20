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

  handleKeyDown (e) {
    if (e.key === 'Enter') {
      e.preventDefault();
      this.props.onSubmit();
    }
  },

  noop () {

  },

  handleFocus () {
    this.props.onShow();
  },

  render () {
    const { intl, value, submitted } = this.props;
    const hasValue = value.length > 0 || submitted;

    return (
      <div className='search'>
        <input
          className='search__input'
          type='text'
          placeholder={intl.formatMessage(messages.placeholder)}
          value={value}
          onChange={this.handleChange}
          onKeyUp={this.handleKeyDown}
          onFocus={this.handleFocus}
        />

        <div role='button' tabIndex='0' className='search__icon' onClick={hasValue ? this.handleClear : this.noop}>
          <i className={`fa fa-search ${hasValue ? '' : 'active'}`} />
          <i aria-label="Clear search" className={`fa fa-times-circle ${hasValue ? 'active' : ''}`} />
        </div>
      </div>
    );
  }

});

export default injectIntl(Search);
