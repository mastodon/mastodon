import type * as ReactRouterModule from 'react-router';

import { render, screen, fireEvent } from '@/testing/rendering';
import type * as BookmarkFoldersTypedModule from 'mastodon/actions/bookmark_folders_typed';
import type * as StoreModule from 'mastodon/store';

import { ConfirmDeleteBookmarkFolderModal } from '../../ui/components/confirmation_modals/delete_bookmark_folder';

interface DeleteBookmarkFolderAction {
  type: 'bookmarkFolders/delete';
  payload: {
    id: string;
  };
}

type DeleteBookmarkFolderDispatchAction = DeleteBookmarkFolderAction;

const mocks = vi.hoisted(() => ({
  dispatchMock: vi.fn(),
  useAppDispatchMock: vi.fn(),
  useAppSelectorMock: vi.fn(),
  deleteBookmarkFolderMock: vi.fn(),
  pushMock: vi.fn(),
}));

vi.mock('mastodon/store', async () => {
  const actual = await vi.importActual<typeof StoreModule>('mastodon/store');

  return {
    ...actual,
    useAppDispatch: mocks.useAppDispatchMock,
    useAppSelector: mocks.useAppSelectorMock,
  };
});

vi.mock('mastodon/actions/bookmark_folders_typed', async () => {
  const actual = await vi.importActual<typeof BookmarkFoldersTypedModule>(
    'mastodon/actions/bookmark_folders_typed',
  );

  const deleteBookmarkFolder = Object.assign(
    mocks.deleteBookmarkFolderMock,
    actual.deleteBookmarkFolder,
  );

  return {
    ...actual,
    deleteBookmarkFolder,
  };
});

vi.mock('react-router', async () => {
  const actual =
    await vi.importActual<typeof ReactRouterModule>('react-router');

  return {
    ...actual,
    useHistory: () => ({ push: mocks.pushMock }),
  };
});

describe('<ConfirmDeleteBookmarkFolderModal />', () => {
  beforeEach(() => {
    mocks.deleteBookmarkFolderMock.mockImplementation(
      ({ id }: DeleteBookmarkFolderAction['payload']) => ({
        type: 'bookmarkFolders/delete',
        payload: { id },
      }),
    );

    mocks.dispatchMock.mockImplementation(
      (action: DeleteBookmarkFolderDispatchAction) => action,
    );

    mocks.useAppDispatchMock.mockReturnValue(mocks.dispatchMock);
  });

  afterEach(() => {
    vi.clearAllMocks();
  });

  it('dispatches delete and navigates back', () => {
    const onClose = vi.fn();

    render(<ConfirmDeleteBookmarkFolderModal id='42' onClose={onClose} />);

    fireEvent.submit(
      screen
        .getByRole('button', { name: 'Delete' })
        .closest('form') as HTMLFormElement,
    );

    expect(mocks.deleteBookmarkFolderMock).toHaveBeenCalledWith({ id: '42' });
    expect(mocks.pushMock).toHaveBeenCalledWith('/bookmarks/folders');
  });
});
