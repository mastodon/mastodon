export function recoverHashtags (recognizedTags, text) {
  return recognizedTags.map(tag => {
    const re = new RegExp(`(?:^|[^/)\w])#(${tag.name})`, 'i');
    const matched_hashtag = text.match(re);
    return matched_hashtag ? matched_hashtag[1] : null;
  },
  ).filter(x => x !== null);
}
