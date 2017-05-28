import React from 'react';
import PropTypes from 'prop-types';
import TransitionMotion from 'react-motion/lib/TransitionMotion';
import spring from 'react-motion/lib/spring';

import { store } from '../../../containers/mastodon';
import { fetchBundleRequest, fetchBundleSuccess, fetchBundleFail } from '../../../actions/bundles';

const FETCH_COMPONENTS = {
  'MEDIA': () => {
    store.dispatch(fetchBundleRequest());
    import(/* webpackChunkName: "media_modal" */ './media_modal')
      .then(Component => {
        MODAL_COMPONENTS.MEDIA = Component.default;
        store.dispatch(fetchBundleSuccess());
      })
      .catch(error => store.dispatch(fetchBundleFail(error)));
  },
  'ONBOARDING': () => {
    store.dispatch(fetchBundleRequest());
    import(/* webpackChunkName: "onboarding_modal" */ './onboarding_modal')
      .then(Component => {
        MODAL_COMPONENTS.ONBOARDING = Component.default;
        store.dispatch(fetchBundleSuccess());
      })
      .catch(error => store.dispatch(fetchBundleFail(error)));
  },
  'VIDEO': () => {
    store.dispatch(fetchBundleRequest());
    import(/* webpackChunkName: "video_modal" */ './video_modal')
      .then(Component => {
        MODAL_COMPONENTS.VIDEO = Component.default;
        store.dispatch(fetchBundleSuccess());
      })
      .catch(error => store.dispatch(fetchBundleFail(error)));
  },
  'BOOST': () => {
    store.dispatch(fetchBundleRequest());
    import(/* webpackChunkName: "boost_modal" */ './boost_modal')
      .then(Component => {
        MODAL_COMPONENTS.BOOST = Component.default;
        store.dispatch(fetchBundleSuccess());
      })
      .catch(error => store.dispatch(fetchBundleFail(error)));
  },
  'CONFIRM': () => {
    store.dispatch(fetchBundleRequest());
    import(/* webpackChunkName: "confirmation_modal" */ './confirmation_modal')
      .then(Component => {
        MODAL_COMPONENTS.CONFIRM = Component.default;
        store.dispatch(fetchBundleSuccess());
      })
      .catch(error => store.dispatch(fetchBundleFail(error)));
  },
};

const MODAL_COMPONENTS = { };

class ModalRoot extends React.PureComponent {

  static propTypes = {
    type: PropTypes.string,
    props: PropTypes.object,
    onClose: PropTypes.func.isRequired,
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

  componentWillReceiveProps ({ type }) {
    if (!!type && !MODAL_COMPONENTS[type]) {
      FETCH_COMPONENTS[type]();
    }
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
        style: { opacity: spring(1), scale: spring(1, { stiffness: 120, damping: 14 }) },
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
                    {SpecificComponent && <SpecificComponent {...props} onClose={onClose} />}
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
