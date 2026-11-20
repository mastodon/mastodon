import { useIdentity } from '@/mastodon/identity_context';
import { profileFeedAccess } from '@/mastodon/initial_state';

/**
 * Whether the posts listed on profiles are restricted to logged-in users by
 * the server (see the `profile_feed_access` admin setting) and the current
 * visitor is not logged in.
 */
export function useProfileFeedRequiresSignIn(): boolean {
  const { signedIn } = useIdentity();

  return !signedIn && profileFeedAccess === 'authenticated';
}
