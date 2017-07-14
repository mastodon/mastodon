/*

`actions/local_settings`
========================

>   For more information on the contents of this file, please contact:
>
>   - kibigo! [@kibi@glitch.social]

This file provides our Redux actions related to local settings. It
consists of the following:

 -  __`changesLocalSetting(key, value)` :__
    Changes the local setting with the given `key` to the given
    `value`. `key` **MUST** be an array of strings, as required by
    `Immutable.Map.prototype.getIn()`.

 -  __`saveLocalSettings()` :__
    Saves the local settings to `localStorage` as a JSON object. We
    shouldn't ever need to call this ourselves.

*/

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

Constants:
----------

We provide the following constants:

 -  __`LOCAL_SETTING_CHANGE` :__
    This string constant is used to dispatch a setting change to our
    reducer in `reducers/local_settings`, where the setting is
    actually changed.

*/

export const LOCAL_SETTING_CHANGE = 'LOCAL_SETTING_CHANGE';

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

`changeLocalSetting(key, value)`:
---------------------------------

Changes the local setting with the given `key` to the given `value`.
`key` **MUST** be an array of strings, as required by
`Immutable.Map.prototype.getIn()`.

To accomplish this, we just dispatch a `LOCAL_SETTING_CHANGE` to our
reducer in `reducers/local_settings`.

*/

export function changeLocalSetting(key, value) {
  return dispatch => {
    dispatch({
      type: LOCAL_SETTING_CHANGE,
      key,
      value,
    });

    dispatch(saveLocalSettings());
  };
};

//  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

/*

`saveLocalSettings()`:
----------------------

Saves the local settings to `localStorage` as a JSON object.
`changeLocalSetting()` calls this whenever it changes a setting. We
shouldn't ever need to call this ourselves.

>   __TODO :__
>   Right now `saveLocalSettings()` doesn't keep track of which user
>   is currently signed in, but it might be better to give each user
>   their *own* local settings.

*/

export function saveLocalSettings() {
  return (_, getState) => {
    const localSettings = getState().get('local_settings').toJS();
    localStorage.setItem('mastodon-settings', JSON.stringify(localSettings));
  };
};
