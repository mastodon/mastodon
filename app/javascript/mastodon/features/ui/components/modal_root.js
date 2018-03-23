import React from 'react';
import PropTypes from 'prop-types';
import BundleContainer from '../containers/bundle_container';
import BundleModalError from './bundle_modal_error';
import ModalLoading from './modal_loading';
import ActionsModal from './actions_modal';
import MediaModal from './media_modal';
import VideoModal from './video_modal';
import BoostModal from './boost_modal';
import ConfirmationModal from './confirmation_modal';
import FocalPointModal from './focal_point_modal';
import {
  OnboardingModal,
  MuteModal,
  ReportModal,
  EmbedModal,
  ListEditor,
} from '../../../features/ui/util/async-components';

const MODAL_COMPONENTS = {
  'MEDIA': () => Promise.resolve({ default: MediaModal }),
  'ONBOARDING': OnboardingModal,
  'VIDEO': () => Promise.resolve({ default: VideoModal }),
  'BOOST': () => Promise.resolve({ default: BoostModal }),
  'CONFIRM': () => Promise.resolve({ default: ConfirmationModal }),
  'MUTE': MuteModal,
  'REPORT': ReportModal,
  'ACTIONS': () => Promise.resolve({ default: ActionsModal }),
  'EMBED': EmbedModal,
  'LIST_EDITOR': ListEditor,
  'FOCAL_POINT': () => Promise.resolve({ default: FocalPointModal }),
};

export default class ModalRoot extends React.PureComponent {

  static propTypes = {
    type: PropTypes.string,
    props: PropTypes.object,
    onClose: PropTypes.func.isRequired,
  };

  state = {
    revealed: false,
  };

  handleKeyUp = (e) => {
    if ((e.key === 'Escape' || e.key === 'Esc' || e.keyCode === 27)
         && !!this.props.type) {
      this.props.onClose();
    }
  }

  componentDidMount () {
    window.addEventListener('keyup', this.handleKeyUp, false);
  }

  componentWillReceiveProps (nextProps) {
    if (!!nextProps.type && !this.props.type) {
      this.activeElement = document.activeElement;

      this.getSiblings().forEach(sibling => sibling.setAttribute('inert', true));
    } else if (!nextProps.type) {
      this.setState({ revealed: false });
    }
  }

  componentDidUpdate (prevProps) {
    if (!this.props.type && !!prevProps.type) {
      this.getSiblings().forEach(sibling => sibling.removeAttribute('inert'));
      this.activeElement.focus();
      this.activeElement = null;
    }
    if (this.props.type) {
      requestAnimationFrame(() => {
        this.setState({ revealed: true });
      });
    }
  }

  componentWillUnmount () {
    window.removeEventListener('keyup', this.handleKeyUp);
  }

  getSiblings = () => {
    return Array(...this.node.parentElement.childNodes).filter(node => node !== this.node);
  }

  setRef = ref => {
    this.node = ref;
  }

  renderLoading = modalId => () => {
    return ['MEDIA', 'VIDEO', 'BOOST', 'CONFIRM', 'ACTIONS'].indexOf(modalId) === -1 ? <ModalLoading /> : null;
  }

  renderError = (props) => {
    const { onClose } = this.props;

    return <BundleModalError {...props} onClose={onClose} />;
  }

  render () {
    const { type, props, onClose } = this.props;
    const { revealed } = this.state;
    const visible = !!type;

    if (!visible) {
      return (
        <div className='modal-root' ref={this.setRef} style={{ opacity: 0 }} />
      );
    }

    return (
      <div className='modal-root' ref={this.setRef} style={{ opacity: revealed ? 1 : 0 }}>
        <div style={{ pointerEvents: visible ? 'auto' : 'none' }}>
          <div role='presentation' className='modal-root__overlay' onClick={onClose} />
          <div role='dialog' className='modal-root__container'>
            {visible && (
              <BundleContainer fetchComponent={MODAL_COMPONENTS[type]} loading={this.renderLoading(type)} error={this.renderError} renderDelay={200}>
                {(SpecificComponent) => <SpecificComponent {...props} onClose={onClose} />}
              </BundleContainer>
            )}
          </div>
        </div>
      </div>
    );
  }

}
