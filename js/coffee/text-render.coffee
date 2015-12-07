"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win

	# -TEXT, -plain text, -text
	class win.TEXTrender
		constructor: (options)->
			defaults =
				model: {}
			@opt = $.extend {}, defaults, options
			@model = @opt.model
			@build_content()
		build_content: ->
			@render()
		render: ->
			model = @model[@model.root]
			system = new TEXTElement
				id: @model.root
				level: 0
				model: model
			system.render()

	class win.XObj
		constructor: (options)->
			defaults =
				model: {}
			@opt = $.extend {}, defaults, options
			@model = @opt.model
			@level = @opt.level
			@indent = @make_indent @level
		render: ->
			model.title
		make_indent: (tabs)->
			indent = ''
			indent += '  ' for i in [0...tabs] # \t
			indent

	class win.TEXTElement extends XObj
		constructor: (options)-> super options
		render: ->
			t = ''
			t += @indent+'- '+(@model.title || '')
			if @model.link and @model.link.url
				t += '\n'+@indent+'  ['+@model.link.url+']'
			if @model.description
				t += '\n'+@indent+'  '+@model.description.replace(/\n/g, '\n'+@indent+'  ')
			if @model.picture and @model.picture.url
				t += '\n'+@indent+'Илл.: '+@model.picture.url
			# structure
			if @model.structure
				t += @render_structure()
			t
		render_structure: (x, y, w, ready)->
			@structure = new TEXTStructure
				model: @model
				level: @level
			@structure.render()

	class win.TEXTStructure extends XObj
		constructor: (options)-> super options
		render: ->
			t = ''
			relations = false
			@model.each_element (model, i)=>
				# element
				t += '\n'+@render_element model
				# relations
				for rel, j in @model.matrix[i]
					continue if j==i or not rel or not @model.system[rel]
					t += '\n'+@render_element @model.system[rel]
			t
		render_element: (model)->
			element = new TEXTElement
				id: model.id
				model: model
				level: @level+1
			element.render()

	# -XML
	class win.XMLrender extends TEXTrender
		constructor: (options)-> super options
		render: ->
			model = @model[@model.root]
			system = new XMLElement
				id: @model.root
				level: 0
				type: 'element'
				model: model
			'<?xml version="1.0" ?>\n<model version="2015.12.04">\n'+system.render()+'\n</model>'

	class win.XMLElement extends XObj
		constructor: (options)->
			super options
			@indent = @make_indent @level+1
			@indent2 = @make_indent @level+2
		render: ->
			t = @indent+'<object type="'+@opt.type+'">'
			if @model.title
				t += '\n'+@indent2+'<title>'+$.escape(@model.title || '')+'</title>'
			if @model.link and @model.link.url
				t += '\n'+@indent2+'<link>'+@model.link.url+'</link>'
			if @model.description
				t += '\n'+@indent2+'<description>'+$.escape(@model.description)+'</description>'
			if @model.picture and @model.picture.url
				t += '\n'+@indent2+'<media src="'+@model.picture.url+'" type="'+(if @model.picture.video then 'video' else 'image')+'" />'
			# structure
			if @model.structure
				t += @render_structure()
			t+'\n'+@indent+'</object>'
		render_structure: (x, y, w, ready)->
			@structure = new XMLStructure
				model: @model
				level: @level+1
			@structure.render()

	class win.XMLStructure extends XObj
		constructor: (options)->
			super options
			@indent = @make_indent @level+1
		render: ->
			t = '\n'+@indent+'<structure type="'+@model.structure+'">'
			relations = false
			@model.each_element (model, i)=>
				# element
				t += '\n'+@render_element model, 'element'
				# relations
				for rel, j in @model.matrix[i]
					continue if j==i or not rel or not @model.system[rel]
					t += '\n'+@render_element @model.system[rel], 'relation'
			t+'\n'+@indent+'</structure>'
		render_element: (model, type)->
			element = new XMLElement
				id: model.id
				model: model
				type: type
				level: @level+1
			element.render()
			
	# -HTML
	class win.HTMLrender extends TEXTrender
		constructor: (options)-> super options
		render: ->
			model = @model[@model.root]
			system = new HTMLElement
				id: @model.root
				level: 0
				type: 'element'
				model: model
			'<ul>'+system.render()+'</ul>'

	class win.HTMLElement extends XObj
		constructor: (options)->
			super options
			@opt.tag = 'li' if not @opt.tag
		render: ->
			t = '<'+@opt.tag+' class="'+@opt.type+' level-'+@level+'">'
			if @model.title
				t += '<h4>'+$.escape(@model.title || '')+'</h4>'
			if @model.link and @model.link.url
				t += '<a href="'+@model.link.url+'">'+@model.link.url+'</a>'
			if @model.description
				t += '<p>'+$.escape(@model.description).replace(/\n/g, '<br />')+'</p>'
			if @model.picture and @model.picture.url
				if @model.picture.video
					t += @model.picture.video+'<a href="'+@model.picture.url+'">Video</a>'
				else
					t += '<img src="'+@model.picture.url+'" />'
			# structure
			if @model.structure
				t += @render_structure()
			t+'</'+@opt.tag+'>'
		render_structure: (x, y, w, ready)->
			@structure = new HTMLStructure
				model: @model
				level: @level
			@structure.render()

	class win.HTMLStructure extends XObj
		constructor: (options)-> super options
		render: ->
			if @model.structure in ['graph', 'matrix']
				@render_table()
			else
				@render_list()
		render_table: ->
			t = '<table class="matrix"><tbody>'
			@model.each_element (model, i)=>
				t += '<tr>'
				for rel, j in @model.matrix[i]
					if rel and @model.system[rel]
						type = if i==j then 'element' else 'relation'
						t += @render_element @model.system[rel], type, 'td'
					else
						t += '<td></td>'
				t += '</tr>'
			t+'</tbody></table>'
		render_list: ->
			t = '<ul data-type="'+@model.structure+'">'
			relations = false
			@model.each_element (model, i)=>
				# element
				t += @render_element model, 'element', 'li'
				# relations
				for rel, j in @model.matrix[i]
					continue if j==i or not rel or not @model.system[rel]
					t += @render_element @model.system[rel], 'relation', 'li'
			t+'</ul>'
		render_element: (model, type, tag)->
			element = new HTMLElement
				id: model.id
				model: model
				type: type
				tag: tag
				level: @level+1
			element.render()
			
)(jQuery, window, document)