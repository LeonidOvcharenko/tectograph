// Generated by CoffeeScript 1.9.3
"use strict";
var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

!(function($, win, doc) {
  var $doc, $win;
  $doc = $(doc);
  $win = $(win);
  win.TEXTrender = (function() {
    function TEXTrender(options) {
      var defaults;
      defaults = {
        model: {}
      };
      this.opt = $.extend({}, defaults, options);
      this.model = this.opt.model;
      this.build_content();
    }

    TEXTrender.prototype.build_content = function() {
      return this.render();
    };

    TEXTrender.prototype.render = function() {
      var model, system;
      model = this.model[this.model.root];
      system = new TEXTElement({
        id: this.model.root,
        level: 0,
        model: model
      });
      return system.render();
    };

    return TEXTrender;

  })();
  win.XObj = (function() {
    function XObj(options) {
      var defaults;
      defaults = {
        model: {}
      };
      this.opt = $.extend({}, defaults, options);
      this.model = this.opt.model;
      this.level = this.opt.level;
      this.indent = this.make_indent(this.level);
    }

    XObj.prototype.render = function() {
      return model.title;
    };

    XObj.prototype.make_indent = function(tabs) {
      var i, indent, k, ref;
      indent = '';
      for (i = k = 0, ref = tabs; 0 <= ref ? k < ref : k > ref; i = 0 <= ref ? ++k : --k) {
        indent += '  ';
      }
      return indent;
    };

    return XObj;

  })();
  win.TEXTElement = (function(superClass) {
    extend(TEXTElement, superClass);

    function TEXTElement(options) {
      TEXTElement.__super__.constructor.call(this, options);
    }

    TEXTElement.prototype.render = function() {
      var t;
      t = '';
      t += this.indent + '- ' + (this.model.title || '');
      if (this.model.link && this.model.link.url) {
        t += '\n' + this.indent + '[' + this.model.link.url + ']';
      }
      if (this.model.description) {
        t += '\n' + this.indent + '  ' + this.model.description.replace(/\n/g, '\n' + this.indent + '  ');
      }
      if (this.model.picture && this.model.picture.url) {
        t += '\n' + this.indent + 'Илл.: ' + this.model.picture.url;
      }
      if (this.model.structure) {
        t += this.render_structure();
      }
      return t;
    };

    TEXTElement.prototype.render_structure = function(x, y, w, ready) {
      this.structure = new TEXTStructure({
        model: this.model,
        level: this.level
      });
      return this.structure.render();
    };

    return TEXTElement;

  })(XObj);
  win.TEXTStructure = (function(superClass) {
    extend(TEXTStructure, superClass);

    function TEXTStructure(options) {
      TEXTStructure.__super__.constructor.call(this, options);
    }

    TEXTStructure.prototype.render = function() {
      var relations, t;
      t = '';
      relations = false;
      this.model.each_element((function(_this) {
        return function(model, i) {
          var j, k, len, ref, rel, results;
          t += '\n' + _this.render_element(model);
          ref = _this.model.matrix[i];
          results = [];
          for (j = k = 0, len = ref.length; k < len; j = ++k) {
            rel = ref[j];
            if (j === i || !rel || !_this.model.system[rel]) {
              continue;
            }
            results.push(t += '\n' + _this.render_element(_this.model.system[rel]));
          }
          return results;
        };
      })(this));
      return t;
    };

    TEXTStructure.prototype.render_element = function(model) {
      var element;
      element = new TEXTElement({
        id: model.id,
        model: model,
        level: this.level + 1
      });
      return element.render();
    };

    return TEXTStructure;

  })(XObj);
  win.XMLrender = (function(superClass) {
    extend(XMLrender, superClass);

    function XMLrender(options) {
      XMLrender.__super__.constructor.call(this, options);
    }

    XMLrender.prototype.render = function() {
      var model, system;
      model = this.model[this.model.root];
      system = new XMLElement({
        id: this.model.root,
        level: 0,
        type: 'element',
        model: model
      });
      return '<?xml version="1.0" ?>\n<model version="2014.11.29">\n' + system.render() + '\n</model>';
    };

    return XMLrender;

  })(TEXTrender);
  win.XMLElement = (function(superClass) {
    extend(XMLElement, superClass);

    function XMLElement(options) {
      XMLElement.__super__.constructor.call(this, options);
      this.indent = this.make_indent(this.level + 1);
      this.indent2 = this.make_indent(this.level + 2);
    }

    XMLElement.prototype.render = function() {
      var t;
      t = this.indent + '<object type="' + this.opt.type + '">';
      if (this.model.title) {
        t += '\n' + this.indent2 + '<title>' + $.escape(this.model.title || '') + '</title>';
      }
      if (this.model.link && this.model.link.url) {
        t += '\n' + this.indent2 + '<link>' + this.model.link.url + '</link>';
      }
      if (this.model.description) {
        t += '\n' + this.indent2 + '<description>' + $.escape(this.model.description) + '</description>';
      }
      if (this.model.picture && this.model.picture.url) {
        t += '\n' + this.indent2 + '<media src="' + this.model.picture.url + '" type="' + (this.model.picture.video ? 'video' : 'image') + '" />';
      }
      if (this.model.structure) {
        t += this.render_structure();
      }
      return t + '\n' + this.indent + '</object>';
    };

    XMLElement.prototype.render_structure = function(x, y, w, ready) {
      this.structure = new XMLStructure({
        model: this.model,
        level: this.level + 1
      });
      return this.structure.render();
    };

    return XMLElement;

  })(XObj);
  win.XMLStructure = (function(superClass) {
    extend(XMLStructure, superClass);

    function XMLStructure(options) {
      XMLStructure.__super__.constructor.call(this, options);
      this.indent = this.make_indent(this.level + 1);
    }

    XMLStructure.prototype.render = function() {
      var relations, t;
      t = '\n' + this.indent + '<structure type="' + this.model.structure + '">';
      relations = false;
      this.model.each_element((function(_this) {
        return function(model, i) {
          var j, k, len, ref, rel, results;
          t += '\n' + _this.render_element(model, 'element');
          ref = _this.model.matrix[i];
          results = [];
          for (j = k = 0, len = ref.length; k < len; j = ++k) {
            rel = ref[j];
            if (j === i || !rel || !_this.model.system[rel]) {
              continue;
            }
            results.push(t += '\n' + _this.render_element(_this.model.system[rel], 'relation'));
          }
          return results;
        };
      })(this));
      return t + '\n' + this.indent + '</structure>';
    };

    XMLStructure.prototype.render_element = function(model, type) {
      var element;
      element = new XMLElement({
        id: model.id,
        model: model,
        type: type,
        level: this.level + 1
      });
      return element.render();
    };

    return XMLStructure;

  })(XObj);
  win.HTMLrender = (function(superClass) {
    extend(HTMLrender, superClass);

    function HTMLrender(options) {
      HTMLrender.__super__.constructor.call(this, options);
    }

    HTMLrender.prototype.render = function() {
      var model, system;
      model = this.model[this.model.root];
      system = new HTMLElement({
        id: this.model.root,
        level: 0,
        type: 'element',
        model: model
      });
      return '<ul>' + system.render() + '</ul>';
    };

    return HTMLrender;

  })(TEXTrender);
  win.HTMLElement = (function(superClass) {
    extend(HTMLElement, superClass);

    function HTMLElement(options) {
      HTMLElement.__super__.constructor.call(this, options);
      if (!this.opt.tag) {
        this.opt.tag = 'li';
      }
    }

    HTMLElement.prototype.render = function() {
      var t;
      t = '<' + this.opt.tag + ' class="' + this.opt.type + ' level-' + this.level + '">';
      if (this.model.title) {
        t += '<h4>' + $.escape(this.model.title || '') + '</h4>';
      }
      if (this.model.link && this.model.link.url) {
        t += '<a href="' + this.model.link.url + '">' + this.model.link.url + '</a>';
      }
      if (this.model.description) {
        t += '<p>' + $.escape(this.model.description).replace(/\n/g, '<br />') + '</p>';
      }
      if (this.model.picture && this.model.picture.url) {
        if (this.model.picture.video) {
          t += this.model.picture.video + '<a href="' + this.model.picture.url + '">Video</a>';
        } else {
          t += '<img src="' + this.model.picture.url + '" />';
        }
      }
      if (this.model.structure) {
        t += this.render_structure();
      }
      return t + '</' + this.opt.tag + '>';
    };

    HTMLElement.prototype.render_structure = function(x, y, w, ready) {
      this.structure = new HTMLStructure({
        model: this.model,
        level: this.level
      });
      return this.structure.render();
    };

    return HTMLElement;

  })(XObj);
  return win.HTMLStructure = (function(superClass) {
    extend(HTMLStructure, superClass);

    function HTMLStructure(options) {
      HTMLStructure.__super__.constructor.call(this, options);
    }

    HTMLStructure.prototype.render = function() {
      var ref;
      if ((ref = this.model.structure) === 'graph' || ref === 'matrix') {
        return this.render_table();
      } else {
        return this.render_list();
      }
    };

    HTMLStructure.prototype.render_table = function() {
      var t;
      t = '<table class="matrix"><tbody>';
      this.model.each_element((function(_this) {
        return function(model, i) {
          var j, k, len, ref, rel, type;
          t += '<tr>';
          ref = _this.model.matrix[i];
          for (j = k = 0, len = ref.length; k < len; j = ++k) {
            rel = ref[j];
            if (rel && _this.model.system[rel]) {
              type = i === j ? 'element' : 'relation';
              t += _this.render_element(_this.model.system[rel], type, 'td');
            } else {
              t += '<td></td>';
            }
          }
          return t += '</tr>';
        };
      })(this));
      return t + '</tbody></table>';
    };

    HTMLStructure.prototype.render_list = function() {
      var relations, t;
      t = '<ul data-type="' + this.model.structure + '">';
      relations = false;
      this.model.each_element((function(_this) {
        return function(model, i) {
          var j, k, len, ref, rel, results;
          t += _this.render_element(model, 'element', 'li');
          ref = _this.model.matrix[i];
          results = [];
          for (j = k = 0, len = ref.length; k < len; j = ++k) {
            rel = ref[j];
            if (j === i || !rel || !_this.model.system[rel]) {
              continue;
            }
            results.push(t += _this.render_element(_this.model.system[rel], 'relation', 'li'));
          }
          return results;
        };
      })(this));
      return t + '</ul>';
    };

    HTMLStructure.prototype.render_element = function(model, type, tag) {
      var element;
      element = new HTMLElement({
        id: model.id,
        model: model,
        type: type,
        tag: tag,
        level: this.level + 1
      });
      return element.render();
    };

    return HTMLStructure;

  })(XObj);
})(jQuery, window, document);

//# sourceMappingURL=text-render.js.map
