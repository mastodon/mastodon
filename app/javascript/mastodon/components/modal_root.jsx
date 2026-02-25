import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import 'wicg-inert';

import { multiply } from 'color-blend';
import { createBrowserHistory } from 'history';

import { WithOptionalRouterPropTypes, withOptionalRouter } from 'mastodon/utils/react_router';

class ModalRoot extends PureComponent {

  static propTypes = {
    children: PropTypes.node,
    onClose: PropTypes.func.isRequired,
    backgroundColor: PropTypes.oneOfType([
      PropTypes.string,
      PropTypes.shape({
        r: PropTypes.number,
        g: PropTypes.number,
        b: PropTypes.number,
      }),
    ]),
    ignoreFocus: PropTypes.bool,
    ...WithOptionalRouterPropTypes,
  };

  activeElement = this.props.children ? document.activeElement : null;

  handleKeyUp = (e) => {
    if ((e.key === 'Escape' || e.key === 'Esc' || e.keyCode === 27)
         && !!this.props.children) {
      this.props.onClose();
    }
  };

  handleKeyDown = (e) => {
    if (e.key === 'Tab') {
      const focusable = Array.from(this.node.querySelectorAll('button:not([disabled]), [href], input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])')).filter((x) => window.getComputedStyle(x).display !== 'none');
      const index = focusable.indexOf(e.target);

      let element;

      if (e.shiftKey) {
        element = focusable[index - 1] || focusable[focusable.length - 1];
      } else {
        element = focusable[index + 1] || focusable[0];
      }

      if (element) {
        element.focus();
        e.stopPropagation();
        e.preventDefault();
      }
    }
  };

  componentDidMount () {
    window.addEventListener('keyup', this.handleKeyUp, false);
    window.addEventListener('keydown', this.handleKeyDown, false);
    this.history = this.props.history || createBrowserHistory();
  }

  componentDidUpdate (prevProps) {
    if (!this.props.children && !!prevProps.children) {
      this.getSiblings().forEach(sibling => sibling.removeAttribute('inert'));

      // Because of the wicg-inert polyfill, the activeElement may not be
      // immediately selectable, we have to wait for observers to run, as
      // described in https://github.com/WICG/inert#performance-and-gotchas
      Promise.resolve().then(() => {
        if (!this.props.ignoreFocus) {
          this.activeElement.focus({ preventScroll: true });
        }
        this.activeElement = null;
      }).catch(console.error);

      this._handleModalClose();
    }

    if (this.props.children && !prevProps.children) {
      this.activeElement = document.activeElement;

      this.getSiblings().forEach(sibling => sibling.setAttribute('inert', true));

      this._handleModalOpen();
    }

    if (this.props.children) {
      this._ensureHistoryBuffer();
    }
  }

  componentWillUnmount () {
    window.removeEventListener('keyup', this.handleKeyUp);
    window.removeEventListener('keydown', this.handleKeyDown);
  }

  _handleModalOpen () {
    this._modalHistoryKey = Date.now();
    this.unlistenHistory = this.history.listen((_, action) => {
      if (action === 'POP') {
        this.props.onClose();
      }
    });
  }

  _handleModalClose () {
    if (this.unlistenHistory) {
      this.unlistenHistory();
    }
    const { state } = this.history.location;
    if (state && state.mastodonModalKey === this._modalHistoryKey) {
      this.history.goBack();
    }
  }

  _ensureHistoryBuffer () {
    const { pathname, search, hash, state } = this.history.location;
    if (!state || state.mastodonModalKey !== this._modalHistoryKey) {
      this.history.push({ pathname, search, hash }, { ...state, mastodonModalKey: this._modalHistoryKey });
    }
  }

  getSiblings = () => {
    return Array(...this.node.parentElement.childNodes).filter(node => node !== this.node);
  };

  setRef = ref => {
    this.node = ref;
  };

  render () {
    const { children, onClose } = this.props;
    const visible = !!children;

    if (!visible) {
      return (
        <div className='modal-root' ref={this.setRef} style={{ opacity: 0 }} />
      );
    }

    let backgroundColor = null;

    if (this.props.backgroundColor && typeof this.props.backgroundColor === 'string') {
      backgroundColor = this.props.backgroundColor;
    } else if (this.props.backgroundColor) {
      const darkenedColor = multiply({ ...this.props.backgroundColor, a: 1 }, { r: 0, g: 0, b: 0, a: 0.7 });
      backgroundColor = `rgb(${darkenedColor.r}, ${darkenedColor.g}, ${darkenedColor.b})`;
    }

    return (
      <div className='modal-root' ref={this.setRef}>
        <div style={{ pointerEvents: visible ? 'auto' : 'none' }}>
          <div role='presentation' className='modal-root__overlay' onClick={onClose} style={{ backgroundColor }} />
          <div role='dialog' className='modal-root__container'>{children}</div>
        </div>
      </div>
    );
  }

}

export default withOptionalRouter(ModalRoot);
