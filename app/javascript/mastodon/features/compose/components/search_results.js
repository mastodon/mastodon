import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage, FormattedNumber } from 'react-intl';
import AccountContainer from '../../../containers/account_container';
import StatusContainer from '../../../containers/status_container';
import { Link } from 'react-router-dom';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { Sparklines, SparklinesCurve } from 'react-sparklines';

const shortNumberFormat = number => {
  if (number < 1000) {
    return <FormattedNumber value={number} />;
  } else {
    return <React.Fragment><FormattedNumber value={number / 1000} maximumFractionDigits={1} />K</React.Fragment>;
  }
};

export default class SearchResults extends ImmutablePureComponent {

  static propTypes = {
    results: ImmutablePropTypes.map.isRequired,
    trends: ImmutablePropTypes.list,
    fetchTrends: PropTypes.func.isRequired,
  };

  componentDidMount () {
    const { fetchTrends } = this.props;
    fetchTrends();
  }

  render () {
    const { results, trends } = this.props;

    let accounts, statuses, hashtags;
    let count = 0;

    if (results.isEmpty()) {
      return (
        <div className='search-results'>
          <div className='trends'>
            <div className='trends__header'>
              <i className='fa fa-fire fa-fw' />
              <FormattedMessage id='trends.header' defaultMessage='Trending now' />
            </div>

            {trends && trends.map(hashtag => (
              <div className='trends__item' key={hashtag.get('name')}>
                <div className='trends__item__name'>
                  <Link to={`/timelines/tag/${hashtag.get('name')}`}>
                    #<span>{hashtag.get('name')}</span>
                  </Link>

                  <FormattedMessage id='trends.count_by_accounts' defaultMessage='{count} {rawCount, plural, one {person} other {people}} talking' values={{ rawCount: hashtag.getIn(['history', 0, 'accounts']), count: <strong>{shortNumberFormat(hashtag.getIn(['history', 0, 'accounts']))}</strong> }} />
                </div>

                <div className='trends__item__current'>
                  {shortNumberFormat(hashtag.getIn(['history', 0, 'uses']))}
                </div>

                <div className='trends__item__sparkline'>
                  <Sparklines width={50} height={28} data={hashtag.get('history').reverse().map(day => day.get('uses')).toArray()}>
                    <SparklinesCurve style={{ fill: 'none' }} />
                  </Sparklines>
                </div>
              </div>
            ))}
          </div>
        </div>
      );
    }

    if (results.get('accounts') && results.get('accounts').size > 0) {
      count   += results.get('accounts').size;
      accounts = (
        <div className='search-results__section'>
          <h5><FormattedMessage id='search_results.accounts' defaultMessage='People' /></h5>

          {results.get('accounts').map(accountId => <AccountContainer key={accountId} id={accountId} />)}
        </div>
      );
    }

    if (results.get('statuses') && results.get('statuses').size > 0) {
      count   += results.get('statuses').size;
      statuses = (
        <div className='search-results__section'>
          <h5><FormattedMessage id='search_results.statuses' defaultMessage='Toots' /></h5>

          {results.get('statuses').map(statusId => <StatusContainer key={statusId} id={statusId} />)}
        </div>
      );
    }

    if (results.get('hashtags') && results.get('hashtags').size > 0) {
      count += results.get('hashtags').size;
      hashtags = (
        <div className='search-results__section'>
          <h5><FormattedMessage id='search_results.hashtags' defaultMessage='Hashtags' /></h5>

          {results.get('hashtags').map(hashtag => (
            <Link key={hashtag} className='search-results__hashtag' to={`/timelines/tag/${hashtag}`}>
              {hashtag}
            </Link>
          ))}
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
