import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Hashtag from 'mastodon/components/hashtag';

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
    this.refreshInterval = setInterval(() => this.props.fetchTrends(), 36000);
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
        {trends.take(3).map(hashtag => <Hashtag key={hashtag.get('name')} hashtag={hashtag} />)}
      </div>
    );
  }

}
