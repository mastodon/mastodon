import api from 'mastodon/api';

export async function logOut() {
  try {
    const response = await api(false).delete<{ redirect_to?: string }>(
      '/auth/sign_out',
      { headers: { Accept: 'application/json' }, withCredentials: true },
    );

    if (response.status === 200 && response.data.redirect_to)
      window.location.href = response.data.redirect_to;
    else
      console.error(
        'Failed to log out, got an unexpected non-redirect response from the server',
        response,
      );
  } catch (error) {
    console.error('Failed to log out, response was an error', error);
  }
}
