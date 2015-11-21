// Generated by CoffeeScript 1.9.3
"use strict";
!(function($, win, doc) {
  var $doc, $win;
  $doc = $(doc);
  $win = $(win);
  return win.Template = (function() {
    function Template(options) {
      var defaults;
      defaults = {
        cont: ''
      };
      this.opt = $.extend({}, defaults, options);
      this.cont = $(this.opt.cont);
      this.build_content();
      this.controller();
    }

    Template.prototype.build_content = function() {
      var T, results, tpl;
      T = {};
      T.footer = "footer.container-fluid\n	.row\n		.col-xs-12.small\n			p\n				| © ParetoNews 2014&nbsp;&nbsp;&nbsp;\n				a href=\"#\"\n					=t 'footer.blog'\n				| &nbsp;&middot;&nbsp;\n				a href=\"#\"\n					=t 'footer.help'\n				| &nbsp;&middot;&nbsp;\n				a href=\"#\"\n					=t 'footer.faq'\n				| &nbsp;&middot;&nbsp;\n				a href=\"#\"\n					=t 'footer.terms'\n				| &nbsp;&middot;&nbsp;\n				a href=\"#\"\n					=t 'footer.privacy'";
      this.div = $('<div />');
      this.create_tpl('application', ".content = outlet");
      results = [];
      for (tpl in T) {
        results.push(this.create_tpl(tpl, T[tpl]));
      }
      return results;
    };

    Template.prototype.controller = function() {};

    Template.prototype.compile = function(source, data) {
      var template;
      template = Emblem.compile(Handlebars, source);
      return template(data);
    };

    Template.prototype.create_tpl = function(id, source) {
      return $('body').append("<script type='text/x-emblem' id='" + id + "' data-template-name='" + id + "'>" + source + "</script>");
    };

    Template.prototype.destroy = function() {
      this.div.remove();
      return this.div = null;
    };

    return Template;

  })();
})(jQuery, window, document);

//# sourceMappingURL=template.js.map