import { handleNotificationClick, handlePush } from './web_push_notifications';

self.addEventListener('push', handlePush);
self.addEventListener('notificationclick', handleNotificationClick);
