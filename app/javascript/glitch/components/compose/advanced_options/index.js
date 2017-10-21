/*

`<ComposeAdvancedOptions>`
==========================

>   For more information on the contents of this file, please contact:
>
>   - surinna [@srn@dev.glitch.social]

This adds an advanced options dropdown to the toot compose box, for
toggles that don't necessarily fit elsewhere.

__Props:__

 -  __`values` (`ImmutablePropTypes.contains(…).isRequired`) :__
    An Immutable map with the following values:

     -  __`do_not_federate` (`PropTypes.bool.isRequired`) :__
        Specifies whether or not to federate the status.

 -  __`onChange` (`PropTypes.func.isRequired`) :__
    The function to call when a toggle is changed. We pass this from
    our container to the toggle.

 -  __`intl` (`PropTypes.object.isRequired`) :__
    Our internationalization object, inserted by `@injectIntl`.

__State:__

 -  __`open` :__
    This tells whether the dropdown is currently open or closed.

*/

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Imports:
--------

*/

//  Package imports  //
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { injectIntl, defineMessages } from 'react-intl';

//  Our imports  //
import ComposeAdvancedOptionsToggle from './toggle';
import ComposeDropdown from '../dropdown/index';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Inital setup:
-------------

The `messages` constant is used to define any messages that we need
from inside props. These are the various titles and labels on our
toggles.

`iconStyle` styles the icon used for the dropdown button.

*/

const messages = defineMessages({
  local_only_short            :
    { id: 'advanced-options.local-only.short', defaultMessage: 'Local-only' },
  local_only_long             :
    { id: 'advanced-options.local-only.long', defaultMessage: 'Do not post to other instances' },
  advanced_options_icon_title :
    { id: 'advanced_options.icon_title', defaultMessage: 'Advanced options' },
});

/*

Implementation:
---------------

*/

@injectIntl
export default class ComposeAdvancedOptions extends React.PureComponent {

  static propTypes = {
    values   : ImmutablePropTypes.contains({
      do_not_federate : PropTypes.bool.isRequired,
    }).isRequired,
    onChange : PropTypes.func.isRequired,
    intl     : PropTypes.object.isRequired,
  };


/*

###  `render()`

`render()` actually puts our component on the screen.

*/

  render () {
    const { intl, values } = this.props;

/*

The `options` array provides all of the available advanced options
alongside their icon, text, and name.

*/
    const options = [
      { icon: 'wifi', shortText: messages.local_only_short, longText: messages.local_only_long, name: 'do_not_federate' },
    ];

/*

`anyEnabled` tells us if any of our advanced options have been enabled.

*/

    const anyEnabled = values.some((enabled) => enabled);

/*

`optionElems` takes our `options` and creates
`<ComposeAdvancedOptionsToggle>`s out of them. We use the `name` of the
toggle as its `key` so that React can keep track of it.

*/

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

/*

Finally, we can render our component.

*/
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
