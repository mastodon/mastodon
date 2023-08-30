import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { fetchTrendingHashtags } from 'mastodon/actions/trends';
import { DismissableBanner } from 'mastodon/components/dismissable_banner';
import { ImmutableHashtag as Hashtag } from 'mastodon/components/hashtag';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';

const mapStateToProps = state => ({
  hashtags: state.getIn(['trends', 'tags', 'items']),
  isLoadingHashtags: state.getIn(['trends', 'tags', 'isLoading']),
});

class Tags extends PureComponent {

  static propTypes = {
    hashtags: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    dispatch: PropTypes.func.isRequired,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchTrendingHashtags());
  }

  render () {
    const { isLoading, hashtags } = this.props;

    const banner = (
      <DismissableBanner id='explore/tags'>
        <FormattedMessage id='dismissable_banner.explore_tags' defaultMessage='These are hashtags that are gaining traction on the social web today. Hashtags that are used by more different people are ranked higher.' />
      </DismissableBanner>
    );

    if (!isLoading && hashtags.isEmpty()) {
      return (
        <div className='explore__links scrollable scrollable--flex'>
          {banner}

          <div className='empty-column-indicator'>
            <FormattedMessage id='empty_column.explore_statuses' defaultMessage='Nothing is trending right now. Check back later!' />
          </div>
        </div>
      );
    }

    return (
      <div className='explore__links'>
        {banner}

        {isLoading ? (<LoadingIndicator />) : hashtags.map(hashtag => (
          <Hashtag key={hashtag.get('name')} hashtag={hashtag} />
        ))}
      </div>
    );
  }

}

export default connect(mapStateToProps)(Tags);
