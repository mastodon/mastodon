import React from 'react';
import PropTypes from 'prop-types';
import { getScrollbarWidth } from 'flavours/glitch/utils/scrollbar';
import Base from 'flavours/glitch/components/modal_root';
import BundleContainer from '../containers/bundle_container';
import BundleModalError from './bundle_modal_error';
import ModalLoading from './modal_loading';
import ActionsModal from './actions_modal';
import MediaModal from './media_modal';
import VideoModal from './video_modal';
import BoostModal from './boost_modal';
import FavouriteModal from './favourite_modal';
import AudioModal from './audio_modal';
import DoodleModal from './doodle_modal';
import ConfirmationModal from './confirmation_modal';
import FocalPointModal from './focal_point_modal';
import DeprecatedSettingsModal from './deprecated_settings_modal';
import ImageModal from './image_modal';
import {
  OnboardingModal,
  MuteModal,
  BlockModal,
  ReportModal,
  SettingsModal,
  EmbedModal,
  ListEditor,
  ListAdder,
  PinnedAccountsEditor,
  CompareHistoryModal,
  FilterModal,
  InteractionModal,
  SubscribedLanguagesModal,
  ClosedRegistrationsModal,
} from 'flavours/glitch/features/ui/util/async-components';
import { Helmet } from 'react-helmet';

const MODAL_COMPONENTS = {
  'MEDIA': () => Promise.resolve({ default: MediaModal }),
  'ONBOARDING': OnboardingModal,
  'VIDEO': () => Promise.resolve({ default: VideoModal }),
  'AUDIO': () => Promise.resolve({ default: AudioModal }),
  'IMAGE': () => Promise.resolve({ default: ImageModal }),
  'BOOST': () => Promise.resolve({ default: BoostModal }),
  'FAVOURITE': () => Promise.resolve({ default: FavouriteModal }),
  'DOODLE': () => Promise.resolve({ default: DoodleModal }),
  'CONFIRM': () => Promise.resolve({ default: ConfirmationModal }),
  'MUTE': MuteModal,
  'BLOCK': BlockModal,
  'REPORT': ReportModal,
  'SETTINGS': SettingsModal,
  'DEPRECATED_SETTINGS': () => Promise.resolve({ default: DeprecatedSettingsModal }),
  'ACTIONS': () => Promise.resolve({ default: ActionsModal }),
  'EMBED': EmbedModal,
  'LIST_EDITOR': ListEditor,
  'FOCAL_POINT': () => Promise.resolve({ default: FocalPointModal }),
  'LIST_ADDER': ListAdder,
  'PINNED_ACCOUNTS_EDITOR': PinnedAccountsEditor,
  'COMPARE_HISTORY': CompareHistoryModal,
  'FILTER': FilterModal,
  'SUBSCRIBED_LANGUAGES': SubscribedLanguagesModal,
  'INTERACTION': InteractionModal,
  'CLOSED_REGISTRATIONS': ClosedRegistrationsModal,
};

export default class ModalRoot extends React.PureComponent {

  static propTypes = {
    type: PropTypes.string,
    props: PropTypes.object,
    onClose: PropTypes.func.isRequired,
    ignoreFocus: PropTypes.bool,
  };

  state = {
    backgroundColor: null,
  };

  componentDidUpdate () {
    if (this.props.type) {
      document.body.classList.add('with-modals--active');
      document.documentElement.style.marginRight = `${getScrollbarWidth()}px`;
    } else {
      document.body.classList.remove('with-modals--active');
      document.documentElement.style.marginRight = 0;
    }
  }

  setBackgroundColor = color => {
    this.setState({ backgroundColor: color });
  };

  renderLoading = modalId => () => {
    return ['MEDIA', 'VIDEO', 'BOOST', 'FAVOURITE', 'DOODLE', 'CONFIRM', 'ACTIONS'].indexOf(modalId) === -1 ? <ModalLoading /> : null;
  };

  renderError = (props) => {
    const { onClose } = this.props;

    return <BundleModalError {...props} onClose={onClose} />;
  };

  handleClose = (ignoreFocus = false) => {
    const { onClose } = this.props;
    let message = null;
    try {
      message = this._modal?.getWrappedInstance?.().getCloseConfirmationMessage?.();
    } catch (_) {
      // injectIntl defines `getWrappedInstance` but errors out if `withRef`
      // isn't set.
      // This would be much smoother with react-intl 3+ and `forwardRef`.
    }
    onClose(message, ignoreFocus);
  };

  setModalRef = (c) => {
    this._modal = c;
  };

  // prevent closing of modal when clicking the overlay
  noop = () => {};

  render () {
    const { type, props, ignoreFocus } = this.props;
    const { backgroundColor } = this.state;
    const visible = !!type;

    return (
      <Base backgroundColor={backgroundColor} onClose={props && props.noClose ? this.noop : this.handleClose} noEsc={props ? props.noEsc : false} ignoreFocus={ignoreFocus}>
        {visible && (
          <>
            <BundleContainer fetchComponent={MODAL_COMPONENTS[type]} loading={this.renderLoading(type)} error={this.renderError} renderDelay={200}>
              {(SpecificComponent) => <SpecificComponent {...props} onChangeBackgroundColor={this.setBackgroundColor} onClose={this.handleClose} ref={this.setModalRef} />}
            </BundleContainer>

            <Helmet>
              <meta name='robots' content='noindex' />
            </Helmet>
          </>
        )}
      </Base>
    );
  }

}
