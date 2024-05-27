import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { injectIntl } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import debounce from 'lodash/debounce';

import {
  expandFollowedHashtags,
  fetchFollowedHashtags,
} from 'mastodon/actions/tags';
import ButtonScrollList from 'mastodon/components/button_scroll_list';
import { Hashtag } from 'mastodon/components/hashtag';
import { WithRouterPropTypes } from 'mastodon/utils/react_router';

const mapStateToProps = (state) => ({
  hashtags: state.getIn(['followed_tags', 'items']),
  isLoading: state.getIn(['followed_tags', 'isLoading'], true),
  hasMore: !!state.getIn(['followed_tags', 'next']),
});

class FollowedTagsList extends PureComponent {
  static propTypes = {
    hashtags: ImmutablePropTypes.list.isRequired,
    isLoading: PropTypes.bool.isRequired,
    hasMore: PropTypes.bool.isRequired,
    ...WithRouterPropTypes,
  };

  componentDidMount() {
    this.props.dispatch(fetchFollowedHashtags());
  }

  handleLoadMore = debounce(
    () => {
      this.props.dispatch(expandFollowedHashtags());
    },
    300,
    { leading: true },
  );

  render() {
    const { hashtags } = this.props;

    return (
      <div className='followed-tags-list'>
        <ButtonScrollList>
          {hashtags.map((hashtag) => (
            <div className='hashtag-wrapper' key={hashtag.get('name')}>
              <Hashtag
                name={hashtag.get('name')}
                showSkeleton={false}
                to={`/tags/${hashtag.get('name')}`}
                withGraph={false}
              />
            </div>
          ))}
        </ButtonScrollList>
      </div>
    );
  }
}

export default connect(mapStateToProps)(injectIntl(FollowedTagsList));
