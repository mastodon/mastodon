import { useCallback, useEffect, useState } from 'react';

import { isFulfilled } from '@reduxjs/toolkit';

import {
  featureHashtag,
  fetchHashtag,
  followHashtag,
  unfeatureHashtag,
  unfollowHashtag,
} from '../actions/tags_typed';
import type { ApiHashtagJSON } from '../api_types/tags';
import { useIdentity } from '../identity_context';
import { useAppDispatch } from '../store';

export function useHashtag(tagId?: string) {
  const dispatch = useAppDispatch();
  const [tag, setTag] = useState<ApiHashtagJSON>();

  useEffect(() => {
    if (!tagId) {
      return;
    }
    void dispatch(fetchHashtag({ tagId })).then((result) => {
      if (isFulfilled(result)) {
        setTag(result.payload);
      }

      return '';
    });
  }, [dispatch, tagId, setTag]);

  const toggleFeature = useCallback(() => {
    if (!tag || !tagId) {
      return;
    }
    if (tag.featuring) {
      void dispatch(unfeatureHashtag({ tagId })).then((result) => {
        if (isFulfilled(result)) {
          setTag(result.payload);
        }

        return '';
      });
    } else {
      void dispatch(featureHashtag({ tagId })).then((result) => {
        if (isFulfilled(result)) {
          setTag(result.payload);
        }

        return '';
      });
    }
  }, [dispatch, tag, tagId]);

  const { signedIn } = useIdentity();

  const toggleFollow = useCallback(() => {
    if (!signedIn || !tag || !tagId) {
      return;
    }

    if (tag.following) {
      setTag((hashtag) => hashtag && { ...hashtag, following: false });

      void dispatch(unfollowHashtag({ tagId })).then((result) => {
        if (isFulfilled(result)) {
          setTag(result.payload);
        }

        return '';
      });
    } else {
      setTag((hashtag) => hashtag && { ...hashtag, following: true });

      void dispatch(followHashtag({ tagId })).then((result) => {
        if (isFulfilled(result)) {
          setTag(result.payload);
        }

        return '';
      });
    }
  }, [dispatch, signedIn, tag, tagId]);

  return { tag, toggleFollow, toggleFeature };
}
