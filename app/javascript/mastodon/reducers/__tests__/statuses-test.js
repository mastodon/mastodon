import {
  STATUS_TRANSLATE_FAIL,
  STATUS_TRANSLATE_REQUEST,
  STATUS_TRANSLATE_SUCCESS,
} from 'mastodon/actions/statuses';
import { STATUS_IMPORT } from 'mastodon/actions/importer';

import statuses from '../statuses';

const baseStatus = {
  id: '1',
  content: '<p>Hola</p>',
  media_attachments: [],
};

const translation = {
  content: '<p>Hello</p>',
  spoiler_text: '',
  media_attachments: [],
  detected_source_language: 'es',
  language: 'en',
  provider: 'DeepL.com',
};

describe('statuses reducer translation loading', () => {
  const imported = () =>
    statuses(undefined, {
      type: STATUS_IMPORT,
      status: baseStatus,
    });

  it('sets isTranslating on STATUS_TRANSLATE_REQUEST', () => {
    const state = statuses(imported(), {
      type: STATUS_TRANSLATE_REQUEST,
      id: '1',
    });

    expect(state.getIn(['1', 'isTranslating'])).toBe(true);
  });

  it('clears isTranslating and stores translation on STATUS_TRANSLATE_SUCCESS', () => {
    let state = statuses(imported(), {
      type: STATUS_TRANSLATE_REQUEST,
      id: '1',
    });

    state = statuses(state, {
      type: STATUS_TRANSLATE_SUCCESS,
      id: '1',
      translation,
    });

    expect(state.getIn(['1', 'isTranslating'])).toBeUndefined();
    expect(state.getIn(['1', 'translation', 'provider'])).toBe('DeepL.com');
    expect(state.getIn(['1', 'translation', 'contentHtml'])).toBe('<p>Hello</p>');
  });

  it('clears isTranslating on STATUS_TRANSLATE_FAIL', () => {
    let state = statuses(imported(), {
      type: STATUS_TRANSLATE_REQUEST,
      id: '1',
    });

    state = statuses(state, {
      type: STATUS_TRANSLATE_FAIL,
      id: '1',
      error: new Error('fail'),
    });

    expect(state.getIn(['1', 'isTranslating'])).toBeUndefined();
    expect(state.getIn(['1', 'translation'])).toBeUndefined();
  });
});
