import React from 'react';
import PropTypes from 'prop-types';
import { getScrollbarWidth } from 'flavours/glitch/util/scrollbar';
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
} from 'flavours/glitch/util/async-components';

const MODAL_COMPONENTS = {
  'MEDIA': () => Promise.resolve({ default: MediaModal }),
  'ONBOARDING': OnboardingModal,
  'VIDEO': () => Promise.resolve({ default: VideoModal }),
  'AUDIO': () => Promise.resolve({ default: AudioModal }),
  'BOOST': () => Promise.resolve({ default: BoostModal }),
  'FAVOURITE': () => Promise.resolve({ default: FavouriteModal }),
  'DOODLE': () => Promise.resolve({ default: DoodleModal }),
  'CONFIRM': () => Promise.resolve({ default: ConfirmationModal }),
  'MUTE': MuteModal,
  'BLOCK': BlockModal,
  'REPORT': ReportModal,
  'SETTINGS': SettingsModal,
  'ACTIONS': () => Promise.resolve({ default: ActionsModal }),
  'EMBED': EmbedModal,
  'LIST_EDITOR': ListEditor,
  'LIST_ADDER':ListAdder,
  'FOCAL_POINT': () => Promise.resolve({ default: FocalPointModal }),
  'PINNED_ACCOUNTS_EDITOR': PinnedAccountsEditor,
};

export default class ModalRoot extends React.PureComponent {

  static propTypes = {
    type: PropTypes.string,
    props: PropTypes.object,
    onClose: PropTypes.func.isRequired,
  };

  state = {
    backgroundColor: null,
  };

  componentDidUpdate () {
    if (!!this.props.type) {
      document.body.classList.add('with-modals--active');
      document.documentElement.style.marginRight = `${getScrollbarWidth()}px`;
    } else {
      document.body.classList.remove('with-modals--active');
      document.documentElement.style.marginRight = 0;
    }
  }

  setBackgroundColor = color => {
    this.setState({ backgroundColor: color });
  }

  renderLoading = modalId => () => {
    return ['MEDIA', 'VIDEO', 'BOOST', 'FAVOURITE', 'DOODLE', 'CONFIRM', 'ACTIONS'].indexOf(modalId) === -1 ? <ModalLoading /> : null;
  }

  renderError = (props) => {
    const { onClose } = this.props;

    return <BundleModalError {...props} onClose={onClose} />;
  }

  handleClose = () => {
    const { onClose } = this.props;
    let message = null;
    try {
      message = this._modal?.getWrappedInstance?.().getCloseConfirmationMessage?.();
    } catch (_) {
      // injectIntl defines `getWrappedInstance` but errors out if `withRef`
      // isn't set.
      // This would be much smoother with react-intl 3+ and `forwardRef`.
    }
    onClose(message);
  }

  setModalRef = (c) => {
    this._modal = c;
  }

  render () {
    const { type, props } = this.props;
    const { backgroundColor } = this.state;
    const visible = !!type;

    return (
      <Base backgroundColor={backgroundColor} onClose={this.handleClose} noEsc={props ? props.noEsc : false}>
        {visible && (
          <BundleContainer fetchComponent={MODAL_COMPONENTS[type]} loading={this.renderLoading(type)} error={this.renderError} renderDelay={200}>
            {(SpecificComponent) => <SpecificComponent {...props} onChangeBackgroundColor={this.setBackgroundColor} onClose={this.handleClose} ref={this.setModalRef} />}
          </BundleContainer>
        )}
      </Base>
    );
  }

}
