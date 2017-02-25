import emojione from 'emojione';

emojione.imageType    = 'png';
emojione.sprites      = false;
emojione.imagePathPNG = '/emoji/';

export default function emojify(text) {
  return emojione.toImage(text);
};
