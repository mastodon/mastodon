const IMAGE_EXTENTION = ['.jpg', '.jpeg', '.png'];
const VIDEO_EXTENTION = ['.mp4'];

export function remote_type(item) {
    let remote_url = item.get('remote_url');
    if (item.get('type') === 'unknown' && remote_url) {
        let ext = '.' + remote_url.split('.').pop();
        if (IMAGE_EXTENTION.indexOf(ext) >= 0) {
            return 'image';
        }
        else if (VIDEO_EXTENTION.indexOf(ext) >= 0) {
            return 'video';
        }
    }
    return item.get('type');
};

export function attr_image(item) {
    let image = new Image();
    image.src = item.get('url');
    return image;
};
