{
  lib,
  stdenv,
  git,
}:

(git.override {
  osxkeychainSupport = false;
  sendEmailSupport = true;
  withSsh = true;
  withLibsecret = !stdenv.hostPlatform.isDarwin;
}).overrideAttrs
  (old: {
    makeFlags =
      old.makeFlags
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        # NOTE: Not sure why /etc/gitconfig is ignored on Darwin.
        "sysconfdir=/etc"
      ];
  })
