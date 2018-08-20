//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import {
  FormattedMessage,
  defineMessages,
} from 'react-intl';
import spring from 'react-motion/lib/spring';
import { Link } from 'react-router-dom';

//  Components.
import AccountContainer from 'flavours/glitch/containers/account_container';
import StatusContainer from 'flavours/glitch/containers/status_container';
import Hashtag from 'flavours/glitch/components/hashtag';

//  Utils.
import Motion from 'flavours/glitch/util/optional_motion';

//  Messages.
const messages = defineMessages({
  total: {
    defaultMessage: '{count, number} {count, plural, one {result} other {results}}',
    id: 'search_results.total',
  },
});

//  The component.
export default function DrawerResults ({
  results,
  visible,
}) {
  const accounts = results ? results.get('accounts') : null;
  const statuses = results ? results.get('statuses') : null;
  const hashtags = results ? results.get('hashtags') : null;

  //  This gets the total number of items.
  const count = [accounts, statuses, hashtags].reduce(function (size, item) {
    if (item && item.size) {
      return size + item.size;
    }
    return size;
  }, 0);

  //  The result.
  return (
    <Motion
      defaultStyle={{ x: -100 }}
      style={{
        x: spring(visible ? 0 : -100, {
          stiffness: 210,
          damping: 20,
        }),
      }}
    >
      {({ x }) => (
        <div
          className='drawer--results'
          style={{
            transform: `translateX(${x}%)`,
            visibility: x === -100 ? 'hidden' : 'visible',
          }}
        >
          <header>
            <FormattedMessage
              {...messages.total}
              values={{ count }}
            />
          </header>
          {accounts && accounts.size ? (
            <section>
              <h5><FormattedMessage id='search_results.accounts' defaultMessage='People' /></h5>

              {accounts.map(
                accountId => (
                  <AccountContainer
                    id={accountId}
                    key={accountId}
                  />
                )
              )}
            </section>
          ) : null}
          {statuses && statuses.size ? (
            <section>
              <h5><FormattedMessage id='search_results.statuses' defaultMessage='Toots' /></h5>

              {statuses.map(
                statusId => (
                  <StatusContainer
                    id={statusId}
                    key={statusId}
                  />
                )
              )}
            </section>
          ) : null}
          {hashtags && hashtags.size ? (
            <section>
              <h5><FormattedMessage id='search_results.hashtags' defaultMessage='Hashtags' /></h5>

              {hashtags.map(hashtag => <Hashtag key={hashtag.get('name')} hashtag={hashtag} />)}
            </section>
          ) : null}
        </div>
      )}
    </Motion>
  );
}

//  Props.
DrawerResults.propTypes = {
  results: ImmutablePropTypes.map,
  visible: PropTypes.bool,
};
