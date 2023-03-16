import {
  SERVER_FETCH_REQUEST,
  SERVER_FETCH_SUCCESS,
  SERVER_FETCH_FAIL,
  SERVER_TRANSLATION_LANGUAGES_FETCH_REQUEST,
  SERVER_TRANSLATION_LANGUAGES_FETCH_SUCCESS,
  SERVER_TRANSLATION_LANGUAGES_FETCH_FAIL,
  EXTENDED_DESCRIPTION_REQUEST,
  EXTENDED_DESCRIPTION_SUCCESS,
  EXTENDED_DESCRIPTION_FAIL,
  SERVER_DOMAIN_BLOCKS_FETCH_REQUEST,
  SERVER_DOMAIN_BLOCKS_FETCH_SUCCESS,
  SERVER_DOMAIN_BLOCKS_FETCH_FAIL,
} from 'flavours/glitch/actions/server';
import { Map as ImmutableMap, List as ImmutableList, fromJS } from 'immutable';

const initialState = ImmutableMap({
  server: ImmutableMap({
    isLoading: true,
  }),

  extendedDescription: ImmutableMap({
    isLoading: true,
  }),

  domainBlocks: ImmutableMap({
    isLoading: true,
    isAvailable: true,
    items: ImmutableList(),
  }),
});

export default function server(state = initialState, action) {
  switch (action.type) {
  case SERVER_FETCH_REQUEST:
    return state.setIn(['server', 'isLoading'], true);
  case SERVER_FETCH_SUCCESS:
    return state.set('server', fromJS(action.server)).setIn(['server', 'isLoading'], false);
  case SERVER_FETCH_FAIL:
    return state.setIn(['server', 'isLoading'], false);
  case SERVER_TRANSLATION_LANGUAGES_FETCH_REQUEST:
    return state.setIn(['translationLanguages', 'isLoading'], true);
  case SERVER_TRANSLATION_LANGUAGES_FETCH_SUCCESS:
    return state.setIn(['translationLanguages', 'items'], fromJS(action.translationLanguages)).setIn(['translationLanguages', 'isLoading'], false);
  case SERVER_TRANSLATION_LANGUAGES_FETCH_FAIL:
    return state.setIn(['translationLanguages', 'isLoading'], false);
  case EXTENDED_DESCRIPTION_REQUEST:
    return state.setIn(['extendedDescription', 'isLoading'], true);
  case EXTENDED_DESCRIPTION_SUCCESS:
    return state.set('extendedDescription', fromJS(action.description)).setIn(['extendedDescription', 'isLoading'], false);
  case EXTENDED_DESCRIPTION_FAIL:
    return state.setIn(['extendedDescription', 'isLoading'], false);
  case SERVER_DOMAIN_BLOCKS_FETCH_REQUEST:
    return state.setIn(['domainBlocks', 'isLoading'], true);
  case SERVER_DOMAIN_BLOCKS_FETCH_SUCCESS:
    return state.setIn(['domainBlocks', 'items'], fromJS(action.blocks)).setIn(['domainBlocks', 'isLoading'], false).setIn(['domainBlocks', 'isAvailable'], action.isAvailable);
  case SERVER_DOMAIN_BLOCKS_FETCH_FAIL:
    return state.setIn(['domainBlocks', 'isLoading'], false);
  default:
    return state;
  }
}
