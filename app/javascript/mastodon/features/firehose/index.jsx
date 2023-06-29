import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';

import { Helmet } from 'react-helmet';
import { NavLink } from 'react-router-dom';

import { connect } from 'react-redux';

import { addColumn } from 'mastodon/actions/columns';
import { connectPublicStream, connectCommunityStream } from 'mastodon/actions/streaming';
import { expandPublicTimeline, expandCommunityTimeline } from 'mastodon/actions/timelines';
import DismissableBanner from 'mastodon/components/dismissable_banner';
import { domain } from 'mastodon/initial_state';

import Column from '../../components/column';
import ColumnHeader from '../../components/column_header';
import StatusListContainer from '../ui/containers/status_list_container';

import ColumnSettingsContainer from './containers/column_settings_container';

const messages = defineMessages({
  title: { id: 'column.firehose', defaultMessage: 'Live feeds' },
});

const mapStateToProps = (state, { feedType }) => {
  const onlyMedia = state.getIn(['settings', 'firehose', 'onlyMedia'], false);

  return {
    onlyMedia,
    hasUnread: state.getIn(['timelines', `${feedType}${onlyMedia ? ':media' : ''}`, 'unread'], 0) > 0,
  }
};

class Firehose extends PureComponent {

  static contextTypes = {
    router: PropTypes.object,
    identity: PropTypes.object,
  };

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    multiColumn: PropTypes.bool,
    hasUnread: PropTypes.bool,
    onlyMedia: PropTypes.bool,
    feedType: PropTypes.string, // TODO: type this properly
  };

  handlePin = () => {
    const { dispatch, onlyMedia, feedType } = this.props;

    switch(feedType) {
    case 'community':
      dispatch(addColumn('COMMUNITY', { other: { onlyMedia } }));
      break;
    case 'public':
      dispatch(addColumn('PUBLIC', { other: { onlyMedia } }));
      break;
    case 'public:remote':
      dispatch(addColumn('REMOTE', { other: { onlyMedia, onlyRemote: true } }));
      break;
    }
  };

  handleHeaderClick = () => {
    this.column.scrollTop();
  };

  componentDidMount () {
    this._connectFeed();
  }

  componentDidUpdate (prevProps) {
    if (prevProps.onlyMedia !== this.props.onlyMedia || prevProps.feedType !== this.props.feedType) {
      if (this.disconnect) {
        this.disconnect();
      }

      this._connectFeed();
    }
  }

  _connectFeed = () => {
    const { dispatch, onlyMedia, feedType } = this.props;
    const { signedIn } = this.context.identity;

    switch(feedType) {
    case 'community':
      dispatch(expandCommunityTimeline({ onlyMedia }));
      if (signedIn) {
        this.disconnect = dispatch(connectCommunityStream({ onlyMedia }));
      }
      break;
    case 'public':
      dispatch(expandPublicTimeline({ onlyMedia }));
      if (signedIn) {
        this.disconnect = dispatch(connectPublicStream({ onlyMedia }));
      }
      break;
    case 'public:remote':
      dispatch(expandPublicTimeline({ onlyMedia, onlyRemote: true }));
      if (signedIn) {
        this.disconnect = dispatch(connectPublicStream({ onlyMedia, onlyRemote: true }));
      }
      break;
    }
  }

  componentWillUnmount () {
    if (this.disconnect) {
      this.disconnect();
      this.disconnect = null;
    }
  }

  setRef = c => {
    this.column = c;
  };

  handleLoadMore = maxId => {
    const { dispatch, onlyMedia, feedType } = this.props;

    switch(feedType) {
    case 'community':
      dispatch(expandCommunityTimeline({ onlyMedia }));
      break;
    case 'public':
      dispatch(expandPublicTimeline({ maxId, onlyMedia }));
      break;
    case 'public:remote':
      dispatch(expandPublicTimeline({ maxId, onlyMedia, onlyRemote: true }));
      break;
    }
  };

  render () {
    const { intl, hasUnread, multiColumn, onlyMedia, feedType } = this.props;

    const prependBanner = feedType === 'community' ? (
      <DismissableBanner id='community_timeline'>
        <FormattedMessage
          id='dismissable_banner.community_timeline'
          defaultMessage='These are the most recent public posts from people whose accounts are hosted by {domain}.'
          values={{ domain }}
        />
      </DismissableBanner>
    ) : (
     <DismissableBanner id='public_timeline'>
       <FormattedMessage
         id='dismissable_banner.public_timeline'
         defaultMessage='These are the most recent public posts from people on this and other servers of the decentralized network that this server knows about.'
       />
     </DismissableBanner>
    );

    const emptyMessage = feedType === 'community' ? (
      <FormattedMessage
        id='empty_column.community'
        defaultMessage='The local timeline is empty. Write something publicly to get the ball rolling!'
      />
    ) : (
     <FormattedMessage
       id='empty_column.public'
       defaultMessage='There is nothing here! Write something publicly, or manually follow users from other servers to fill it up'
     />
    );

    return (
      <Column bindToDocument={!multiColumn} ref={this.setRef} label={intl.formatMessage(messages.title)}>
        <ColumnHeader
          icon='globe'
          active={hasUnread}
          title={intl.formatMessage(messages.title)}
          onPin={this.handlePin}
          onClick={this.handleHeaderClick}
          multiColumn={multiColumn}
        >
          <ColumnSettingsContainer />
        </ColumnHeader>

        <div className='scrollable scrollable--flex'>
          <div className='account__section-headline'>
            <NavLink exact to='/public/local'>
              <FormattedMessage tagName='div' id='firehose.local' defaultMessage='Local' />
            </NavLink>

            <NavLink exact to='/public/remote'>
              <FormattedMessage tagName='div' id='firehose.remote' defaultMessage='Remote' />
            </NavLink>

            <NavLink exact to='/public'>
              <FormattedMessage tagName='div' id='firehose.all' defaultMessage='All' />
            </NavLink>
          </div>

          <StatusListContainer
            prepend={prependBanner}
            timelineId={`${feedType}${onlyMedia ? ':media' : ''}`}
            onLoadMore={this.handleLoadMore}
            trackScroll
            scrollKey='firehose'
            emptyMessage={emptyMessage}
            bindToDocument={!multiColumn}
          />
        </div>

        <Helmet>
          <title>{intl.formatMessage(messages.title)}</title>
          <meta name='robots' content='noindex' />
        </Helmet>
      </Column>
    );
  }

}

export default connect(mapStateToProps)(injectIntl(Firehose));
