import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Autosuggest from 'react-autosuggest';
import AutosuggestAccountContainer from '../containers/autosuggest_account_container';
import AutosuggestStatusContainer from '../containers/autosuggest_status_container';
import { debounce } from 'react-decoration';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

const messages = defineMessages({
  placeholder: { id: 'search.placeholder', defaultMessage: 'Search' }
});

const getSuggestionValue = suggestion => suggestion.value;

const renderSuggestion = suggestion => {
  if (suggestion.type === 'account') {
    return <AutosuggestAccountContainer id={suggestion.id} />;
  } else if (suggestion.type === 'hashtag') {
    return <span>#{suggestion.id}</span>;
  } else {
    return <AutosuggestStatusContainer id={suggestion.id} />;
  }
};

const renderSectionTitle = section => (
  <strong><FormattedMessage id={`search.${section.title}`} defaultMessage={section.title} /></strong>
);

const getSectionSuggestions = section => section.items;

const outerStyle = {
  padding: '10px',
  lineHeight: '20px',
  position: 'relative'
};

const iconStyle = {
  position: 'absolute',
  top: '18px',
  right: '20px',
  fontSize: '18px',
  pointerEvents: 'none'
};

const Search = React.createClass({

  contextTypes: {
    router: React.PropTypes.object
  },

  propTypes: {
    suggestions: React.PropTypes.array.isRequired,
    value: React.PropTypes.string.isRequired,
    onChange: React.PropTypes.func.isRequired,
    onClear: React.PropTypes.func.isRequired,
    onFetch: React.PropTypes.func.isRequired,
    onReset: React.PropTypes.func.isRequired,
    intl: React.PropTypes.object.isRequired
  },

  mixins: [PureRenderMixin],

  onChange (_, { newValue }) {
    if (typeof newValue !== 'string') {
      return;
    }

    this.props.onChange(newValue);
  },

  onSuggestionsClearRequested () {
    this.props.onClear();
  },

  @debounce(500)
  onSuggestionsFetchRequested ({ value }) {
    value = value.replace('#', '');
    this.props.onFetch(value.trim());
  },

  onSuggestionSelected (_, { suggestion }) {
    if (suggestion.type === 'account') {
      this.context.router.push(`/accounts/${suggestion.id}`);
    } else if(suggestion.type === 'hashtag') {
      this.context.router.push(`/timelines/tag/${suggestion.id}`);
    } else {
      this.context.router.push(`/statuses/${suggestion.id}`);
    }
  },

  render () {
    const inputProps = {
      placeholder: this.props.intl.formatMessage(messages.placeholder),
      value: this.props.value,
      onChange: this.onChange,
      className: 'search__input'
    };

    return (
      <div className='search' style={outerStyle}>
        <Autosuggest
          multiSection={true}
          suggestions={this.props.suggestions}
          focusFirstSuggestion={true}
          focusInputOnSuggestionClick={false}
          alwaysRenderSuggestions={false}
          onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
          onSuggestionsClearRequested={this.onSuggestionsClearRequested}
          onSuggestionSelected={this.onSuggestionSelected}
          getSuggestionValue={getSuggestionValue}
          renderSuggestion={renderSuggestion}
          renderSectionTitle={renderSectionTitle}
          getSectionSuggestions={getSectionSuggestions}
          inputProps={inputProps}
        />

        <div style={iconStyle}><i className='fa fa-search' /></div>
      </div>
    );
  },

});

export default injectIntl(Search);
