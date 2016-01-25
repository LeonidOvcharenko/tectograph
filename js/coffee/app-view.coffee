"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win
	
	def = $.Deferred()
	
	# load from params
	s = location.hash.substring 1
	s = s.split '##'
	if s[0]
		url = s[0]
		$.ajax(
			url: url
			crossDomain: true
			contentType: "application/json"
			success: (data)->
				system = new S {}
				system.deserialize data
				def.resolve system
		)
		.fail -> def.resolve system7
	else
		def.resolve system7
	style = if s[1]!='' then Math.min(win.Themes.length-1, parseInt s[1]) else 1
	
	$win.load ->
		$.when(def).then (s) ->
			win.system = s
			win.Theme = win.Themes[style]
			win.viewer = new Viewer
				div: 'canvas'
				# smooth: true
			win.modelview = new ModelWebView
				div: 'canvas'
				model: system
			doc.title = system[system.root]?.title || 'Tectogram'
			
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