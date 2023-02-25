import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Story from './components/story';
import LoadingIndicator from 'flavours/glitch/components/loading_indicator';
import { connect } from 'react-redux';
import { fetchTrendingLinks } from 'flavours/glitch/actions/trends';
import { FormattedMessage } from 'react-intl';
import DismissableBanner from 'flavours/glitch/components/dismissable_banner';

const mapStateToProps = state => ({
  links: state.getIn(['trends', 'links', 'items']),
  isLoading: state.getIn(['trends', 'links', 'isLoading']),
});

export default @connect(mapStateToProps)
class Links extends React.PureComponent {

  static propTypes = {
    links: ImmutablePropTypes.list,
    isLoading: PropTypes.bool,
    dispatch: PropTypes.func.isRequired,
  };

  componentDidMount () {
    const { dispatch } = this.props;
    dispatch(fetchTrendingLinks());
  }

  render () {
    const { isLoading, links } = this.props;

    const banner = (
      <DismissableBanner id='explore/links'>
        <FormattedMessage id='dismissable_banner.explore_links' defaultMessage='These news stories are being talked about by people on this and other servers of the decentralized network right now.' />
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
      <div className='explore__links'>
        {banner}

        {isLoading ? (<LoadingIndicator />) : links.map(link => (
          <Story
            key={link.get('id')}
            url={link.get('url')}
            title={link.get('title')}
            publisher={link.get('provider_name')}
            sharedTimes={link.getIn(['history', 0, 'accounts']) * 1 + link.getIn(['history', 1, 'accounts']) * 1}
            thumbnail={link.get('image')}
            blurhash={link.get('blurhash')}
          />
        ))}
      </div>
    );
  }

}
