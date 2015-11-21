"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win
	
	win.system = system7
	$win.load ->
		win.Theme = win.ThemeSerif
		win.viewer = new Viewer
			div: 'canvas'
			# smooth: true
		win.modelview = new ModelWebView
			div: 'canvas'
			model: system
			
		# win.modelviewstatic = new ModelStaticView
		# 	div: 'static'
		# 	model: system
		# bbox = modelviewstatic.object.bbox()
		# $('#static').css
		# 	position: 'absolute'
		# 	width: bbox.width
		# 	height: bbox.height
		# 	top: 0
		# 	left: 0
		# 	zIndex: 99999
		# 	background: 'white'

)(jQuery, window, document)