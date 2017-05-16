import React from 'react';
import PropTypes from 'prop-types';
import MediaModal from './media_modal';
import OnboardingModal from './onboarding_modal';
import VideoModal from './video_modal';
import BoostModal from './boost_modal';
import ConfirmationModal from './confirmation_modal';
import { TransitionMotion, spring } from 'react-motion';

const MODAL_COMPONENTS = {
  'MEDIA': MediaModal,
  'ONBOARDING': OnboardingModal,
  'VIDEO': VideoModal,
  'BOOST': BoostModal,
  'CONFIRM': ConfirmationModal
};

class ModalRoot extends React.PureComponent {

  static propTypes = {
    type: PropTypes.string,
    props: PropTypes.object,
    onClose: PropTypes.func.isRequired
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

  componentWillUnmount () {
    window.removeEventListener('keyup', this.handleKeyUp);
  }

  willEnter () {
    return { opacity: 0, scale: 0.98 };
  }

  willLeave () {
    return { opacity: spring(0), scale: spring(0.98) };
  }

  render () {
    const { type, props, onClose } = this.props;
    const visible = !!type;
    const items = [];

    if (visible) {
      items.push({
        key: type,
        data: { type, props },
        style: { opacity: spring(1), scale: spring(1, { stiffness: 120, damping: 14 }) }
      });
    }

    return (
      <TransitionMotion
        styles={items}
        willEnter={this.willEnter}
        willLeave={this.willLeave}>
        {interpolatedStyles =>
          <div className='modal-root'>
            {interpolatedStyles.map(({ key, data: { type, props }, style }) => {
              const SpecificComponent = MODAL_COMPONENTS[type];

              return (
                <div key={key} style={{ pointerEvents: visible ? 'auto' : 'none' }}>
                  <div role='presentation' className='modal-root__overlay' style={{ opacity: style.opacity }} onClick={onClose} />
                  <div className='modal-root__container' style={{ opacity: style.opacity, transform: `translateZ(0px) scale(${style.scale})` }}>
                    <SpecificComponent {...props} onClose={onClose} />
                  </div>
                </div>
              );
            })}
          </div>
        }
      </TransitionMotion>
    );
  }

}

export default ModalRoot;
