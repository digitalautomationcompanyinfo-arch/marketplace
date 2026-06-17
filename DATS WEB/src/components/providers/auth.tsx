import { createContext, useContext, useState, useMemo, useCallback } from "react";
import { AuthProvider as OL, useAuth as t_ } from "react-oidc-context";
import { UserManager as ME, WebStorageStateStore as Xv } from "oidc-client-ts";

const oC = createContext<any>(null);
export const S4 = () => useContext(oC);

export function E4() {
  const { userManager: e } = S4();
  const t = t_();
  const { signoutRedirect: n, removeUser: i, signinRedirect: a } = t;

  const c = useCallback(async () => {
    if (await e.metadataService.getEndSessionEndpoint() != null) {
      await n();
    } else {
      await i();
    }
  }, [e, n, i]);

  const u = useCallback(async () => {
    await a();
  }, [a]);

  return useMemo(() => ({ ...t, signout: c, signin: u }), [t, c, u]);
}

// Rename E4 to useAuth for exporting so other components can use it
export { E4 as useAuth };

function T4({ children, userManagerSettings, authority, client_id, ...a }: any) {
  const [c] = useState(() => new ME({
    ...userManagerSettings,
    authority: userManagerSettings?.authority ?? authority,
    client_id: userManagerSettings?.client_id ?? client_id,
    prompt: userManagerSettings?.prompt ?? "select_account",
    response_type: userManagerSettings?.response_type ?? "code",
    scope: userManagerSettings?.scope ?? "openid profile email offline_access",
    redirect_uri: userManagerSettings?.redirect_uri ?? `${window.location.origin}/auth/callback`,
    post_logout_redirect_uri: userManagerSettings?.post_logout_redirect_uri ?? window.location.origin,
    userStore: userManagerSettings?.userStore ?? new Xv({ store: window.localStorage })
  }));

  return (
    <oC.Provider value={{ userManager: c }}>
      <OL userManager={c} {...a}>
        {children}
      </OL>
    </oC.Provider>
  );
}

export function C4({ children }: any) {
  return (
    <T4
      authority="https://01krtmbp8y08y877g4jncf8cbs.hercules-auth.com"
      client_id="yQdpOfGdSTxOFnlAabGTnsdbWpKLgmFo"
      userManagerSettings={{
        prompt: "select_account",
        response_type: "code",
        scope: "openid profile email offline_access",
        redirect_uri: `${window.location.origin}/auth/callback`
      }}
    >
      {children}
    </T4>
  );
}

export { C4 as AuthProvider };
