// Generated by CoffeeScript 1.9.3
"use strict";
!(function($, win, doc) {
  var $doc, $win;
  $doc = $(doc);
  $win = $(win);
  win.editor = win.viewer = null;
  win.system = system2;
  win.system.reload('autosave');
  $win.load(function() {
    win.Theme = win.ThemeSerif;
    win.viewer = new Viewer({
      div: 'canvas'
    });
    win.modelview = new ModelWebViewEditable({
      div: 'canvas',
      model: system
    });
    win.editor = new Editor(system);
    win.editor.edit(system.root);
    return win.editor.load_settings();
  });
  return win.addEventListener("message", function(event) {
    if (event.source !== win) {
      return;
    }
    if (event.data.type) {
      if (event.data.type === "SAVE") {
        return win.postMessage({
          type: "DATA",
          system: system.serialize()
        }, "*");
      } else if (event.data.type === "LOAD") {
        return editor.load_file(event.data.system);
      }
    }
  }, false);
})(jQuery, window, document);

//# sourceMappingURL=app.js.map