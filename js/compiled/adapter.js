// Generated by CoffeeScript 1.9.3
"use strict";
!(function($, win, doc) {
  var $doc, $win;
  $doc = $(doc);
  $win = $(win);
  return win.createAdapter = function(App) {
    DS.JSONSerializer.reopen({
      serializeHasMany: function(record, json, relationship) {
        var key, relationshipType;
        key = relationship.key;
        relationshipType = DS.RelationshipChange.determineRelationshipType(record.constructor, relationship);
        if (relationshipType === 'manyToNone' || relationshipType === 'manyToMany' || relationshipType === 'manyToOne') {
          return json[key] = Ember.get(record, key).mapBy('id');
        }
      }
    });
    App.SubscriptionSerializer = DS.JSONSerializer.extend({
      extractSingle: function(store, type, payload) {
        var all, f, item, j, len, list, ref, words;
        if (payload) {
          payload.sources.forEach(function(item, index) {
            if (item.virtual_stream) {
              item.stream = item.virtual_stream;
            }
            item.id = item.page_id + '.' + item.stream + '—' + payload._id;
            console.log('stream@subscription', item.id, payload);
            item.type = 'stream';
            return item.subscription = payload._id;
          });
          f = {};
          if (payload.filters) {
            ref = payload.filters;
            for (j = 0, len = ref.length; j < len; j++) {
              item = ref[j];
              all = item.match(/^\[(\w+)\]\s(.*)$/);
              list = all[1];
              if (!f[list]) {
                f[list] = [];
              }
              words = all[2].split(' || ');
              words.forEach(function(item) {
                var ww;
                ww = item.split(': ');
                return f[list].push({
                  where: ww[0],
                  what: ww[1]
                });
              });
            }
          }
          if (!f.only) {
            f.only = [];
          }
          if (!f.except) {
            f.except = [];
          }
          payload.filters = f;
        }
        return this._super(store, type, payload);
      },
      extractArray: function(store, type, payload) {
        return payload.map(function(json) {
          return this.extractSingle(store, type, json);
        }, this);
      },
      serializeHasMany: function(record, json, relationship) {},
      normalize: function(type, hash) {
        var json;
        json = {
          id: hash._id
        };
        delete hash._id;
        $.extend(true, json, hash);
        return this._super(type, json);
      }
    });
    App.StreamSerializer = DS.JSONSerializer.extend({
      extractArray: function(store, type, payload) {
        console.log('stream ex arr', type, payload);
        return this._super(store, type, payload);
      },
      normalize: function(type, hash) {
        var json, prop;
        json = {
          id: hash.page_id + '.' + (hash.virtual_stream || hash.stream) + '—' + hash.sub
        };
        for (prop in hash) {
          json[prop] = hash[prop];
        }
        if (hash.virtual_stream) {
          json.stream = hash.virtual_stream;
        }
        console.log('stream serializer: ', type, hash, json);
        return this._super(type, json);
      },
      serialize: function(record, options) {
        console.log('stream serialize: ', record, options);
        return this._super(record, options);
      },
      serializeBelongsTo: function(record, json, relationship) {
        console.log('stream serialize bt: ', record, json, relationship);
        return this._super(record, json, relationship);
      },
      serializeHasMany: function(record, json, relationship) {
        console.log('stream serialize hm: ', record, json, relationship);
        return this._super(record, json, relationship);
      }
    });
    App.NewspackSerializer = DS.JSONSerializer.extend({
      normalize: function(type, hash) {
        var json;
        json = {
          id: hash._id
        };
        delete hash._id;
        $.extend(true, json, hash);
        return this._super(type, json);
      }
    });
    App.PieceSerializer = DS.JSONSerializer.extend({
      normalize: function(type, hash) {
        var json, prop;
        json = {
          id: hash.page_id + '.' + hash.stream
        };
        delete hash._id;
        for (prop in hash) {
          json[prop] = hash[prop];
        }
        console.log('piece serializer: ', hash, json);
        return this._super(type, json);
      }
    });
    App.AdapterCache = Ember.Object.extend;
    App.AdapterCache.subscriptions = [];
    App.AdapterCache.pages = {};
    App.AdapterCache.newspacks = [];
    App.SubscriptionAdapter = DS.Adapter.extend({
      host: '/ajax',
      find: function(store, type, id) {
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/get_data', {}, function(res) {
              var sub;
              sub = App.AdapterCache.subscriptions.findBy('_id', id);
              return resolve(sub);
            });
          };
        })(this));
      },
      findAll: function(store, type, sinceToken) {
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/get_data', {}, function(res) {
              console.log('find all subs: ', res.user_data.subscriptions);
              res.user_data.subscriptions.forEach(function(item, index) {
                App.AdapterCache.subscriptions[index] = {};
                return $.extend(true, App.AdapterCache.subscriptions[index], item);
              });
              $.extend(true, App.AdapterCache.pages, res.pages_data);
              return resolve(res.user_data.subscriptions);
            });
          };
        })(this));
      },
      findQuery: function(store, type, query) {},
      findMany: function(store, type, ids, owner) {},
      createRecord: function(store, type, record) {
        console.log('create sub: ', type, record);
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/create_subscription', {}, function(res) {
              var sub;
              sub = res.subscription;
              sub.id = sub._id;
              return resolve(sub);
            });
          };
        })(this));
      },
      updateRecord: function(store, type, record) {
        var data, s_id;
        console.log('update sub: ', type.typeKey);
        data = this.serialize(record, {
          includeId: false
        });
        delete data.filters;
        s_id = record.get('id');
        console.log('update sub: ', type, data, s_id);
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/set_user_data', {
              subscription_id: s_id,
              multi_params: data,
              val: '1'
            }, function(res) {
              return resolve(null);
            });
          };
        })(this));
      },
      deleteRecord: function(store, type, record) {
        console.log('delete sub: ', type, record);
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/del_subscription/', {
              id: record.get('id')
            }, function(res) {
              return resolve(null);
            });
          };
        })(this));
      }
    });
    App.StreamAdapter = DS.Adapter.extend({
      host: '/ajax',
      find: function(store, type, id) {
        console.log('find src: ', type, id);
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/get_data', {}, function(res) {
              var src;
              src = res.user_data.subscriptions[0].sources;
              console.log('stream: ', src);
              return resolve(src);
            });
          };
        })(this));
      },
      findAll: function(store, type, sinceToken) {
        var i;
        console.log('find all src: ', type, sinceToken);
        i = 0;
        App.AdapterCache.streams = [];
        App.AdapterCache.subscriptions.forEach(function(sub) {
          return sub.sources.forEach(function(src) {
            App.AdapterCache.streams[i] = {};
            $.extend(App.AdapterCache.streams[i], src);
            App.AdapterCache.streams[i].subscription = sub._id;
            return i++;
          });
        });
        console.log(App.AdapterCache.streams);
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/get_data', {}, function(res) {
              return resolve(App.AdapterCache.streams);
            });
          };
        })(this));
      },
      findQuery: function(store, type, query) {},
      findMany: function(store, type, ids, owner) {
        console.log('find many streams: ', type, ids, owner);
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            var srcs;
            srcs = App.AdapterCache.subscriptions.findBy('_id', owner.id).sources;
            console.log('streams of sub: ', srcs);
            srcs.forEach(function(item, index) {
              if (item.virtual_stream) {
                item.stream = item.virtual_stream;
              }
              item.id = item.page_id + '.' + item.stream + '—' + owner.id;
              item.type = 'stream';
              item.subscription = owner.id;
              item.sub = owner.id;
              return $.extend(true, item, App.AdapterCache.pages[item.page_id]);
            });
            return resolve(srcs);
          };
        })(this));
      },
      createRecord: function(store, type, record) {
        var params, s_id, special, stream;
        console.log('create stream: ', type, record);
        s_id = record.get('sub');
        stream = {};
        stream.site_id = record.get('page_id');
        stream.name = record.get('name');
        params = {
          subscription_id: s_id,
          stream: stream
        };
        special = record.get('special');
        if (special) {
          params['special[' + special.key + ']'] = special.value;
        }
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/add_stream/', params, function(res) {
              var orig_str, str;
              orig_str = record.getProperties('title', 'favicon', 'url', 'streamTitle', 'subscription.id', 'sub');
              res.stream.id = (res.stream.page_id ? res.stream.page_id : stream.site_id) + '.' + stream.name + '—' + orig_str.sub;
              console.log('creating stream:', res.stream.id);
              if (res.warning) {
                resolve({});
              }
              str = $.extend(true, orig_str, res.stream);
              str.subscription = str['subscription.id'];
              delete str['subscription.id'];
              console.log('cr str: ', str);
              return resolve(str);
            });
          };
        })(this));
      },
      updateRecord: function(store, type, record) {
        return console.log('update stream: ', type, record);
      },
      deleteRecord: function(store, type, record) {
        var page_id, s_id, ss_id, stream;
        ss_id = record.get('subscription.id');
        console.log('delete stream: ', record.get('id'), record.get('sub'));
        s_id = record.get('sub');
        stream = record.get('stream');
        page_id = record.get('page_id');
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/rem_subs_stream/', {
              subscription_id: s_id,
              page_id: page_id,
              stream: stream
            }, function(res) {
              return resolve(record.getProperties('id', 'stream', 'page_id', 'url', 'favicon', 'title'));
            });
          };
        })(this));
      }
    });
    App.NewspackAdapter = DS.Adapter.extend({
      host: '/ajax',
      find: function(store, type, id) {
        var sub;
        console.log('find newspack: ', type, id);
        sub = App.AdapterCache.newspacks.findBy('_id', id);
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/get_delivery_packs', {
              subscription_id: s_id,
              pack_id: id
            }, function(res) {
              return resolve(res.packs[0]);
            });
          };
        })(this));
      },
      findAll: function(store, type, sinceToken) {
        console.log('find all newspacks: ', type);
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return resolve(null);
          };
        })(this));
      },
      findQuery: function(store, type, query) {
        var params;
        console.log('find newspacks by: ', query);
        params = {
          subscription_id: query.subscription
        };
        if (query.last_pack_id) {
          params.after_pack_id = query.last_pack_id;
        }
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/get_delivery_packs', params, function(res) {
              var loaded_packs, newspacks, queue;
              newspacks = res.last_delivery_packs_info || res.next_delivery_packs_info;
              if (!newspacks || newspacks.length === 0) {
                return resolve([]);
              }
              queue = new Ember.RSVP.resolve;
              loaded_packs = [];
              newspacks.forEach(function(item, index) {
                item.subscription = query.subscription;
                if (res.packs && index === 0) {
                  $.extend(true, item, res.packs[0]);
                  return loaded_packs.push(item);
                } else if (index < query.N) {
                  return queue = queue.then(function() {
                    return new Ember.RSVP.Promise(function(resolve, reject) {
                      var pack;
                      pack = App.AdapterCache.newspacks.findBy('_id', item._id);
                      if (pack) {
                        $.extend(true, item, pack);
                        loaded_packs.push(item);
                        return resolve();
                      } else {
                        return $.json(_this.host + '/get_delivery_packs', {
                          subscription_id: query.subscription,
                          pack_id: item._id
                        }, function(res) {
                          if (res.packs) {
                            $.extend(true, item, res.packs[0]);
                          }
                          App.AdapterCache.newspacks.push(item);
                          loaded_packs.push(item);
                          return resolve();
                        });
                      }
                    });
                  });
                }
              });
              return queue.then(function() {
                return resolve(loaded_packs);
              });
            });
          };
        })(this));
      },
      findMany: function(store, type, ids, owner) {
        return console.log('find many newspacks for: ', owner);
      },
      createRecord: function(store, type, record) {},
      updateRecord: function(store, type, record) {
        console.log('update newspack: ', type.typeKey);
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return resolve(null);
          };
        })(this));
      },
      deleteRecord: function(store, type, record) {
        console.log('delete newspack: ', type, record);
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return resolve(null);
          };
        })(this));
      }
    });
    return App.PieceAdapter = DS.Adapter.extend({
      host: '/ajax',
      find: function(store, type, id) {
        console.log('find piece: ', type, id);
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/get_data', {}, function(res) {
              var src;
              src = res.user_data.subscriptions[0].sources;
              console.log(src);
              return resolve(src);
            });
          };
        })(this));
      },
      findAll: function(store, type, sinceToken) {
        console.log('find all piece: ', type, App.AdapterCache.subscriptions);
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            App.AdapterCache.pieces = [];
            App.AdapterCache.streams.forEach(function(item, index) {
              console.log(item);
              return $.json(_this.host + '/get_subs_preview', {
                subscription_id: item.subscription,
                page_id: item.page_id,
                stream: item.stream
              }, function(res) {
                return console.log(res);
              });
            });
            return resolve(App.AdapterCache.pieces);
          };
        })(this));
      },
      findQuery: function(store, type, query) {},
      findMany: function(store, type, ids, owner) {
        return console.log('find many piece: ', type, ids, owner);
      },
      createRecord: function(store, type, record) {
        var page_id;
        console.log('create piece: ', type, record);
        page_id = record.get('page_id');
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/add_stream/', {
              subscription_id: s_id,
              stream: stream
            }, function(res) {
              return resolve({});
            });
          };
        })(this));
      },
      updateRecord: function(store, type, record) {
        return console.log('update piece: ', type, record);
      },
      deleteRecord: function(store, type, record) {
        var page_id, s_id, stream;
        console.log('delete piece: ', type, record);
        s_id = record.get('subscription.id');
        stream = record.get('stream');
        page_id = record.get('page_id');
        return new Ember.RSVP.Promise((function(_this) {
          return function(resolve, reject) {
            return $.json(_this.host + '/rem_subs_stream/', {
              subscription_id: s_id,
              page_id: page_id,
              stream: stream
            }, function(res) {
              return resolve({});
            });
          };
        })(this));
      }
    });
  };
})(jQuery, window, document);

//# sourceMappingURL=adapter.js.map
