"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win

	class win.Viewer
		constructor: (options)->
			defaults =
				div: 'canvas'
				model: {}
				smooth: false
				svg: null
			@opt = $.extend {}, defaults, options
			@div = $ '#'+@opt.div
			@wrapper = @div.parent()
			@build_content()
			@controller()
		
		build_content: ->
			@scale = 1
			@save_canvas_size()
			@controls = new Ractive
				el: 'controls'
				template: '#map-controls'
				data:
					zoomlock: ''
					is_drawing: false
					progress: 0
			@minimap = $ '#minimap .model'
			@viewport = $ '#minimap .view'
			@quickdrag = $ '#minimap .map'
			
			@wrapper.addClass 'drag'
			@div.addClass 'smooth-transform' if @opt.smooth
			$('#wrapper').css {backgroundColor: Theme.color.background}
			@update_minimap()
		
		controller: ->
			@controls.on
				'zoom-in': =>
					@zoom_step true
				'zoom-out': =>
					@zoom_step false
			$win.on 'keydown.viewer', (e)=>
				@wrapper.addClass 'zoom_fit' if e.which == $.key.Ctrl
				if $.activeInput()
					return true
				# Shift+key
				else if e.shiftKey
					switch e.which
						when $.key.Plus, $.key.Plus_num
						# zoom in
							@zoom_step true
						when $.key.Minus, $.key.Minus_num
						# zoom out
							@zoom_step false
						when $.key.Up
						# pan up
							@pan_step 0, +1
						when $.key.Down
						# pan down
							@pan_step 0, -1
						when $.key.Left
						# pan left
							@pan_step +1, 0
						when $.key.Right
						# pan right
							@pan_step -1, 0
						else
							return true
					return false
				# key
				else
					switch e.which
						when $.key.Plus, $.key.Plus_num
						# zoom in
							@zoom_step true
						when $.key.Minus, $.key.Minus_num
						# zoom out
							@zoom_step false
						when $.key.n8_num
						# pan up
							@pan_step 0, +1
						when $.key.n2_num
						# pan down
							@pan_step 0, -1
						when $.key.n4_num
						# pan left
							@pan_step +1, 0
						when $.key.n6_num
						# pan right
							@pan_step -1, 0
						when $.key.n7_num
						# pan up-left
							@pan_step +1, +1
						when $.key.n9_num
						# pan up-right
							@pan_step -1, +1
						when $.key.n1_num
						# pan down-left
							@pan_step +1, -1
						when $.key.n3_num
						# pan down-right
							@pan_step -1, -1
						else
							return true
					return false
				true
			$win.on 'keyup.viewer', (e)=>
				@wrapper.removeClass 'zoom_fit' if e.which == $.key.Ctrl
			# zoom on mousewheel
			@wrapper.on 'mousewheel.viewer', (e)=>
				@fix_point e.pageX-@wrapper.offset().left, e.pageY-@wrapper.offset().top
				factor = if e.deltaY > 0 then @Settings.zoomInStep else @Settings.zoomOutStep
				@zoom_by factor
				false
			# dragging
			@wrapper.on 'mousedown.viewer', (e)=>
				$.clearSelection()
				doc.activeElement.blur() if $.activeInput()
				if e.ctrlKey
					el = $(e.target).closest('g')[0]
					@zoom_fit el.instance if el
					return
				@wrapper.addClass 'dragging'
				@dragging =
					x: e.clientX,
					y: e.clientY
				e.preventDefault()
				false
			@wrapper.on 'mousemove.viewer', (e)=>
				return if not @dragging
				@div.removeClass 'smooth-transform' if @opt.smooth
				@pan_by e.clientX-@dragging.x, e.clientY-@dragging.y
				@dragging.x = e.clientX
				@dragging.y = e.clientY
			$win.on 'mouseup.viewer', (e)=>
				# $.clearSelection()
				@wrapper.trigger 'mousemove', e
				@wrapper.removeClass 'dragging'
				@dragging = null
				@div.addClass 'smooth-transform' if @opt.smooth
			# quick dragging
			@quickdrag.on 'mousedown.viewer', (e)=>
				$.clearSelection()
				doc.activeElement.blur() if $.activeInput()
				@wrapper.addClass 'dragging'
				@dragging =
					x: e.clientX,
					y: e.clientY
				e.preventDefault()
				false
			@quickdrag.on 'mousemove.viewer', (e)=>
				return if not @dragging
				@div.removeClass 'smooth-transform' if @opt.smooth
				@pan_by (e.clientX-@dragging.x)*5, (e.clientY-@dragging.y)*5
				@dragging.x = e.clientX
				@dragging.y = e.clientY
			# resize
			$win.on 'resize.viewer', (e)=>
				@update_minimap()
			# after smooth canvas resize
			if @opt.smooth
				@div.on 'transitionend webkitTransitionEnd oTransitionEnd', (e)=>
					@update_minimap()
		
		Settings:
			zoomInStep: 1.25
			zoomOutStep: 0.8
			panStep: 100 # px
			minisize: 0.05
			miniH: 100 # px
			miniW: 100 # px
			# minZoom: 0.01
			# maxZoom: 50.0
				
		save_canvas_size: (w, h)->
			@original_width  = w || @div.width()
			@original_height = h || @div.height()
		
		update_minimap: ->
			# mini viewport
			vw = @wrapper.width()*@Settings.minisize
			vh = @wrapper.height()*@Settings.minisize
			vl = (@Settings.miniW-vw)/2
			vt = (@Settings.miniH-vh)/2
			@viewport.css
				width: vw
				height: vh
				left: vl
				top: vt
			# mini model map
			mw = @div.width() * @Settings.minisize
			mh = @div.height() * @Settings.minisize
			dp = @div.position()
			ml = dp.left * @Settings.minisize + vl
			mt = dp.top * @Settings.minisize + vt
			@minimap.css
				width: mw
				height: mh
				left: ml
				top: mt
				
		lock_zoom: (param)->
			@controls.set 'zoomlock', param
			
		zoom_step: (zoomin)->
			@fix_point @wrapper.width()/2, @wrapper.height()/2
			factor = if zoomin then @Settings.zoomInStep else @Settings.zoomOutStep
			@zoom_by factor
				
		zoom_by: (factor)->
			@scale = Math.max(Theme.minzoom, Math.min(Theme.maxzoom, @scale*factor))
			@apply_scale()
			
		zoom: (zoom)->
			@scale = zoom
			@apply_scale()

		scale_content: (scale)->
			# console.log 'TODO: scale content for canvas to',scale

		apply_scale: ->
			@lock_zoom(if @scale==Theme.minzoom then 'min' else if @scale==Theme.maxzoom then 'max' else '')
		
			# gather the old properties
			oldw = @div.width()
			oldh = @div.height()
			oldpos = @div.position()

			# compute the new width and height
			neww = @original_width * @scale
			newh = @original_height * @scale
			# compute the new left and top
			newl = @fixed_x + (neww / oldw) * (oldpos.left - @fixed_x)
			newt = @fixed_y + (newh / oldh) * (oldpos.top - @fixed_y)

			# limit the new left and top to the new mins and maxes
			newl = Math.min(Math.max(newl, -neww), @wrapper.width())
			newt = Math.min(Math.max(newt, -newh), @wrapper.height())

			# save all the property updating to last
			@div.css
				width: neww
				height: newh
				left: newl
				top: newt
			
			@scale_content @scale
			@update_minimap()
			
		pan_by: (dx, dy)->
			# calculate new left and top
			oldpos = @div.position()
			newl = oldpos.left+dx
			newt = oldpos.top+dy
			# limit the new left and top to the new mins and maxes
			newl = Math.min(Math.max(newl, -@div.width()), @wrapper.width())
			newt = Math.min(Math.max(newt, -@div.height()), @wrapper.height())
			# set properties
			@div.css
				left: newl
				top: newt
			@update_minimap()
				
		pan_step: (dx, dy)->
			@pan_by dx*@Settings.panStep, dy*@Settings.panStep

		fix_point: (x, y)->
			@fixed_x = x
			@fixed_y = y
			
		zoom_fit_all: ->
			@fix_point 0, 0
			@scale = Math.min @wrapper.height()/@div.height(), @wrapper.width()/@div.width()
			@apply_scale()
			
		# methods for editor: on canvas — SVG object
		find: (tag)->
			@div.find('g[data-model="'+tag+'"]')

		find_and_zoom: (tag)->
			el = @div.find('g[data-model="'+tag+'"]')[0]
			@zoom_fit el.instance if el

		find_and_pan: (tag)->
			el = @div.find('g[data-model="'+tag+'"]')[0]
			@pan_to el.instance if el
			
		pan_to: (el)->
			rbox = el.rbox()
			@div.css
				left: -rbox.cx+@wrapper.width()/2
				top: -rbox.cy+@wrapper.height()/2 # -rbox.y #
			@update_minimap()
			
		zoom_fit: (el)->
			@fix_point 0, 0
			rbox = el.rbox()
			factor = Math.min (@wrapper.height()-Theme.margin)/rbox.height, (@wrapper.width()-Theme.margin)/rbox.width
			@zoom_by factor
			rbox = el.rbox()
			@div.css
				left: -rbox.cx+@wrapper.width()/2
				top:  -rbox.cy+@wrapper.height()/2
			@update_minimap()
				
		in_center: ->
			p = @wrapper.offset()
			x = p.left + @wrapper.width()/2
			y = p.top  + @wrapper.height()/2
			node = doc.elementFromPoint x, y
			el = if node then $(node).closest('g').data('model') else null
			return el
			
		is_too_big: (tag)->
			el = @div.find('g[data-model="'+tag+'"]')[0]
			if el
				rbox = el.instance.rbox()
				return @wrapper.height()<rbox.height || @wrapper.width()<rbox.width
			else
				false
		
		show_slide: (el)->
			node = @div.find('[data-model='+el+']')[0]
			@zoom_fit node.instance if node
		
		show_story: ->
			return if not @model.story
			$.each @model.story, (i, el)=>
				$doc.queue 'slides', ()=>
					setTimeout( ()=>
						@show_slide el
						$doc.dequeue 'slides'
					, Theme.slideshow)
			$doc.dequeue 'slides'
				
		destroy: ->
			@div.empty()

)(jQuery, window, document)