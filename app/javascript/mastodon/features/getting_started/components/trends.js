import classNames from 'classnames';
import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage, defineMessages } from 'react-intl';
import Hashtag from '../../../components/hashtag';
import { Link } from 'react-router-dom';

const messages = defineMessages({
  refresh_trends: { id: 'trends.refresh', defaultMessage: 'Refresh' },
});

export default class Trends extends ImmutablePureComponent {

  static defaultProps = {
    loading: false,
  };

  static propTypes = {
    trends: ImmutablePropTypes.list,
    loading: PropTypes.bool.isRequired,
    showTrends: PropTypes.bool.isRequired,
    fetchTrends: PropTypes.func.isRequired,
    toggleTrends: PropTypes.func.isRequired,
  };

  componentDidMount () {
    setTimeout(() => this.props.fetchTrends(), 5000);
  }

  handleRefreshTrends = () => {
    this.props.fetchTrends();
  }

  handleToggle = () => {
    this.props.toggleTrends(!this.props.showTrends);
  }

  render () {
    const { intl, trends, loading, showTrends } = this.props;

    if (!trends || trends.size < 1) {
      return null;
    }

    return (
      <div className='getting-started__trends'>
        <div className='column-header__wrapper'>
          <h1 className='column-header'>
            <button>
              <i className='fa fa-fire fa-fw' />
              <FormattedMessage id='trends.header' defaultMessage='Trending now' />
            </button>

            <div className='column-header__buttons'>
              {showTrends && <button onClick={this.handleRefreshTrends} className='column-header__button' title={intl.formatMessage(messages.refresh_trends)} aria-label={intl.formatMessage(messages.refresh_trends)} disabled={loading}><i className={classNames('fa', 'fa-refresh', { 'fa-spin': loading })} /></button>}
              <button onClick={this.handleToggle} className='column-header__button'><i className={classNames('fa', showTrends ? 'fa-chevron-down' : 'fa-chevron-up')} /></button>
            </div>
          </h1>
        </div>

        {showTrends && <div className='getting-started__scrollable'>
          {trends.take(3).map(hashtag => <Hashtag key={hashtag.get('name')} hashtag={hashtag} />)}
          <Link to='/trends' className='load-more'><FormattedMessage id='status.load_more' defaultMessage='Load more' /></Link>
        </div>}
      </div>
    );
  }

}
