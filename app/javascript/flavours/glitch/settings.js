export default class Settings {

  constructor(keyBase = null) {
    this.keyBase = keyBase;
  }

  generateKey(id) {
    return this.keyBase ? [this.keyBase, `id${id}`].join('.') : id;
  }

  set(id, data) {
    const key = this.generateKey(id);
    try {
      const encodedData = JSON.stringify(data);
      localStorage.setItem(key, encodedData);
      return data;
    } catch (e) {
      return null;
    }
  }

  get(id) {
    const key = this.generateKey(id);
    try {
      const rawData = localStorage.getItem(key);
      return JSON.parse(rawData);
    } catch (e) {
      return null;
    }
  }

  remove(id) {
    const data = this.get(id);
    if (data) {
      const key = this.generateKey(id);
      try {
        localStorage.removeItem(key);
      } catch (e) {
      }
    }
    return data;
  }

}

export const pushNotificationsSetting = new Settings('mastodon_push_notification_data');
export const tagHistory = new Settings('mastodon_tag_history');
