import { isServerFeatureEnabled } from '@/mastodon/utils/environment';

export function EmojiPicker () {
  return import('../../emoji/emoji_picker');
}

export function Compose () {
  return import('../../compose');
}

export function Notifications () {
  return import('../../notifications_v2');
}

export function HomeTimeline () {
  return import('../../home_timeline');
}

export function PublicTimeline () {
  return import('../../public_timeline');
}

export function CommunityTimeline () {
  return import('../../community_timeline');
}

export function Firehose () {
  return import('../../firehose');
}

export function HashtagTimeline () {
  return import('../../hashtag_timeline');
}

export function DirectTimeline() {
  return import('../../direct_timeline');
}

export function ListTimeline () {
  return import('../../list_timeline');
}

export function Lists () {
  return import('../../lists');
}

export function Collections() {
  return import('../../collections').then(
    module => ({default: module.Collections})
  );
}

export function CollectionDetail() {
  return import('../../collections/detail/index').then(
    module => ({default: module.CollectionDetailPage})
  );
}

export function CollectionsEditor() {
  return import('../../collections/editor').then(
    module => ({default: module.CollectionEditorPage})
  );
}

export function Status () {
  return import('../../status');
}

export function GettingStarted () {
  return import('../../getting_started');
}

export function KeyboardShortcuts () {
  return import('../../keyboard_shortcuts');
}

export function PinnedStatuses () {
  return import('../../pinned_statuses');
}

export function AccountTimeline () {
  if (isServerFeatureEnabled('profile_redesign')) {
    return import('../../account_timeline/v2');
  }
  return import('../../account_timeline');
}

export function AccountGallery () {
  return import('../../account_gallery');
}

export function AccountFeatured() {
  return import('../../account_featured');
}

export function AccountAbout() {
  return import('../../account_about')
    .then((module) => ({ default: module.AccountAbout }));
}

export function AccountEdit() {
  return import('../../account_edit')
  .then((module) => ({ default: module.AccountEdit }));
}

export function Followers () {
  return import('../../followers');
}

export function Following () {
  return import('../../following');
}

export function Reblogs () {
  return import('../../reblogs');
}

export function Favourites () {
  return import('../../favourites');
}

export function Quotes () {
  return import('../../quotes');
}

export function FollowRequests () {
  return import('../../follow_requests');
}

export function FavouritedStatuses () {
  return import('../../favourited_statuses');
}

export function FollowedTags () {
  return import('../../followed_tags');
}

export function BookmarkedStatuses () {
  return import('../../bookmarked_statuses');
}

export function Blocks () {
  return import('../../blocks');
}

export function DomainBlocks () {
  return import('../../domain_blocks');
}

export function Mutes () {
  return import('../../mutes');
}

export function MuteModal () {
  return import('../components/mute_modal');
}

export function BlockModal () {
  return import('../components/block_modal');
}

export function DomainBlockModal () {
  return import('../components/domain_block_modal');
}

export function ReportModal () {
  return import('../components/report_modal');
}

export function IgnoreNotificationsModal () {
  return import('../components/ignore_notifications_modal');
}

export function MediaGallery () {
  return import('../../../components/media_gallery');
}

export function Video () {
  return import('../../video');
}

export function EmbedModal () {
  return import('../components/embed_modal');
}

export function ListAdder () {
  return import('../../list_adder');
}

export function Tesseract () {
  return import('tesseract.js');
}

export function Audio () {
  return import('../../audio');
}

export function Directory () {
  return import('../../directory');
}

export function OnboardingProfile () {
  return import('../../onboarding/profile');
}

export function OnboardingFollows () {
  return import('../../onboarding/follows');
}

export function CompareHistoryModal () {
  return import('../components/compare_history_modal');
}

export function Explore () {
  return import('../../explore');
}

export function Search () {
  return import('../../search');
}

export function FilterModal () {
  return import('../components/filter_modal');
}

export function InteractionModal () {
  return import('../../interaction_modal');
}

export function SubscribedLanguagesModal () {
  return import('../../subscribed_languages_modal');
}

export function ClosedRegistrationsModal () {
  return import('../../closed_registrations_modal');
}

export function About () {
  return import('../../about');
}

export function PrivacyPolicy () {
  return import('../../privacy_policy');
}

export function TermsOfService () {
  return import('../../terms_of_service');
}

export function NotificationRequests () {
  return import('../../notifications/requests');
}

export function NotificationRequest () {
  return import('../../notifications/request');
}

export function LinkTimeline () {
  return import('../../link_timeline');
}

export function AnnualReportModal () {
  return import('../../annual_report/modal');
}

export function ListEdit () {
  return import('../../lists/new');
}

export function ListMembers () {
  return import('../../lists/members');
}
