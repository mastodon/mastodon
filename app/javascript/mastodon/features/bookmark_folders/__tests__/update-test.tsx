import type * as ReactRouterDomModule from 'react-router-dom';

import { Map as ImmutableMap } from 'immutable';
import type { Map as ImmutableMapType } from 'immutable';

import { fireEvent, render, screen, waitFor } from '@/testing/rendering';
import type * as BookmarkFoldersTypedModule from 'mastodon/actions/bookmark_folders_typed';
import type * as StoreModule from 'mastodon/store';

import NewBookmarkFolderWrapper from '../new';

const folder = { id: '1', title: 'Alpha' };

interface BookmarkFoldersState {
  bookmark_folders: ImmutableMapType<string, typeof folder>;
}

interface UpdateBookmarkFolderAction {
  type: 'bookmarkFolders/update';
  payload: {
    id: string;
    title: string;
  };
}

interface UpdateBookmarkFolderFulfilledAction {
  type: 'bookmarkFolders/update/fulfilled';
  meta: { requestStatus: 'fulfilled' };
  payload: { id: string; title: string };
}

interface FetchBookmarkFolderAction {
  type: 'bookmarkFolders/fetchOne';
  payload: { id: string };
}

type BookmarkFolderDispatchAction =
  | UpdateBookmarkFolderAction
  | FetchBookmarkFolderAction;

const mocks = vi.hoisted(() => ({
  dispatchMock: vi.fn(),
  useAppDispatchMock: vi.fn(),
  useAppSelectorMock: vi.fn(),
  updateBookmarkFolderMock: vi.fn(),
  fetchBookmarkFolderMock: vi.fn(),
}));

vi.mock('mastodon/store', async (importOriginal) => {
  const actual: typeof StoreModule = await importOriginal();

  return {
    ...actual,
    useAppDispatch: mocks.useAppDispatchMock,
    useAppSelector: mocks.useAppSelectorMock,
  };
});

vi.mock('@/mastodon/store', async (importOriginal) => {
  const actual: typeof StoreModule = await importOriginal();

  return {
    ...actual,
    useAppDispatch: mocks.useAppDispatchMock,
    useAppSelector: mocks.useAppSelectorMock,
  };
});

vi.mock('mastodon/actions/bookmark_folders_typed', async (importOriginal) => {
  const actual: typeof BookmarkFoldersTypedModule = await importOriginal();

  const updateBookmarkFolder = Object.assign(
    mocks.updateBookmarkFolderMock,
    actual.updateBookmarkFolder,
  );
  const fetchBookmarkFolder = Object.assign(
    mocks.fetchBookmarkFolderMock,
    actual.fetchBookmarkFolder,
  );

  return {
    ...actual,
    updateBookmarkFolder,
    fetchBookmarkFolder,
  };
});

vi.mock('react-router-dom', async (importOriginal) => {
  const actual: typeof ReactRouterDomModule = await importOriginal();

  return {
    ...actual,
    useParams: () => ({ id: '1' }),
  };
});

describe('<NewBookmarkFolder (update) />', () => {
  beforeEach(() => {
    mocks.updateBookmarkFolderMock.mockImplementation(
      (payload: UpdateBookmarkFolderAction['payload']) => ({
        type: 'bookmarkFolders/update',
        payload,
      }),
    );

    mocks.fetchBookmarkFolderMock.mockImplementation(
      ({ id }: FetchBookmarkFolderAction['payload']) => ({
        type: 'bookmarkFolders/fetchOne',
        payload: { id },
      }),
    );

    mocks.dispatchMock.mockImplementation(
      (action: BookmarkFolderDispatchAction) => {
        if (action.type === 'bookmarkFolders/update') {
          return Promise.resolve({
            type: 'bookmarkFolders/update/fulfilled',
            meta: { requestStatus: 'fulfilled' },
            payload: { id: action.payload.id, title: action.payload.title },
          } satisfies UpdateBookmarkFolderFulfilledAction);
        }

        return action;
      },
    );

    mocks.useAppDispatchMock.mockReturnValue(mocks.dispatchMock);
    mocks.useAppSelectorMock.mockImplementation(
      (selector: (state: BookmarkFoldersState) => typeof folder | undefined) =>
        selector({
          bookmark_folders: ImmutableMap([[folder.id, folder]]),
        }),
    );
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('submits an update when editing a folder', async () => {
    render(<NewBookmarkFolderWrapper />);

    const input = screen.getByDisplayValue('Alpha');
    fireEvent.change(input, { target: { value: 'Work' } });

    fireEvent.submit(input.closest('form') as HTMLFormElement);

    await waitFor(() => {
      expect(mocks.updateBookmarkFolderMock).toHaveBeenCalledWith({
        id: '1',
        title: 'Work',
      });
    });
  });
});
