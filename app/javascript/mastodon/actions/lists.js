import api from '../api';
import { fetchAccountList } from './accounts';

export const LIST_FETCH_REQUEST = 'LIST_FETCH_REQUEST';
export const LIST_FETCH_SUCCESS = 'LIST_FETCH_SUCCESS';
export const LIST_FETCH_FAIL = 'LIST_FETCH_FAIL';

export const LISTS_FETCH_REQUEST = 'LISTS_FETCH_REQUEST';
export const LISTS_FETCH_SUCCESS = 'LISTS_FETCH_SUCCESS';
export const LISTS_FETCH_FAIL = 'LISTS_FETCH_FAIL';

export const LIST_EDITOR_TITLE_CHANGE = 'LIST_EDITOR_TITLE_CHANGE';
export const LIST_EDITOR_HASHTAG_CHANGE = 'LIST_EDITOR_HASHTAG_CHANGE';
export const LIST_EDITOR_RESET = 'LIST_EDITOR_RESET';
export const LIST_EDITOR_SETUP = 'LIST_EDITOR_SETUP';

export const LIST_CREATE_REQUEST = 'LIST_CREATE_REQUEST';
export const LIST_CREATE_SUCCESS = 'LIST_CREATE_SUCCESS';
export const LIST_CREATE_FAIL = 'LIST_CREATE_FAIL';

export const LIST_UPDATE_REQUEST = 'LIST_UPDATE_REQUEST';
export const LIST_UPDATE_SUCCESS = 'LIST_UPDATE_SUCCESS';
export const LIST_UPDATE_FAIL = 'LIST_UPDATE_FAIL';

export const LIST_DELETE_REQUEST = 'LIST_DELETE_REQUEST';
export const LIST_DELETE_SUCCESS = 'LIST_DELETE_SUCCESS';
export const LIST_DELETE_FAIL = 'LIST_DELETE_FAIL';

export const UPDATE_HASHTAGS_USERS = 'UPDATE_HASHTAGS_USERS';

export const fetchList = (id) => (dispatch, getState) => {
  if (getState().getIn(['lists', id])) {
    return;
  }

  dispatch(fetchListRequest(id));

  api(getState)
    .get(`/api/v1/lists/${id}`)
    .then(({ data }) => dispatch(fetchListSuccess(data)))
    .catch((err) => dispatch(fetchListFail(id, err)));
};

export const fetchListRequest = (id) => ({
  type: LIST_FETCH_REQUEST,
  id,
});

export const fetchListSuccess = (list) => ({
  type: LIST_FETCH_SUCCESS,
  list,
});

export const fetchListFail = (id, error) => ({
  type: LIST_FETCH_FAIL,
  id,
  error,
});

export const fetchLists = () => (dispatch, getState) => {
  dispatch(fetchListsRequest());

  api(getState)
    .get('/api/v1/lists')
    .then(({ data }) => dispatch(fetchListsSuccess(data)))
    .catch((err) => dispatch(fetchListsFail(err)));
};

export const fetchListsRequest = () => ({
  type: LISTS_FETCH_REQUEST,
});

export const fetchListsSuccess = (lists) => ({
  type: LISTS_FETCH_SUCCESS,
  lists,
});

export const fetchListsFail = (error) => ({
  type: LISTS_FETCH_FAIL,
  error,
});

export const updateHashtagsUsers = (hashtagsUsersJSON) => ({
  type: UPDATE_HASHTAGS_USERS,
  hashtagsUsersJSON,
});

export const submitListEditor = (shouldReset) => (dispatch, getState) => {
  const listId = getState().getIn(['listEditor', 'listId']);
  const title = getState().getIn(['listEditor', 'title']);

  if (listId === null) {
    dispatch(createList(title, shouldReset));
  } else {
    dispatch(updateList(listId, title, shouldReset));
  }
};

export const setupListEditor = (listId) => (dispatch, getState) => {
  dispatch({
    type: LIST_EDITOR_SETUP,
    list: getState().getIn(['lists', listId]),
  });
  dispatch(setupAccounts());
  
};

export const setupAccounts = () => (dispatch, getState) => {
  var hashtagsUsers;
  if (getState().getIn(['listEditor', 'hashtagsUsers']) === '') {
    hashtagsUsers = { hashtags: {}, users: {} };
  } else {
    hashtagsUsers = JSON.parse(
      getState().getIn(['listEditor', 'hashtagsUsers'])
    );
  }
  const users = Object.values(hashtagsUsers.users);

  users.forEach((u, i) => {
    dispatch(fetchAccountList(users[i]));
  });

  

};

export const changeListEditorTitle = (value) => ({
  type: LIST_EDITOR_TITLE_CHANGE,
  value,
});

export const changeListEditorHashtag = (hashtags) => ({
  type: LIST_EDITOR_HASHTAG_CHANGE,
  hashtags,
});

export const createList = (title, shouldReset) => (dispatch, getState) => {
  dispatch(createListRequest());

  api(getState)
    .post('/api/v1/lists', { title })
    .then(({ data }) => {
      dispatch(createListSuccess(data));

      if (shouldReset) {
        dispatch(changeListEditorTitle(title));
      }
    })
    .catch((err) => dispatch(createListFail(err)));
};

export const createListRequest = () => ({
  type: LIST_CREATE_REQUEST,
});

export const createListSuccess = (list) => ({
  type: LIST_CREATE_SUCCESS,
  list,
});

export const createListFail = (error) => ({
  type: LIST_CREATE_FAIL,
  error,
});

export const updateList =
  (id, title, shouldReset, hashtags_users, replies_policy) =>
  (dispatch, getState) => {
    dispatch(updateListRequest(id));

    api(getState)
      .put(`/api/v1/lists/${id}`, { title, replies_policy, hashtags_users })
      .then(({ data }) => {
        dispatch(updateListSuccess(data));

        if (shouldReset) {
          dispatch(resetListEditor());
        }
      })
      .catch((err) => dispatch(updateListFail(id, err)));
  };

export const updateListRequest = (id) => ({
  type: LIST_UPDATE_REQUEST,
  id,
});

export const updateListSuccess = (list) => ({
  type: LIST_UPDATE_SUCCESS,
  list,
});

export const updateListFail = (id, error) => ({
  type: LIST_UPDATE_FAIL,
  id,
  error,
});

export const resetListEditor = () => ({
  type: LIST_EDITOR_RESET,
});

export const deleteList = (id) => (dispatch, getState) => {
  dispatch(deleteListRequest(id));

  api(getState)
    .delete(`/api/v1/lists/${id}`)
    .then(() => dispatch(deleteListSuccess(id)))
    .catch((err) => dispatch(deleteListFail(id, err)));
};

export const deleteListRequest = (id) => ({
  type: LIST_DELETE_REQUEST,
  id,
});

export const deleteListSuccess = (id) => ({
  type: LIST_DELETE_SUCCESS,
  id,
});

export const deleteListFail = (id, error) => ({
  type: LIST_DELETE_FAIL,
  id,
  error,
});

export const addHashtagsToListEditor =
  (shouldReset) => (dispatch, getState) => {
    dispatch(
      addHashtagsToList(getState().getIn(['listEditor', 'listId']), shouldReset)
    );
  };

export const addHashtagsToList =
  (listId, shouldReset) => (dispatch, getState) => {
    dispatch(fetchList(listId));
    var hashtagsUsers;

    const title = getState().getIn(['listEditor', 'title']);
    if (getState().getIn(['listEditor', 'hashtagsUsers']) === '') {
      hashtagsUsers = { hashtags: {}, users: {} };
    } else {
      hashtagsUsers = JSON.parse(
        getState().getIn(['listEditor', 'hashtagsUsers'])
      );
    }

    const hashtags = getState()
      .getIn(['listEditor', 'hashtags'])
      .split(/(\s+)/)
      .filter((e) => e.trim().length > 0);

    if (hashtags.length === 0) {
      hashtagsUsers.hashtags = {};
    } else {
      hashtags.forEach((h, i) => (hashtagsUsers.hashtags[i] = h));
    }
    console.log(hashtagsUsers);
    const hashtagsUsersJSON = JSON.stringify(hashtagsUsers);

    dispatch(updateList(listId, title, shouldReset, hashtagsUsersJSON));

    dispatch(updateHashtagsUsers(hashtagsUsersJSON));
  };

export const addToListEditor = (accountId) => (dispatch, getState) => {
  dispatch(
    addToList(getState().getIn(['listEditor', 'listId']), accountId, false)
  );
};

export const addToList =
  (listId, accountId, shouldReset) => (dispatch, getState) => {
    dispatch(fetchList(listId));

    var hashtagsUsers;

    const title = getState().getIn(['listEditor', 'title']);
    if (getState().getIn(['listEditor', 'hashtagsUsers']) === '') {
      hashtagsUsers = { hashtags: {}, users: {} };
    } else {
      hashtagsUsers = JSON.parse(
        getState().getIn(['listEditor', 'hashtagsUsers'])
      );
    }

    //console.log(hashtagsUsers);

    //console.log(Object.keys(hashtagsUsers.users).length);

    hashtagsUsers.users[Object.keys(hashtagsUsers.users).length] = accountId;

    //console.log(accountId);

    const hashtagsUsersJSON = JSON.stringify(hashtagsUsers);

    dispatch(updateList(listId, title, shouldReset, hashtagsUsersJSON));

    dispatch(updateHashtagsUsers(hashtagsUsersJSON));
  };

export const removeFromListEditor =
  (accountId, shouldReset) => (dispatch, getState) => {
    const listId = getState().getIn(['listEditor', 'listId']);
    const title = getState().getIn(['listEditor', 'title']);
    const hashtagsUsers = JSON.parse(
      getState().getIn(['listEditor', 'hashtagsUsers'])
    );

    Object.keys(hashtagsUsers.users).forEach((h, i) => {
      if (hashtagsUsers.users[h] === accountId) {
        delete hashtagsUsers.users[h];
      }
    });
    console.log(hashtagsUsers);
    const hashtagsUsersJSON = JSON.stringify(hashtagsUsers);

    dispatch(updateList(listId, title, shouldReset, hashtagsUsersJSON));

    dispatch(updateHashtagsUsers(hashtagsUsersJSON));
  };
