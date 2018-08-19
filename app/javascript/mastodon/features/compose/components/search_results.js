import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import AccountContainer from '../../../containers/account_container';
import StatusContainer from '../../../containers/status_container';
import ImmutablePureComponent from 'react-immutable-pure-component';
import Hashtag from '../../../components/hashtag';
import { fetchAnonymously } from '../../../initial_state';

export default class SearchResults extends ImmutablePureComponent {

  static propTypes = {
    results: ImmutablePropTypes.map.isRequired,
    query: PropTypes.string.isRequired,
  };

  render () {
    const { results, query } = this.props;

    let accounts, statuses, hashtags;
    let count = 0;

    if (results.get('accounts') && results.get('accounts').size > 0) {
      count   += results.get('accounts').size;
      accounts = (
        <div className='search-results__section'>
          <h5><i className='fa fa-fw fa-users' /><FormattedMessage id='search_results.accounts' defaultMessage='People' /></h5>

          {results.get('accounts').map(accountId => <AccountContainer key={accountId} id={accountId} />)}
        </div>
      );
    }

    if (results.get('statuses') && results.get('statuses').size > 0) {
      count   += results.get('statuses').size;
      statuses = (
        <div className='search-results__section'>
          <h5><i className='fa fa-fw fa-quote-right' /><FormattedMessage id='search_results.statuses' defaultMessage='Toots' /></h5>

          {results.get('statuses').map(statusId => <StatusContainer key={statusId} id={statusId} />)}
        </div>
      );
    } else if (count === 0 && query.trim().startsWith('https://') && fetchAnonymously) {
      statuses = (
        <div className='search-results__section'>
          <h5><i className='fa fa-fw fa-quote-right' /><FormattedMessage id='search_results.statuses' defaultMessage='Toots' /></h5>

          <div className='search-results__warning'>
            <FormattedMessage id='search_results.fetch_anonymously_warning' defaultMessage='Nothing was found at the requested URL. It may require authentication, but your account is configured to not authentify to remote instances. You can {change_setting}.' values={{ change_setting: <a href='/settings/preferences#user_setting_fetch_anonymously'><FormattedMessage id='search_results.change_setting' defaultMessage='change this setting' /></a> }} />

          </div>
        </div>
      );
    }

    if (results.get('hashtags') && results.get('hashtags').size > 0) {
      count += results.get('hashtags').size;
      hashtags = (
        <div className='search-results__section'>
          <h5><i className='fa fa-fw fa-hashtag' /><FormattedMessage id='search_results.hashtags' defaultMessage='Hashtags' /></h5>

          {results.get('hashtags').map(hashtag => <Hashtag key={hashtag.get('name')} hashtag={hashtag} />)}
        </div>
      );
    }

    return (
      <div className='search-results'>
        <div className='search-results__header'>
          <i className='fa fa-search fa-fw' />
          <FormattedMessage id='search_results.total' defaultMessage='{count, number} {count, plural, one {result} other {results}}' values={{ count }} />
        </div>

        {accounts}
        {statuses}
        {hashtags}
      </div>
    );
  }

}
