import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { defineMessages, injectIntl } from 'react-intl';
import classNames from 'classnames';
import Permalink from 'mastodon/components/permalink';
import ShortNumber from 'mastodon/components/short_number';
import { List as ImmutableList } from 'immutable';

const messages = defineMessages({
  hashtag_all: { id: 'account.hashtag_all', defaultMessage: 'All' },
  hashtag_all_description: { id: 'account.hashtag_all_description', defaultMessage: 'All posts (deselect hashtags)' },
  hashtag_select_description: { id: 'account.hashtag_select_description', defaultMessage: 'Select hashtag #{name}' },
  statuses_counter: { id: 'account.statuses_counter', defaultMessage: '{count, plural, one {{counter} Post} other {{counter} Posts}}' },
});

const mapStateToProps = (state, { account }) => ({
  featuredTags: state.getIn(['user_lists', 'featured_tags', account.get('id'), 'items'], ImmutableList()),
});

export default @connect(mapStateToProps)
@injectIntl
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
    const { account, featuredTags, tagged, intl } = this.props;

    if (!account || featuredTags.isEmpty()) {
      return null;
    }

    const suspended = account.get('suspended');

    return (
      <div className={classNames('account__header', 'advanced', { inactive: !!account.get('moved') })}>
        <div className='account__header__extra'>
          <div className='account__header__extra__hashtag-links'>
            <Permalink key='all' className={classNames('account__hashtag-link', { active: !tagged })} title={intl.formatMessage(messages.hashtag_all_description)} href={account.get('url')} to={`/@${account.get('acct')}`}>{intl.formatMessage(messages.hashtag_all)}</Permalink>
            {!suspended && featuredTags.map(featuredTag => {
              const name  = featuredTag.get('name');
              const url   = featuredTag.get('url');
              const to    = `/@${account.get('acct')}/tagged/${name}`;
              const desc  = intl.formatMessage(messages.hashtag_select_description, { name });
              const count = featuredTag.get('statuses_count');

              return (
                <Permalink key={`#${name}`} className={classNames('account__hashtag-link', { active: this.context.router.history.location.pathname === to })} title={desc} href={url} to={to}>
                  #{name} <span title={intl.formatMessage(messages.statuses_counter, { count: count, counter: intl.formatNumber(count) })}>({<ShortNumber value={count} />})</span>
                </Permalink>
              );
            })}
          </div>
        </div>
      </div>
    );
  }

}
