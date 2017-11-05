/*

`reducers/local_settings`
========================

>   For more information on the contents of this file, please contact:
>
>   - kibigo! [@kibi@glitch.social]

This file provides our Redux reducers related to local settings. The
associated actions are:

 -  __`STORE_HYDRATE` :__
    Used to hydrate the store with its initial values.

 -  __`LOCAL_SETTING_CHANGE` :__
    Used to change the value of a local setting in the store.

*/

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Imports:
--------

*/

//  Package imports  //
import { Map as ImmutableMap } from 'immutable';

//  Mastodon imports  //
import { STORE_HYDRATE } from '../../mastodon/actions/store';

//  Our imports  //
import { LOCAL_SETTING_CHANGE } from '../actions/local_settings';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

initialState:
-------------

You can see the default values for all of our local settings here.
These are only used if no previously-saved values exist.

*/

const initialState = ImmutableMap({
  layout    : 'auto',
  stretch   : true,
  navbar_under : false,
  side_arm  : 'none',
  collapsed : ImmutableMap({
    enabled     : true,
    auto        : ImmutableMap({
      all              : false,
      notifications    : true,
      lengthy          : true,
      reblogs          : false,
      replies          : false,
      media            : false,
    }),
    backgrounds : ImmutableMap({
      user_backgrounds : false,
      preview_images   : false,
    }),
  }),
  media     : ImmutableMap({
    letterbox   : true,
    fullwidth   : true,
  }),
});

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Helper functions:
-----------------

###  `hydrate(state, localSettings)`

`hydrate()` is used to hydrate the `local_settings` part of our store
with its initial values. The `state` will probably just be the
`initialState`, and the `localSettings` should be whatever we pulled
from `localStorage`.

*/

const hydrate = (state, localSettings) => state.mergeDeep(localSettings);

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

`localSettings(state = initialState, action)`:
----------------------------------------------

This function holds our actual reducer.

If our action is `STORE_HYDRATE`, then we call `hydrate()` with the
`local_settings` property of the provided `action.state`.

If our action is `LOCAL_SETTING_CHANGE`, then we set `action.key` in
our state to the provided `action.value`. Note that `action.key` MUST
be an array, since we use `setIn()`.

>   __Note :__
>   We call this function `localSettings`, but its associated object
>   in the store is `local_settings`.

*/

export default function localSettings(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    return hydrate(state, action.state.get('local_settings'));
  case LOCAL_SETTING_CHANGE:
    return state.setIn(action.key, action.value);
  default:
    return state;
  }
};
