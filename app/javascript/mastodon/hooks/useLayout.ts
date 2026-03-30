import type { LayoutType } from '../is_mobile';
import { useAppSelector } from '../store';

export const useLayout = () => {
  const layout = useAppSelector(
    (state) => state.meta.get('layout') as LayoutType,
  );

  return {
    singleColumn: layout === 'single-column' || layout === 'mobile',
    multiColumn: layout === 'multi-column',
    layout,
  };
};
