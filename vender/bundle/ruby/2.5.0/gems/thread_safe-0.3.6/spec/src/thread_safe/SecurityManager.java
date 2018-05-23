package thread_safe;

import java.security.Permission;
import java.util.ArrayList;
import java.util.List;

public class SecurityManager extends java.lang.SecurityManager {
  private final List<Permission> deniedPermissions =
      new ArrayList<Permission>();

  @Override
  public void checkPermission(Permission p) {
    if (deniedPermissions.contains(p)) {
      throw new SecurityException("Denied!");
    }
  }

  public void deny(Permission p) {
    deniedPermissions.add(p);
  }
}
