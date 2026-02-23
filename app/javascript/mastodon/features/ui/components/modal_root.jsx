import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { Helmet } from 'react-helmet';

import Base from 'mastodon/components/modal_root';
import { AltTextModal } from 'mastodon/features/alt_text_modal';
import {
  MuteModal,
  BlockModal,
  DomainBlockModal,
  ReportModal,
  EmbedModal,
  ListAdder,
  CompareHistoryModal,
  FilterModal,
  InteractionModal,
  SubscribedLanguagesModal,
  ClosedRegistrationsModal,
  IgnoreNotificationsModal,
  AnnualReportModal,
} from 'mastodon/features/ui/util/async-components';

import { ActionsModal } from './actions_modal';
import AudioModal from './audio_modal';
import { BoostModal } from './boost_modal';
import Bundle from './bundle';
import {
  ConfirmationModal,
  ConfirmDeleteStatusModal,
  ConfirmDeleteListModal,
  ConfirmDeleteCollectionModal,
  ConfirmReplyModal,
  ConfirmEditStatusModal,
  ConfirmUnblockModal,
  ConfirmUnfollowModal,
  ConfirmWithdrawRequestModal,
  ConfirmClearNotificationsModal,
  ConfirmLogOutModal,
  ConfirmFollowToListModal,
  ConfirmFollowToCollectionModal,
  ConfirmMissingAltTextModal,
  ConfirmRevokeQuoteModal,
  QuietPostQuoteInfoModal,
} from './confirmation_modals';
import { ImageModal } from './image_modal';
import { MediaModal } from './media_modal';
import { ModalPlaceholder } from './modal_placeholder';
import VideoModal from './video_modal';
import { VisibilityModal } from './visibility_modal';
import { PrivateQuoteNotify } from './confirmation_modals/private_quote_notify';

export const MODAL_COMPONENTS = {
  'MEDIA': () => Promise.resolve({ default: MediaModal }),
  'VIDEO': () => Promise.resolve({ default: VideoModal }),
  'AUDIO': () => Promise.resolve({ default: AudioModal }),
  'IMAGE': () => Promise.resolve({ default: ImageModal }),
  'BOOST': () => Promise.resolve({ default: BoostModal }),
  'CONFIRM': () => Promise.resolve({ default: ConfirmationModal }),
  'CONFIRM_DELETE_STATUS': () => Promise.resolve({ default: ConfirmDeleteStatusModal }),
  'CONFIRM_DELETE_LIST': () => Promise.resolve({ default: ConfirmDeleteListModal }),
  'CONFIRM_DELETE_COLLECTION': () => Promise.resolve({ default: ConfirmDeleteCollectionModal }),
  'CONFIRM_REPLY': () => Promise.resolve({ default: ConfirmReplyModal }),
  'CONFIRM_EDIT_STATUS': () => Promise.resolve({ default: ConfirmEditStatusModal }),
  'CONFIRM_UNBLOCK': () => Promise.resolve({ default: ConfirmUnblockModal }),
  'CONFIRM_UNFOLLOW': () => Promise.resolve({ default: ConfirmUnfollowModal }),
  'CONFIRM_WITHDRAW_REQUEST': () => Promise.resolve({ default: ConfirmWithdrawRequestModal }),
  'CONFIRM_CLEAR_NOTIFICATIONS': () => Promise.resolve({ default: ConfirmClearNotificationsModal }),
  'CONFIRM_LOG_OUT': () => Promise.resolve({ default: ConfirmLogOutModal }),
  'CONFIRM_FOLLOW_TO_LIST': () => Promise.resolve({ default: ConfirmFollowToListModal }),
  'CONFIRM_FOLLOW_TO_COLLECTION': () => Promise.resolve({ default: ConfirmFollowToCollectionModal }),
  'CONFIRM_MISSING_ALT_TEXT': () => Promise.resolve({ default: ConfirmMissingAltTextModal }),
  'CONFIRM_PRIVATE_QUOTE_NOTIFY': () => Promise.resolve({ default: PrivateQuoteNotify }),
  'CONFIRM_REVOKE_QUOTE': () => Promise.resolve({ default: ConfirmRevokeQuoteModal }),
  'CONFIRM_QUIET_QUOTE': () => Promise.resolve({ default: QuietPostQuoteInfoModal }),
  'MUTE': MuteModal,
  'BLOCK': BlockModal,
  'DOMAIN_BLOCK': DomainBlockModal,
  'REPORT': ReportModal,
  'ACTIONS': () => Promise.resolve({ default: ActionsModal }),
  'EMBED': EmbedModal,
  'FOCAL_POINT': () => Promise.resolve({ default: AltTextModal }),
  'LIST_ADDER': ListAdder,
  'COMPARE_HISTORY': CompareHistoryModal,
  'FILTER': FilterModal,
  'SUBSCRIBED_LANGUAGES': SubscribedLanguagesModal,
  'INTERACTION': InteractionModal,
  'CLOSED_REGISTRATIONS': ClosedRegistrationsModal,
  'IGNORE_NOTIFICATIONS': IgnoreNotificationsModal,
  'ANNUAL_REPORT': AnnualReportModal,
  'COMPOSE_PRIVACY': () => Promise.resolve({ default: VisibilityModal }),
  'ACCOUNT_NOTE': () => import('@/mastodon/features/account_timeline/modals/note_modal').then(module => ({ default: module.AccountNoteModal })),
  'ACCOUNT_EDIT_NAME': () => import('@/mastodon/features/account_edit/components/name_modal').then(module => ({ default: module.NameModal })),
  'ACCOUNT_EDIT_BIO': () => import('@/mastodon/features/account_edit/components/bio_modal').then(module => ({ default: module.BioModal })),
};

export default class ModalRoot extends PureComponent {

  static propTypes = {
    type: PropTypes.string,
    props: PropTypes.object,
    onClose: PropTypes.func.isRequired,
    ignoreFocus: PropTypes.bool,
  };

  state = {
    backgroundColor: null,
  };

  setBackgroundColor = color => {
    this.setState({ backgroundColor: color });
  };

  renderLoading = () => {
    const { onClose } = this.props;

    return <ModalPlaceholder loading onClose={onClose} />;
  };

  renderError = (props) => {
    const { onClose } = this.props;

    return <ModalPlaceholder {...props} onClose={onClose} />;
  };

  handleClose = (ignoreFocus = false) => {
    const { onClose } = this.props;
    const message = this._modal?.getCloseConfirmationMessage?.();
    onClose(message, ignoreFocus);
  };

  setModalRef = (c) => {
    this._modal = c;
  };

  render () {
    const { type, props, ignoreFocus } = this.props;
    const { backgroundColor } = this.state;
    const visible = !!type;

    return (
      <Base backgroundColor={backgroundColor} onClose={this.handleClose} ignoreFocus={ignoreFocus}>
        {visible && (
          <>
            <Bundle key={type} fetchComponent={MODAL_COMPONENTS[type]} loading={this.renderLoading} error={this.renderError} renderDelay={200}>
              {(SpecificComponent) => {
                return <SpecificComponent {...props} onChangeBackgroundColor={this.setBackgroundColor} onClose={this.handleClose} ref={this.setModalRef} />;
              }}
            </Bundle>

            <Helmet>
              <meta name='robots' content='noindex' />
            </Helmet>
          </>
        )}
      </Base>
    );
  }

}
