#define EV_STANDALONE /* keeps ev from requiring config.h */

#ifdef _WIN32
#define EV_SELECT_IS_WINSOCKET 1
#define EV_USE_MONOTONIC 0
#define EV_USE_REALTIME 0
#endif

#include "../libev/ev.h"