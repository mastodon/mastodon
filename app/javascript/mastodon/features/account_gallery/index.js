import React from 'react';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { fetchAccount } from '../../actions/accounts';
import { refreshAccountMediaTimeline, expandAccountMediaTimeline } from '../../actions/timelines';
import LoadingIndicator from '../../components/loading_indicator';
import Column from '../ui/components/column';
import ColumnBackButton from '../../components/column_back_button';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { getAccountGallery } from '../../selectors';
import MediaItem from './components/media_item';
import HeaderContainer from '../account_timeline/containers/header_container';
import { FormattedMessage } from 'react-intl';
import { ScrollContainer } from 'react-router-scroll';
import LoadMore from '../../components/load_more';

const mapStateToProps = (state, props) => ({
  medias: getAccountGallery(state, Number(props.params.accountId)),
  isLoading: state.getIn(['timelines', `account:${Number(props.params.accountId)}:media`, 'isLoading']),
  hasMore: !!state.getIn(['timelines', `account:${Number(props.params.accountId)}:media`, 'next']),
  autoPlayGif: state.getIn(['meta', 'auto_play_gif']),
});

@connect(mapStateToProps)
export default class AccountGallery extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    medias: ImmutablePropTypes.list.isRequired,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    autoPlayGif: PropTypes.bool,
  };

  componentDidMount () {
    this.props.dispatch(fetchAccount(Number(this.props.params.accountId)));
    this.props.dispatch(refreshAccountMediaTimeline(Number(this.props.params.accountId)));
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) {
      this.props.dispatch(fetchAccount(Number(nextProps.params.accountId)));
      this.props.dispatch(refreshAccountMediaTimeline(Number(this.props.params.accountId)));
    }
  }

  handleScrollToBottom = () => {
    if (this.props.hasMore) {
      this.props.dispatch(expandAccountMediaTimeline(Number(this.props.params.accountId)));
    }
  }

  handleScroll = (e) => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;
    const offset = scrollHeight - scrollTop - clientHeight;

    if (150 > offset && !this.props.isLoading) {
      this.handleScrollToBottom();
    }
  }

  handleLoadMore = (e) => {
    e.preventDefault();
    this.handleScrollToBottom();
  }

  render () {
    const { medias, autoPlayGif, isLoading, hasMore } = this.props;

    let loadMore = null;

    if (!medias && isLoading) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    if (!isLoading && medias.size > 0 && hasMore) {
      loadMore = <LoadMore onClick={this.handleLoadMore} />;
    }

    return (
      <Column>
        <ColumnBackButton />

        <ScrollContainer scrollKey='account_gallery'>
          <div className='scrollable' onScroll={this.handleScroll}>
            <HeaderContainer accountId={this.props.params.accountId} />

            <div className='account-section-headline'>
              <FormattedMessage id='account.media' defaultMessage='Media' />
            </div>

            <div className='account-gallery__container'>
              {medias.map(media =>
                <MediaItem
                  key={media.get('id')}
                  media={media}
                  autoPlayGif={autoPlayGif}
                />
              )}
              {loadMore}
            </div>
          </div>
        </ScrollContainer>
      </Column>
    );
  }

}
