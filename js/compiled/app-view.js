// Generated by CoffeeScript 1.9.3
"use strict";
!(function($, win, doc) {
  var $doc, $win;
  $doc = $(doc);
  $win = $(win);
  win.system = system7;
  return $win.load(function() {
    win.Theme = win.ThemeSerif;
    win.viewer = new Viewer({
      div: 'canvas'
    });
    return win.modelview = new ModelWebView({
      div: 'canvas',
      model: system
    });
  });
})(jQuery, window, document);

//# sourceMappingURL=app-view.js.map
