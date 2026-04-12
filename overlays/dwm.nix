final: prev: {
  dwm = prev.dwm.overrideAttrs (oldAttrs: {
    src = ../config/dwm;
    patches = [];
  });
}
