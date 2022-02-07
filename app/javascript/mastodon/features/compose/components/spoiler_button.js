import React from 'react';
import TextIconButton from '../components/text_icon_button';
import PropTypes from 'prop-types';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  marked: { id: 'compose_form.spoiler.marked', defaultMessage: 'Text is hidden behind warning' },
  unmarked: { id: 'compose_form.spoiler.unmarked', defaultMessage: 'Text is not hidden' },
});

export default @injectIntl
class SpoilerButton extends React.PureComponent {

  static propTypes = {
    active: PropTypes.bool,
    onClick: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  render () {
    const { active, onClick, intl } = this.props;

    return (
      <TextIconButton
        label='CW'
        title={intl.formatMessage(active ? messages.marked : messages.unmarked)}
        active={active}
        ariaControls={'cw-spoiler-input'}
        onClick={onClick}
      />
    );
  }

};
