"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win
	
	win.Render =
		init: ->
			$('<div id="t" />').appendTo 'body'
		balance_text: (text, fs, width)->
			# normalize
			fsn = Theme.minfontsize*3
			width = width*fsn/fs
			fs = fsn
			text = text.replace /\n/g, ' '
			# count rows
			div = $('#t').show()
			div.text(text)
			div.css
				position: 'absolute'
				visibility: 'hidden'
				width: width+'px'
				'font-size': fs+'px'
				'line-height': Theme.lineHeight
				'white-space': 'normal'
			h1 = div.height()
			div.css
				width: 'auto'
				'white-space': 'nowrap'
			h2 = div.height()
			rows = Math.round(h1/h2)
			$('#t').hide()
			# make balanced linebreaks
			row_length = Math.floor(text.length/rows)
			i = 0
			while (i<=text.length and i>=0)
				i += row_length
				i = text.indexOf(' ', i-2)
				text = text.substring(0,i)+'\n'+text.substring(i+1, text.length) if i>0
			lines = text.split '\n'
			lines
			
	win.GraphLayout =
		matrix: null
		padding: 0

		min_block_dist: (node1, node2)->
			(node1.dia/2 + node2.dia/2 + @params.margin) * @params.reducer

		min_block_dist_dyn: (node1, node2)->
			if node1.x and node2.x and node1.y and node2.y
				a = Math.sqrt( (node1.h+node2.h)*(node1.h+node2.h)/4 + (node1.x-node2.x)*(node1.x-node2.x) )
				b = Math.sqrt( (node1.w+node2.w)*(node1.w+node2.w)/4 + (node1.y-node2.y)*(node1.y-node2.y) )
				c = (node1.dia/2 + node2.dia/2 + @params.margin) * @params.reducer
				Math.min( Math.min(a, b), c )
			else
				@min_block_dist node1, node2

		arrange: ->
			@init_edges()
			# params of Fruchterman-Reingold algorithm
			@params =
				mind2: 0.0001 # 0.01
				mind: 0.01 # 0.1
				speed: 0.1 # 0.01
				maxVertexMovement: 0.5
				maxRepulsiveForceDistance2: 0.5*0.5
				k: 1/Math.sqrt(4*@V)
				l: 0.005 # 1/Math.sqrt(@V)     # natural spring length
			# total area of graph nodes
			S = 0
			for row in @matrix
				for m in row
					S += m.bbox.width * m.bbox.height if m
			# params of displaying
			@params.W = 3 * Math.sqrt(S) # area length
			@params.margin = @params.W * 0.03 # guaranteed block margin
			@params.reducer = Math.sqrt(2)/@params.W
			@params.restorer = 1/@params.reducer
			
			for edge in @edges
				edge.min_len = @min_block_dist edge.from.node, edge.to.node
			
			# iterate distances
			Rand.reset()
			@graph_layout_iteration() for [0..100]
			
			@layout_arrange()
			
		init_edges: ->
			@edges = []
			@V = @matrix.length
			for row, i in @matrix
				for m, j in row
					if m and i!=j
						@edges.push
							from: @matrix[i][i]
							to: m
							arrow: false
						@edges.push
							from: m
							to: @matrix[j][j]
							arrow: true
						@V++
				
		graph_layout_iteration: ->
			# Forces on nodes due to node-node repulsions
			prev = []
			for row, i in @matrix
				for m1, j in row
					if m1
						for m in prev
							m2 = @matrix[ m[0] ][ m[1] ]
							@layout_repulsive m1.node, m2.node
						prev.push [i, j]
			# Forces on nodes due to edge attractions
			for edge in @edges
				@layout_attractive edge
			# Move by the given force
			for row in @matrix
				for m in row
					@layout_move m if m
			
		layout_repulsive: (node1, node2)->
			dx = node1.x - node2.x
			dy = node1.y - node2.y
			d2 = dx * dx + dy * dy
			if d2 < @params.mind2
				dx = @params.mind * Rand.random() + @params.mind
				dy = @params.mind * Rand.random() + @params.mind
				d2 = dx * dx + dy * dy
			k = Math.max @params.k, @min_block_dist(node1, node2)
			if d2 < @params.maxRepulsiveForceDistance2 and d2 > 0
				# repulsive force: f.r(x) = k^2 / x
				f = k * k / d2
				move_x = f * dx   # move_x = f.r(d) * dx / d
				move_y = f * dy   # move_y = f.r(d) * dy / d
				node2.move_x -= move_x
				node2.move_y -= move_y
				node1.move_x += move_x
				node1.move_y += move_y

		layout_attractive: (edge)->
			node1 = edge.from.node
			node2 = edge.to.node
			dx = node1.x - node2.x
			dy = node1.y - node2.y
			d2 = dx * dx + dy * dy
			if d2 < @params.mind2
				dx = @params.mind * Rand.random() + @params.mind
				dy = @params.mind * Rand.random() + @params.mind
				d2 = dx * dx + dy * dy
			d = Math.sqrt d2
			k = Math.max @params.k, edge.min_len
			# attractive force: f.a(x) = x^2 / k
			f = d / k
			move_x = f * dx   # move_x = f.a(d) * dx / d
			move_y = f * dy   # move_y = f.a(d) * dy / d
			node2.move_x += move_x
			node2.move_y += move_y
			node1.move_x -= move_x
			node1.move_y -= move_y

		layout_move: (m)->
			xmove = @params.speed * m.node.move_x
			ymove = @params.speed * m.node.move_y
            # limit displacement
			max = @params.maxVertexMovement
			xmove = max  if xmove > max
			xmove = -max if xmove < -max
			ymove = max  if ymove > max
			ymove = -max if ymove < -max
			# move node
			m.node.x += xmove
			m.node.y += ymove
			m.node.move_x = 0
			m.node.move_y = 0
			
		layout_bounds: ->
			minx = miny = Infinity
			maxx = maxy = -Infinity
			for row in @matrix
				for m in row
					if m
						minx = Math.min minx, m.node.x
						miny = Math.min miny, m.node.y
						maxx = Math.max maxx, m.node.x
						maxy = Math.max maxy, m.node.y
			@graph = { minx: minx, miny: miny, maxx: maxx, maxy: maxy }
			
		layout_arrange: ->
			padding_x = Theme.cellp[@level-1]
			for row in @matrix
				for m in row
					if m
						m.node.x = m.node.x * @params.restorer - m.bbox.width/2 + @padding
						m.node.y = m.node.y * @params.restorer - m.bbox.height/2 + @padding
			# move top left corner of graph to 0,0
			@layout_bounds()
			for row in @matrix
				for m in row
					if m
						m.node.x -= @graph.minx
						m.node.y -= @graph.miny
						m.object.move m.node.x, m.node.y
			
	# .object
	# .render()
	# .bbox()
	# model: { w, h, color }
	class win.VectorObj
		constructor: (options)->
			defaults =
				model: {}
				level: 0
				canvas: null
				x: 0
				y: 0
				w: 0
				h: 0
			@opt = $.extend {}, defaults, options
			@model = @opt.model
			@level = @opt.level
			@draw  = @opt.canvas
			@x = @opt.x
			@y = @opt.y
			@w = @opt.w
			@h = @opt.h
			@id = @opt.id
			@ready = @opt.ready
			@fontsize1 = Theme.sizes[@level]
			@fontsize2 = Theme.sizes[@level+1]
			@fontsize3 = Theme.sizes[@level+2]
			@spacesize1 = Theme.spaces[@level]
			@spacesize2 = Theme.spaces[@level+1]
			@block_spacing = Theme.spaces[@level+1]-Theme.cellp[@level+1]*2
		
		render: ->
			@object = @draw.rect(@model.w, @model.h).attr({ fill: @model.color })
			@object.drawer = @
			
		bbox: -> @object.bbox()
			
	# model: { system, title, description, image... }
	class win.Element extends VectorObj
		constructor: (options)-> super options
		
		render: ->
			@object = @draw.group().data('level', @level)
			@object.attr 'data-model', @id
			@object.drawer = @
			@pad = Theme.cellp[@level-1]
			# make frame for active object
			@element_frame()
			# init offsets
			title_x = image_x = image_x2 = desc_x = @x+@pad
			title_y = image_y = desc_y = @y+@pad
			max_w = desc_w = Theme.width[@level]
			# title row
			if @model.picture and @model.picture.pos == 'left.title'
				box = @render_icon title_x, title_y
				title_x += box.width+@fontsize2
			if @model.title
				box = @render_title title_x, title_y
				# image_x = desc_x = box.x
				image_x2 = box.x2
				image_y = desc_y = box.y2+@fontsize3
				title_x += box.width+@fontsize2
				max_w = desc_w = Math.max desc_w, box.width
			if @model.picture and @model.picture.pos == 'right.title'
				box = @render_icon title_x, title_y
			# picture + description
			if @model.picture and @model.picture.url
				if @model.picture.pos == 'left.desc'
					box = @render_image image_x, image_y
					desc_x += box.width+@fontsize2
					desc_w = Math.max(0, desc_w-box.width-@fontsize2)
				else if @model.picture.pos == 'right.desc'
					box = @render_image(Math.max(image_x+Theme.width[@level], image_x2), image_y, true)
					desc_w = Math.max(0, desc_w-box.width-@fontsize2)
				else if @model.picture.pos == 'above.desc'
					box = @render_image image_x, image_y
					desc_y += box.height+@fontsize2
			if @model.description
				desc_w = Math.min(desc_w, Theme.width[@level])
				box = @render_description(desc_x, desc_y, desc_w)
				image_y = box.y2+@fontsize2
				if @model.picture and @model.picture.pos == 'right.desc'
					@ra_img.x box.x2+@fontsize2
			if @model.picture and @model.picture.pos == 'below.desc'
				@render_image image_x, image_y
			# structure
			if @model.structure
				@render_structure(@x, @bbox().y2 || @y, max_w || 0)
			@fix_frame()
		
		iconic_picture: (x, y)->
			pw = @model.picture.width
			ph = @model.picture.height
			ysize = @fontsize1*Theme.lineHeight
			xsize = if pw > 0 then ysize/ph*pw else ysize
			url = @model.picture.preview || @model.picture.url
			img = @draw.image(url, xsize, ysize).move(x, y).back()
			img

		render_icon: (x, y)->
			img = @iconic_picture x, y
			if @model.picture.video
				img.addClass('pointer').click ()=>
					win.open @model.picture.url, '_blank'
			@object.add img
			img.bbox()

		text_mask: (bbox, level)->
			mask = @draw.rect(bbox.width, bbox.height).addClass('mask').attr('data-level',level).move(bbox.x, bbox.y).fill(Theme.color.mask)
			@object.add mask
			mask.back().hide()

		render_title: (x, y)->
			base = @draw
			if @model.link and @model.link.url and @model.link.pos == 'title'
				base = @draw.link(@model.link.url)
				base.target('_blank').addClass('pointer')
				title = base
			text = base.plain(@model.title).font({size: @fontsize1, family: Theme.fontFamily, leading: Theme.lineHeight+'em'}).attr('data-level',@level).move(x, y)
			# append link if exists
			# if 0 and @model.link.url
			# 	# TODO: MAKE VISIBLE LINK ON PRINT/PICTURE VIEW
			# 	# link = text.tspan ' ➦'
			# 	link = text.tspan ' ' # font awesome external link character
			# 	link.addClass('pointer fa').fill Theme.color.link
			# 	link.click ()=>
			# 		win.open @model.link.url, '_blank'
			# 	# link = @draw.link(@model.link.url).target('_blank')
			# 	# link.plain ' '
			# 	# link.addTo text
			# 	link.mouseover -> @fill Theme.color.link_hover
			# 	link.mouseout -> @fill Theme.color.link

			# correct min width
			text.build true
			w = text.bbox().width
			while w < Theme.spaces[@level]
				text.plain ' ' # nbsp here
				w = text.bbox().width
			text.build false
			text.fill if @model.featured then Theme.color.emphasis else Theme.color.text
			title = text if not title
			
			@object.add title
			bbox = text.bbox()
			@text_mask bbox, @level
			bbox
			
		balance_text: (w)->
			description = @model.description.split '\n'
			lines = []
			for paragraph in description
				if paragraph.match /[^\s]/g
					balanced = Render.balance_text paragraph.replace(/(\s+)$/g, ''), @fontsize2, w
				else
					balanced = [' ']
				$.merge lines, balanced
			lines
		
		render_description: (x, y, w)->
			lines = @balance_text w
			link = if @model.link and @model.link.url and @model.link.pos == 'desc' then @model.link.url else null
			text = @draw.text( (add)=>
				add.tspan(line).newLine() for line in lines
				# simulated link
				if link
					linkobj = add.tspan ' ➦'
					linkobj.addClass('pointer fa').fill Theme.color.link
					linkobj.click ()=>
						win.open @model.link.url, '_blank'
			).font({size: @fontsize2, family: Theme.fontFamily, leading: Theme.lineHeight+'em'}).attr('data-level',@level+1).move(x, y).fill(Theme.color.text)
			@object.add text
			bbox = text.bbox()
			@text_mask bbox, @level+1
			bbox
		
		sized_picture: (x, y, alignright)->
			pw = @model.picture.width
			ph = @model.picture.height
			if @model.picture.scale
				pw *= @model.picture.scale
				ph *= @model.picture.scale
			xsize = Theme.imgsize[@level]*(if pw > 0 then Math.min(1, pw/Theme.max_imgwidth) else 1)
			ysize = if pw > 0 then xsize/pw*ph else xsize
			x -= xsize if alignright
			url = @model.picture.preview || @model.picture.url
			img = @draw.image(url, xsize, ysize).move(x, y).back()
			img
		
		render_image: (x, y, alignright)->
			img = @sized_picture x, y, alignright
			if @model.picture.video
				img.addClass('pointer').click ()=>
					win.open @model.picture.url, '_blank'
			@ra_img = img if alignright
			@object.add img
			img.bbox()
		
		render_structure: (x, y, w, ready)->
			w = Theme.width[@level] if not w
			@structure = new Structure
				model: @model
				level: @level
				canvas: @draw
				x: x
				y: y
				w: w
				ready: ready
				EL: @constructor
			@structure.render()
			@structure.object.dmove Theme.cellp[@level-1]-Theme.cellp[@level], @fontsize2
			@object.add @structure.object
			
		# for editable
		
		rerender_structure: (pH={only:''})->
			bbox = @structure.object.bbox()
			# save old elements, remove old structure
			ready = {}
			objects = $('#wrapper svg').find('g')
			@model.each_child (m)=>
				return if m.id == pH.only
				el = objects.filter('[data-model="'+m.id+'"]')[0]    # TODO: ?
				ready[m.id] = el.instance if el
			@structure.object.remove()
			# render new structure
			@render_structure bbox.x-Theme.cellp[@level-1]+Theme.cellp[@level], bbox.y-@fontsize2, 0, ready
			@fix_frame()
			
		element_frame: ->
			frame_stroke = { color: Theme.color.background, width: Theme.strokes[@level-1] }
			@frame = @draw.rect(1, 1).radius(@pad).fill('none').stroke(frame_stroke)
			@frame.addClass('frame none').move(@x, @y)
			@object.add @frame
			
		fix_frame: ->
			@frame.back().size 1, 1
			fullbox = @bbox()
			@frame.size fullbox.width/@object.trans.scaleX+@pad, fullbox.height/@object.trans.scaleY+@pad

	class win.Element_NoFrame extends Element
		constructor: (options)-> super options
		rerender_structure: ->
			
	class win.Element_Plain extends Element_NoFrame
		constructor: (options)-> super options

		render_icon: (x, y)->
			img = @iconic_picture()
			@object.add img
			img.bbox()

		render_title: (x, y)->
			text = @draw.plain(@model.title).font({size: @fontsize1, family: Theme.fontFamily, leading: Theme.lineHeight+'em'}).attr('data-level',@level).move(x, y)
			text.build true
			w = text.bbox().width
			while w < Theme.spaces[@level]
				text.plain ' ' # nbsp here
				w = text.bbox().width
			text.build false
			text.fill Theme.color.emphasis if @model.featured
			title = text if not title
			@object.add title
			bbox = text.bbox()
			bbox

		render_description: (x, y, w)->
			lines = @balance_text w
			link = if @model.link and @model.link.url then @model.link.url else null
			text = @draw.text( (add)=>
				add.tspan(line).newLine() for line in lines
				if link
					linkobj = add.tspan(link).newLine()
					linkobj.fill Theme.color.link
			).font({size: @fontsize2, family: Theme.fontFamily, leading: Theme.lineHeight+'em'}).attr('data-level',@level+1).move(x, y)
			@object.add text
			bbox = text.bbox()
			bbox

		# TODO: fire when all images are embedded + caching on server is needed
		embed_image: (loaded, object)->
			canvas = doc.createElement 'CANVAS'
			context = canvas.getContext '2d'
			img = new Image
			img.setAttribute 'crossorigin', 'anonymous'
			img.onload = =>
				canvas.height = loaded.height
				canvas.width = loaded.width
				context.drawImage img, 0, 0
				try
					dataURL = canvas.toDataURL 'image/png'
				catch
					dataURL = loaded.url   # embed failed, store original url
				object.loaded ->  # do nothing
				object.load dataURL
				canvas = null
			img.onerror = =>
				canvas = null
			img.src = loaded.url
		
		render_image: (x, y, alignright)->
			img = @sized_picture x, y, alignright
			img.loaded (loaded)=>
				@embed_image loaded, img
			@ra_img = img if alignright
			@object.add img
			img.bbox()
			
	# model: { structure, matrix, system }
	class win.Structure extends VectorObj
		constructor: (options)-> super options
		
		render: ->
			# debugger
			@stroke = { color: Theme.color.stroke, width: Theme.strokes[@level] }
			@object = @draw.group().data('level', @level)
			@object.drawer = @
			switch @model.structure
				when 'list.bricks'
					@render_list_compact()
				when 'list.inline'
					@render_list_inline()
				when 'list.stack'
					@render_list_stack()
				when 'matrix'
					@render_matrix()
				when 'graph'
					@render_graph()
					
		render_element: (model)->
			if @ready and @ready[model.id]   # use already rendered object
				object = @ready[model.id]
			else
				element = new @opt.EL
					id: model.id
					model: model
					level: @level+1
					canvas: @draw
					x: @x
					y: @y
				element.render()
				object = element.object
			object

		# -compact list, -bricks
		render_list_compact: ->
			x = 0
			above = y = 0
			draw_child = (model)=>
				object = @render_element model
				@object.add object
				this_bbox = object.bbox()
				object.move x, y
				# fix element position
				if x+@block_spacing+this_bbox.width > @w
					if x > 0   # if not first element in line
						# start new line
						object.dmove(-x, above)
						x = 0
						y += above
					above = this_bbox.height
				else
					above = Math.max(above, this_bbox.height)
				x += this_bbox.width+@block_spacing
			@model.each_element (model)=> draw_child model
			@model.each_relation (model)=> draw_child model

		# -inline list
		render_list_inline: ->
			@matrix = []
			relations = false
			x = 0
			@model.each_element (model, i)=>
				# element
				src_obj = object = @render_element model
				@object.add object
				object.x x
				# relations
				@matrix.push []
				y = 0
				for rel, j in @model.matrix[i]
					@matrix[i].push(if i==j then {object: src_obj} else null)
					continue if j==i or not @model.system[rel]
					y += object.rbox().height
					object = @render_element @model.system[rel]
					@object.add object
					object.move x, y
					@matrix[i][j] = {object: object}
					relations = true
				x = @object.bbox().width+@block_spacing
			if relations
				@render_nodes(false)
				@render_edges()

		# -stack list
		render_list_stack: ->
			@matrix = []
			relations = false
			R = @fontsize2/8
			Yoffset = @y+Theme.cellp[@level]+@fontsize2*0.57+R
			y = 0
			@model.each_element (model, i)=>
				# element
				src_obj = object = @render_element model
				@object.add object
				object.y y
				# bullet
				bullet = @draw.circle(R*2).fill(Theme.color.bullet).center(R, Yoffset+y)
				@object.add bullet
				bullet.back()
				# relations
				@matrix.push []
				x = 0
				for rel, j in @model.matrix[i]
					@matrix[i].push(if i==j then {object: src_obj} else null)
					continue if j==i or not @model.system[rel]
					x += object.rbox().width
					object = @render_element @model.system[rel]
					@object.add object
					object.move x, y
					@matrix[i][j] = {object: object}
					relations = true
				y = @object.bbox().height
			if relations
				@render_nodes(false)
				@render_edges()
		
		arrange_matrix: ->
			p = Theme.cellp[@level-1]
			# calculate sizes of matrix cells
			@cols_w = []
			@cols_w.push(p) for i in [0...@matrix.length]
			@rows_h = []
			@rows_h.push(p) for i in [0...@matrix.length]
			for row, i in @matrix
				for el, j in row
					continue if not el
					@rows_h[i] = Math.max(@rows_h[i], el.bbox.height)
					@cols_w[j] = Math.max(@cols_w[j], el.bbox.width)
			# arrange elements in cells
			y = 0
			for row_h, i in @rows_h
				x = 0
				for col_w, j in @cols_w
					el = @matrix[i][j]
					el.object.move(x, y) if el
					x += col_w
				y += row_h
		
		render_grid: ->
			mh = 0
			mh += row for row in @rows_h
			mw = 0
			mw += col for col in @cols_w
			# draw vertical lines
			x = @x
			for i in [0...@cols_w.length-1]
				x += @cols_w[i]
				line = @draw.line(x, @y, x, @y+mh).stroke(@stroke)
				@object.add line
				line.back()
			# draw horizontal lines
			y = @y
			for i in [0...@rows_h.length-1]
				y += @rows_h[i]
				line = @draw.line(@x, y, @x+mw, y).stroke(@stroke)
				@object.add line
				line.back()
			# draw rectangle
			rect = @draw.rect(mw, mh).move(@x, @y).fill('none').stroke(@stroke)
			@object.add rect
			rect.back()

		render_elements_links: ->
			@matrix = []
			for links, i in @model.matrix
				@matrix[i] = []
				for element_tag, j in links
					@matrix[i][j] = null
					continue if not element_tag
					model = @model.system[element_tag]
					object = @render_element model
					@object.add object
					bbox = object.bbox()
					@matrix[i][j] =
						object: object
						bbox: bbox
						node:
							x: 0
							y: 0
							move_x: 0
							move_y: 0
							dia: Math.sqrt(bbox.width * bbox.width + bbox.height * bbox.height)
							h: bbox.height
							w: bbox.width
							is_element: i==j

		# -matrix
		render_matrix: ->
			@render_elements_links()
			@arrange_matrix()
			@render_grid()

		arrange_graph: ->
			GraphLayout.matrix = @matrix
			GraphLayout.padding = Theme.cellp[@level-1]
			GraphLayout.arrange()
		
		render_nodes: (show_elements)->
			padding_x = Theme.cellp[@level]
			for row, i in @matrix
				for m, j in row
					if m
						bbox = m.object.bbox()
						rbox = m.object.rbox()
						rect = @draw.rect(bbox.width, bbox.height).radius(padding_x).move(rbox.x, rbox.y).fill(Theme.color.background)
						if i==j and show_elements
							rect.stroke @stroke
						else
							rect.opacity Theme.rel_opacity
						@object.add rect
						rect.back()

		# -arrow
		make_arrow_marker: ->
			p = Theme.markersize   # actually all markers are of one size, auto resizing accordingly to stroke width
			@arrow = @draw.marker 4*p, 4*p, (add)->
				add.path('M 0,'+2*p+' L'+4*p+','+3*p+' L'+3*p+','+2*p+' L'+4*p+','+p+' Z')
			@arrow.fill @stroke.color  # Theme.color.stroke
		
		closest_point: (points, p)->
			minw = Infinity
			closest = null
			for c, i in points
				dx = p.x - c.x
				dy = p.y - c.y
				w = dx*dx + dy*dy
				if minw > w
					minw = w
					closest = c
			closest
		
		# -connection
		connect_objects: (p0, p1, p2)->
			# make control points - edges
			edge_points = [
				{x: p1.cx, y: p1.cy-p1.height/2},
				{x: p1.cx-p1.width/2, y: p1.cy},
				{x: p1.cx, y: p1.cy+p1.height/2},
				{x: p1.cx+p1.width/2, y: p1.cy}
			]
			cp1 = @closest_point edge_points, {x: p0.cx, y: p0.cy}
			cp2 = @closest_point edge_points, {x: p2.cx, y: p2.cy}
			# draw line
			#   method 1: via relation center, edgy
			# path = 'M '+p0.cx+','+p0.cy
			# path += ' Q '+cp1.x+','+cp1.y+' '+p1.cx+','+p1.cy
			# path += ' Q '+cp2.x+','+cp2.y+' '+p2.cx+','+p2.cy
			p1c =
				x: (cp1.x+cp2.x)/2
				y: (cp1.y+cp2.y)/2
			#   method 2: cubic splines via relation center, curvy
			# path = 'M '+p0.cx+','+p0.cy
			# path += ' C '+cp1.x+','+cp1.y+' '+p1c.x+','+p1c.y+' '+p1.cx+','+p1.cy
			# path += ' S '+cp2.x+','+cp2.y+' '+p2.cx+','+p2.cy
			#   method 3: optimal, smoothy
			path = 'M '+p0.cx+','+p0.cy
			path += ' Q '+cp1.x+','+cp1.y+' '+p1c.x+','+p1c.y
			path += ' Q '+cp2.x+','+cp2.y+' '+p2.cx+','+p2.cy
			line = @draw.path(path).fill('none').stroke(@stroke)
			@object.add line
			line.back()
			# draw arrows
			edge_length = line.length()
			# create a helper line
			make_helper = (pos)=>
				dp = 0.01
				hp1 = line.pointAt pos*edge_length
				hp2 = line.pointAt (pos-dp)*edge_length
				helper = @draw.line(hp1.x, hp1.y, hp2.x, hp2.y).stroke({ width: @stroke.width, color: Theme.color.stroke })
				helper.marker 'start', @arrow
				@object.add helper
				helper.back()
				# IE fix
				if !!navigator.userAgent.match(/(MSIE\s)|(Trident.*rv\:11\.)/)
					# helper.marker 'start', @arrow
					# helper.plot hp1.x, hp1.y, hp2.x, hp2.y
					parent = helper.node.parentNode
					parent.removeChild helper.node
					parent.appendChild helper.node
			# find intersection of line and box
			inside = (box, p)-> p.x>box.x and p.x<box.x2 and p.y>box.y and p.y<box.y2
			find_intersection = (box, from, to)=>
				e1 = from
				e2 = to
				while Math.abs(e2-e1) > 0.01
					eC = (e1+e2)/2
					if inside box, line.pointAt(eC*edge_length)
						e1 = eC
					else
						e2 = eC
				(e1+e2)/2
			# find any point at line inside the box
			any_point_inside = (box, from, to)=>
				e1 = Math.min from, to
				e2 = Math.max from, to
				while e2>e1
					break if inside box, line.pointAt(e1*edge_length)
					e1 += 0.01
				e1
			ipA = find_intersection p0, 0, 1
			ipB = find_intersection p2, 1, 0
			ipC = any_point_inside p1, ipA, ipB
			ip1 = find_intersection p1, ipC, ipA
			ip2 = find_intersection p1, ipC, ipB
			# make arrows in the middle of visible part of connection
			make_helper (ipA+ip1)/2
			make_helper (ipB+ip2)/2

		render_edges: ->
			@make_arrow_marker()
			for row, i in @matrix
				for m, j in row
					if m and i!=j
						p1 = m.object.rbox()
						p0 = @matrix[i][i].object.rbox()
						p2 = @matrix[j][j].object.rbox()
						@connect_objects p0, p1, p2

		# -graph
		render_graph: ->
			@render_elements_links()
			@arrange_graph()
			@render_nodes true
			@render_edges()

	# SVG renderer for web -view
	class win.ModelWebView
		constructor: (options)->
			@EL = Element_NoFrame
			@init options
			return null if not SVG.supported
			Render.init()
			@build_content()
			@controller()
			
		init: (options)->
			defaults =
				div: 'canvas'
				model: {}
			@opt = $.extend {}, defaults, options
			@div = $ '#'+@opt.div
			@model = @opt.model
		
		build_content: ->
			viewer.scale_content = (scale)=>
				padding = @padding_x * scale
				@object.scale(scale).move(padding, padding)
				@apply_text_masks()
			@draw = SVG(@opt.div).size('100%', '100%')
			@padding_x = Theme.cellp[Theme.toplevel-1]
			@padding_f = Theme.cellp[Theme.toplevel]
			@render_all()

		controller: ->
		
		render_all: ->
			@render()
			viewer.zoom_fit @object

		render: ->
			# @controls.set 'is_drawing', true
			model = @model[@model.root]
			system = new @EL
				id: @model.root
				model: model
				level: Theme.toplevel
				canvas: @draw
			system.render()
			@object = system.object
			@correct_canvas()
			# @controls.set 'is_drawing', false
			
		correct_canvas: ->
			bbox = @object.bbox()
			neww = bbox.width + @padding_x*2*viewer.scale
			newh = bbox.height+ @padding_x*2*viewer.scale
			@div.css
				width: neww
				height: newh
			viewer.save_canvas_size neww/viewer.scale, newh/viewer.scale
		
		rerender: ->
			@draw.clear()
			viewer.zoom 1
			@render_all()
			
		redraw: (tag)->
			if tag == @model.root
				@rerender()
				return
			el = @div.find('g[data-model="'+tag+'"]')[0]
			return if not el
			# @controls.set 'is_drawing', true
			parent_obj = el.instance.parent.parent
			parent_tag = parent_obj.attr 'data-model'
			parent = parent_obj.drawer
			parent.model = @model[parent_tag]
			parent.rerender_structure {only: tag}
			@correct_canvas()
			@apply_text_masks()
			# @controls.set 'is_drawing', false
			
		apply_text_masks: ->
			# apply text masking for small font sizes
			level = Theme.threshold viewer.scale
			texts = @div.find('text').show()
			texts.filter( ()-> $(@).attr('data-level') >= level ).hide()
			masks = @div.find('rect.mask').hide()
			masks.filter( ()-> $(@).attr('data-level') >= level ).show()
			
	# SVG renderer for web -editing
	class win.ModelWebViewEditable extends ModelWebView
		constructor: (options)->
			@EL = Element
			@init options
			return null if not SVG.supported
			Render.init()
			@build_content()
			@controller()
		
		frame_for: (tag, c)->
			@div.find('g[data-model="'+tag+'"]>rect.frame').svgRemoveClass('none').svgAddClass c
		no_frames: (c) ->
			@div.find('rect.frame.'+c).svgRemoveClass c
			@div.find('rect.frame:not(.current):not(.selected)').svgAddClass 'none'
		
		select: (tag)->
			@no_frames 'selected'
			@frame_for tag, 'selected' 
		deselect: ->
			@no_frames 'selected'
		
		highlight: (tag)->
			@no_frames 'current'
			@frame_for tag, 'current' 
	
	# SVG renderer for -print or -file export
	class win.ModelStaticView
		constructor: (options)->
			@EL = Element_Plain
			@init options
			return null if not SVG.supported
			Render.init()
			@build_content()
		
		build_content: ->
			@draw = SVG(@opt.div).size('100%', '100%')
			@render()
		
		render: ->
			model = @model[@model.root]
			system = new @EL
				id: @model.root
				model: model
				level: Theme.toplevel
				canvas: @draw
			system.render()
			@object = system.object
		
)(jQuery, window, document)