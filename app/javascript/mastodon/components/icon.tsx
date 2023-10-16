import classNames from 'classnames';

import { ReactComponent as AddIcon } from '@material-design-icons/svg/filled/add.svg';
import { ReactComponent as AlternateEmailIcon } from '@material-design-icons/svg/filled/alternate_email.svg';
import { ReactComponent as ArrowDropDownIcon } from '@material-design-icons/svg/filled/arrow_drop_down.svg';
import { ReactComponent as AudiotrackIcon } from '@material-design-icons/svg/filled/audiotrack.svg';
import { ReactComponent as BlockIcon } from '@material-design-icons/svg/filled/block.svg';
import { ReactComponent as BookmarkIcon } from '@material-design-icons/svg/filled/bookmark.svg';
import { ReactComponent as BookmarksIcon } from '@material-design-icons/svg/filled/bookmarks.svg';
import { ReactComponent as CancelIcon } from '@material-design-icons/svg/filled/cancel.svg';
import { ReactComponent as CheckIcon } from '@material-design-icons/svg/filled/check.svg';
import { ReactComponent as CheckBoxOutlineBlankIcon } from '@material-design-icons/svg/filled/check_box_outline_blank.svg';
import { ReactComponent as CloseIcon } from '@material-design-icons/svg/filled/close.svg';
import { ReactComponent as ContentCopyIcon } from '@material-design-icons/svg/filled/content_copy.svg';
import { ReactComponent as DeleteIcon } from '@material-design-icons/svg/filled/delete.svg';
import { ReactComponent as DeleteForeverIcon } from '@material-design-icons/svg/filled/delete_forever.svg';
import { ReactComponent as DescriptionIcon } from '@material-design-icons/svg/filled/description.svg';
import { ReactComponent as DoneAllIcon } from '@material-design-icons/svg/filled/done_all.svg';
import { ReactComponent as DownloadIcon } from '@material-design-icons/svg/filled/download.svg';
import { ReactComponent as EditIcon } from '@material-design-icons/svg/filled/edit.svg';
import { ReactComponent as EditNoteIcon } from '@material-design-icons/svg/filled/edit_note.svg';
import { ReactComponent as FindInPageIcon } from '@material-design-icons/svg/filled/find_in_page.svg';
import { ReactComponent as FlagIcon } from '@material-design-icons/svg/filled/flag.svg';
import { ReactComponent as FullscreenIcon } from '@material-design-icons/svg/filled/fullscreen.svg';
import { ReactComponent as FullscreenExitIcon } from '@material-design-icons/svg/filled/fullscreen_exit.svg';
import { ReactComponent as HomeIcon } from '@material-design-icons/svg/filled/home.svg';
import { ReactComponent as InfoIcon } from '@material-design-icons/svg/filled/info.svg';
import { ReactComponent as ListAltIcon } from '@material-design-icons/svg/filled/list_alt.svg';
import { ReactComponent as LogoutIcon } from '@material-design-icons/svg/filled/logout.svg';
import { ReactComponent as MenuIcon } from '@material-design-icons/svg/filled/menu.svg';
import { ReactComponent as NotificationsIcon } from '@material-design-icons/svg/filled/notifications.svg';
import { ReactComponent as OpenInNewIcon } from '@material-design-icons/svg/filled/open_in_new.svg';
import { ReactComponent as PauseIcon } from '@material-design-icons/svg/filled/pause.svg';
import { ReactComponent as PeopleIcon } from '@material-design-icons/svg/filled/people.svg';
import { ReactComponent as PersonIcon } from '@material-design-icons/svg/filled/person.svg';
import { ReactComponent as PersonAddIcon } from '@material-design-icons/svg/filled/person_add.svg';
import { ReactComponent as PlayArrowIcon } from '@material-design-icons/svg/filled/play_arrow.svg';
import { ReactComponent as RefreshIcon } from '@material-design-icons/svg/filled/refresh.svg';
import { ReactComponent as RepeatIcon } from '@material-design-icons/svg/filled/repeat.svg';
import { ReactComponent as ReplyIcon } from '@material-design-icons/svg/filled/reply.svg';
import { ReactComponent as ReplyAllIcon } from '@material-design-icons/svg/filled/reply_all.svg';
import { ReactComponent as SearchIcon } from '@material-design-icons/svg/filled/search.svg';
import { ReactComponent as SettingsIcon } from '@material-design-icons/svg/filled/settings.svg';
import { ReactComponent as StarIcon } from '@material-design-icons/svg/filled/star.svg';
import { ReactComponent as TagIcon } from '@material-design-icons/svg/filled/tag.svg';
import { ReactComponent as TuneIcon } from '@material-design-icons/svg/filled/tune.svg';
import { ReactComponent as UploadFileIcon } from '@material-design-icons/svg/filled/upload_file.svg';
import { ReactComponent as VisibilityIcon } from '@material-design-icons/svg/filled/visibility.svg';
import { ReactComponent as VisibilityOffIcon } from '@material-design-icons/svg/filled/visibility_off.svg';
import { ReactComponent as VolumeOffIcon } from '@material-design-icons/svg/filled/volume_off.svg';
import { ReactComponent as VolumeUpIcon } from '@material-design-icons/svg/filled/volume_up.svg';
import { ReactComponent as AddPhotoAlternateIcon } from '@material-design-icons/svg/outlined/add_photo_alternate.svg';
import { ReactComponent as InsertChartIcon } from '@material-design-icons/svg/outlined/insert_chart.svg';
import { ReactComponent as LockIcon } from '@material-design-icons/svg/outlined/lock.svg';
import { ReactComponent as LockOpenIcon } from '@material-design-icons/svg/outlined/lock_open.svg';
import { ReactComponent as PublicIcon } from '@material-design-icons/svg/outlined/public.svg';
import { ReactComponent as RectangleIcon } from '@material-design-icons/svg/outlined/rectangle.svg';

interface Props extends React.SVGProps<SVGSVGElement> {
  children?: never;
  id: string;
  icon?: React.FC<React.SVGProps<SVGSVGElement>>;
}

type IconMap = Record<string, React.FC<{ className?: string }> | undefined>;

const iconIdMap: IconMap = {
  'arrows-alt': FullscreenIcon,
  at: AlternateEmailIcon,
  ban: BlockIcon,
  bars: MenuIcon,
  bell: NotificationsIcon,
  bookmark: BookmarkIcon,
  bookmarks: BookmarksIcon,
  'caret-down': ArrowDropDownIcon,
  check: CheckIcon,
  close: CloseIcon,
  cog: SettingsIcon,
  compress: FullscreenExitIcon,
  copy: ContentCopyIcon,
  'done-all': DoneAllIcon,
  download: DownloadIcon,
  eraser: DeleteForeverIcon,
  expand: RectangleIcon,
  'external-link': OpenInNewIcon,
  eye: VisibilityIcon,
  'eye-slash': VisibilityOffIcon,
  'file-text': DescriptionIcon,
  'file-text-o': DescriptionIcon,
  flag: FlagIcon,
  globe: PublicIcon,
  hashtag: TagIcon,
  home: HomeIcon,
  'info-circle': InfoIcon,
  'list-ul': ListAltIcon,
  lock: LockIcon,
  music: AudiotrackIcon,
  paperclip: AddPhotoAlternateIcon,
  pause: PauseIcon,
  pencil: EditIcon,
  'pencil-square-o': EditNoteIcon,
  play: PlayArrowIcon,
  plus: AddIcon,
  'quote-right': FindInPageIcon,
  refresh: RefreshIcon,
  reply: ReplyIcon,
  'reply-all': ReplyAllIcon,
  retweet: RepeatIcon,
  search: SearchIcon,
  'sign-out': LogoutIcon,
  sliders: TuneIcon,
  star: StarIcon,
  tasks: InsertChartIcon,
  times: CloseIcon,
  'times-circle': CancelIcon,
  trash: DeleteIcon,
  unlock: LockOpenIcon,
  upload: UploadFileIcon,
  user: PersonIcon,
  'user-plus': PersonAddIcon,
  users: PeopleIcon,
  'volume-off': VolumeOffIcon,
  'volume-up': VolumeUpIcon,
};

export const Icon: React.FC<Props> = ({ id, className, ...other }) => {
  if ('icon' in other && other.icon) {
    const IconComponent = other.icon;

    return (
      <IconComponent
        className={classNames('icon', `icon-${id}`, className)}
        id={id}
        {...other}
      />
    );
  }

  if (!iconIdMap[id]) {
    console.warn('Missing icon', id);
  }

  const SVG = iconIdMap[id] ?? CheckBoxOutlineBlankIcon;

  return (
    <SVG className={classNames('icon', `icon-${id}`, className)} {...other} />
  );
};
