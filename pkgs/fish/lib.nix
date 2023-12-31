/*
  Fish counterparts of Bash script builders defined in
  <nixpkgs>/pkgs/build-support/trivial-builders/default.nix.
*/
{ lib, writeTextFile, fish }:

{
  /*
    Writes a Fish script and checks its syntax.
    Automatically includes interpreter above the contents passed.
  */
  writeFishScript = name: text:
    writeTextFile {
      inherit name;
      executable = true;
      text = ''
        #!${fish}/bin/fish
        ${text}
      '';
      checkPhase = ''
        ${fish}/bin/fish -n "$target"
      '';
    };

  /*
    Writes an executable Fish script to /nix/store/<store path>/bin/<name>
    and checks its syntax.
    Automatically includes interpreter above the contents passed.
  */
  writeFishScriptBin = name: text:
    writeTextFile {
      inherit name;
      executable = true;
      destination = "/bin/${name}";
      text = ''
        #!${fish}/bin/fish
        ${text}
      '';
      checkPhase = ''
        ${fish}/bin/fish -n "$target"
      '';
      meta.mainProgram = name;
    };

  /*
    Writes an executable Fish script to /nix/store/<store path>/bin/<name> and
    checks its syntax.
    Individual checks can be foregone by putting them in the excludeShellChecks
    list, e.g. [ "SC2016" ].
    Automatically handles creation of PATH based on runtimeInputs
  */
  writeFishApplication = {
    name,
    text,
    runtimeInputs ? [],
    meta ? {},
    checkPhase ? null,
    excludeShellChecks ? []
  }:
    writeTextFile {
      inherit name meta;
      executable = true;
      destination = "/bin/${name}";
      allowSubstitutes = true;
      preferLocalBuild = false;
      text = ''
        #!${fish}/bin/fish
      '' + lib.optionalString (runtimeInputs != []) ''

        fish_add_path --path (string split : "${lib.makeBinPath runtimeInputs}")
      '' + ''

        ${text}
      '';
      checkPhase =
        if checkPhase == null
        then ''
          runHook preCheck
          ${fish}/bin/fish -n "$target"
          runHook postCheck
        ''
        else checkPhase;
    };
}
