{ writeFishApplication, maim, libnotify }:

writeFishApplication {
  name = "maim";
  runtimeInputs = [ maim libnotify ];
  text = builtins.readFile ./maim.fish;
}
