import PropTypes from 'prop-types';
import { useCallback, useEffect, useRef, useState } from 'react';

const emptyComponent = () => null;

const moduleCache = new Map;

const Bundle = ({ fetchComponent, loading: Loading = emptyComponent, error: Error = emptyComponent, renderDelay = 0, children }) => {
  const [resolvedMod, setResolvedMod] = useState(undefined);
  const [forceRender, setForceRender] = useState(false);
  const timestampRef = useRef(null);
  const timeoutRef = useRef(null);

  const loadComponent = useCallback(() => {
    const cachedMod = moduleCache.get(fetchComponent);

    if (fetchComponent === undefined) {
      setResolvedMod(null);
      return;
    }

    if (cachedMod) {
      setResolvedMod(cachedMod.default);
      return;
    }

    setResolvedMod(undefined);

    if (renderDelay !== 0) {
      timestampRef.current = new Date();
      timeoutRef.current = setTimeout(() => setForceRender(true), renderDelay);
    }

    fetchComponent()
      .then((mod) => {
        moduleCache.set(fetchComponent, mod);
        setResolvedMod(mod.default);
      })
      .catch((error) => {
        console.error('Bundle fetching error:', error);
        setResolvedMod(null);
      });
  }, [fetchComponent, setResolvedMod, setForceRender]);

  useEffect(() => {
    loadComponent();

    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    }
  }, [fetchComponent, loadComponent]);

  const elapsed = timestampRef.current ? (new Date() - timestampRef.current) : renderDelay;

  if (resolvedMod === undefined) {
    return (elapsed >= renderDelay || forceRender) ? <Loading /> : null;
  }

  if (resolvedMod === null) {
    return <Error onRetry={loadComponent} />;
  }

  return children(resolvedMod);
};

Bundle.propTypes = {
  fetchComponent: PropTypes.func.isRequired,
  loading: PropTypes.func,
  error: PropTypes.func,
  children: PropTypes.func.isRequired,
  renderDelay: PropTypes.number,
};

export default Bundle;
