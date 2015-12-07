"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win

	# -import plain text, -import text, -text reader
	class win.TEXTreader
		constructor: (options)->
			defaults =
				text: {}
			@opt = $.extend {}, defaults, options
			@lines = @opt.text.split '\n'
			@i = 0
			@build_content()
		build_content: ->
			@read()
		read_element: (lines, el)->
			line = lines[0]
			# pick title
			m = line.match /^\-\s(.*)$/
			title = m[1] if m
			j = 1
			struct = []
			desc = []
			while lines[j] and lines[j].substr(0,2)=='  '
				line = lines[j].replace(/^\s\s/,'')
				j++
				continue if not line
				# test for link
				m = line.match /^\[(.*)\]$/
				if m
					link = m[1]
					skip = true
				else
					# test for illustration
					m = line.match /^Илл\.\:\s(.*)$/
					if m
						ill = m[1]
						skip = true
					else
						skip = false
				# pick structure
				if line.substr(0,2)=='  ' or line.substr(0,2)=='- '
					struct.push line
				# rest is for description
				else
					desc.push line if not skip
			description = desc.join '\n'
			el.title = title || ''
			el.description = description || ''
			el.link = {url:link} if link
			el.picture = {url:ill, width: 100, height: 100} if ill
			@read_structure struct, el
		read_structure: (lines, el)->
			children = lines.join '\n'
			return if not children
			children = children.split '\n- '
			for child, i in children
				child = '- '+child if i>0
				lines = child.split '\n'
				C = el.create_child()
				C = @system[C]
				@read_element lines, C
			el.structure = 'list.bricks'
		read: ->
			@system = new S
				root: 'iSystem'
				iSystem: new A { title: 'New' }
			@read_element @lines, @system.iSystem
			@system
			
)(jQuery, window, document)