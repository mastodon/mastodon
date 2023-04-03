import React from 'react';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import Column from 'flavours/glitch/components/column';
import ColumnHeader from 'flavours/glitch/components/column_header';
import { NavLink, Switch, Route } from 'react-router-dom';
import Links from './links';
import Tags from './tags';
import Statuses from './statuses';
import Suggestions from './suggestions';
import Search from 'flavours/glitch/features/compose/containers/search_container';
import SearchResults from './results';
import { showTrends } from 'flavours/glitch/initial_state';
import { Helmet } from 'react-helmet';

const messages = defineMessages({
  title: { id: 'explore.title', defaultMessage: 'Explore' },
  searchResults: { id: 'explore.search_results', defaultMessage: 'Search results' },
});

const mapStateToProps = state => ({
  layout: state.getIn(['meta', 'layout']),
  isSearching: state.getIn(['search', 'submitted']) || !showTrends,
});

class Explore extends React.PureComponent {

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
    const { intl, multiColumn, isSearching } = this.props;
    const { signedIn } = this.context.identity;

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.title)}>
        <ColumnHeader
          icon={isSearching ? 'search' : 'hashtag'}
          title={intl.formatMessage(isSearching ? messages.searchResults : messages.title)}
          onClick={this.handleHeaderClick}
          multiColumn={multiColumn}
        />

        <div className='explore__search-header'>
          <Search />
        </div>

        <div className='scrollable scrollable--flex'>
          {isSearching ? (
            <SearchResults />
          ) : (
            <>
              <div className='account__section-headline'>
                <NavLink exact to='/explore'>
                  <FormattedMessage tagName='div' id='explore.trending_statuses' defaultMessage='Posts' />
                </NavLink>
                <NavLink exact to='/explore/tags'>
                  <FormattedMessage tagName='div' id='explore.trending_tags' defaultMessage='Hashtags' />
                </NavLink>
                <NavLink exact to='/explore/links'>
                  <FormattedMessage tagName='div' id='explore.trending_links' defaultMessage='News' />
                </NavLink>
                {signedIn && (
                  <NavLink exact to='/explore/suggestions'>
                    <FormattedMessage tagName='div' id='explore.suggested_follows' defaultMessage='For you' />
                  </NavLink>
                )}
              </div>

              <Switch>
                <Route path='/explore/tags' component={Tags} />
                <Route path='/explore/links' component={Links} />
                <Route path='/explore/suggestions' component={Suggestions} />
                <Route exact path={['/explore', '/explore/posts', '/search']}>
                  <Statuses multiColumn={multiColumn} />
                </Route>
              </Switch>

              <Helmet>
                <title>{intl.formatMessage(messages.title)}</title>
                <meta name='robots' content={isSearching ? 'noindex' : 'all'} />
              </Helmet>
            </>
          )}
        </div>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Explore));
