// Generated by CoffeeScript 1.9.3
"use strict";
!(function($, win, doc) {
  var $doc, $win;
  $doc = $(doc);
  $win = $(win);
  win.A = (function() {
    function A(system, id) {
      $.extend(this, system);
      this.id = this.id || id || 'i' + Math.round(Math.random() * 100000);
    }

    A.prototype.each_element = function(func) {
      var i, l, len, ref, results, row;
      if (!this.matrix) {
        return;
      }
      ref = this.matrix;
      results = [];
      for (i = l = 0, len = ref.length; l < len; i = ++l) {
        row = ref[i];
        results.push(func(this.system[row[i]], i));
      }
      return results;
    };

    A.prototype.each_relation = function(func) {
      var i, j, l, len, m, ref, results, row;
      if (!this.matrix) {
        return;
      }
      ref = this.matrix;
      results = [];
      for (i = l = 0, len = ref.length; l < len; i = ++l) {
        row = ref[i];
        results.push((function() {
          var len1, n, results1;
          results1 = [];
          for (j = n = 0, len1 = row.length; n < len1; j = ++n) {
            m = row[j];
            if (m && i !== j) {
              results1.push(func(this.system[m], i, j));
            } else {
              results1.push(void 0);
            }
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    A.prototype.each_child = function(func) {
      var i, j, l, len, m, ref, results, row;
      if (!this.matrix) {
        return;
      }
      ref = this.matrix;
      results = [];
      for (i = l = 0, len = ref.length; l < len; i = ++l) {
        row = ref[i];
        results.push((function() {
          var len1, n, results1;
          results1 = [];
          for (j = n = 0, len1 = row.length; n < len1; j = ++n) {
            m = row[j];
            if (m) {
              results1.push(func(this.system[m], i, j));
            } else {
              results1.push(void 0);
            }
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    A.prototype.create_child = function(id, title) {
      var child, i, l, len, newline, ref, row;
      if (title == null) {
        title = '';
      }
      if (!this.matrix) {
        this.matrix = [];
        this.structure = "list.inline";
      }
      if (id) {
        child = this.system[id];
      } else {
        child = new A({
          system: this.system,
          title: title || '[' + (this.matrix.length + 1) + '] ' + this.title
        });
        this.system[child.id] = child;
      }
      newline = [];
      ref = this.matrix;
      for (i = l = 0, len = ref.length; l < len; i = ++l) {
        row = ref[i];
        row.push(null);
        newline.push(null);
      }
      newline.push(child.id);
      this.matrix.push(newline);
      return child.id;
    };

    A.prototype.create_sibling_shift = function(shift) {
      var i, l, len, len1, n, newline, parent, pmatrix, pos, row, sibling;
      parent = this.system.parent_of(this.id);
      pmatrix = this.system[parent].matrix;
      sibling = new A({
        system: this.system,
        title: '[' + (pmatrix.length + 1) + '] ' + this.system[parent].title
      });
      this.system[sibling.id] = sibling;
      for (i = l = 0, len = pmatrix.length; l < len; i = ++l) {
        row = pmatrix[i];
        if (row[i] === this.id) {
          break;
        }
      }
      pos = i + shift;
      newline = [];
      for (i = n = 0, len1 = pmatrix.length; n < len1; i = ++n) {
        row = pmatrix[i];
        row.splice(pos, 0, null);
        newline.push(null);
      }
      newline.splice(pos, 0, sibling.id);
      pmatrix.splice(pos, 0, newline);
      return sibling.id;
    };

    A.prototype.create_sibling_before = function() {
      return this.create_sibling_shift(0);
    };

    A.prototype.create_sibling_after = function() {
      return this.create_sibling_shift(+1);
    };

    A.prototype.create_relation = function(id1, id2) {
      var i, j, k, l, len, ref, relation, row;
      ref = this.matrix;
      for (k = l = 0, len = ref.length; l < len; k = ++l) {
        row = ref[k];
        if (row[k] === id1) {
          i = k;
        }
        if (row[k] === id2) {
          j = k;
        }
      }
      if (this.matrix[i][j]) {
        return this.matrix[i][j];
      }
      relation = new A({
        system: this.system,
        title: this.system[id1].nav_title() + ' → ' + this.system[id2].nav_title()
      });
      this.system[relation.id] = relation;
      this.matrix[i][j] = relation.id;
      return relation.id;
    };

    A.prototype.delete_child = function(id, leave) {
      var i, j, l, len, len1, len2, m, n, o, ref, ref1, results, row;
      if (!leave) {
        delete this.system[id];
      }
      ref = this.matrix;
      for (i = l = 0, len = ref.length; l < len; i = ++l) {
        row = ref[i];
        if (row[i] === id) {
          break;
        }
        for (j = n = 0, len1 = row.length; n < len1; j = ++n) {
          m = row[j];
          if (m === id && i !== j) {
            this.matrix[i][j] = null;
            return;
          }
        }
      }
      this.each_relation((function(_this) {
        return function(rel, ri, rj) {
          if (ri === i || rj === i) {
            return delete _this.system[rel.id];
          }
        };
      })(this));
      this.matrix.splice(i, 1);
      ref1 = this.matrix;
      results = [];
      for (o = 0, len2 = ref1.length; o < len2; o++) {
        row = ref1[o];
        results.push(row.splice(i, 1));
      }
      return results;
    };

    A.prototype.move_child = function(id, step) {
      var e, i, j, l, len, len1, n, r, ref, ref1, row, row1;
      ref = this.matrix;
      for (i = l = 0, len = ref.length; l < len; i = ++l) {
        row = ref[i];
        j = i + step;
        if (row[i] === id && this.matrix[j] && this.matrix[j][j]) {
          ref1 = this.matrix;
          for (n = 0, len1 = ref1.length; n < len1; n++) {
            row1 = ref1[n];
            e = row1[i];
            row1[i] = row1[j];
            row1[j] = e;
          }
          r = this.matrix[i];
          this.matrix[i] = this.matrix[j];
          this.matrix[j] = r;
          return;
        }
      }
    };

    A.prototype.next_sibling = function(id) {
      var i, j, l, len, ref, row;
      ref = this.matrix;
      for (i = l = 0, len = ref.length; l < len; i = ++l) {
        row = ref[i];
        j = i + 1;
        if (row[i] === id && this.matrix[j] && this.matrix[j][j]) {
          return this.matrix[j][j];
        }
      }
      return null;
    };

    A.prototype.nav_title = function() {
      if (this.title && !/^\s*$/.test(this.title)) {
        return this.title;
      } else if (this.description) {
        return this.description.split('\n')[0];
      } else {
        return this.id;
      }
    };

    A.prototype.match = function(regexp) {
      return (this.title && this.title.match(regexp)) || (this.description && this.description.match(regexp));
    };

    return A;

  })();
  return win.S = (function() {
    function S(system) {
      var a, key;
      $.extend(this, system);
      for (key in this) {
        a = this[key];
        if (a instanceof A) {
          a.system = this;
          a.id = key;
        }
      }
    }

    S.prototype.parent_of = function(child) {
      var element, id, l, len, len1, model, n, ref, row;
      for (id in this) {
        model = this[id];
        if (model.matrix) {
          ref = model.matrix;
          for (l = 0, len = ref.length; l < len; l++) {
            row = ref[l];
            for (n = 0, len1 = row.length; n < len1; n++) {
              element = row[n];
              if (element && element === child) {
                return id;
              }
            }
          }
        }
      }
      return null;
    };

    S.prototype.depth_of = function(id) {
      var d, el;
      el = this[id];
      if (el.matrix) {
        d = 0;
        el.each_element((function(_this) {
          return function(child) {
            return d = Math.max(d, _this.depth_of(child.id));
          };
        })(this));
        return d + 1;
      } else {
        return 0;
      }
    };

    S.prototype.height = function() {
      return this.depth_of(this.root) + 1;
    };

    S.prototype.serialize = function() {
      return JSON.stringify(this, function(key, value) {
        if (key === "system") {
          return void 0;
        } else {
          return value;
        }
      });
    };

    S.prototype.deserialize = function(s) {
      var a, key, p, results;
      for (key in this) {
        a = this[key];
        if (a instanceof A) {
          delete this[key];
        }
      }
      p = JSON.parse(s);
      results = [];
      for (key in p) {
        a = p[key];
        if (key === 'root' || key === 'story') {
          results.push(this[key] = a);
        } else {
          this[key] = new A(a);
          results.push(this[key].system = this);
        }
      }
      return results;
    };

    S.prototype.save = function(key) {
      var s;
      key = key || 'system';
      s = this.serialize();
      return localStorage.setItem(key, s);
    };

    S.prototype.reload = function(key) {
      var s;
      key = key || 'system';
      s = localStorage.getItem(key);
      if (s) {
        return this.deserialize(s);
      }
    };

    S.prototype.find = function(query, from) {
      var a, key, reg, search_on;
      reg = new RegExp(RegExp.escape(query), 'gi');
      search_on = from == null;
      for (key in this) {
        a = this[key];
        if (a instanceof A) {
          if (search_on && a.match(reg)) {
            return key;
          }
          if (!search_on && key === from) {
            search_on = true;
          }
        }
      }
      return null;
    };

    S.prototype.findAll = function(query) {
      var a, key, reg, res;
      reg = new RegExp(RegExp.escape(query), 'gi');
      res = [];
      for (key in this) {
        a = this[key];
        if (a instanceof A && a.match(reg)) {
          res.push(key);
        }
      }
      return res;
    };

    return S;

  })();
})(jQuery, window, document);

//# sourceMappingURL=model.js.map
