"use strict";	

RegExp.escape = (text)->
	text.replace /[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&"
	
# -random ~pseudo
Rand =
	seed: 1
	reset: -> @seed = 1
	random: ->
		@seed = @seed*40692%2147483399
		@seed/2147483399

# jQuery object extentions
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win	

	$.key =
		Enter: 13
		Esc: 27
		Down: 40
		Up: 38
		Left: 37
		Right: 39
		Tab: 9
		Backspace: 8
		Space: 32
		Plus: 187
		Minus: 189
		Slash_cyr: 190
		Slash: 191
		Shift: 16
		Ctrl: 17
		PgUp: 33
		PgDn: 34
		End: 35
		Home: 36
		Ins: 45
		Del: 46
		n1: 49
		n2: 50
		n3: 51
		n4: 52
		n5: 53
		A: 65
		D: 68
		F: 70
		G: 71
		H: 72
		I: 73
		J: 74
		K: 75
		L: 76
		R: 82
		S: 83
		T: 84
		U: 85
		V: 86
		W: 87
		X: 88
		Y: 89
		Z: 90
		n1_num: 97
		n2_num: 98
		n3_num: 99
		n4_num: 100
		n5_num: 101
		n6_num: 102
		n7_num: 103
		n8_num: 104
		n9_num: 105
		Star_num: 106
		Plus_num: 107
		Minus_num: 109
		Slash_num: 111

	$.activeInput = ->
		tag = doc.activeElement.tagName
		tag == "INPUT" || tag == "TEXTAREA" || tag == "SELECT"
	
	$.clearSelection = ->
		if doc.selection and doc.selection.empty
			doc.selection.empty
		else if win.getSelection
			sel = win.getSelection()
			sel.removeAllRanges()

	$.selectContents = (id)->
		el = doc.getElementById id
		range = doc.createRange()
		range.selectNodeContents el
		sel = win.getSelection()
		sel.removeAllRanges()
		sel.addRange range
		
	$.selection = ->
		s = ''
		if win.getSelection
			sel = win.getSelection()
			s = sel.toString()
		s
		
	$.escape = (text)->
		text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;")
		
	$.fn.svgRemoveClass = (c)->
		@.each (i, el)-> el.instance?.removeClass c
	
	$.fn.svgAddClass = (c)->
		@.each (i, el)-> el.instance?.addClass c
		
)(jQuery, window, document)