_:

let
  noSandbox = _: { __noChroot = true; };
  broken = _: { meta.broken = true; };
in
{
  macpass = _: { setSourceRoot = "sourceRoot=."; };
  docker = noSandbox;
  little-snitch = broken;
}
