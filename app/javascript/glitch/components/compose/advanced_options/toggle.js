/*

`<ComposeAdvancedOptionsToggle>`
================================

>   For more information on the contents of this file, please contact:
>
>   - surinna [@srn@dev.glitch.social]

This creates the toggle used by `<ComposeAdvancedOptions>`.

__Props:__

 -  __`onChange` (`PropTypes.func`) :__
    This provides the function to call when the toggle is
    (de-?)activated.

 -  __`active` (`PropTypes.bool`) :__
    This prop controls whether the toggle is currently active or not.

 -  __`name` (`PropTypes.string`) :__
    This identifies the toggle, and is sent to `onChange()` when it is
    called.

 -  __`shortText` (`PropTypes.string`) :__
    This is a short string used as the title of the toggle.

 -  __`longText` (`PropTypes.string`) :__
    This is a longer string used as a subtitle for the toggle.

*/

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Imports:
--------

*/

//  Package imports  //
import React from 'react';
import PropTypes from 'prop-types';
import Toggle from 'react-toggle';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Implementation:
---------------

*/

export default class ComposeAdvancedOptionsToggle extends React.PureComponent {

  static propTypes = {
    onChange: PropTypes.func.isRequired,
    active: PropTypes.bool.isRequired,
    name: PropTypes.string.isRequired,
    shortText: PropTypes.string.isRequired,
    longText: PropTypes.string.isRequired,
  }

/*

###  `onToggle()`

The `onToggle()` function simply calls the `onChange()` prop with the
toggle's `name`.

*/

  onToggle = () => {
    this.props.onChange(this.props.name);
  }

/*

###  `render()`

The `render()` function is used to render our component. We just render
a `<Toggle>` and place next to it our text.

*/

  render() {
    const { active, shortText, longText } = this.props;
    return (
      <div role='button' tabIndex='0' className='advanced-options-dropdown__option' onClick={this.onToggle}>
        <div className='advanced-options-dropdown__option__toggle'>
          <Toggle checked={active} onChange={this.onToggle} />
        </div>
        <div className='advanced-options-dropdown__option__content'>
          <strong>{shortText}</strong>
          {longText}
        </div>
      </div>
    );
  }

}
