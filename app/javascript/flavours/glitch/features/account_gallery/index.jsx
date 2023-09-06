import PropTypes from 'prop-types';

import { FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { lookupAccount, fetchAccount } from 'flavours/glitch/actions/accounts';
import { openModal } from 'flavours/glitch/actions/modal';
import { expandAccountMediaTimeline } from 'flavours/glitch/actions/timelines';
import { LoadMore } from 'flavours/glitch/components/load_more';
import { LoadingIndicator } from 'flavours/glitch/components/loading_indicator';
import ScrollContainer from 'flavours/glitch/containers/scroll_container';
import ProfileColumnHeader from 'flavours/glitch/features/account/components/profile_column_header';
import HeaderContainer from 'flavours/glitch/features/account_timeline/containers/header_container';
import BundleColumnError from 'flavours/glitch/features/ui/components/bundle_column_error';
import Column from 'flavours/glitch/features/ui/components/column';
import { normalizeForLookup } from 'flavours/glitch/reducers/accounts_map';
import { getAccountGallery } from 'flavours/glitch/selectors';

import MediaItem from './components/media_item';

const mapStateToProps = (state, { params: { acct, id } }) => {
  const accountId = id || state.getIn(['accounts_map', normalizeForLookup(acct)]);

  if (!accountId) {
    return {
      isLoading: true,
    };
  }

  return {
    accountId,
    isAccount: !!state.getIn(['accounts', accountId]),
    attachments: getAccountGallery(state, accountId),
    isLoading: state.getIn(['timelines', `account:${accountId}:media`, 'isLoading']),
    hasMore: state.getIn(['timelines', `account:${accountId}:media`, 'hasMore']),
    suspended: state.getIn(['accounts', accountId, 'suspended'], false),
  };
};

class LoadMoreMedia extends ImmutablePureComponent {

  static propTypes = {
    maxId: PropTypes.string,
    onLoadMore: PropTypes.func.isRequired,
  };

  handleLoadMore = () => {
    this.props.onLoadMore(this.props.maxId);
  };

  render () {
    return (
      <LoadMore
        disabled={this.props.disabled}
        onClick={this.handleLoadMore}
      />
    );
  }

}

class AccountGallery extends ImmutablePureComponent {

  static propTypes = {
    params: PropTypes.shape({
      acct: PropTypes.string,
      id: PropTypes.string,
    }).isRequired,
    accountId: PropTypes.string,
    dispatch: PropTypes.func.isRequired,
    attachments: ImmutablePropTypes.list.isRequired,
    isLoading: PropTypes.bool,
    hasMore: PropTypes.bool,
    isAccount: PropTypes.bool,
    suspended: PropTypes.bool,
    multiColumn: PropTypes.bool,
  };

  state = {
    width: 323,
  };

  _load () {
    const { accountId, isAccount, dispatch } = this.props;

    if (!isAccount) dispatch(fetchAccount(accountId));
    dispatch(expandAccountMediaTimeline(accountId));
  }

  componentDidMount () {
    const { params: { acct }, accountId, dispatch } = this.props;

    if (accountId) {
      this._load();
    } else {
      dispatch(lookupAccount(acct));
    }
  }

  componentDidUpdate (prevProps) {
    const { params: { acct }, accountId, dispatch } = this.props;

    if (prevProps.accountId !== accountId && accountId) {
      this._load();
    } else if (prevProps.params.acct !== acct) {
      dispatch(lookupAccount(acct));
    }
  }

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  handleScrollToBottom = () => {
    if (this.props.hasMore) {
      this.handleLoadMore(this.props.attachments.size > 0 ? this.props.attachments.last().getIn(['status', 'id']) : undefined);
    }
  };

  handleScroll = e => {
    const { scrollTop, scrollHeight, clientHeight } = e.target;
    const offset = scrollHeight - scrollTop - clientHeight;

    if (150 > offset && !this.props.isLoading) {
      this.handleScrollToBottom();
    }
  };

  handleLoadMore = maxId => {
    this.props.dispatch(expandAccountMediaTimeline(this.props.accountId, { maxId }));
  };

  handleLoadOlder = e => {
    e.preventDefault();
    this.handleScrollToBottom();
  };

  setColumnRef = c => {
    this.column = c;
  };

  handleOpenMedia = attachment => {
    const { dispatch } = this.props;
    const statusId = attachment.getIn(['status', 'id']);
    const lang = attachment.getIn(['status', 'language']);

    if (attachment.get('type') === 'video') {
      dispatch(openModal({
        modalType: 'VIDEO',
        modalProps: { media: attachment, statusId, lang, options: { autoPlay: true } },
      }));
    } else if (attachment.get('type') === 'audio') {
      dispatch(openModal({
        modalType: 'AUDIO',
        modalProps: { media: attachment, statusId, lang, options: { autoPlay: true } },
      }));
    } else {
      const media = attachment.getIn(['status', 'media_attachments']);
      const index = media.findIndex(x => x.get('id') === attachment.get('id'));

      dispatch(openModal({
        modalType: 'MEDIA',
        modalProps: { media, index, statusId, lang },
      }));
    }
  };

  handleRef = c => {
    if (c) {
      this.setState({ width: c.offsetWidth });
    }
  };

  render () {
    const { attachments, isLoading, hasMore, isAccount, multiColumn, suspended } = this.props;
    const { width } = this.state;

    if (!isAccount) {
      return (
        <BundleColumnError multiColumn={multiColumn} errorType='routing' />
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
      <Column ref={this.setColumnRef}>
        <ProfileColumnHeader onClick={this.handleHeaderClick} multiColumn={multiColumn} />

        <ScrollContainer scrollKey='account_gallery'>
          <div className='scrollable scrollable--flex' onScroll={this.handleScroll}>
            <HeaderContainer accountId={this.props.accountId} />

            {suspended ? (
              <div className='empty-column-indicator'>
                <FormattedMessage id='empty_column.account_suspended' defaultMessage='Account suspended' />
              </div>
            ) : (
              <div role='feed' className='account-gallery__container' ref={this.handleRef}>
                {attachments.map((attachment, index) => attachment === null ? (
                  <LoadMoreMedia key={'more:' + attachments.getIn(index + 1, 'id')} maxId={index > 0 ? attachments.getIn(index - 1, 'id') : null} onLoadMore={this.handleLoadMore} />
                ) : (
                  <MediaItem key={attachment.get('id')} attachment={attachment} displayWidth={width} onOpenMedia={this.handleOpenMedia} />
                ))}

                {loadOlder}
              </div>
            )}

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

export default connect(mapStateToProps)(AccountGallery);
