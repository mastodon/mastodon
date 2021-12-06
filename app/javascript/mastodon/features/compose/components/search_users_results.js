import React from 'react';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage, defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { setupListEditor, resetListEditor } from '../../../actions/lists';
import { clearSearch } from '../../../actions/search_users';
import Account from '../../lists/components/account';
import Motion from '../../ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import LoadMore from 'mastodon/components/load_more';

const mapStateToProps = (state) => ({
  accountIds: Object.values(
    JSON.parse(state.getIn(['listEditor', 'hashtagsUsers'])).users
  ),
});

const mapDispatchToProps = (dispatch) => ({
  onInitialize: (listId) => dispatch(setupListEditor(listId)),
  onClear: () => dispatch(clearSearch()),
  onReset: () => dispatch(resetListEditor()),
});

const messages = defineMessages({
  dismissSuggestion: {
    id: 'suggestions.dismiss',
    defaultMessage: 'Dismiss suggestion',
  },
});

export default
@connect(mapStateToProps, mapDispatchToProps)
@injectIntl
class SearchUsersResults extends ImmutablePureComponent {
  static propTypes = {
    results: ImmutablePropTypes.map.isRequired,
    suggestions: ImmutablePropTypes.list.isRequired,
    accountIds: PropTypes.instanceOf(Array).isRequired,
    fetchSuggestions: PropTypes.func.isRequired,
    expandSearch: PropTypes.func.isRequired,
    dismissSuggestion: PropTypes.func.isRequired,
    searchTerm: PropTypes.string,
    intl: PropTypes.object.isRequired,
    onClear: PropTypes.func.isRequired,
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
    const {
      intl,
      results,
      suggestions,
      dismissSuggestion,
      searchTerm,
      onClear,
      accountIds,
    } = this.props;

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

    if (results.get('accounts') && results.get('accounts').size > 0)
      count += results.get('accounts').size;
    accounts = (
      <div className="drawer__pager">
        <div className="drawer__inner list-editor__accounts">
          {accountIds.map((accountId) => (
            <Account key={accountId} accountId={accountId} added />
          ))}
        </div>

        {count > 0 && (
          <div
            role="button"
            tabIndex="-1"
            className="drawer__backdrop"
            onClick={onClear}
          />
        )}

        {results.get('accounts') && results.get('accounts').size > 0 && (
          <Motion
            defaultStyle={{ x: -100 }}
            style={{
              x: spring(count > 0 ? 0 : -100, {
                stiffness: 210,
                damping: 20,
              }),
            }}
          >
            {({ x }) => (
              <div
                className="drawer__inner backdrop"
                style={{
                  transform: x === 0 ? null : `translateX(${x}%)`,
                  visibility: x === -100 ? 'hidden' : 'visible',
                }}
              >
                {results.get('accounts').map((accountId) => (
                  <Account key={accountId} accountId={accountId} />
                ))}

                {results.get('accounts').size >= 3 && (
                  <LoadMore visible onClick={this.handleLoadMoreAccounts} />
                )}
              </div>
            )}
          </Motion>
        )}
      </div>
    );

    return <div className="search-results">{accounts}</div>;
  }
}
