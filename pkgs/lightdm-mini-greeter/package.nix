{ origin, fetchFromGitHub }:

origin.overrideAttrs (_: rec {
  version = "1bd55f4fa763277dc2680c8e8c49f1e3862b3337";
  src = fetchFromGitHub {
    owner = "prikhi";
    repo = "lightdm-mini-greeter";
    rev = version;
    hash = "sha256-thfjJm0wAfCsLX4/B1OoLkEqpcEbltJhrAxtK5YHcHU=";
  };
})
