import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import { Link } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { ImmutableHashtag as Hashtag } from 'mastodon/components/hashtag';

export default class Trends extends ImmutablePureComponent {

  static defaultProps = {
    loading: false,
  };

  static propTypes = {
    trends: ImmutablePropTypes.list,
    fetchTrends: PropTypes.func.isRequired,
  };

  componentDidMount () {
    this.props.fetchTrends();
    this.refreshInterval = setInterval(() => this.props.fetchTrends(), 900 * 1000);
  }

  componentWillUnmount () {
    if (this.refreshInterval) {
      clearInterval(this.refreshInterval);
    }
  }

  render () {
    const { trends } = this.props;

    if (!trends || trends.isEmpty()) {
      return null;
    }

    return (
      <div className='getting-started__trends'>
        <h4>
          <Link to={'/explore/tags'}>
            <FormattedMessage id='trends.trending_now' defaultMessage='Trending now' />
          </Link>
        </h4>

        {trends.take(3).map(hashtag => <Hashtag key={hashtag.get('name')} hashtag={hashtag} />)}
      </div>
    );
  }

}
