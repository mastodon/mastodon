import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { fetchStatus } from '../../actions/statuses';
import Immutable from 'immutable';
import EmbeddedStatus from '../../components/status';
import MissingIndicator from '../../components/missing_indicator';
import DetailedStatus from './components/detailed_status';
import ActionBar from './components/action_bar';
import Column from '../ui/components/column';
import {
  favourite,
  unfavourite,
  reblog,
  unreblog
} from '../../actions/interactions';
import {
  replyCompose,
  mentionCompose
} from '../../actions/compose';
import { deleteStatus } from '../../actions/statuses';
import { initReport } from '../../actions/reports';
import {
  makeGetStatus,
  getStatusAncestors,
  getStatusDescendants
} from '../../selectors';
import { ScrollContainer } from 'react-router-scroll';
import ColumnBackButton from '../../components/column_back_button';
import StatusContainer from '../../containers/status_container';
import { openModal } from '../../actions/modal';
import { isMobile } from '../../is_mobile'
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';

const messages = defineMessages({
  deleteConfirm: { id: 'confirmations.delete.confirm', defaultMessage: 'Delete' },
  deleteMessage: { id: 'confirmations.delete.message', defaultMessage: 'Are you sure you want to delete this status?' }
});

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const mapStateToProps = (state, props) => ({
    status: getStatus(state, Number(props.params.statusId)),
    ancestorsIds: state.getIn(['timelines', 'ancestors', Number(props.params.statusId)]),
    descendantsIds: state.getIn(['timelines', 'descendants', Number(props.params.statusId)]),
    me: state.getIn(['meta', 'me']),
    boostModal: state.getIn(['meta', 'boost_modal']),
    autoPlayGif: state.getIn(['meta', 'auto_play_gif'])
  });

  return mapStateToProps;
};

class Status extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object
  };

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    status: ImmutablePropTypes.map,
    ancestorsIds: ImmutablePropTypes.list,
    descendantsIds: ImmutablePropTypes.list,
    me: PropTypes.number,
    boostModal: PropTypes.bool,
    autoPlayGif: PropTypes.bool,
    intl: PropTypes.object.isRequired
  };

  componentWillMount () {
    this.props.dispatch(fetchStatus(Number(this.props.params.statusId)));
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.statusId !== this.props.params.statusId && nextProps.params.statusId) {
      this.props.dispatch(fetchStatus(Number(nextProps.params.statusId)));
    }
  }

  handleFavouriteClick = (status) => {
    if (status.get('favourited')) {
      this.props.dispatch(unfavourite(status));
    } else {
      this.props.dispatch(favourite(status));
    }
  }

  handleReplyClick = (status) => {
    this.props.dispatch(replyCompose(status, this.context.router));
  }

  handleModalReblog = (status) => {
    this.props.dispatch(reblog(status));
  }

  handleReblogClick = (status, e) => {
    if (status.get('reblogged')) {
      this.props.dispatch(unreblog(status));
    } else {
      if (e.shiftKey || !this.props.boostModal) {
        this.handleModalReblog(status);
      } else {
        this.props.dispatch(openModal('BOOST', { status, onReblog: this.handleModalReblog }));
      }
    }
  }

  handleDeleteClick = (status) => {
    const { dispatch, intl } = this.props;

    dispatch(openModal('CONFIRM', {
      message: intl.formatMessage(messages.deleteMessage),
      confirm: intl.formatMessage(messages.deleteConfirm),
      onConfirm: () => dispatch(deleteStatus(status.get('id')))
    }));
  }

  handleMentionClick = (account, router) => {
    this.props.dispatch(mentionCompose(account, router));
  }

  handleOpenMedia = (media, index) => {
    this.props.dispatch(openModal('MEDIA', { media, index }));
  }

  handleOpenVideo = (media, time) => {
    this.props.dispatch(openModal('VIDEO', { media, time }));
  }

  handleReport = (status) => {
    this.props.dispatch(initReport(status.get('account'), status));
  }

  renderChildren (list) {
    return list.map(id => <StatusContainer key={id} id={id} />);
  }

  render () {
    let ancestors, descendants;
    const { status, ancestorsIds, descendantsIds, me, autoPlayGif } = this.props;

    if (status === null) {
      return (
        <Column>
          <ColumnBackButton />
          <MissingIndicator />
        </Column>
      );
    }

    const account = status.get('account');

    if (ancestorsIds && ancestorsIds.size > 0) {
      ancestors = <div>{this.renderChildren(ancestorsIds)}</div>;
    }

    if (descendantsIds && descendantsIds.size > 0) {
      descendants = <div>{this.renderChildren(descendantsIds)}</div>;
    }

    return (
      <Column>
        <ColumnBackButton />

        <ScrollContainer scrollKey='thread'>
          <div className='scrollable detailed-status__wrapper'>
            {ancestors}

            <DetailedStatus
              status={status}
              autoPlayGif={autoPlayGif}
              me={me}
              onOpenVideo={this.handleOpenVideo}
              onOpenMedia={this.handleOpenMedia}
            />

            <ActionBar
              status={status}
              me={me}
              onReply={this.handleReplyClick}
              onFavourite={this.handleFavouriteClick}
              onReblog={this.handleReblogClick}
              onDelete={this.handleDeleteClick}
              onMention={this.handleMentionClick}
              onReport={this.handleReport}
            />

            {descendants}
          </div>
        </ScrollContainer>
      </Column>
    );
  }

}

export default injectIntl(connect(makeMapStateToProps)(Status));
