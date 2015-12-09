"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win
	
	win.editor = win.viewer = null
	win.system = win.empty_system
	win.system.reload 'autosave'
	
	$win.load ->
		win.Theme = win.Themes[0]
		win.viewer = new Viewer
			div: 'canvas'
		win.modelview = new ModelWebViewEditable
			div: 'canvas'
			model: system
		#win.DasModel.show_story()

		win.editor = new Editor system
		win.editor.edit system.root
		
		win.editor.load_settings()
	
	# responces on extension's messages
	# win.addEventListener "message", (event)->
	# 	# We only accept messages from ourselves
	# 	return if event.source != win
	# 	if event.data.type
	# 		if event.data.type == "SAVE"
	# 			win.postMessage { type: "DATA", system: system.serialize() }, "*"
	# 		else if event.data.type == "LOAD"
	# 			editor.load_file event.data.system
	# , false

)(jQuery, window, document)