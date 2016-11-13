import PureRenderMixin from 'react-addons-pure-render-mixin';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Autosuggest from 'react-autosuggest';
import AutosuggestAccountContainer from '../containers/autosuggest_account_container';

const getSuggestionValue = suggestion => suggestion.value;

const renderSuggestion = suggestion => {
  if (suggestion.type === 'account') {
    return <AutosuggestAccountContainer id={suggestion.id} />;
  } else {
    return <span>#{suggestion.id}</span>
  }
};

const renderSectionTitle = section => (
  <strong>{section.title}</strong>
);

const getSectionSuggestions = section => section.items;

const outerStyle = {
  padding: '10px',
  lineHeight: '20px',
  position: 'relative'
};

const inputStyle = {
  boxSizing: 'border-box',
  display: 'block',
  width: '100%',
  border: 'none',
  padding: '10px',
  paddingRight: '30px',
  fontFamily: 'Roboto',
  background: '#282c37',
  color: '#9baec8',
  fontSize: '14px',
  margin: '0'
};

const iconStyle = {
  position: 'absolute',
  top: '18px',
  right: '20px',
  color: '#9baec8',
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
    onReset: React.PropTypes.func.isRequired
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

  onSuggestionsFetchRequested ({ value }) {
    value = value.replace('#', '');
    this.props.onFetch(value.trim());
  },

  onSuggestionSelected (_, { suggestion }) {
    if (suggestion.type === 'account') {
      this.context.router.push(`/accounts/${suggestion.id}`);
    } else {
      this.context.router.push(`/statuses/tag/${suggestion.id}`);
    }
  },

  render () {
    const inputProps = {
      placeholder: 'Search',
      value: this.props.value,
      onChange: this.onChange,
      style: inputStyle
    };

    return (
      <div style={outerStyle}>
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

export default Search;
