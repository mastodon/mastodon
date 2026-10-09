//  Package imports.
import { Map as ImmutableMap } from 'immutable';

//  Our imports.
import { LOCAL_SETTING_CHANGE, LOCAL_SETTING_DELETE } from 'flavours/glitch/actions/local_settings';
import { STORE_HYDRATE } from 'flavours/glitch/actions/store';

const initialState = ImmutableMap({
  fullwidth_columns: false,
  stretch   : true,
  side_arm  : 'none',
  side_arm_reply_mode : 'restrict',
  show_reply_count : true,
  always_show_spoilers_field: false,
  confirm_boost_missing_media_description: false,
  confirm_before_clearing_draft: true,
  prepend_cw_re: true,
  preselect_on_reply: true,
  inline_preview_cards: true,
  hicolor_privacy_icons: false,
  tag_misleading_links: true,
  rewrite_mentions: 'no',
  content_warnings : ImmutableMap({
    filter       : null,
    shared_state : false,
  }),
  media     : ImmutableMap({
    letterbox        : true,
    fullwidth        : true,
    reveal_behind_cw : false,
    pop_in_player    : true,
    pop_in_position  : 'right',
  }),
  notifications : ImmutableMap({
    favicon_badge : false,
    tab_badge     : true,
  }),
  status_icons : ImmutableMap({
    language:   true,
    reply:      true,
    local_only: true,
    media:      true,
    visibility: true,
  }),
  show_published_toast: true,
});

const hydrate = (state, localSettings) => state.mergeDeep(localSettings);

/** @type {import('@reduxjs/toolkit').Reducer<ImmutableMap<string, unknown>>} */
export default function localSettings(state = initialState, action) {
  switch(action.type) {
  case STORE_HYDRATE:
    return hydrate(state, action.state.get('local_settings'));
  case LOCAL_SETTING_CHANGE:
    return state.setIn(action.key, action.value);
  case LOCAL_SETTING_DELETE:
    return state.deleteIn(action.key);
  default:
    return state;
  }
}
