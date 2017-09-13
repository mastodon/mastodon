export function EmojiPicker () {
  return import(/* webpackChunkName: "emojione_picker" */'emojione-picker');
}

export function Compose () {
  return import(/* webpackChunkName: "features/compose" */'../../compose');
}

export function Notifications () {
  return import(/* webpackChunkName: "features/notifications" */'../../notifications');
}

export function HomeTimeline () {
  return import(/* webpackChunkName: "features/home_timeline" */'../../home_timeline');
}

export function PublicTimeline () {
  return import(/* webpackChunkName: "features/public_timeline" */'../../public_timeline');
}

export function CommunityTimeline () {
  return import(/* webpackChunkName: "features/community_timeline" */'../../community_timeline');
}

export function HashtagTimeline () {
  return import(/* webpackChunkName: "features/hashtag_timeline" */'../../hashtag_timeline');
}

export function Status () {
  return import(/* webpackChunkName: "features/status" */'../../status');
}

export function GettingStarted () {
  return import(/* webpackChunkName: "features/getting_started" */'../../getting_started');
}

export function PinnedStatuses () {
  return import(/* webpackChunkName: "features/pinned_statuses" */'../../pinned_statuses');
}

export function AccountTimeline () {
  return import(/* webpackChunkName: "features/account_timeline" */'../../account_timeline');
}

export function AccountGallery () {
  return import(/* webpackChunkName: "features/account_gallery" */'../../account_gallery');
}

export function Followers () {
  return import(/* webpackChunkName: "features/followers" */'../../followers');
}

export function Following () {
  return import(/* webpackChunkName: "features/following" */'../../following');
}

export function Reblogs () {
  return import(/* webpackChunkName: "features/reblogs" */'../../reblogs');
}

export function Favourites () {
  return import(/* webpackChunkName: "features/favourites" */'../../favourites');
}

export function FollowRequests () {
  return import(/* webpackChunkName: "features/follow_requests" */'../../follow_requests');
}

export function GenericNotFound () {
  return import(/* webpackChunkName: "features/generic_not_found" */'../../generic_not_found');
}

export function FavouritedStatuses () {
  return import(/* webpackChunkName: "features/favourited_statuses" */'../../favourited_statuses');
}

export function Blocks () {
  return import(/* webpackChunkName: "features/blocks" */'../../blocks');
}

export function Mutes () {
  return import(/* webpackChunkName: "features/mutes" */'../../mutes');
}

export function OnboardingModal () {
  return import(/* webpackChunkName: "modals/onboarding_modal" */'../components/onboarding_modal');
}

export function ReportModal () {
  return import(/* webpackChunkName: "modals/report_modal" */'../components/report_modal');
}

export function MediaGallery () {
  return import(/* webpackChunkName: "status/media_gallery" */'../../../components/media_gallery');
}

export function VideoPlayer () {
  return import(/* webpackChunkName: "status/video_player" */'../../../components/video_player');
}

export function EmbedModal () {
  return import(/* webpackChunkName: "modals/embed_modal" */'../components/embed_modal');
}
