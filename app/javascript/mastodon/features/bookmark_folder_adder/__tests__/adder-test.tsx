import { Map as ImmutableMap } from 'immutable';
import type { Map as ImmutableMapType } from 'immutable';

import { fireEvent, render, screen, waitFor } from '@/testing/rendering';

import type * as BookmarkFoldersTypedModule from 'mastodon/actions/bookmark_folders_typed';
import type * as InteractionsModule from 'mastodon/actions/interactions';
import BookmarkFolderAdder from '..';
import type * as StoreModule from 'mastodon/store';

const status = ImmutableMap({ bookmark_folder_id: '1' });

interface CreateBookmarkFolderAction {
  type: 'bookmarkFolders/create';
  payload: {
    title: string;
  };
}

interface FetchBookmarkFoldersAction {
  type: 'bookmarkFolders/fetch';
}

interface BookmarkAction {
  type: 'bookmarks/bookmark';
  payload: {
    statusValue: typeof status;
    folderId: string | null;
  };
}

interface CreateBookmarkFolderFulfilledAction {
  type: 'bookmarkFolders/create/fulfilled';
  meta: { requestStatus: 'fulfilled' };
  payload: { id: string; title: string };
}

interface BookmarkFoldersState {
  bookmark_folders: ImmutableMapType<string, { id: string; title: string } | null>;
}

type BookmarkFolderDispatchAction =
  | CreateBookmarkFolderAction
  | FetchBookmarkFoldersAction;

const folders = [
  { id: '2', title: 'Zulu' },
  { id: '1', title: 'Alpha' },
];

const mocks = vi.hoisted(() => ({
  dispatchMock: vi.fn(),
  useAppDispatchMock: vi.fn(),
  useAppSelectorMock: vi.fn(),
  createBookmarkFolderMock: vi.fn(),
  fetchBookmarkFoldersMock: vi.fn(),
  bookmarkMock: vi.fn(),
}));

const renderComponent = () => {
  return render(<BookmarkFolderAdder status={status} onClose={vi.fn()} />);
};

const getFolderRadio = (name: string) =>
  screen.getByLabelText<HTMLInputElement>(name);

const getNewFolderInput = () =>
  screen.getByPlaceholderText<HTMLInputElement>('New folder name');

const submitNewFolderForm = () => {
  fireEvent.submit(getNewFolderInput().closest('form') as HTMLFormElement);
};

const createFolderFulfilledAction = (
  title: string,
): CreateBookmarkFolderFulfilledAction => ({
  type: 'bookmarkFolders/create/fulfilled',
  meta: { requestStatus: 'fulfilled' },
  payload: { id: '3', title },
});

vi.mock('mastodon/store', async (importOriginal) => {
  const actual: typeof StoreModule = await importOriginal();

  return {
    ...actual,
    useAppDispatch: mocks.useAppDispatchMock,
    useAppSelector: mocks.useAppSelectorMock,
  };
});

vi.mock('mastodon/actions/bookmark_folders_typed', async (importOriginal) => {
  const actual: typeof BookmarkFoldersTypedModule = await importOriginal();

  const createBookmarkFolder = Object.assign(
    mocks.createBookmarkFolderMock,
    actual.createBookmarkFolder,
  );
  const fetchBookmarkFolders = Object.assign(
    mocks.fetchBookmarkFoldersMock,
    actual.fetchBookmarkFolders,
  );

  return {
    ...actual,
    createBookmarkFolder,
    fetchBookmarkFolders,
  };
});

vi.mock('mastodon/actions/interactions', async (importOriginal) => {
  const actual: typeof InteractionsModule = await importOriginal();

  return {
    ...actual,
    bookmark: mocks.bookmarkMock,
  };
});

describe('<BookmarkFolderAdder />', () => {
  beforeEach(() => {
    mocks.createBookmarkFolderMock.mockImplementation(
      (payload: CreateBookmarkFolderAction['payload']) => ({
        type: 'bookmarkFolders/create',
        payload,
      }),
    );
    mocks.fetchBookmarkFoldersMock.mockImplementation(() => ({
      type: 'bookmarkFolders/fetch',
    }));
    mocks.bookmarkMock.mockImplementation(
      (statusValue: typeof status, folderId: string | null): BookmarkAction => ({
        type: 'bookmarks/bookmark',
        payload: { statusValue, folderId },
      }),
    );

    mocks.dispatchMock.mockImplementation(
      (action: BookmarkFolderDispatchAction) => {
        if (action.type === 'bookmarkFolders/create') {
          const fulfilledAction = createFolderFulfilledAction(
            action.payload.title,
          );

          mocks.bookmarkMock(status, fulfilledAction.payload.id);

          return Promise.resolve(fulfilledAction);
        }

        return action;
      },
    );

    mocks.useAppDispatchMock.mockReturnValue(mocks.dispatchMock);
    mocks.useAppSelectorMock.mockImplementation(
      (selector: (state: BookmarkFoldersState) => unknown) =>
        selector({
          bookmark_folders: ImmutableMap(
            folders.map((folder) => [folder.id, folder]),
          ),
        }),
    );
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('fetches folders on mount and renders them in title order', () => {
    renderComponent();

    expect(mocks.fetchBookmarkFoldersMock).toHaveBeenCalledTimes(1);

    const titles = screen
      .getAllByRole('radio')
      .map((radio) => radio.closest('label')?.querySelector('span')?.textContent);

    expect(titles).toEqual(['No folder', 'Alpha', 'Zulu']);
  });

  it('keeps the current folder selected and can move back to no folder', () => {
    renderComponent();

    expect(getFolderRadio('Alpha').checked).toBe(true);

    fireEvent.click(screen.getByLabelText('No folder'));

    expect(mocks.bookmarkMock).toHaveBeenCalledWith(status, null);
  });

  it('selects another existing folder', () => {
    renderComponent();

    fireEvent.click(screen.getByLabelText('Zulu'));

    expect(mocks.bookmarkMock).toHaveBeenCalledWith(status, '2');
  });

  it('creates a new folder and bookmarks the status into it', async () => {
    renderComponent();

    fireEvent.change(getNewFolderInput(), {
      target: { value: 'Work' },
    });

    submitNewFolderForm();

    expect(mocks.createBookmarkFolderMock).toHaveBeenCalledWith({
      title: 'Work',
    });

    await waitFor(() => {
      expect(mocks.bookmarkMock).toHaveBeenCalledWith(status, '3');
    });
  });
});
