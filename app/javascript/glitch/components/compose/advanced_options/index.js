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

//  Mastodon imports  //
import IconButton from '../../../../mastodon/components/icon_button';

//  Our imports  //
import ComposeAdvancedOptionsToggle from './toggle';

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

const iconStyle = {
  height     : null,
  lineHeight : '27px',
};

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

  state = {
    open: false,
  };

/*

###  `onToggleDropdown()`

This function toggles the opening and closing of the advanced options
dropdown.

*/

  onToggleDropdown = () => {
    this.setState({ open: !this.state.open });
  };

/*

###  `onGlobalClick(e)`

This function closes the advanced options dropdown if you click
anywhere else on the screen.

*/

  onGlobalClick = (e) => {
    if (e.target !== this.node && !this.node.contains(e.target) && this.state.open) {
      this.setState({ open: false });
    }
  }

/*

###  `componentDidMount()`, `componentWillUnmount()`

This function closes the advanced options dropdown if you click
anywhere else on the screen.

*/

  componentDidMount () {
    window.addEventListener('click', this.onGlobalClick);
    window.addEventListener('touchstart', this.onGlobalClick);
  }
  componentWillUnmount () {
    window.removeEventListener('click', this.onGlobalClick);
    window.removeEventListener('touchstart', this.onGlobalClick);
  }

/*

###  `setRef(c)`

`setRef()` stores a reference to the dropdown's `<div> in `this.node`.

*/

  setRef = (c) => {
    this.node = c;
  }

/*

###  `render()`

`render()` actually puts our component on the screen.

*/

  render () {
    const { open } = this.state;
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
      <div ref={this.setRef} className={`advanced-options-dropdown ${open ?  'open' : ''} ${anyEnabled ? 'active' : ''} `}>
        <div className='advanced-options-dropdown__value'>
          <IconButton
            className='advanced-options-dropdown__value'
            title={intl.formatMessage(messages.advanced_options_icon_title)}
            icon='ellipsis-h' active={open || anyEnabled}
            size={18}
            style={iconStyle}
            onClick={this.onToggleDropdown}
          />
        </div>
        <div className='advanced-options-dropdown__dropdown'>
          {optionElems}
        </div>
      </div>
    );
  }

}
