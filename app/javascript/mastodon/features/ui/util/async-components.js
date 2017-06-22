import { store } from '../../../containers/mastodon';
import { injectAsyncReducer } from '../../../store/configureStore';

export function Compose () {
  return Promise.all([
    import(/* webpackChunkName: "features/compose" */'../../compose'),
    import(/* webpackChunkName: "reducers/compose" */'../../../reducers/compose'),
    import(/* webpackChunkName: "reducers/media_attachments" */'../../../reducers/media_attachments'),
    import(/* webpackChunkName: "reducers/search" */'../../../reducers/search'),
  ]).then(([component, composeReducer, mediaAttachmentsReducer, searchReducer]) => {
    injectAsyncReducer(store, 'compose', composeReducer.default);
    injectAsyncReducer(store, 'media_attachments', mediaAttachmentsReducer.default);
    injectAsyncReducer(store, 'search', searchReducer.default);

    return component;
  });
}

export function Notifications () {
  return Promise.all([
    import(/* webpackChunkName: "features/notifications" */'../../notifications'),
    import(/* webpackChunkName: "reducers/notifications" */'../../../reducers/notifications'),
  ]).then(([component, notificationsReducer]) => {
    injectAsyncReducer(store, 'notifications', notificationsReducer.default);

    return component;
  });
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

export function Report () {
  return import(/* webpackChunkName: "features/report" */'../../report');
}

