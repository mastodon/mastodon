import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import AccountContainer from '../../../containers/account_container';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Icon from 'mastodon/components/icon';
import LoadMore from 'mastodon/components/load_more';

const messages = defineMessages({
  dismissSuggestion: {
    id: 'suggestions.dismiss',
    defaultMessage: 'Dismiss suggestion',
  },
});

export default
@injectIntl
class SearchUsersResults extends ImmutablePureComponent {
  static propTypes = {
    results: ImmutablePropTypes.map.isRequired,
    suggestions: ImmutablePropTypes.list.isRequired,
    fetchSuggestions: PropTypes.func.isRequired,
    expandSearch: PropTypes.func.isRequired,
    dismissSuggestion: PropTypes.func.isRequired,
    searchTerm: PropTypes.string,
    intl: PropTypes.object.isRequired,
  };

  componentDidMount() {
    if (this.props.searchTerm === '') {
      this.props.fetchSuggestions();
    }
  }

  componentDidUpdate() {
    if (this.props.searchTerm === '') {
      this.props.fetchSuggestions();
    }
  }

  handleLoadMoreAccounts = () => this.props.expandSearch('accounts');


  render() {
    const { intl, results, suggestions, dismissSuggestion, searchTerm } =
      this.props;

    if (searchTerm === '' && !suggestions.isEmpty()) {
      return (
        <div className="search-results">
          <div className="trends">
            <div className="trends__header">
              <Icon id="user-plus" fixedWidth />
              <FormattedMessage
                id="suggestions.header"
                defaultMessage="You might be interested in…"
              />
            </div>

            {suggestions &&
              suggestions.map((suggestion) => (
                <AccountContainer
                  key={suggestion.get('account')}
                  id={suggestion.get('account')}
                  actionIcon={
                    suggestion.get('source') === 'past_interaction'
                      ? 'times'
                      : null
                  }
                  actionTitle={
                    suggestion.get('source') === 'past_interaction'
                      ? intl.formatMessage(messages.dismissSuggestion)
                      : null
                  }
                  onActionClick={dismissSuggestion}
                />
              ))}
          </div>
        </div>
      );
    }

    let accounts;
    let count = 0;

    if (results.get('accounts') && results.get('accounts').size > 0) {
      count += results.get('accounts').size;
      accounts = (
        <div className="search-results__section">
          {results.get('accounts').map((accountId) => (
            <AccountContainer key={accountId} id={accountId} />
          ))}

          {results.get('accounts').size >= 3 && (
            <LoadMore visible onClick={this.handleLoadMoreAccounts} />
          )}
        </div>
      );
    }

    return <div className="search-results">{accounts}</div>;
  }
}
