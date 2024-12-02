import type { ReactElement } from 'react';
import { createContext, useContext, useMemo, useState } from 'react';
import { createPortal } from 'react-dom';

export const ColumnsContext = createContext<{
  tabsBarElement: HTMLElement | null;
  setTabsBarElement: (element: HTMLElement) => void;
  multiColumn: boolean;
}>({
  tabsBarElement: null,
  multiColumn: false,
  setTabsBarElement: () => undefined, // no-op
});

export function useColumnsContext() {
  return useContext(ColumnsContext);
}

export const ButtonInTabsBar: React.FC<{
  children: ReactElement | string | undefined;
}> = ({ children }) => {
  const { multiColumn, tabsBarElement } = useColumnsContext();

  if (multiColumn) {
    return children;
  } else if (!tabsBarElement) {
    return children;
  } else {
    return createPortal(children, tabsBarElement);
  }
};

type ContextValue = React.ContextType<typeof ColumnsContext>;

export const ColumnsContextProvider: React.FC<
  React.PropsWithChildren<{ multiColumn: boolean }>
> = ({ multiColumn, children }) => {
  const [tabsBarElement, setTabsBarElement] =
    useState<ContextValue['tabsBarElement']>(null);

  const contextValue = useMemo<ContextValue>(
    () => ({ multiColumn, tabsBarElement, setTabsBarElement }),
    [multiColumn, tabsBarElement],
  );

  return (
    <ColumnsContext.Provider value={contextValue}>
      {children}
    </ColumnsContext.Provider>
  );
};
