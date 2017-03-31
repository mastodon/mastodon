import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

const messages = defineMessages({
  placeholder: { id: 'search.placeholder', defaultMessage: 'Search' }
});

const Search = React.createClass({

  propTypes: {
    value: React.PropTypes.string.isRequired,
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

  handleFocus () {
    this.props.onShow();
  },

  render () {
    const { intl, value } = this.props;
    const hasValue = value.length > 0;

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

        <div className='search__icon'>
          <i className={`fa fa-search ${hasValue ? '' : 'active'}`} />
          <i className={`fa fa-times-circle ${hasValue ? 'active' : ''}`} onClick={this.handleClear} />
        </div>
      </div>
    );
  }

});

export default injectIntl(Search);
