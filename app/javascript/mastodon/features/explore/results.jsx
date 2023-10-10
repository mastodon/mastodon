import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import { List as ImmutableList } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { submitSearch, expandSearch } from 'mastodon/actions/search';
import { ImmutableHashtag as Hashtag } from 'mastodon/components/hashtag';
import { Icon } from 'mastodon/components/icon';
import ScrollableList from 'mastodon/components/scrollable_list';
import Account from 'mastodon/containers/account_container';
import Status from 'mastodon/containers/status_container';

import { SearchSection } from './components/search_section';

const messages = defineMessages({
  title: { id: 'search_results.title', defaultMessage: 'Search for {q}' },
});

const mapStateToProps = state => ({
  isLoading: state.getIn(['search', 'isLoading']),
  results: state.getIn(['search', 'results']),
  q: state.getIn(['search', 'searchTerm']),
  submittedType: state.getIn(['search', 'type']),
});

const INITIAL_PAGE_LIMIT = 10;
const INITIAL_DISPLAY = 4;

const hidePeek = list => {
  if (list.size > INITIAL_PAGE_LIMIT && list.size % INITIAL_PAGE_LIMIT === 1) {
    return list.skipLast(1);
  } else {
    return list;
  }
};

const renderAccounts = accounts => hidePeek(accounts).map(id => (
  <Account key={id} id={id} />
));

const renderHashtags = hashtags => hidePeek(hashtags).map(hashtag => (
  <Hashtag key={hashtag.get('name')} hashtag={hashtag} />
));

const renderStatuses = statuses => hidePeek(statuses).map(id => (
  <Status key={id} id={id} />
));

class Results extends PureComponent {

  static propTypes = {
    results: ImmutablePropTypes.contains({
      accounts: ImmutablePropTypes.orderedSet,
      statuses: ImmutablePropTypes.orderedSet,
      hashtags: ImmutablePropTypes.orderedSet,
    }),
    isLoading: PropTypes.bool,
    multiColumn: PropTypes.bool,
    dispatch: PropTypes.func.isRequired,
    q: PropTypes.string,
    intl: PropTypes.object,
    submittedType: PropTypes.oneOf(['accounts', 'statuses', 'hashtags']),
  };

  state = {
    type: this.props.submittedType || 'all',
  };

  static getDerivedStateFromProps(props, state) {
    if (props.submittedType !== state.type) {
      return {
        type: props.submittedType || 'all',
      };
    }

    return null;
  }

  handleSelectAll = () => {
    const { submittedType, dispatch } = this.props;

    // If we originally searched for a specific type, we need to resubmit
    // the query to get all types of results
    if (submittedType) {
      dispatch(submitSearch());
    }

    this.setState({ type: 'all' });
  };

  handleSelectAccounts = () => {
    const { submittedType, dispatch } = this.props;

    // If we originally searched for something else (but not everything),
    // we need to resubmit the query for this specific type
    if (submittedType !== 'accounts') {
      dispatch(submitSearch('accounts'));
    }

    this.setState({ type: 'accounts' });
  };

  handleSelectHashtags = () => {
    const { submittedType, dispatch } = this.props;

    // If we originally searched for something else (but not everything),
    // we need to resubmit the query for this specific type
    if (submittedType !== 'hashtags') {
      dispatch(submitSearch('hashtags'));
    }

    this.setState({ type: 'hashtags' });
  };

  handleSelectStatuses = () => {
    const { submittedType, dispatch } = this.props;

    // If we originally searched for something else (but not everything),
    // we need to resubmit the query for this specific type
    if (submittedType !== 'statuses') {
      dispatch(submitSearch('statuses'));
    }

    this.setState({ type: 'statuses' });
  };

  handleLoadMoreAccounts = () => this._loadMore('accounts');
  handleLoadMoreStatuses = () => this._loadMore('statuses');
  handleLoadMoreHashtags = () => this._loadMore('hashtags');

  _loadMore (type) {
    const { dispatch } = this.props;
    dispatch(expandSearch(type));
  }

  handleLoadMore = () => {
    const { type } = this.state;

    if (type !== 'all') {
      this._loadMore(type);
    }
  };

  render () {
    const { intl, isLoading, q, results } = this.props;
    const { type } = this.state;

    // We request 1 more result than we display so we can tell if there'd be a next page
    const hasMore = type !== 'all' ? results.get(type, ImmutableList()).size > INITIAL_PAGE_LIMIT && results.get(type).size % INITIAL_PAGE_LIMIT === 1 : false;

    let filteredResults;

    const accounts = results.get('accounts', ImmutableList());
    const hashtags = results.get('hashtags', ImmutableList());
    const statuses = results.get('statuses', ImmutableList());

    switch(type) {
    case 'all':
      filteredResults = (accounts.size + hashtags.size + statuses.size) > 0 ? (
        <>
          {accounts.size > 0 && (
            <SearchSection key='accounts' title={<><Icon id='users' fixedWidth /><FormattedMessage id='search_results.accounts' defaultMessage='Profiles' /></>} onClickMore={this.handleLoadMoreAccounts}>
              {accounts.take(INITIAL_DISPLAY).map(id => <Account key={id} id={id} />)}
            </SearchSection>
          )}

          {hashtags.size > 0 && (
            <SearchSection key='hashtags' title={<><Icon id='hashtag' fixedWidth /><FormattedMessage id='search_results.hashtags' defaultMessage='Hashtags' /></>} onClickMore={this.handleLoadMoreHashtags}>
              {hashtags.take(INITIAL_DISPLAY).map(hashtag => <Hashtag key={hashtag.get('name')} hashtag={hashtag} />)}
            </SearchSection>
          )}

          {statuses.size > 0 && (
            <SearchSection key='statuses' title={<><Icon id='quote-right' fixedWidth /><FormattedMessage id='search_results.statuses' defaultMessage='Posts' /></>} onClickMore={this.handleLoadMoreStatuses}>
              {statuses.take(INITIAL_DISPLAY).map(id => <Status key={id} id={id} />)}
            </SearchSection>
          )}
        </>
      ) : [];
      break;
    case 'accounts':
      filteredResults = renderAccounts(accounts);
      break;
    case 'hashtags':
      filteredResults = renderHashtags(hashtags);
      break;
    case 'statuses':
      filteredResults = renderStatuses(statuses);
      break;
    }

    return (
      <>
        <div className='account__section-headline'>
          <button onClick={this.handleSelectAll} className={type === 'all' ? 'active' : undefined}><FormattedMessage id='search_results.all' defaultMessage='All' /></button>
          <button onClick={this.handleSelectAccounts} className={type === 'accounts' ? 'active' : undefined}><FormattedMessage id='search_results.accounts' defaultMessage='Profiles' /></button>
          <button onClick={this.handleSelectHashtags} className={type === 'hashtags' ? 'active' : undefined}><FormattedMessage id='search_results.hashtags' defaultMessage='Hashtags' /></button>
          <button onClick={this.handleSelectStatuses} className={type === 'statuses' ? 'active' : undefined}><FormattedMessage id='search_results.statuses' defaultMessage='Posts' /></button>
        </div>

        <div className='explore__search-results' data-nosnippet>
          <ScrollableList
            scrollKey='search-results'
            isLoading={isLoading}
            onLoadMore={this.handleLoadMore}
            hasMore={hasMore}
            emptyMessage={<FormattedMessage id='search_results.nothing_found' defaultMessage='Could not find anything for these search terms' />}
            bindToDocument
          >
            {filteredResults}
          </ScrollableList>
        </div>

        <Helmet>
          <title>{intl.formatMessage(messages.title, { q })}</title>
        </Helmet>
      </>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Results));
