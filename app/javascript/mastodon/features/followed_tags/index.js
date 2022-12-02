import { debounce } from 'lodash';
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import ColumnHeader from 'mastodon/components/column_header';
import LoadingIndicator from 'mastodon/components/loading_indicator';
import ScrollableList from 'mastodon/components/scrollable_list';
import Column from 'mastodon/features/ui/components/column';
import { Helmet } from 'react-helmet';
import Hashtag from 'mastodon/components/hashtag';
import { expandFollowedHashtags, fetchFollowedHashtags } from 'mastodon/actions/tags';

const messages = defineMessages({
  heading: { id: 'followed_tags', defaultMessage: 'Followed hashtags' },
});

const mapStateToProps = state => ({
  hashtags: state.getIn(['followed_tags', 'items']),
  isLoading: state.getIn(['followed_tags', 'isLoading'], true),
  hasMore: !!state.getIn(['followed_tags', 'next']),
});

export default @connect(mapStateToProps)
@injectIntl
class FollowedTags extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    hashtags: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
  };

  constructor(props) {
    super(props);

    this.props.dispatch(fetchFollowedHashtags());
  };

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandFollowedHashtags());
  }, 300, { leading: true });

  render () {
    const { intl, hashtags, isLoading, hasMore } = this.props;

    if (isLoading) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    const emptyMessage = <FormattedMessage id='empty_column.followed_tags' defaultMessage='You have not followed any hashtags yet. When you do, they will show up here.' />;

    return (
      <Column>
        <ColumnHeader
          icon='hashtag'
          title={intl.formatMessage(messages.heading)}
          showBackButton
        />

        <ScrollableList
          scrollKey='followed_tags'
          emptyMessage={emptyMessage}
          hasMore={hasMore}
          onLoadMore={this.handleLoadMore}
        >
          {hashtags.map((hashtag) => (
            <Hashtag
              key={hashtag.get('name')}
              name={hashtag.get('name')}
              to={`/tags/${hashtag.get('name')}`}
              withGraph={false}
              // Taken from ImmutableHashtag. Should maybe refactor ImmutableHashtag to accept more options?
              people={hashtag.getIn(['history', 0, 'accounts']) * 1 + hashtag.getIn(['history', 1, 'accounts']) * 1}
              history={hashtag.get('history').reverse().map((day) => day.get('uses')).toArray()}
            />
          ))}
        </ScrollableList>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}
