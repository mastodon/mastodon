import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { ImmutableHashtag as Hashtag } from 'flavours/glitch/components/hashtag';
import LoadingIndicator from 'flavours/glitch/components/loading_indicator';
import { connect } from 'react-redux';
import { fetchTrendingHashtags } from 'flavours/glitch/actions/trends';
import { FormattedMessage } from 'react-intl';
import DismissableBanner from 'flavours/glitch/components/dismissable_banner';

const mapStateToProps = state => ({
  hashtags: state.getIn(['trends', 'tags', 'items']),
  isLoadingHashtags: state.getIn(['trends', 'tags', 'isLoading']),
});

export default @connect(mapStateToProps)
class Tags extends React.PureComponent {

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
        <FormattedMessage id='dismissable_banner.explore_tags' defaultMessage='These hashtags are gaining traction among people on this and other servers of the decentralized network right now.' />
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
