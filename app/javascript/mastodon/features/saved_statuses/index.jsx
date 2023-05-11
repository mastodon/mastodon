import React from 'react';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import PropTypes from 'prop-types';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import { NavLink, Switch, Route, Redirect } from 'react-router-dom';
import Favourites from './favourites';
import Bookmarks from './bookmarks';
import { Helmet } from 'react-helmet';

const messages = defineMessages({
  title: { id: 'saved.title', defaultMessage: 'Saved posts' },
});

class SavedStatuses extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
    identity: PropTypes.object,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
    isSearching: PropTypes.bool,
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  setRef = c => {
    this.column = c;
  };

  render() {
    const { intl, multiColumn } = this.props;

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.title)}>
        <ColumnHeader
          icon={'bookmark'}
          title={intl.formatMessage(messages.title)}
          onClick={this.handleHeaderClick}
          multiColumn={multiColumn}
        />

        <div className='scrollable scrollable--flex'>
          <div className='account__section-headline'>
            <NavLink exact to='/saved/favourites'>
              <FormattedMessage tagName='div' id='favourites.title' defaultMessage='Favourites' />
            </NavLink>

            <NavLink exact to='/saved/bookmarks'>
              <FormattedMessage tagName='div' id='bookmarks.title' defaultMessage='Bookmarks' />
            </NavLink>
          </div>

          <Switch>
            <Redirect from='/saved' to='/saved/favourites' exact />
            <Route path='/saved/favourites' component={Favourites} />
            <Route path='/saved/bookmarks' component={Bookmarks} />
          </Switch>
        </div>

        <Helmet>
          <title>{intl.formatMessage(messages.title)}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default injectIntl(SavedStatuses);
