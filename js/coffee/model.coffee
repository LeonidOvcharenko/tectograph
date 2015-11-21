"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win

	# system inner objects — extend with methods
	# .system .id [.title .description .picture .link .structure .matrix]
	class win.A
		constructor: (system, id)->
			$.extend @, system
			@id = @id || id || 'i'+Math.round(Math.random()*100000) # TODO: autogenerate id on server

		each_element: (func)->
			return if not @matrix
			for row, i in @matrix
				func @system[row[i]], i

		each_relation: (func)->
			return if not @matrix
			for row, i in @matrix
				for m, j in row
					func @system[m], i, j if m and i!=j

		each_child: (func)->
			return if not @matrix
			for row, i in @matrix
				for m, j in row
					func @system[m], i, j if m

		create_child: (id, title='')->
			# create matrix if empty
			if not @matrix
				@matrix = []
				@structure = "list.inline"
			# use existing element or create a new one
			if id
				child = @system[id]
			else
				child = new A
					system: @system
					title: title || '['+(@matrix.length+1)+'] '+@title
				@system[child.id] = child
			# expand matrix
			newline = []
			for row, i in @matrix
				row.push null
				newline.push null
			newline.push child.id
			@matrix.push newline
			# return id
			child.id
			
		create_sibling_shift: (shift)->
			parent = @system.parent_of @id
			pmatrix = @system[parent].matrix
			# create new element
			sibling = new A
				system: @system
				title: '['+(pmatrix.length+1)+'] '+@system[parent].title
			@system[sibling.id] = sibling
			# get index of inserted element
			for row, i in pmatrix
				break if row[i] == @id
			# if current element is relation, add into the end
			pos = i+shift
			# expand parent matrix
			newline = []
			for row, i in pmatrix
				row.splice pos, 0, null
				newline.push null
			newline.splice pos, 0, sibling.id
			pmatrix.splice pos, 0, newline
			# return id
			sibling.id

		create_sibling_before: -> @create_sibling_shift 0
		create_sibling_after:  -> @create_sibling_shift +1
		
		create_relation: (id1, id2)->
			for row, k in @matrix
				i = k if row[k]==id1
				j = k if row[k]==id2
			return @matrix[i][j] if @matrix[i][j]
			relation = new A
				system: @system
				title: @system[id1].nav_title()+' → '+@system[id2].nav_title()
			@system[relation.id] = relation
			@matrix[i][j] = relation.id
			relation.id

		delete_child: (id, leave)->
			# we assume there is only one link to an element in structure
			delete @system[id] unless leave  # delete element/relation
			for row, i in @matrix
				break if row[i]==id  # this is an element
				for m, j in row
					if m==id and i!=j  # this is a relation
						@matrix[i][j] = null
						return
			# delete relations of deleted element
			@each_relation (rel, ri, rj)=>
				delete @system[rel.id] if ri==i or rj==i
			# collapse matrix: remove row and columns
			@matrix.splice i, 1
			row.splice i, 1 for row in @matrix

		move_child: (id, step)->
			for row, i in @matrix
				j = i+step
				if row[i]==id and @matrix[j] and @matrix[j][j]
					# swap columns
					for row1 in @matrix
						e = row1[i]
						row1[i] = row1[j]
						row1[j] = e
					# swap rows
					r = @matrix[i]
					@matrix[i] = @matrix[j]
					@matrix[j] = r
					return
					
		next_sibling: (id)->
			for row, i in @matrix
				j = i+1
				if row[i]==id and @matrix[j] and @matrix[j][j]
					return @matrix[j][j]
			null

		nav_title: ->
			if @title and not /^\s*$/.test @title
				return @.title
			else if @description
				return @description.split('\n')[0]
			else
				return @id
		
		match: (regexp)->
			return ((@title and @title.match regexp) or (@description and @description.match regexp))

	class win.S
		constructor: (system)->
			$.extend @, system
			for key, a of @
				if a instanceof A
					a.system = @
					a.id = key
					
		parent_of: (child)->
			for id, model of @
				if model.matrix
					for row in model.matrix
						for element in row
							return id if element and element == child
			null
		
		depth_of: (id)->
			el = @[id]
			if el.matrix
				d = 0
				el.each_element (child)=>
					d = Math.max d, @depth_of child.id
				return d+1
			else
				return 0

		height: ->
			@depth_of(@root)+1
		
		# TODO: auto-id, add-element, add-link, remove-element, ...
		serialize: ->
			JSON.stringify @, (key, value)->
				return if key == "system" then undefined else value   # avoid circular reference

		deserialize: (s)->
			for key, a of @
				delete @[key] if a instanceof A
			p = JSON.parse s
			for key, a of p
				if key=='root' or key=='story'
					@[key] = a
				else
					@[key] = new A a
					@[key].system = @
		
		save: (key)->
			key = key || 'system'
			s = @serialize()
			localStorage.setItem key, s
		
		reload: (key)->
			key = key || 'system'
			s = localStorage.getItem key
			@deserialize s if s
			
		find: (query, from)->
			reg = new RegExp RegExp.escape(query), 'gi'
			search_on = not from?
			for key, a of @
				if a instanceof A
					return key if search_on and a.match reg
					search_on = true if not search_on and key == from   # start search at "from" element
			null
			
		findAll: (query)->
			reg = new RegExp RegExp.escape(query), 'gi'
			res = []
			for key, a of @
				res.push key if a instanceof A and a.match reg
			res

)(jQuery, window, document)