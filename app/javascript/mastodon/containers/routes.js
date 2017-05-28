import UI from '../features/ui';

const loadRoute = (cb) => module => cb(null, module.default);

export default [
  {
    path: '/',
    component: UI,
    // <IndexRedirect to='/getting-started' />
    childRoutes: [
      {
        path: 'getting-started',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/getting_started" */ '../features/getting_started').then(loadRoute(cb));
        },
      },
      {
        path: 'timelines/home',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/home_timeline" */ '../features/home_timeline').then(loadRoute(cb));
        },
      },
      {
        path: 'timelines/public',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/public_timeline" */ '../features/public_timeline').then(loadRoute(cb));
        },
      },
      {
        path: 'timelines/public/local',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/community_timeline" */ '../features/community_timeline').then(loadRoute(cb));
        },
      },
      {
        path: 'timelines/tag/:id',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/hashtag_timeline" */ '../features/hashtag_timeline').then(loadRoute(cb));
        },
      },

      {
        path: 'notifications',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/notifications" */ '../features/notifications').then(loadRoute(cb));
        },
      },
      {
        path: 'favourites',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/favourited_statuses" */ '../features/favourited_statuses').then(loadRoute(cb));
        },
      },

      {
        path: 'statuses/new',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/compose" */ '../features/compose').then(loadRoute(cb));
        },
      },
      {
        path: 'statuses/:statusId',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/status" */ '../features/status').then(loadRoute(cb));
        },
      },
      {
        path: 'statuses/:statusId/reblogs',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/reblogs" */ '../features/reblogs').then(loadRoute(cb));
        },
      },
      {
        path: 'statuses/:statusId/favourites',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/favourites" */ '../features/favourites').then(loadRoute(cb));
        },
      },

      {
        path: 'accounts/:accountId',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/account_timeline" */ '../features/account_timeline').then(loadRoute(cb));
        },
      },
      {
        path: 'accounts/:accountId/followers',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/followers" */ '../features/followers').then(loadRoute(cb));
        },
      },
      {
        path: 'accounts/:accountId/following',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/following" */ '../features/following').then(loadRoute(cb));
        },
      },
      {
        path: 'accounts/:accountId/media',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/account_gallery" */ '../features/account_gallery').then(loadRoute(cb));
        },
      },

      {
        path: 'follow_requests',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/follow_requests" */ '../features/follow_requests').then(loadRoute(cb));
        },
      },
      {
        path: 'blocks',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/blocks" */ '../features/blocks').then(loadRoute(cb));
        },
      },
      {
        path: 'mutes',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/mutes" */ '../features/mutes').then(loadRoute(cb));
        },
      },
      {
        path: 'report',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/report" */ '../features/report').then(loadRoute(cb));
        },
      },

      {
        path: '*',
        getComponent: (location, cb) => {
          import(/* webpackChunkName: "features/generic_not_found" */ '../features/generic_not_found').then(loadRoute(cb));
        },
      },
    ],
  },
];
