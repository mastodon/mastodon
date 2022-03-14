import React from 'react';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import Column from 'mastodon/components/column';
import ColumnHeader from 'mastodon/components/column_header';
import { NavLink, Switch, Route } from 'react-router-dom';
import Links from './links';
import Tags from './tags';
import Statuses from './statuses';
import Suggestions from './suggestions';
import Search from 'mastodon/features/compose/containers/search_container';
import SearchResults from './results';

const messages = defineMessages({
  title: { id: 'explore.title', defaultMessage: 'Explore' },
  searchResults: { id: 'explore.search_results', defaultMessage: 'Search results' },
});

const mapStateToProps = state => ({
  layout: state.getIn(['meta', 'layout']),
  isSearching: state.getIn(['search', 'submitted']),
});

export default @connect(mapStateToProps)
@injectIntl
class Explore extends React.PureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
    isSearching: PropTypes.bool,
    layout: PropTypes.string,
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  }

  setRef = c => {
    this.column = c;
  }

  render () {
    const { intl, multiColumn, isSearching, layout } = this.props;

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.title)}>
        {layout === 'mobile' ? (
          <div className='explore__search-header'>
            <Search />
          </div>
        ) : (
          <ColumnHeader
            icon={isSearching ? 'search' : 'hashtag'}
            title={intl.formatMessage(isSearching ? messages.searchResults : messages.title)}
            onClick={this.handleHeaderClick}
            multiColumn={multiColumn}
          />
        )}

        <div className='scrollable scrollable--flex'>
          {isSearching ? (
            <SearchResults />
          ) : (
            <React.Fragment>
              <div className='account__section-headline'>
                <NavLink exact to='/explore'><FormattedMessage id='explore.trending_statuses' defaultMessage='Posts' /></NavLink>
                <NavLink exact to='/explore/tags'><FormattedMessage id='explore.trending_tags' defaultMessage='Hashtags' /></NavLink>
                <NavLink exact to='/explore/links'><FormattedMessage id='explore.trending_links' defaultMessage='News' /></NavLink>
                <NavLink exact to='/explore/suggestions'><FormattedMessage id='explore.suggested_follows' defaultMessage='For you' /></NavLink>
              </div>

              <Switch>
                <Route path='/explore/tags' component={Tags} />
                <Route path='/explore/links' component={Links} />
                <Route path='/explore/suggestions' component={Suggestions} />
                <Route exact path={['/explore', '/explore/posts', '/search']} component={Statuses} componentParams={{ multiColumn }} />
              </Switch>
            </React.Fragment>
          )}
        </div>
      </Column>
    );
  }

}
