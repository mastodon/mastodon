import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Hashtag from 'mastodon/components/hashtag';

const messages = defineMessages({
  lastStatusAt: { id: 'account.featured_tags.last_status_at', defaultMessage: 'Last post on {date}' },
  empty: { id: 'account.featured_tags.last_status_never', defaultMessage: 'No posts' },
});

export default @injectIntl
class FeaturedTags extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    account: ImmutablePropTypes.map,
    featuredTags: ImmutablePropTypes.list,
    tagged: PropTypes.string,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { account, featuredTags, intl } = this.props;

    if (!account || account.get('suspended') || featuredTags.isEmpty()) {
      return null;
    }

    return (
      <div className='getting-started__trends'>
        <h4><FormattedMessage id='account.featured_tags.title' defaultMessage="{name}'s featured hashtags" values={{ name: <bdi dangerouslySetInnerHTML={{ __html: account.get('display_name_html') }} /> }} /></h4>

        {featuredTags.take(3).map(featuredTag => (
          <Hashtag
            key={featuredTag.get('name')}
            name={featuredTag.get('name')}
            href={featuredTag.get('url')}
            to={`/@${account.get('acct')}/tagged/${featuredTag.get('name')}`}
            uses={featuredTag.get('statuses_count') * 1}
            withGraph={false}
            description={((featuredTag.get('statuses_count') * 1) > 0) ? intl.formatMessage(messages.lastStatusAt, { date: intl.formatDate(featuredTag.get('last_status_at'), { month: 'short', day: '2-digit' }) }) : intl.formatMessage(messages.empty)}
          />
        ))}
      </div>
    );
  }

}
