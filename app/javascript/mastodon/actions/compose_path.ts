export function isStandaloneComposePath(pathname: string): boolean {
  const normalized = pathname.startsWith('/deck/')
    ? pathname.slice('/deck'.length)
    : pathname;

  return normalized === '/publish' || normalized === '/statuses/new';
}
