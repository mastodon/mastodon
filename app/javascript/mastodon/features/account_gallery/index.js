import React from 'react';
import { connect } from 'react-redux';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { fetchAccount } from 'mastodon/actions/accounts';
import { expandAccountMediaTimeline } from '../../actions/timelines';
import LoadingIndicator from 'mastodon/components/loading_indicator';
import Column from '../ui/components/column';
import ColumnBackButton from 'mastodon/components/column_back_button';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { getAccountGallery } from 'mastodon/selectors';
import MediaItem from './components/media_item';
import HeaderContainer from '../account_timeline/containers/header_container';
import { ScrollContainer } from 'react-router-scroll-4';
import LoadMore from 'mastodon/components/load_more';
import MissingIndicator from 'mastodon/components/missing_indicator';
import { openModal } from 'mastodon/actions/modal';

const mapStateToProps = (state, props) => ({
  isAccount: !!state.getIn(['accounts', props.params.accountId]),
  attachments: getAccountGallery(state, props.params.accountId),
  isLoading: state.getIn(['timelines', `account:${props.params.accountId}:media`, 'isLoading']),
  hasMore: state.getIn(['timelines', `account:${props.params.accountId}:media`, 'hasMore']),
});

class LoadMoreMedia extends ImmutablePureComponent {

  static propTypes = {
    shouldUpdateScroll: PropTypes.func,
    maxId: PropTypes.string,
    onLoadMore: PropTypes.func.isRequired,
  };

  handleLoadMore = () => {
    this.props.onLoadMore(this.props.maxId);
  }

  render () {
    return (
      <LoadMore
        disabled={this.props.disabled}
        onClick={this.handleLoadMore}
      />
    );
  }

}

export default @connect(mapStateToProps)
class AccountGallery extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    attachments: ImmutablePropTypes.list.isRequired,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    isAccount: PropTypes.bool,
    multiColumn: PropTypes.bool,
  };

  state = {
    width: 323,
  };

  componentDidMount () {
    this.props.dispatch(fetchAccount(this.props.params.accountId));
    this.props.dispatch(expandAccountMediaTimeline(this.props.params.accountId));
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.accountId !== this.props.params.accountId && nextProps.params.accountId) {
      this.props.dispatch(fetchAccount(nextProps.params.accountId));
      this.props.dispatch(expandAccountMediaTimeline(this.props.params.accountId));
    }
  }

  handleScrollToBottom = () => {
    if (this.props.hasMore) {
      this.handleLoadMore(this.props.attachments.size > 0 ? this.props.attachments.last().getIn(['status', 'id']) : undefined);
    }
  }

  handleScroll = e => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;
    const offset = scrollHeight - scrollTop - clientHeight;

    if (150 > offset && !this.props.isLoading) {
      this.handleScrollToBottom();
    }
  }

  handleLoadMore = maxId => {
    this.props.dispatch(expandAccountMediaTimeline(this.props.params.accountId, { maxId }));
  };

  handleLoadOlder = e => {
    e.preventDefault();
    this.handleScrollToBottom();
  }

  handleOpenMedia = attachment => {
    if (attachment.get('type') === 'video') {
      this.props.dispatch(openModal('VIDEO', { media: attachment, status: attachment.get('status') }));
    } else {
      const media = attachment.getIn(['status', 'media_attachments']);
      const index = media.findIndex(x => x.get('id') === attachment.get('id'));

      this.props.dispatch(openModal('MEDIA', { media, index, status: attachment.get('status') }));
    }
  }

  handleRef = c => {
    if (c) {
      this.setState({ width: c.offsetWidth });
    }
  }

  render () {
    const { attachments, shouldUpdateScroll, isLoading, hasMore, isAccount, multiColumn } = this.props;
    const { width } = this.state;

    if (!isAccount) {
      return (
        <Column>
          <MissingIndicator />
        </Column>
      );
    }

    if (!attachments && isLoading) {
      return (
        <Column>
          <LoadingIndicator />
        </Column>
      );
    }

    let loadOlder = null;

    if (hasMore && !(isLoading && attachments.size === 0)) {
      loadOlder = <LoadMore visible={!isLoading} onClick={this.handleLoadOlder} />;
    }

    return (
      <Column>
        <ColumnBackButton multiColumn={multiColumn} />

        <ScrollContainer scrollKey='account_gallery' shouldUpdateScroll={shouldUpdateScroll}>
          <div className='scrollable scrollable--flex' onScroll={this.handleScroll}>
            <HeaderContainer accountId={this.props.params.accountId} />

            <div role='feed' className='account-gallery__container' ref={this.handleRef}>
              {attachments.map((attachment, index) => attachment === null ? (
                <LoadMoreMedia key={'more:' + attachments.getIn(index + 1, 'id')} maxId={index > 0 ? attachments.getIn(index - 1, 'id') : null} onLoadMore={this.handleLoadMore} />
              ) : (
                <MediaItem key={attachment.get('id')} attachment={attachment} displayWidth={width} onOpenMedia={this.handleOpenMedia} />
              ))}

              {loadOlder}
            </div>

            {isLoading && attachments.size === 0 && (
              <div className='scrollable__append'>
                <LoadingIndicator />
              </div>
            )}
          </div>
        </ScrollContainer>
      </Column>
    );
  }

}
