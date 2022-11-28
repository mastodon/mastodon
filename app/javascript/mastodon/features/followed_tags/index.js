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
import { fetchFollowedHashtags } from 'mastodon/actions/tags';

const messages = defineMessages({
  heading: { id: 'followed_tags', defaultMessage: 'Followed hashtags' },
});

const mapStateToProps = (state, props) => ({
  hashtags: state.getIn(['followed_tags', 'items']),
  isLoading: state.getIn(['followed_tags', 'isLoading'], true),
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
  };

  componentWillMount () {
    this.props.dispatch(fetchFollowedHashtags());
  }

  render () {
    const { intl, hashtags, isLoading } = this.props;

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
        >
          {hashtags.map(hashtag =>
            <Hashtag key={hashtag.get('name')} hashtag={hashtag} withGraph={false} />,
          )}
        </ScrollableList>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}
