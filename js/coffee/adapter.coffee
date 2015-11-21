"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win
	win.createAdapter = (App)->
		
		# fix for Ember-Data
		DS.JSONSerializer.reopen
			serializeHasMany: (record, json, relationship)->
				key = relationship.key
				relationshipType = DS.RelationshipChange.determineRelationshipType record.constructor, relationship
				if relationshipType == 'manyToNone' or relationshipType == 'manyToMany' or relationshipType == 'manyToOne'
					json[key] = Ember.get(record, key).mapBy('id')
					# TODO support for polymorphic manyToNone and manyToMany
					# relationships
	
		App.SubscriptionSerializer = DS.JSONSerializer.extend
			extractSingle: (store, type, payload)->
				if payload
					payload.sources.forEach (item, index)->
						item.stream = item.virtual_stream if item.virtual_stream
						item.id = item.page_id+'.'+item.stream+'—'+payload._id
						console.log 'stream@subscription', item.id, payload
						item.type = 'stream'
						item.subscription = payload._id
					f = {}
					if payload.filters
						for item in payload.filters
							all = item.match /^\[(\w+)\]\s(.*)$/
							list = all[1]
							f[list] = [] if !f[list]
							words = all[2].split ' || '
							words.forEach (item)->
								ww = item.split ': '
								f[list].push { where: ww[0], what: ww[1] }
					f.only = [] if !f.only
					f.except = [] if !f.except
					payload.filters = f
				@_super store, type, payload
			extractArray: (store, type, payload)->
				payload.map( (json)->
					@extractSingle(store, type, json)
				, @)
			serializeHasMany: (record, json, relationship)->
				# console.log record, json, relationship
				# key = relationship.key
				# hasManyRecords = Ember.get(record, key)
				## if hasManyRecords and relationship.options.embedded == 'always'
				## 	json[key] = []
				## 	console.log hasManyRecords.get('content'), json
				## 	hasManyRecords.forEach (item, index)->
				## 		json[key].push(item.serialize())
				## 	return
				# relationshipType = DS.RelationshipChange.determineRelationshipType record.constructor, relationship
				# if relationshipType == 'manyToNone' or relationshipType == 'manyToMany' or relationshipType == 'manyToOne'
				# 	console.log hasManyRecords
				# 	json[key] = hasManyRecords.mapBy('id')
			normalize: (type, hash)->
				json = { id: hash._id }
				delete hash._id
				$.extend true, json, hash
				@_super(type, json)
		App.StreamSerializer = DS.JSONSerializer.extend
			# serializeBelongsTo: (record, json, relationship)->
			# 	console.log 'ser bt stream>sub', record, json, relationship
			extractArray: (store, type, payload)->
				console.log 'stream ex arr',type,payload
				@_super store, type, payload
			normalize: (type, hash)->
				json = { id: hash.page_id+'.'+(hash.virtual_stream || hash.stream)+'—'+hash.sub }
				for prop of hash
					json[prop] = hash[prop]
				json.stream = hash.virtual_stream if hash.virtual_stream
				console.log 'stream serializer: ', type, hash, json
				@_super(type, json)
			serialize: (record, options)->
				console.log 'stream serialize: ',record, options
				@_super record, options
			serializeBelongsTo: (record, json, relationship)->
				console.log 'stream serialize bt: ',record, json, relationship
				@_super record, json, relationship
			serializeHasMany: (record, json, relationship)->
				console.log 'stream serialize hm: ',record, json, relationship
				@_super record, json, relationship
		App.NewspackSerializer = DS.JSONSerializer.extend
			normalize: (type, hash)->
				json = { id: hash._id }
				delete hash._id
				$.extend true, json, hash
				@_super(type, json)
		App.PieceSerializer = DS.JSONSerializer.extend
			normalize: (type, hash)->
				json = { id: hash.page_id+'.'+hash.stream }
				delete hash._id
				for prop of hash
					json[prop] = hash[prop]
				console.log 'piece serializer: ', hash, json
				@_super(type, json)
		
		# cache for optimizations server queries
		App.AdapterCache = Ember.Object.extend
		App.AdapterCache.subscriptions = []
		App.AdapterCache.pages = {}
		App.AdapterCache.newspacks = []
		
		# App.ApplicationAdapter = DS.Adapter.extend
		App.SubscriptionAdapter = DS.Adapter.extend
			host: '/ajax'				
			find: (store, type, id)->
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/get_data', {}, (res)->
						sub = App.AdapterCache.subscriptions.findBy('_id',id)
						resolve sub
				)
			findAll: (store, type, sinceToken)->
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/get_data', {}, (res)->
						console.log 'find all subs: ', res.user_data.subscriptions
						# caching data
						res.user_data.subscriptions.forEach (item, index)->
							App.AdapterCache.subscriptions[index] = {}
							$.extend true, App.AdapterCache.subscriptions[index], item
						$.extend true, App.AdapterCache.pages, res.pages_data
						resolve res.user_data.subscriptions
				)
			findQuery: (store, type, query)->
				# TODO
			findMany: (store, type, ids, owner)->
				# TODO
			createRecord: (store, type, record)->
				# TODO
				console.log 'create sub: ', type, record
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/create_subscription', {}, (res)->
						sub = res.subscription
						sub.id = sub._id
						resolve sub
				)
				# todo: save new record data
			updateRecord: (store, type, record)->
				console.log 'update sub: ', type.typeKey
				data = @serialize record, { includeId: false }
				delete data.filters
				s_id = record.get 'id'
				console.log 'update sub: ', type, data, s_id
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/set_user_data', {subscription_id:s_id, multi_params:data, val:'1'}, (res)->
						resolve null
				)
			deleteRecord: (store, type, record)->
				console.log 'delete sub: ', type, record
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/del_subscription/', {id: record.get('id')}, (res)->
						resolve null
				)
	
		App.StreamAdapter = DS.Adapter.extend
			host: '/ajax'					
			find: (store, type, id)->
				console.log 'find src: ', type, id
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/get_data', {}, (res)->
						src = res.user_data.subscriptions[0].sources
						console.log 'stream: ', src
						resolve src
				)
			findAll: (store, type, sinceToken)->
				console.log 'find all src: ', type, sinceToken
				i=0
				App.AdapterCache.streams = []
				App.AdapterCache.subscriptions.forEach (sub)->
					sub.sources.forEach (src)->
						App.AdapterCache.streams[i] = {}
						$.extend App.AdapterCache.streams[i], src
						App.AdapterCache.streams[i].subscription = sub._id
						i++
				console.log App.AdapterCache.streams
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/get_data', {}, (res)->
						resolve App.AdapterCache.streams
				)
			findQuery: (store, type, query)->
				# TODO
			findMany: (store, type, ids, owner)->
				# TODO
				console.log 'find many streams: ', type, ids, owner
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					srcs = App.AdapterCache.subscriptions.findBy('_id',owner.id).sources
					console.log 'streams of sub: ', srcs
					srcs.forEach (item, index)->
						item.stream = item.virtual_stream if item.virtual_stream
						item.id = item.page_id+'.'+item.stream+'—'+owner.id
						item.type = 'stream'
						item.subscription = owner.id
						item.sub = owner.id
						$.extend true, item, App.AdapterCache.pages[item.page_id]
					resolve srcs
				)
	
			createRecord: (store, type, record)->
				# TODO
				console.log 'create stream: ', type, record
				s_id = record.get 'sub'
				stream = {}
				stream.site_id = record.get 'page_id'
				stream.name = record.get 'name'
				params = {subscription_id: s_id, stream: stream}
				special = record.get 'special'
				if special
					params['special['+special.key+']'] = special.value
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/add_stream/', params, (res)->
						orig_str = record.getProperties 'title', 'favicon', 'url', 'streamTitle', 'subscription.id', 'sub'
						res.stream.id = (if res.stream.page_id then res.stream.page_id else stream.site_id)+'.'+stream.name+'—'+orig_str.sub
						console.log 'creating stream:',res.stream.id
						resolve {} if res.warning
						str = $.extend true, orig_str, res.stream
						str.subscription = str['subscription.id']
						delete str['subscription.id']
						console.log 'cr str: ', str
						resolve str
				)
			updateRecord: (store, type, record)->
				# TODO
				console.log 'update stream: ', type, record
			deleteRecord: (store, type, record)->
				ss_id = record.get('subscription.id')
				console.log 'delete stream: ', record.get('id'), record.get('sub')
				s_id = record.get('sub')
				stream = record.get('stream')
				page_id = record.get('page_id')
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/rem_subs_stream/', {subscription_id: s_id, page_id: page_id, stream: stream}, (res)->
						resolve record.getProperties('id','stream','page_id','url','favicon','title')
				)
	
		App.NewspackAdapter = DS.Adapter.extend
			host: '/ajax'
			find: (store, type, id)->
				# TODO
				console.log 'find newspack: ', type, id
				sub = App.AdapterCache.newspacks.findBy('_id',id)
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/get_delivery_packs', {subscription_id: s_id, pack_id: id}, (res)->
						resolve res.packs[0]
				)
			findAll: (store, type, sinceToken)->
				console.log 'find all newspacks: ', type
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					resolve null
				)
			findQuery: (store, type, query)->
				# TODO
				console.log 'find newspacks by: ', query
				params = { subscription_id: query.subscription }
				params.after_pack_id = query.last_pack_id if query.last_pack_id 
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/get_delivery_packs', params, (res)=>
						# caching data
						newspacks = res.last_delivery_packs_info || res.next_delivery_packs_info
						return resolve [] if !newspacks || newspacks.length == 0
						queue = new Ember.RSVP.resolve
						loaded_packs = []
						newspacks.forEach (item, index)=>
							item.subscription = query.subscription
							if res.packs and index==0
								$.extend true, item, res.packs[0]
								loaded_packs.push item
							else if index<query.N
								queue = queue.then =>
									return new Ember.RSVP.Promise( (resolve, reject)=>
										pack = App.AdapterCache.newspacks.findBy '_id', item._id
										if pack
											$.extend true, item, pack
											loaded_packs.push item
											resolve()
										else
											$.json @host+'/get_delivery_packs', {subscription_id: query.subscription, pack_id: item._id}, (res)->
												$.extend true, item, res.packs[0] if res.packs
												App.AdapterCache.newspacks.push item
												loaded_packs.push item
												resolve()
									)
						queue.then => resolve loaded_packs # newspacks
				)
	
			findMany: (store, type, ids, owner)->
				# TODO
				console.log 'find many newspacks for: ', owner
			createRecord: (store, type, record)->
				# TODO
			updateRecord: (store, type, record)->
				console.log 'update newspack: ', type.typeKey
				# data = @serialize record, { includeId: false }
				# delete data.filters
				# s_id = record.get 'id'
				# console.log 'update newspack: ', type, data, s_id
				# ///- pr
				# 	$.json @host+'/mark_packs_as_read', {subscription_id:s_id, multi_params:data}, (res)->
				# 		resolve null
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					resolve null
				)
			deleteRecord: (store, type, record)->
				console.log 'delete newspack: ', type, record
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					resolve null
				)
						
		App.PieceAdapter = DS.Adapter.extend
			host: '/ajax'					
			find: (store, type, id)->
				console.log 'find piece: ', type, id
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/get_data', {}, (res)->
						src = res.user_data.subscriptions[0].sources
						console.log src
						resolve src
				)
			findAll: (store, type, sinceToken)->
				console.log 'find all piece: ', type, App.AdapterCache.subscriptions
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					App.AdapterCache.pieces = []
					App.AdapterCache.streams.forEach (item,index)=>
						console.log item
						# $.extend item, page_id.stream
						$.json @host+'/get_subs_preview', {subscription_id: item.subscription, page_id: item.page_id, stream: item.stream}, (res)->
							console.log res
					resolve App.AdapterCache.pieces
				)
			findQuery: (store, type, query)->
				# TODO
			findMany: (store, type, ids, owner)->
				# TODO
				console.log 'find many piece: ', type, ids, owner
	
			createRecord: (store, type, record)->
				# TODO
				console.log 'create piece: ', type, record
				page_id = record.get('page_id')
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/add_stream/', {subscription_id: s_id, stream: stream}, (res)->
						resolve {}
				)
			updateRecord: (store, type, record)->
				# TODO
				console.log 'update piece: ', type, record
			deleteRecord: (store, type, record)->
				console.log 'delete piece: ', type, record
				s_id = record.get('subscription.id')
				stream = record.get('stream')
				page_id = record.get('page_id')
				#- pr
				new Ember.RSVP.Promise( (resolve,reject)=>
					$.json @host+'/rem_subs_stream/', {subscription_id: s_id, page_id: page_id, stream: stream}, (res)->
						resolve {}
				)
)(jQuery, window, document)
						
# the end
