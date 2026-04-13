final: prev: {
  slstatus = prev.slstatus.overrideAttrs (oldAttrs: {
    src = ../config/slstatus;
    patches = [];
  });
}
