import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import { withRouter } from 'react-router-dom';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { fetchTrendingLinks } from 'mastodon/actions/trends';
import { DismissableBanner } from 'mastodon/components/dismissable_banner';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import { WithRouterPropTypes } from 'mastodon/utils/react_router';

import { Story } from './components/story';

const mapStateToProps = state => ({
  links: state.getIn(['trends', 'links', 'items']),
  isLoading: state.getIn(['trends', 'links', 'isLoading']),
});

class Links extends PureComponent {

  static propTypes = {
    links: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    dispatch: PropTypes.func.isRequired,
    ...WithRouterPropTypes,
  };

  componentDidMount () {
    const { dispatch, links, history } = this.props;

    // If we're navigating back to the screen, do not trigger a reload
    if (history.action === 'POP' && links.size > 0) {
      return;
    }

    dispatch(fetchTrendingLinks());
  }

  render () {
    const { isLoading, links } = this.props;

    const banner = (
      <DismissableBanner id='explore/links'>
        <FormattedMessage id='dismissable_banner.explore_links' defaultMessage='These are news stories being shared the most on the social web today. Newer news stories posted by more different people are ranked higher.' />
      </DismissableBanner>
    );

    if (!isLoading && links.isEmpty()) {
      return (
        <div className='explore__links scrollable scrollable--flex'>
          {banner}

          <div className='empty-column-indicator'>
            <FormattedMessage id='empty_column.explore_statuses' defaultMessage='Nothing is trending right now. Check back later!' />
          </div>
        </div>
      );
    }

    return (
      <div className='explore__links scrollable' data-nosnippet>
        {banner}

        {isLoading ? (<LoadingIndicator />) : links.map((link, i) => (
          <Story
            key={link.get('id')}
            expanded={i === 0}
            lang={link.get('language')}
            url={link.get('url')}
            title={link.get('title')}
            publisher={link.get('provider_name')}
            publishedAt={link.get('published_at')}
            author={link.get('author_name')}
            authorAccount={link.getIn(['authors', 0, 'account', 'id'])}
            sharedTimes={link.getIn(['history', 0, 'accounts']) * 1 + link.getIn(['history', 1, 'accounts']) * 1}
            thumbnail={link.get('image')}
            thumbnailDescription={link.get('image_description')}
            blurhash={link.get('blurhash')}
          />
        ))}
      </div>
    );
  }

}

export default connect(mapStateToProps)(withRouter(Links));
