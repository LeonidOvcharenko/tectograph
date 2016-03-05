"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win
	
	class win.EditorMenu
		constructor: (editor, sidebar)->
			@editor = editor
			@sidebar = sidebar
			@panels =
				tree: true
				help: false
				storyboard: false
				onlytext: false
			@menu = new Ractive
				el: 'menu'
				template: '#editor-menu'
				data:
					panels: @panels
			@menu.on
				# imhub
				'help': (event)=>
					@panels.help = !@panels.help
					@sidebar.set 'help_visible', @panels.help
					@menu.set 'panels', @panels
					viewer.update_minimap()
				# scheme
				'create': => win.editor.create()
				'fork':   => alert 'TODO: fork'
				'import': => $('#import-window').modal 'toggle'
				'export': => $('#export-window').modal 'toggle'
				'save':   => alert 'TODO: save'
				'print':  => win.editor.print()
				'save1':  => @editor.fire 'save'
				'load1':  => @editor.fire 'load'
				# edit
				'undo':   => @editor.fire 'undo' # TODO: show state
				'redo':   => @editor.fire 'redo' # TODO: show state
				'cut':    => win.editor.select()
				'paste':  => win.editor.move_into()
				'insert-image': => win.editor.media_form true
				'insert-link':  => win.editor.link_form()
				'relation': => alert 'TODO: relation'
				'element':  => alert 'TODO: element'
				'delete':   => alert 'TODO: delete'
				# view
				'redraw-this': => win.editor.update_this()
				'redraw-all':  => win.editor.update_all()
				'fit-all':     => win.editor.focus_all()
				'fit-this':    => win.editor.focus_this()
				'zoom-in':     => win.viewer.controls.fire 'zoom-in'
				'zoom-out':    => win.viewer.controls.fire 'zoom-out'
				'toggle-tree': =>
					@panels.tree = !@panels.tree
					@editor.set 'tree_visible', @panels.tree
					@menu.set 'panels', @panels
					viewer.update_minimap()

				'toggle-storyboard': =>
					@panels.storyboard = !@panels.storyboard
					@sidebar.set 'storyboard_visible', @panels.storyboard
					@menu.set 'panels', @panels
					viewer.update_minimap()
					
				'toggle-onlytext': =>
					@panels.onlytext = !@panels.onlytext
					@editor.set 'onlytext_visible', @panels.onlytext
					@menu.set 'panels', @panels



				# share
				'show-link': => alert 'TODO: show link'
				'embed':     => alert 'TODO: embed'
				'share-fb':  => alert 'TODO: Facebook'
				'share-vk':  => alert 'TODO: VK'
				'share-tw':  => alert 'TODO: Twitter'
				'co-authors':  => alert 'TODO: co-authors'
	
	class win.Editor
		constructor: (system)->
			@system = system
			@extend_ractive()
			@init_history()
			@build_content()
			@controller()
			
		Settings:
			maxLevel: 7
			
		extend_ractive: ->
			# sortable
			sortableDecorator = (node, elements_arr)=>
				from = 0
				$(node).sortable
					distance: 10
					start: (event, ui)=>
						from = ui.item.index()
					stop: (event, ui)=>
						to = ui.item.index()
						m = elements_arr[from]
						elements_arr.splice from, 1
						elements_arr.splice to, 0, m
						id = @editor.get 'id'
						model = @system[id]
						model.matrix = @rebuild_matrix()
				return {
					teardown: => $(node).sortable('destroy')
				}
			Ractive.decorators.sortable = sortableDecorator
			# slider input
			sliderDecorator = (node, scale, disabled)=>
				if scale > 0
					scale = (scale-0.1)/9.9
					# scale = Math.log scale*(Math.E-1)+1
					scale = Math.log(scale*9+1)/Math.LN10
				else
					scale = 0
				save_val = (event, ui)=>
					x = $(node).slider('value')
					# s = (Math.exp(x)-1)/(Math.E-1)
					s = (Math.pow(10, x)-1)/9
					s = (s*9.9+0.1).toFixed(1)
					@editor.set 'imgscale', s
				$(node).slider
					min: 0
					max: 1
					step: 0.01
					value: scale
					slide: save_val
					stop: =>
						save_val()
						@update_this()
					disabled: disabled
				$(node).find('.ui-slider-handle').attr 'title', 'Масштабировать перед отрисовкой'
				return {
					teardown: ->  # $(node).slider('value', 0)
				}
			Ractive.decorators.slider = sliderDecorator
			# focus input: decorator="focus:{{changed}}" - NOT USED NOW
			inputFocusDecorator = (node, changed)=>
				node.focus() if changed
				return { teardown: -> }
			Ractive.decorators.focus = inputFocusDecorator
			
		init_history: ->
			@history =
				stack: []
				limit: 10
				pos: -1
				save: (state)->
					# clear redo states
					@stack.splice @pos+1, @stack.length-@pos-1 if @is_redo()
					# limit states count
					@stack.shift() if @stack.length==@limit
					# save new state
					@stack.push state
					@pos = @stack.length-1
				undo: -> # -> state
					@pos--
					@stack[@pos+1]
				redo: -> # -> state
					@pos++
					@stack[@pos]
				is_undo: -> # f
					@pos >= 0
				is_redo: -> # f
					@pos < @stack.length-1

		build_content: ->
			@editor = new Ractive
				el: 'modeller'
				template: '#modelling-form'
				data:
					search: ''
					theme: Theme
					themes: Themes
					tree_visible: true
					onlytext_visible: false
			@sidebar = new Ractive
				el: 'sidebar'
				template: '#sidebar-panels'
				data:
					help_visible: false
					storyboard_visible: false
			the_menu = new EditorMenu @editor, @sidebar
			@panels = the_menu.panels
			@menu = the_menu.menu
			@controls = win.viewer.controls
			@images = {}
			@external_links = {}
			@search_query = ''
			@filtered = []
			@selected = null
			
			$('#form').draggable
				containment: '#wrapper'
				cursor: 'move'
				opacity: 0.8
		
		controller: ->
			$win.on 'keydown.editor', (e)=>
				# hide modal window on Esc
				$('.modal:visible').modal 'hide' if e.which == $.key.Esc
				$('#wrapper').addClass 'edit' if e.which == $.key.Shift
				# keys work everywhere
				# Alt+Shift+key
				if e.altKey and e.shiftKey
					switch e.which
						when $.key.n1
							@editor.fire 'change-struct', null, 'list.inline'
							return false
						when $.key.n2
							@editor.fire 'change-struct', null, 'list.stack'
							return false
						when $.key.n3
							@editor.fire 'change-struct', null, 'list.bricks'
							return false
						when $.key.n4
							@editor.fire 'change-struct', null, 'matrix'
							return false
						when $.key.n5
							@editor.fire 'change-struct', null, 'graph'
							return false
				# Ctrl+key
				else if (e.ctrlKey or e.metaKey) and not e.altKey # reject AltGr
					switch e.which
						when $.key.Enter
						# create before and go to sibling
							parent = @editor.get 'parent'
							id = @editor.get 'id'
							if parent
								@write_history id
								sibling = @system[id].create_sibling_before()
								@redraw parent, true
								@show sibling
								@edit_title()
							return false
						when $.key.Up
						# attach to grand parent as last child
							@move_level_higher()
							return false
						when $.key.Down
						# attach to next sibling as last child
							@move_level_lower()
							return false
						when $.key.Slash, $.key.Slash_cyr, $.key.Slash_num
						# show/hide help
							@panels.help = !@panels.help
							@sidebar.set 'help_visible', @panels.help
							@menu.set 'panels', @panels
							viewer.update_minimap()
							return false
						when $.key.S
						# save
							@editor.fire 'save'
							return false
						when $.key.L
						# load
							@editor.fire 'load'
							return false
				# Shift+key
				else if e.shiftKey
					switch e.which
						when $.key.Enter
						# create and go to sibling
							parent = @editor.get 'parent'
							id = @editor.get 'id'
							if parent
								@write_history id
								sibling = @system[id].create_sibling_after()
								@redraw parent, true
								@show sibling
								@edit_title()
							return false
						when $.key.Ins
						# create with title and go to child element
							@editor.fire 'add-element', null, $.selection()
							return false
				# Alt+key
				else if e.altKey
					switch e.which
						when $.key.T
						# toggle tree
							@panels.tree = !@panels.tree
							@editor.set 'tree_visible', @panels.tree
							@menu.set 'panels', @panels
							viewer.update_minimap()
							return false
						when $.key.S
						# toggle system editor
							@panels.onlytext = !@panels.onlytext
							@editor.set 'onlytext_visible', @panels.onlytext
							@menu.set 'panels', @panels
							return false
						when $.key.R
						# redraw current
							@update_this()
							return false
						when $.key.A
						# redraw all
							@update_all()
							return false
						when $.key.F
						# focus to current
							@focus_this()
							return false
						when $.key.V
						# pan to current
							el = @editor.get 'id'
							win.viewer.find_and_pan el
							return false
				# key
				else
					switch e.which
						when $.key.Ins
						# create and go to child element
							@editor.fire 'add-element'
							return false
				# keys work not on active input
				if not $.activeInput()
					# Ctrl+key
					if (e.ctrlKey or e.metaKey) and not e.altKey # reject AltGr
						switch e.which
							when $.key.Left
							# swap with previous sibling
								@move_same_level -1
								return false
							when $.key.Right
							# swap with next sibling
								@move_same_level +1
								return false
							when $.key.Z
							# undo
								@editor.fire 'undo'
								return false
							when $.key.Y
							# redo
								@editor.fire 'redo'
								return false
							when $.key.X
								# cut
								@select()
								return false
							when $.key.V
								# paste
								@move_into()
								return false
					else if not (e.altKey or e.ctrlKey or e.metaKey or e.shiftKey)
						switch e.which
							when $.key.Up, $.key.K
							# go to previous sibling
								# @change_sibling -1
								@change_current -1
								return false
							when $.key.Down, $.key.J
							# go to next sibling
								# @change_sibling +1
								@change_current +1
								return false
							when $.key.Left, $.key.H
							# go to parent
								parent = @editor.get 'parent'
								@show parent if parent
								return false
							when $.key.Right, $.key.L
							# go to first child
								child = @editor.get 'elements.0.link'
								@show child if child
								return false
							when $.key.S
							# change structure type
								$('button[data-target="#edit-structure"]:not(.active):not(.disabled)').click()
								b = $('#model-structure-type button.active + button')
								if b[0]
									b.click()
								else
									$('#model-structure-type button:first').click()
								return false
							when $.key.I
							# add image/video link
								@media_form()
								return false
							when $.key.U
							# add external link
								@link_form()
								return false
							when $.key.R
							# make relation with sibling
								$('#tie-with').dropdown 'toggle'
								return false
							when $.key.Enter
							# edit title
								if doc.activeElement.tagName in ["BUTTON","A"]
									return true   # allow for menus' events
								@edit_title()
								return false
							when $.key.Space
							# edit description
								$('#model-description').focus().select() # TODO remake to decorator?
								return false
							when $.key.Del
							# remove current
								@editor.fire 'remove'
								return false
							when $.key.F, $.key.Star_num
							# toggle featured
								@editor.fire 'toggle-featured'
								return false
							when $.key.Slash, $.key.Slash_cyr, $.key.Slash_num
							# activate search field
								$('#search input').focus().select()
								return false
							when $.key.n5_num
							# edit element in center
								el = win.viewer.in_center()
								@show_edit el
								return false
				else
					# blur input field on Esc
					doc.activeElement.blur() if e.which == $.key.Esc
				@editor.fire 'hide-editor' if e.which == $.key.Esc
				true
			$win.on 'keyup.editor', (e)=>
				if e.which == $.key.Shift
					$('#wrapper').removeClass 'edit'
				return true
				
			# simple editor
			$("#systemtext").on 'keydown.simpleeditor', (e)=>
				ta = e.target
				if e.which in [$.key.Enter, $.key.Tab]
					e.preventDefault()
					sel_start = ta.selectionStart
					sel_end = ta.selectionEnd
					text = $(ta).val()
					lines_start = text.lastIndexOf "\n", sel_start-1
				if e.which == $.key.Tab
					if sel_start <= sel_end
						lines_end = text.indexOf "\n", sel_end-1
						lines_end = sel_end if lines_end < sel_end
						breaks = text.substring(lines_start+1, lines_end).split("\n");
						nbr = 0
						if e.shiftKey
							for line, i in breaks
								if line.match /^\s\s/g
									breaks[i] = line.substring 2, line.length
									nbr += 2
							ins = breaks.join "\n"
						else
							ins = "  " + breaks.join("\n  ")
							nbr = breaks.length*2
						$(ta).val(text.substring(0, lines_start+1) + ins + text.substring(lines_end, text.length))
						ta.selectionStart = if e.shiftKey then sel_start-Math.min(2, nbr) else sel_start+Math.min(2, nbr)
						ta.selectionEnd = if e.shiftKey then sel_end-nbr else sel_end+nbr
				else if e.which == $.key.Enter
					ins = '\n'
					t = text.substring(lines_start+1, sel_start)
					m = t.match /^[\s\-]*/g
					if m and m[0]
						ins += m[0]
					$(ta).val text.substring(0, sel_start)+ins+text.substring(sel_start, text.length)
					ta.selectionStart = sel_start + ins.length
					ta.selectionEnd = sel_end + ins.length
				@editor.set 'systemtext', $(ta).val()
			
			# activate editor on map
			$win.off 'dblclick.viewer'
			$win.on 'dblclick.editor', (e)=>
				el = $(e.target).closest('g').data('model')
				@show el if el  # show_edit
				false
			$('#wrapper').on 'mousedown.editor', (e)=>
				$.clearSelection()
				if e.shiftKey
					el = $(e.target).closest('g').data('model')
					@show_edit el if el
					return false
			
			# export window
			$('#export-window').on 'show.bs.modal', (e)=>
				# json
				json = @system.serialize()
				$('pre.exported-json').text json
				# plain text
				renderer = new TEXTrender( model:@system )
				$('pre.exported-text').text renderer.render()
				# html
				renderer = new HTMLrender( model:@system )
				$('div.exported-html').html renderer.render()
				# xml
				renderer = new XMLrender( model:@system )
				$('pre.exported-xml').text renderer.render()
			# show first tab - json
			$('#export-window').on 'shown.bs.modal', (e)=>
				json = $('pre.exported-json').clone()
				$('#export-preview').attr('data-type','application/json').attr('data-ext','json').empty().append json
				$.selectContents 'export-preview'
				$('#export-window a[data-toggle=tab]:first').tab('show')
			# on tab change
			$('#export-window a[data-toggle=tab]').on 'show.bs.tab', (e)=>
				id = $(e.target).attr 'aria-controls'
				el = $ '#'+id
				type = el.attr 'data-type'
				ext  = el.attr 'data-ext'
				exported = el.html()
				$('#export-preview').attr('data-type',type).attr('data-ext',ext).html exported
				$.selectContents 'export-preview'

			# model subforms as tabs
			$('#model-addons .collapse').on 'show.bs.collapse', (e)=>
				id = $(e.target).attr 'id'
				btn = $ 'button[data-target=#'+id+']'
				btn.addClass 'active'
				$('#model-addons button[data-toggle=collapse]').each (i, el)=>
					target = $(el).attr 'data-target'
					$(target).collapse 'hide' if target != '#'+id and $(target).is ':visible'
			$('#model-addons .collapse').on 'hidden.bs.collapse', (e)=>
				id = $(e.target).attr 'id'
				btn = $ 'button[data-target=#'+id+']'
				btn.removeClass 'active'
				$(e.target).find('input').blur()

			@sidebar.on
				'close-help': =>
					@panels.help = false
					@sidebar.set 'help_visible', @panels.help
					@menu.set 'panels', @panels
					viewer.update_minimap()
				'close-storyboard': =>
					@panels.storyboard = false
					@sidebar.set 'storyboard_visible', @panels.storyboard
					@menu.set 'panels', @panels
					viewer.update_minimap()

			@editor.on
				'clear-search': =>
					@editor.set 'search', ''
				'show-search-results': (e)=>
					if e.original.which in [$.key.Down, $.key.Enter]
						$('#filter-dropdown').dropdown 'toggle'
						return false
				'goto': (event, zoom)=>
					data = event.context
					@redraw data.link, true
					@show data.link
					@focus_this() if zoom
					event.original.preventDefault()
					false
				'hide-editor': ->
					$('#form').css
						display: 'none'
				'clear-picture': (event, mediastate)=>
					if mediastate == 'error'
						@editor.set
							mediaurl: ''
							imgpos: ''
							imgsize: ''
				'set-scale': (event, value)=>
					@editor.set 'imgscale', value
					@update_this()
				'change-struct': (event, value)=>
					@editor.set 'structure', value
					@update_this()
				'change-imgpos': (event, value)=>
					@editor.set 'imgpos', value
					@save event.context
					@redraw event.context.id
				'change-linkpos': (event, value)=>
					@editor.set 'linkpos', value
					@save event.context
					@redraw event.context.id
				'toggle-featured': =>
					f = @editor.get 'featured'
					@editor.set 'featured', !f
				'add-element': (event, title)=>
					hierarchy = @editor.get 'hierarchy'
					return if hierarchy.length >= @Settings.maxLevel
					id = @editor.get 'id'
					@write_history id
					child = @system[id].create_child null, title
					@redraw id, true
					@show child
					@edit_title()
					false
				'add-relation': (event)=>
					id = event.context.id
					@write_history id
					id1 = event.context.rel_from
					id2 = event.context.rel_to
					relation = @system[id].create_relation id1, id2
					@redraw id, true
					@show relation
					@edit_title()
					false
				'tie-with': (event)=>
					target = event.context
					id = @editor.get 'id'
					parent = @editor.get 'parent'
					relation = @system[parent].create_relation id, target.link
					@redraw parent, true
					@show relation
					@edit_title()
					true
				'rel-dir-inverse': (event)=>
					id1 = event.context.rel_from
					id2 = event.context.rel_to
					@editor.set
						rel_from: id2
						rel_to: id1
				'swap-on': (event)=>
					$(event.node).children('i').removeClass('fa-long-arrow-right').addClass('fa-arrows-h text-info')
				'swap-off': (event)=>
					$(event.node).children('i').removeClass('fa-arrows-h text-info').addClass('fa-long-arrow-right')
				'save': (event)=>
					data = @editor.get()
					@save data
					@system.save() # TODO: save to localstorage
					false
				'load': (event)=>
					@system.reload()
					@edit @system.root
					@update_all()
					false
				'remove': (event)=>
					@remove @editor.get()
					false
				'undo': =>
					return unless @history.is_undo()
					state = @history.undo()
					@system.deserialize state.data
					@update state.id
					@menu.set
						is_undo: @history.is_undo()
						is_redo: @history.is_redo()
				'redo': =>
					return unless @history.is_redo()
					state = @history.redo()
					@system.deserialize state.data
					@update state.id
					@menu.set
						is_undo: @history.is_undo()
						is_redo: @history.is_redo()
				'exportSVG': =>
					filename = @model_name()
					@editor.set 'exportingSVG', true
					# set zoom for export
					win.viewer.zoom 1
					bbox = win.modelview.object.bbox()
					svg_file = win.modelview.draw.exportSvg
						width:  bbox.width
						height: bbox.height
						exclude: ->
							@show() if @type == 'text'
							return @type == 'rect' and (@hasClass('mask') or @hasClass('frame'))
					# get svg file object link
					data = new Blob [svg_file], { "type": "text\/xml" }
					@export_file filename+'.svg', data
					# restore zoom
					@update_all()
					@editor.set 'exportingSVG', false
					false
				'exportPNG': =>
					filename = @model_name()
					@editor.set 'exportingPNG', true
					# set zoom for export
					win.viewer.zoom 1
					bbox = win.modelview.object.bbox()
					# here about canvas limit - http://stackoverflow.com/questions/6081483/maximum-size-of-a-canvas-element
					overzoom = 8000/Math.max(bbox.width, bbox.height, bbox.x2, bbox.y2)
					if overzoom < 1
						win.viewer.zoom overzoom
						bbox = win.modelview.object.bbox()
					w = Math.round Math.max bbox.width, bbox.x2
					h = Math.round Math.max bbox.height, bbox.y2
					svg_file = win.modelview.draw.exportSvg
						width:  w
						height: h
						exclude: ->
							@show() if @type == 'text'
							return @type == 'rect' and (@hasClass('mask') or @hasClass('frame'))
					# draw image on canvas
					image = new Image
					image.onload = =>
						# prepare canvas for png export
						canvas = $('<canvas>').appendTo('body').hide()[0]
						canvas.width  = w
						canvas.height = h
						png = canvas.getContext "2d"
						# set white background color and draw image
						png.fillStyle = '#FFFFFF'
						png.fillRect 0, 0, canvas.width, canvas.height
						png.drawImage image, 0, 0
						# return file
						url = canvas.toDataURL "image/png"
						a = $('<a>').attr('download', filename+".png").attr('href', url)
						a[0].click()
						# canvas.remove()
						@editor.set 'exportingPNG', false
						# restore zoom
						@update_all()
					image.src = 'data:image/svg+xml;utf8,'+svg_file
					# image.src = 'data:image/svg+xml;base64,'+window.btoa(unescape(encodeURIComponent(svg_file)))
					false
				'exportFile': =>
					filename = @model_name()
					type = $('#export-preview').attr('data-type')
					ext  = $('#export-preview').attr('data-ext')
					get_html = ->
						t = '<!DOCTYPE html><html><head><title>'+$.escape(filename)+'</title></head><body>'
						t += $('#export-preview>div').html()
						t+'</body></html>'
					content = $('#export-preview>pre').text() || get_html()
					data = new Blob [content], { "type": type }
					@export_file filename+'.'+ext, data
					false
				'exportJSON': =>
					filename = @model_name()
					json = @system.serialize()
					data = new Blob [json], { "type": "application\/json" }
					@export_file filename+'.json', data
					false
				'importJSON': (event)=>
					file = event.node.files[0]
					if file and file.size<100000
						@import_json file
						$('#import-window').modal 'toggle'
					false

			@editor.observe
				'onlytext_visible': (value)=>
					if value
						renderer = new TEXTrender( model:@system )
						@editor.set 'systemtext', renderer.render()
				'systemtext': (text)=>
					if text
						importer = new TEXTreader( text:text )
						@system = importer.read()
						@edit @system.root
						@update_all()
				'theme': (theme)=>
					if theme != win.Theme
						win.Theme = theme
						$('#wrapper').css {backgroundColor:theme.color.background}
						@update_all()
				'search': (query)=>
					@search query
				'mediaurl': (url)=>
					@editor.set 'mediastate', ''
					clearTimeout @timer_check_media if @timer_check_media
					@timer_check_media = setTimeout ()=>
						@check_media url
						@timer_check_media = null
					, 500
					if url
						pos = @editor.get 'imgpos'
						@editor.set 'imgpos', 'above.desc' if not pos
					else
						@editor.set 'imgpos', ''
				'link': (url)=>
					return if not url
					if not url.match /^(\w+\:|\/)/gi
						@editor.set 'link', 'http://'+url
					pos = @editor.get 'linkpos'
					@editor.set 'linkpos', 'title' if not pos
					# clearTimeout @timer_check_link if @timer_check_link
					# @timer_check_link = setTimeout ()=>
					# 	@check_link url
					# 	@timer_check_link = null
					# , 500
				'rel_from': (link)=>
					to = @editor.get 'rel_to'
					@editor.set 'rel_to', '' if link == to
				'title description mediastate link linkstate featured  systemtext': =>
					data = @editor.get()
					clearTimeout @timer_data_update if @timer_data_update
					@timer_data_update = setTimeout ()=>
						new_data = @editor.get()
						# if model changed since changes observed, save old data
						if new_data.id != data.id
							@save data
						else
							@save new_data
							@redraw new_data.id
						@timer_data_update = null
					, 500
					
			autosave = setInterval( =>
				@system.save 'autosave'
				@save_settings()
			, 10000)
			
			# import picture by dragging
			imgType = /image.*/
			maxImgSize = 500000
			picZone = $ '#picture-preview, #model-image'
			picZone.on('dragover', (e)->
				e.preventDefault()
				picZone.addClass 'fileover'
				false
			).on('dragleave', (e)->
				e.preventDefault()
				picZone.removeClass 'fileover'
				false
			).on('drop', (e)=>
				e.preventDefault()
				picZone.removeClass 'fileover'
				data = e.originalEvent.dataTransfer
				file = data.files[0]
				if data.types[0].match(imgType) or file.type.match(imgType)
					if file and file.size < maxImgSize
						@import_picture file
				false
			)
			foundImage = false
			paste_mode = ''
			picZone.on 'paste', (e)=>
				paste_mode = ''
				data = e.originalEvent.clipboardData
				if data.items  # Chrome
					item = data.items[0]
					if data.types[0].match(imgType) or item.type.match(imgType)
						file = item.getAsFile()
						if file and file.size < maxImgSize
							e.preventDefault()
							paste_mode = 'auto'
							@import_picture file
							return false

			# on picture paste for Firefox
			if $.browser.firefox
				pasteCatcher = $('<div />').attr("contenteditable","true")
					.css({"position" : "absolute", "left" : "-999", width : "0", height : "0", "overflow" : "hidden", outline : 0})
					.appendTo('body')   # for FF
				ctrl_pressed = false
				pasteCatcher.on 'DOMSubtreeModified.pasteimg', =>
					return true if paste_mode == 'auto' or not ctrl_pressed
					child = pasteCatcher.children().last().get(0)
					if child
						if child.tagName == "IMG" and child.src.substr(0, 5) == 'data:'
							@import_picture_src child.src
					else
						@import_picture_src pasteCatcher.text()
					setTimeout ( -> pasteCatcher.html ''), 100
				picZone.on 'keydown.pasteimg', (e)=>
					key = e.keyCode
					if key == $.key.Ctrl or e.metaKey or e.ctrlKey
						ctrl_pressed = true if not ctrl_pressed
					if key == $.key.V and (e.ctrlKey or e.metaKey) and not e.altKey
						if ctrl_pressed
							pasteCatcher.focus()
				$win.on 'keyup.pasteimg', (e)=>
					if ctrl_pressed
						key = e.keyCode
						if key == $.key.Ctrl or e.metaKey or e.ctrlKey
							ctrl_pressed = false
							$('#model-image').focus() 
			
			# dropzone to import system
			dropZone = $ '#wrapper'
			dropZone.on('dragover', (e)->
				e.preventDefault()
				dropZone.addClass 'fileover'
				false
			).on('dragleave', (e)->
				e.preventDefault()
				dropZone.removeClass 'fileover'
				false
			).on('drop', (e)=>
				e.preventDefault()
				dropZone.removeClass 'fileover'
				file = e.originalEvent.dataTransfer.files[0]
				if file and file.size < 1000000
					@import_json file
				false
			)
		
		print: ->
			# set zoom for print
			win.viewer.zoom Theme.maxzoom
			win.print()
			@update_all()

		import_json: (file)->
			reader = new FileReader()
			reader.onload = (e)=>
				data = e.target.result
				@system.deserialize data
				@edit @system.root
				@update_all()
				reader = null
			reader.readAsText file
			
		import_picture: (file)->
			reader = new FileReader()
			reader.onload = (e)=>
				data = e.target.result
				@editor.set 'mediaurl', data
				@update_this()
				reader = null
			reader.readAsDataURL file
		
		import_picture_src: (src)->
			@editor.set 'mediaurl', src
			@update_this()
		
		media_form: (f)->
			$('button[data-target="#insert-media"]'+(if f then ':not(.active)' else '')).click()
			$('#model-image').focus().select()
		
		video_provider: (url)->
			v =
				video: null
				preview: null
			# youtube
			if m = url.match /(?:https?\:\/\/)?(?:www\.)?(?:youtu\.be\/|youtube\.com(?:\/embed\/|\/v\/|\/watch\?v=|\/watch\?.+&v=))([\w-]{11})/i
				id = m[1]
				v.preview = 'http://i.ytimg.com/vi/'+id+'/hqdefault.jpg'  # OR  http://img.youtube.com/vi/<id>/0.jpg / TODO: pick correct url by get_video_info ??
				v.video = '<iframe src="//www.youtube.com/embed/'+id+'" width="420" height="315" frameborder="0" allowfullscreen></iframe>' # TODO: size of iframe
			# vimeo
			else if m = url.match /(?:https?\:\/\/)?(?:\w+.)?vimeo\.com\/(?:video\/|moogaloop\.swf\?clip_id=)?(\w+)/i
				id = m[1]
				v.preview = 'http://i.vimeocdn.com/video/'+id+'_640.jpg'  # INCORRECT! TODO: pick correct url by http://vimeo.com/api/v2/video/<id>.php'->thumbnail_large/ http://i.vimeocdn.com/video/<photo_id>_640.jpg
				v.video = '<iframe src="//player.vimeo.com/video/'+id+'?color=ffffff" width="500" height="281" frameborder="0" allowfullscreen></iframe>' # TODO: size of iframe
			# dailymotion
			else if m = url.match /(?:https?\:\/\/)?(?:www\.)?dailymotion\.com\/(?:embed\/)?video\/([^_#\?]+)/i
				id = m[1]
				v.preview = 'http://s2.dmcdn.net//GmQgw//x240-AbD.jpg'  # INCORRECT! TODO: pick correct url by https://api.dailymotion.com/video/<id>?fields=title,description,created_time,owner.screenname,tags,thumbnail_url,thumbnail_large_url,url
				v.video = '<iframe src="//www.dailymotion.com/embed/video/'+id+'" width="480" height="270" frameborder="0" allowfullscreen></iframe>' # TODO: size of iframe
			# rutube - TODO
			return v
		
		check_video: (url)->
			dfrd = $.Deferred()
			# check service
			v = @video_provider url
			if v.video
				@editor.set
					preview: v.preview
					video: v.video
			else
				@editor.set
					preview: null
					video: null
				dfrd.reject()
				return dfrd
			# show preview image
			@load_picture v.preview, =>
				@editor.set {mediastate: 'success'}
				@show_media_preview true
				dfrd.resolve()
			, =>
				@editor.set {mediastate: 'warning'}
				@media_preview_error()
				dfrd.resolve()
			dfrd
		
		check_image: (url)->
			@load_picture url, =>
				@editor.set {mediastate: 'success'}
				@show_media_preview()
			, =>
				@editor.set {mediastate: 'error'}
				@media_preview_error()
			
		check_media: (url)->
			@hide_media_preview()
			if not url
				@editor.set
					mediastate: ''
				return
			@check_video(url).fail => @check_image url
			
		load_picture: (url, do_success, do_fail)->
			# if image in cache
			if @images[url] and @images[url].img
				do_success()
				return
			# load image
			image_tag = $ '<img src="'+url+'" style="visibility:hidden;">'
			image_tag.appendTo '#cache'
			imgscale = @editor.get('imgscale') || 1
			@media_preview_loading()
			# on success
			image_tag.on 'load', =>
				@images[url] =
					img: image_tag
					size: image_tag.width()+'x'+image_tag.height()
				image_tag.hide()
				@editor.set
					imgsize: @images[url].size
					imgscale: imgscale
				do_success()
			# on error
			image_tag.on 'error', =>
				@images[url] =
					img: null
					size: null
				image_tag.hide()
				@editor.set
					imgsize: ''
					imgscale: imgscale
				do_fail()

		show_media_preview: (is_video)->
			url = @editor.get(if is_video then 'preview' else 'mediaurl')
			if @images[url] and @images[url].img
				img = @images[url].img
				$('#picture-preview').empty().append img
				img.show().css 'visibility', 'visible'
			if is_video
				play_btn = $('<div class="play"><i class="fa fa-5x fa-play"></i></div>').on 'click', =>
					$('#video-preview').modal 'toggle'
				$('#picture-preview').append play_btn

		hide_media_preview: ->
			img = $('#picture-preview').find('img')		
			img.css('visibility', 'hidden').hide().appendTo('#cache')
			$('#picture-preview').html '<i class="fa fa-image fa-5x text-muted"></i>'
			
		media_preview_loading: ->
			$('#picture-preview').html '<i class="fa fa-circle-o-notch fa-spin fa-2x text-muted"></i>'

		media_preview_error: ->
			$('#picture-preview').html '<i class="fa fa-eye-slash fa-5x text-muted"></i>'

		link_form: ->
			$('button[data-target="#insert-link"]').click()
			$('#model-link').focus().select()

		check_link: (url)->
			if not url
				@editor.set
					linkstate: ''
				return
			# if link in cache
			if @external_links[url]
				@editor.set
					linkstate: if @external_links[url].valid then 'success' else 'error'
				return @external_links[url]
			# link is incorrect URL
			if not /^((https?:)?\/\/)?((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|((\d{1,3}\.){3}\d{1,3}))(\:\d+)?(\/[-a-z\d%_.~+]*)*(\?[,;&a-z\d%_.~+=-]*)?(\#[-a-z\d_]*)?$/.test url
				@external_links[url] =
					valid: false
				@editor.set
					linkstate: 'error'
				return
			# check link
			$.ajax
				type: 'HEAD'
				url: url
				success: =>
					@external_links[url] =
						valid: true
					@editor.set
						linkstate: 'success'
				error: =>
					@external_links[url] =
						valid: false
					@editor.set
						linkstate: 'error'

		edit: (id)->
			model = @system[id]
			return unless model
			old = @editor.get 'id'
			# convert model to editable form
			# properties
			title = model.title || ''
			description = model.description || ''
			if model.link
				link = model.link.url || ''
				linkpos = model.link.pos || 'title'
			else
				link = linkpos = ''
			if model.picture
				image = model.picture.url
				imgsize = if model.picture.width > 0 && model.picture.height > 0 then model.picture.width+'x'+model.picture.height else ''
				imgpos = model.picture.pos
				imgscale = model.picture.scale || 1
				videopreview = model.picture.preview || ''
				videocode = model.picture.video || ''
			else
				image = imgsize = imgpos = imgscale = ''
			# elements and relations
			elements = []
			relations = []
			if model.matrix
				for row, i in model.matrix
					from = row[i]
					for m, j in row
						to = model.matrix[j][j]
						if m
							arr = if i==j then elements else relations
							arr.push
								title: @system[m].nav_title()
								link: m
								from: from
								to: to
			# siblings
			parent = @system.parent_of id
			siblings = if parent then @children_of parent else null
			is_element = false
			if siblings # is not root
				for e in siblings.elements
					if e.link == id
						is_element = true
						break
			else # is root
				is_element = true
			# editable model
			editable =
				# super
				id: id
				is_element: is_element
				parent: parent
				siblings: siblings
				changed: (id != old) # if model changed, set focus to title
				selected: @selected
				# -
				title: title
				description: description
				mediaurl: image
				mediastate: if @images[image] then (if @images[image].img then 'success' else 'error') else null
				imgsize: imgsize
				imgpos: imgpos
				imgscale: imgscale
				preview: videopreview
				video: videocode
				link: link
				linkpos: linkpos
				linkstate: if @external_links[link] then (if @external_links[link].iframe then 'success' else 'error') else null
				featured: model.featured
				# sub
				structure: model.structure
				elements: elements
				relations: relations
			@editor.set editable
			@show_hierarchy id
			# highlight current model
			win.modelview.highlight id
			# show form over element
			@pos_editor id
			$('#form').show() if not @editor.get 'onlytext-visible'
			
		edit_title: ->
			$('#model-title').focus().select() # TODO remake to decorator?
			
		pos_editor: (id)->
			el = win.viewer.find id
			if el[0]
				o = el.offset()
				w = el[0].getBoundingClientRect().width
				top  = Math.max $('#modeller').offset().top, Math.min o.top, $('body').height()-$('#form').outerHeight(true)
				left = Math.min o.left+w, $('body').width()-$('#form').outerWidth(true)
			else
				top  = 100
				left = 0
			$('#form').css
				left: left
				top: top
		
		redraw: (id, locate)->
			win.modelview.model = @system
			win.modelview.redraw id
			# win.viewer.find_and_zoom id if locate  ## TODO: remove locate param in calls
			# highlight current model
			current = @editor.get 'id'
			win.modelview.highlight current
			selected = @editor.get 'selected'
			win.modelview.select selected
		
		update: (id)->
			id = @editor.get 'id' if not id
			@edit id
			@redraw id

		update_this: ->
			data = @editor.get()
			@save data
			@redraw data.id

		update_all: ->
			data = @editor.get()
			@save data
			@redraw @system.root
			
		focus_this: ->
			el = @editor.get 'id'
			win.viewer.find_and_zoom el

		focus_all: ->
			win.viewer.find_and_zoom @system.root

		show: (id)->
			# win.viewer.find_and_zoom id
			# win.viewer.find_and_pan id TEMP
			$('#tree-'+id).scrollintoview()
			@edit id
			@focus_this() if win.viewer.is_too_big id
			
		show_edit: (id)->
			$('#tree-'+id).scrollintoview()
			@edit id
			@focus_this() if win.viewer.is_too_big id
			@edit_title()

		remove: (model)->
			# TODO: delete from story
			# delete only elements with empty structure and not root element
			if model.elements.length==0 and model.parent
				@system[model.parent].delete_child model.id
				# go to parent
				win.viewer.find_and_zoom model.parent
				@edit model.parent

		children_of: (el)=>
			matrix = @system[el].matrix
			children =
				elements: []
				relations: []
			if matrix
				for row, i in matrix
					for el, j in row
						continue if not el
						arr = if i==j then children.elements else children.relations
						arr.push
							title: @system[el].nav_title()
							link: el
							found: el in @filtered
				children
			else
				null

		rebuild_matrix: ->
			elements = @editor.get 'elements'
			return null if not elements or elements.length==0
			# generate matrix with elements
			new_matrix = []
			for el, i in elements
				row = []
				for el2, j in elements
					row.push(if i==j then el.link else null)
				new_matrix.push row
			# fill new matrix with relations
			relations = @editor.get 'relations'
			if relations and relations.length>0
				for el, i in elements
					for el2, j in elements
						for r in relations
							if r.from==new_matrix[i][i] and r.to==new_matrix[j][j]
								new_matrix[i][j] = r.link
			new_matrix
			
		show_hierarchy: (id)->
			# system tree
			tree = []
			add_obj = (obj, level)=>
				tree.push
					title: @system[obj].nav_title()
					link: obj
					level: level
					found: obj in @filtered
					f: @system[obj].featured
				matrix = @system[obj].matrix
				if matrix
					for row, i in matrix
						add_obj row[i], level+1 if row[i]
					for row, i in matrix
						for el, j in row
							add_obj el, level+1 if el and i!=j
			add_obj @system.root, 0
			# hierarchy
			hierarchy = [ { title: @system[id].nav_title(), link: id } ]
			child = id
			all_parents = false
			while not all_parents
				parent = @system.parent_of child
				if parent
					hierarchy[0].siblings = @children_of parent
					hierarchy.unshift
						title: @system[parent].nav_title()
						link: parent
						found: parent in @filtered
					child = parent
				else
					all_parents = true
			@editor.set
				system: tree
				hierarchy: hierarchy

		save: (fields)->
			fields = @editor.get() if not fields
			@write_history fields.id
			data =
				title: fields.title
				description: fields.description
				featured: fields.featured
			if fields.mediastate != 'error' and fields.mediaurl
				isize = fields.imgsize.split 'x'
				data.picture =
					url: fields.mediaurl
					pos: fields.imgpos
					width: isize[0]
					height: isize[1]
					scale: fields.imgscale || 1
					preview: fields.preview || ''
					video: fields.video || ''
			else if fields.mediastate == ''
				data.picture = null
			# if fields.linkstate
			if fields.link
				data.link =
					url: fields.link
					pos: fields.linkpos
			else
				data.link = null
			if fields.elements and fields.elements.length > 0
				data.structure = fields.structure
				data.matrix = @rebuild_matrix()
			else
				data.structure = null
				data.matrix = null
			$.extend @system[fields.id], data
			@show_hierarchy fields.id

		write_history: (id)->
			data = @system.serialize()
			@history.save {data:data, id:id}
			@menu.set
				is_undo: @history.is_undo()
				is_redo: @history.is_redo()
		
		model_name: ->
			@system[@system.root].nav_title().replace(/\s/gi, '_').replace(/[^a-z0-9_]/gi, '-').toLowerCase()

		change_sibling: (dir)->
			id = @editor.get 'id'
			len = @editor.get 'hierarchy.length'
			if len > 0
				el_rel = @editor.get 'hierarchy.'+(len-1)+'.siblings'
				return if not el_rel
				siblings = if el_rel.relations then $.merge el_rel.elements, el_rel.relations else el_rel.elements
				for el, current in siblings
					break if el.link == id
				i = Math.max(0, Math.min(siblings.length-1, current+dir))
				sibling = siblings[i]
				@show sibling.link
		
		change_current: (dir)->
			id = @editor.get 'id'
			S = @editor.get 'system'
			for el, current in S
				break if el.link == id
			i = Math.max(0, Math.min(S.length-1, current+dir))
			other = S[i]
			@show other.link
		
		move_level_higher: ->
			parent = @editor.get 'parent'
			return if not parent
			grand_parent = @system.parent_of parent
			return if not grand_parent
			id = @editor.get 'id'
			@write_history id
			@system[parent].delete_child id, true
			@system[grand_parent].create_child id
			@redraw grand_parent
			@show id
			
		move_level_lower: ->
			parent = @editor.get 'parent'
			return if not parent
			id = @editor.get 'id'
			sibling = @system[parent].next_sibling id
			return if not sibling
			above = @editor.get 'hierarchy.length'
			below = @system.depth_of id
			return if above+below >= @Settings.maxLevel  # do not move if levels limit reached
			
			@write_history id
			@system[parent].delete_child id, true
			@system[sibling].create_child id
			@redraw parent
			@show id
		
		move_same_level: (dir)->
			parent = @editor.get 'parent'
			return if not parent
			id = @editor.get 'id'
			@write_history id
			@system[parent].move_child id, dir
			@redraw parent
			@show id
		
		select: ->
			id = @editor.get 'id'
			if @editor.get('parent') and @editor.get('is_element')
				win.modelview.select id
				@selected = id
		
		move_into: ->
			target = @editor.get 'id'
			parent = @system.parent_of @selected
			return if not parent or parent == target
			above = @editor.get 'hierarchy.length'
			below = @system.depth_of @selected
			return if above+below >= @Settings.maxLevel  # do not paste if levels limit reached
			
			@write_history target
			@system[parent].delete_child @selected, true
			@system[target].create_child @selected
			@redraw parent
			@redraw target
			@show target
			win.modelview.deselect()
			@selected = null
		
		export_file: (filename, data)->
			url = window.URL.createObjectURL data
			a = $('<a>').attr('download', filename).attr('href', url)
			a[0].click()
			setTimeout ()->
				window.URL.revokeObjectURL url
				a.remove()
			, 10
			
		search: (query)->
			if query == ''
				@filtered = []
				@search_query = ''
				@editor.set 'filtered', []
				return
			if @search_query != query
				@search_from = null
				@search_query = query
				@filtered = @system.findAll(query)
				filtered = []
				for el in @filtered
					filtered.push
						link: el
						title: @system[el].nav_title()
				@editor.set 'filtered', filtered
			# !!! doesn't work for now:
			id = @system.find query, @search_from
			if id
				@edit id
				@show id
			@search_from = id
			
		load_file: (data)->
			@system.deserialize data
			@edit @system.root
			@update_all()
			
		create: ->
			@system = new S
				root: 'iSystem'
				iSystem: new A { title: 'New system' }
			@edit @system.root
			@update_all()
		
		apply_settings: (settings)->
			panels = settings.panels
			if panels
				$.extend @panels, panels
				@sidebar.set
					help_visible: panels.help
					storyboard_visible: panels.storyboard
				@editor.set
					tree_visible: panels.tree
					onlytext_visible: panels.onlytext
				@menu.set 'panels', panels
				viewer.update_minimap()
		
		load_settings: ->
			s = localStorage.getItem 'editor'
			settings = JSON.parse s
			@apply_settings settings if settings
					
		save_settings: ->
			settings =
				panels: @panels
			s = JSON.stringify settings
			localStorage.setItem 'editor', s	
			
)(jQuery, window, document)