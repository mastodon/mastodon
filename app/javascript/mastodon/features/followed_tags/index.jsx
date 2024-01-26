import PropTypes from 'prop-types';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { debounce } from 'lodash';

import TagIcon from '@/material-icons/400-24px/tag.svg?react';
import { expandFollowedHashtags, fetchFollowedHashtags } from 'mastodon/actions/tags';
import ColumnHeader from 'mastodon/components/column_header';
import { Hashtag } from 'mastodon/components/hashtag';
import ScrollableList from 'mastodon/components/scrollable_list';
import Column from 'mastodon/features/ui/components/column';

const messages = defineMessages({
  heading: { id: 'followed_tags', defaultMessage: 'Followed hashtags' },
});

const mapStateToProps = state => ({
  hashtags: state.getIn(['followed_tags', 'items']),
  isLoading: state.getIn(['followed_tags', 'isLoading'], true),
  hasMore: !!state.getIn(['followed_tags', 'next']),
});

class FollowedTags extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    hashtags: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    multiColumn: PropTypes.bool,
  };

  componentDidMount() {
    this.props.dispatch(fetchFollowedHashtags());
  }

  handleLoadMore = debounce(() => {
    this.props.dispatch(expandFollowedHashtags());
  }, 300, { leading: true });

  render () {
    const { intl, hashtags, isLoading, hasMore, multiColumn } = this.props;

    const emptyMessage = <FormattedMessage id='empty_column.followed_tags' defaultMessage='You have not followed any hashtags yet. When you do, they will show up here.' />;

    return (
      <Column bindToDocument={!multiColumn}>
        <ColumnHeader
          icon='hashtag'
          iconComponent={TagIcon}
          title={intl.formatMessage(messages.heading)}
          showBackButton
          multiColumn={multiColumn}
        />

        <ScrollableList
          scrollKey='followed_tags'
          emptyMessage={emptyMessage}
          hasMore={hasMore}
          isLoading={isLoading}
          onLoadMore={this.handleLoadMore}
          bindToDocument={!multiColumn}
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

export default connect(mapStateToProps)(injectIntl(FollowedTags));
