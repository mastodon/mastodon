import React from 'react';
import Column from 'mastodon/components/column';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import ImmutablePureComponent from 'react-immutable-pure-component';
import ColumnHeader from 'mastodon/components/column_header';
import { Helmet } from 'react-helmet';
import { searchEnabled } from '../../initial_state';

const messages = defineMessages({
  heading: { id: 'search_reference.heading', defaultMessage: 'Search Reference' },
});

export default @injectIntl
class SearchReference extends ImmutablePureComponent {

  static propTypes = {
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
  };

  render () {
    const { intl, multiColumn } = this.props;

    return (
      <Column>
        <ColumnHeader
          title={intl.formatMessage(messages.heading)}
          icon='question'
          multiColumn={multiColumn}
        />

        <div className='search-reference scrollable optionally-scrollable'>

          <p>
            { searchEnabled
              ? <FormattedMessage id='search_popout.tips.full_text' defaultMessage='Simple text returns statuses you have written, favourited, boosted, or have been mentioned in, as well as matching usernames, display names, and hashtags.' />
              : <FormattedMessage id='search_popout.tips.text' defaultMessage='Simple text returns matching display names, usernames and hashtags' />
            }
          </p>

          <table>
            <thead>
              <tr>
                <th><FormattedMessage id='search_reference.operator' defaultMessage='Operator' /></th>
                <th><FormattedMessage id='search_reference.description' defaultMessage='Description' /></th>
              </tr>
            </thead>

            <tbody>
              <tr>
                <th colSpan='2'><FormattedMessage id='search_reference.search_operators.sections.lookups' defaultMessage='Lookups'/></th>
              </tr>
              <tr>
                <td><kbd>#example</kbd></td>
                <td><FormattedMessage id='search_popout.tips.hashtag' defaultMessage='hashtag' /></td>
              </tr>
              <tr>
                <td><kbd>@username@domain</kbd></td>
                <td><FormattedMessage id='search_popout.tips.user' defaultMessage='user' /></td>
              </tr>
              <tr>
                <td><kbd>URL</kbd></td>
                <td><FormattedMessage id='search_popout.tips.user' defaultMessage='user' /></td>
              </tr>
              <tr>
                <td><kbd>URL</kbd></td>
                <td><FormattedMessage id='search_popout.tips.status' defaultMessage='status' /></td>
              </tr>
            </tbody>

            { searchEnabled &&
              <tbody>
                <tr>
                  <th colSpan='2'><FormattedMessage id='search_reference.search_operators.sections.advanced_syntax' defaultMessage='Advanced syntax'/></th>
                </tr>
                <tr>
                  <td><kbd>+term</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.include' defaultMessage='require term in results' /></td>
                </tr>
                <tr>
                  <td><kbd>-term</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.exclude' defaultMessage='exclude results containing term' /></td>
                </tr>
                <tr>
                  <td><kbd>&quot;John Mastodon&quot;</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.phrase' defaultMessage='search for an entire phrase instead of a single word' /></td>
                </tr>
                <tr>
                  <td><kbd>cat has:media</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.combinations' defaultMessage='operators can be combined with search terms or each other' /></td>
                </tr>
                <tr>
                  <td><kbd>-is:bot</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.negation' defaultMessage='most operators can be negated' /></td>
                </tr>
              </tbody>
            }

            { searchEnabled &&
              <tbody>
                <tr>
                  <th colSpan='2'><FormattedMessage id='search_reference.search_operators.sections.users_and_posts' defaultMessage='User and post operators'/></th>
                </tr>
                <tr>
                  <td><kbd>is:bot</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.is.bot' defaultMessage='automated accounts and posts from them' /></td>
                </tr>
                <tr>
                  <td><kbd>domain:example.org</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.domain' defaultMessage='limit search to users and posts from a given domain' /></td>
                </tr>
                <tr>
                  <td><kbd>scope:following</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.scope.following' defaultMessage='limit search to users that you follow and posts from them' /></td>
                </tr>
              </tbody>
            }

            { searchEnabled &&
              <tbody>
                <tr>
                  <th colspan='2'><FormattedMessage id='search_reference.search_operators.sections.posts' defaultMessage='Post operators' /></th>
                </tr>
                <tr>
                  <td><kbd>from:@username@domain</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.from' defaultMessage='posts authored by a given user' /></td>
                </tr>
                <tr>
                  <td><kbd>mentions:@username@domain</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.mentions' defaultMessage='posts mentioning a given user' /></td>
                </tr>
                <tr>
                  <td><kbd>is:reply</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.is.reply' defaultMessage='posts that are replies to another post' /></td>
                </tr>
                <tr>
                  <td><kbd>lang:es</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.lang' defaultMessage='posts in the given language' /></td>
                </tr>
                <tr>
                  <td><kbd>has:link</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.has.link' defaultMessage='posts that contain links' /></td>
                </tr>
                <tr>
                  <td><kbd>has:media</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.has.media' defaultMessage='posts that include media of some kind' /></td>
                </tr>
                <tr>
                  <td><kbd>has:poll</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.has.poll' defaultMessage='posts that include a poll' /></td>
                </tr>
                <tr>
                  <td><kbd>has:warning</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.has.warning' defaultMessage='posts that have a content warning' /></td>
                </tr>
                <tr>
                  <td><kbd>-has:warning</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.has.not_warning' defaultMessage='exclude posts that have a content warning' /></td>
                </tr>
                <tr>
                  <td><kbd>sensitive:yes</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.sensitive.yes' defaultMessage='posts that include sensitive media' /></td>
                </tr>
                <tr>
                  <td><kbd>sensitive:no</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.sensitive.no' defaultMessage='exclude posts that include sensitive media' /></td>
                </tr>
                <tr>
                  <td><kbd>before:2022-12-17</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.date.before' defaultMessage='search before a given date' /></td>
                </tr>
                <tr>
                  <td><kbd>after:2022-12-17</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.date.after' defaultMessage='search after a given date' /></td>
                </tr>
                <tr>
                  <td><kbd>sort:newest</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.sort.newest' defaultMessage='show newest results first' /></td>
                </tr>
                <tr>
                  <td><kbd>sort:oldest</kbd></td>
                  <td><FormattedMessage id='search_reference.search_operators.sort.oldest' defaultMessage='show oldest results first' /></td>
                </tr>
              </tbody>
            }
          </table>
        </div>

        <Helmet>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}
