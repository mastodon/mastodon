import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import IconButton from '../../../components/icon_button';
import { changeComposeSensitivity } from '../../../actions/compose';
import Motion from 'react-motion/lib/Motion';
import spring from 'react-motion/lib/spring';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  title: { id: 'compose_form.sensitive', defaultMessage: 'Mark media as sensitive' },
});

const mapStateToProps = state => ({
  visible: state.getIn(['compose', 'media_attachments']).size > 0,
  active: state.getIn(['compose', 'sensitive']),
  disabled: state.getIn(['compose', 'spoiler']),
});

const mapDispatchToProps = dispatch => ({

  onClick () {
    dispatch(changeComposeSensitivity());
  },

});

class SensitiveButton extends React.PureComponent {

  static propTypes = {
    visible: PropTypes.bool,
    active: PropTypes.bool,
    disabled: PropTypes.bool,
    onClick: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { visible, active, disabled, onClick, intl } = this.props;

    return (
      <Motion defaultStyle={{ scale: 0.87 }} style={{ scale: spring(visible ? 1 : 0.87, { stiffness: 200, damping: 3 }) }}>
        {({ scale }) => {
          const icon = active ? 'eye-slash' : 'eye';
          const className = classNames('compose-form__sensitive-button', {
            'compose-form__sensitive-button--visible': visible,
          });
          return (
            <div className={className} style={{ transform: `translateZ(0) scale(${scale})` }}>
              <IconButton
                className='compose-form__sensitive-button__icon'
                title={intl.formatMessage(messages.title)}
                icon={icon}
                onClick={onClick}
                size={18}
                active={active}
                disabled={disabled}
                style={{ lineHeight: null, height: null }}
                inverted
              />
            </div>
          );
        }}
      </Motion>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(injectIntl(SensitiveButton));
