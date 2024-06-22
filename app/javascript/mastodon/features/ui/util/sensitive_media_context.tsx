import { createContext, useContext, useMemo } from 'react';

export const SensitiveMediaContext = createContext<{
  hideMediaByDefault: boolean;
}>({
  hideMediaByDefault: false,
});

export function useSensitiveMediaContext() {
  return useContext(SensitiveMediaContext);
}

type ContextValue = React.ContextType<typeof SensitiveMediaContext>;

export const SensitiveMediaContextProvider: React.FC<
  React.PropsWithChildren<{ hideMediaByDefault: boolean }>
> = ({ hideMediaByDefault, children }) => {
  const contextValue = useMemo<ContextValue>(
    () => ({ hideMediaByDefault }),
    [hideMediaByDefault],
  );

  return (
    <SensitiveMediaContext.Provider value={contextValue}>
      {children}
    </SensitiveMediaContext.Provider>
  );
};
