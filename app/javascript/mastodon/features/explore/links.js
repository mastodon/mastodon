import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import Story from './components/story';
import LoadingIndicator from 'mastodon/components/loading_indicator';
import { connect } from 'react-redux';
import { fetchTrendingLinks } from 'mastodon/actions/trends';

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

    return (
      <div className='explore__links'>
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
