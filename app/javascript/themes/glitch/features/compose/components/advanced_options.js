//  Package imports.
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages } from 'react-intl';

//  Our imports.
import ComposeAdvancedOptionsToggle from './advanced_options_toggle';
import ComposeDropdown from './dropdown';

const messages = defineMessages({
  local_only_short            :
    { id: 'advanced-options.local-only.short', defaultMessage: 'Local-only' },
  local_only_long             :
    { id: 'advanced-options.local-only.long', defaultMessage: 'Do not post to other instances' },
  advanced_options_icon_title :
    { id: 'advanced_options.icon_title', defaultMessage: 'Advanced options' },
});

@injectIntl
export default class ComposeAdvancedOptions extends React.PureComponent {

  static propTypes = {
    values   : ImmutablePropTypes.contains({
      do_not_federate : PropTypes.bool.isRequired,
    }).isRequired,
    onChange : PropTypes.func.isRequired,
    intl     : PropTypes.object.isRequired,
  };

  render () {
    const { intl, values } = this.props;
    const options = [
      { icon: 'wifi', shortText: messages.local_only_short, longText: messages.local_only_long, name: 'do_not_federate' },
    ];
    const anyEnabled = values.some((enabled) => enabled);

    const optionElems = options.map((option) => {
      return (
        <ComposeAdvancedOptionsToggle
          onChange={this.props.onChange}
          active={values.get(option.name)}
          key={option.name}
          name={option.name}
          shortText={intl.formatMessage(option.shortText)}
          longText={intl.formatMessage(option.longText)}
        />
      );
    });

    return (
      <ComposeDropdown
        title={intl.formatMessage(messages.advanced_options_icon_title)}
        icon='home'
        highlight={anyEnabled}
      >
        {optionElems}
      </ComposeDropdown>
    );
  }

}
