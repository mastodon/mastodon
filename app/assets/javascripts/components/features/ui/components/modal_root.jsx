import PureRenderMixin from 'react-addons-pure-render-mixin';
import MediaModal from './media_modal';
import BoostModal from './boost_modal';
import { TransitionMotion, spring } from 'react-motion';

const MODAL_COMPONENTS = {
  'MEDIA': MediaModal,
  'BOOST': BoostModal
};

const ModalRoot = React.createClass({

  propTypes: {
    type: React.PropTypes.string,
    props: React.PropTypes.object,
    onClose: React.PropTypes.func.isRequired
  },

  mixins: [PureRenderMixin],

  handleKeyUp (e) {
    if (e.key === 'Escape' && !!this.props.type) {
      this.props.onClose();
    }
  },

  componentDidMount () {
    window.addEventListener('keyup', this.handleKeyUp, false);
  },

  componentWillUnmount () {
    window.removeEventListener('keyup', this.handleKeyUp);
  },

  willEnter () {
    return { opacity: 0, scale: 0.98 };
  },

  willLeave () {
    return { opacity: spring(0), scale: spring(0.98) };
  },

  render () {
    const { type, props, onClose } = this.props;
    const items = [];

    if (!!type) {
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
                <div key={key}>
                  <div className='modal-root__overlay' style={{ opacity: style.opacity, transform: `translateZ(0px)` }} onClick={onClose} />
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

});

export default ModalRoot;
