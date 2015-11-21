#!
"use strict";
!(($, win, doc) ->
	$doc = $ doc
	# !!! на цей момент body ще може не бути, якщо скрипт підключається на початку документа, а якщо вкінці, то ок
	$body = $ 'body'

	
	#///// ------- P = project global ------- ///////////////////////////////////////////////////////////////////////////////
	win.P = {}
	cMenu?.setSrcBase '/images/cMenu/'
	
	# returns http://domain.com/
	P.get_domain = (url)->
		url.replace(/(\/\/.+?\/).+/, '$1')
		
	P.prepare_favicon_src = (path, site_url)->
		if (path.match /^http/)
			path
		else
			P.get_domain(site_url ? g_pageData.url)+path.replace(/^\//, '')
		
	# P.get_tpl '#wnd.tpl .filter_line'
	P.get_tpl = (selector)->
		$(selector+'.tpl').clone().removeClass('tpl')
	
	$.fn.get_tpl = (selector)->
		@.find(selector+'.tpl').clone().removeClass('tpl')
	
	# .safe_dots()
	String::safe_dots = ->
		@.replace /\./g, '·'
	
	P.d_not_ready_msg = 'Feature is not implemented yet'
	
	$.fn.get_wnd = ->
		@.closest('.wnd').o()
	
	P.get_master_page_id = (page_id)->
		g_db.pages_data[page_id]?.part_of || page_id
	
	# розпізнаємо асоціації у тексті виду: [novyny≈новини] [polityka≈політика] [foto-novyny≈фото-новини] щопоаоп
	# [@assos, @text] = P.recognize_assos @phrase
	P.recognize_assos = (text)->
			assos = []
			text = text.replace /\[(.+?)≈(.+?)\] ?/g, (m, key, value)->
				assos.push {id:key, text:value}
				''
			[assos, text]
	
	#///// ------- /P = project global ------- ///////////////////////////////////////////////////////////////////////////////
	
	
	# .to_formatted 'yyyy-mm-dd HH:MM:SS'
	Date::to_formatted = (_format)->
		yyyy = @.getFullYear()
		m = @.getMonth()+1
		mm = ( m<10 && '0' || '' )+m
		d = @.getDate()
		dd = ( d<10 && '0' || '' )+d
		H = @.getHours()
		HH = ( H<10 && '0' || '' )+H
		M = @.getMinutes()
		MM = ( M<10 && '0' || '' )+M
		S = @.getSeconds()
		SS = ( S<10 && '0' || '' )+S
		_format.replace(/yyyy/, yyyy).replace(/mm/, mm).replace(/dd/, dd).replace(/HH/, HH).replace(/MM/, MM).replace(/SS/, SS)
	
	# should be string in format: '2012-08-30 13:20:20', '2013-03-25 00:00:00'
	String::UTC_time = ->
		parse_res = @.match(/(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)/)
		time_UTC = new Date(+RegExp.$1, +RegExp.$2-1, +RegExp.$3, +RegExp.$4, +RegExp.$5, +RegExp.$6)

	# should be string in format: '2012-08-30 13:20:20'
	String::UTC_to_local_time = ->
		time_local = new Date(@.UTC_time().getTime() - new Date().getTimezoneOffset()*60000)
		time_local

	
	
	class win.TrackableTimeout
		@active_timeoutsH: {}
		
		# TrackableTimeout.clear()
		@clear: ->
			@active_timeoutsH = {}
		
		# TrackableTimeout.active_count()
		@active_count: ->
			$.H_size @active_timeoutsH
		
		# TrackableTimeout.stop_all()
		@stop_all: ->
			for id of @active_timeoutsH
				clearTimeout id
		
		# TrackableTimeout.execute_and_stop_all_now()
		@execute_and_stop_all_now: ->
			@stop_all()
			# execute all functions
			fn() for id, fn of @active_timeoutsH
		
		# new TrackableTimeout 500, ->
		constructor: (delay, fn)->
			@id = $.run_after delay, =>
				fn()
				delete @constructor.active_timeoutsH[@id]
			@constructor.active_timeoutsH[@id] = fn
		
		destroy: ->
			clearTimeout @id
			delete @constructor.active_timeoutsH[@id]
	
	

	# for mixin
	#	include Button, Options
	# -- or --
	#	class win.Virtual_StreamPlate extends StreamPlate
	#		include @, Virtual
	win.extend = (obj, mixin) ->
		for name, method of mixin
			obj[name] = method

	win.include = (klass, mixin) ->
		extend klass::, mixin



	# !!!! remove from here
	# $.json
	$.json = (url, data, success)-> $.post(url, data, success, 'json')
	# $.sync_json
	$.sync_json = (url, data, success)->
		$.ajax {type:'POST', async:false, url, data, success, dataType:'json'}
	
	# транслітерація ------------------------------------------------------------------------------------------------------------
	# "цук".cyr2tr()
	# "цук".cyr2tr('rus')
	String.cyr2trH = {}
	String.cyr2trSc = {}
	String.cyr2trSen = {}

	# по мовам
	# 'ukr'
	# хеш для складних правил
	String.cyr2trH['ukr'] =
		'Щ':'Sch'
		'Ш':'Sh'
		'Є':'Je'
		'Ж':'Zh'
		'Ї':'Ji'
		'Ц':'Ts'
		'Ч':'Ch'
		'Ю':'Ju'
		'Я':'Ja'
		'щ':'sch'
		'ш':'sh'
		'є':'je'
		'ж':'zh'
		'ї':'ji'
		'ц':'ts'
		'ч':'ch'
		'ю':'ju'
		'я':'ja'
	# масиви для прямого перетворення
	String.cyr2trSc['ukr'] = 'ЙйУуКкЕеНнГгЗзХхФфІіВвАаПпРрОоЛлДдСсМмИиТтБбь'
	String.cyr2trSen['ukr'] = "JjUuKkEeNnGgZzHhFfIiVvAaPpRrOoLlDdSsMmYyTtBb'"
		
	# 'rus' (на основі 'ukr')
	# хеш для складних правил
	String.cyr2trH['rus'] = {}
	String.cyr2trH['rus'][k] = v for k, v of String.cyr2trH['ukr']
			
	# масиви для прямого перетворення
	String.cyr2trSc['rus'] = String.cyr2trSc['ukr']+'ЫыЁёЪъ'
	String.cyr2trSen['rus'] = String.cyr2trSen['ukr'].replace('Yy', 'Ii')+'YyEe  '
			
	String::cyr2tr = (lang='ukr')->
		res = ''
		
		# побуквенно замінюємо складні
		res = @.replace /./g, (m)->
			String.cyr2trH[lang][m] ? m
		
		# побуквенно прості
		res = res.replace /./g, (m)->
			i = String.cyr2trSc[lang].indexOf(m)
			if i>-1 then String.cyr2trSen[lang][i] else m
	# /транслітерація ------------------------------------------------------------------------------------------------------------
	
	String::prepare_for_sorting = ->
		@.toLowerCase().replace(/і/g, 'и').replace(/ї/g, 'и').replace(/є/g, 'е')

	String::strip = String::trim = ->
		@.replace(/^\s+|\s+$/g, '')
		
	String::escapeHTML2 = ->
		@.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&#34;').replace(/'/g, '&#39;')

	String::unescapeHTML2 = ->
		@.replace(/&amp;/g, '&').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&#34;/g, '"').replace(/&#39;/g, '\'')

	# прибиває теги в тексті
	String::stripTags2 = ->
		@.replace(/<\/?[^>]+>/gi, '')

			
		
	# -Hash size, -size hash
	$.H_size = (hash)->
		(k for k of hash).length
	
	# pull from array
	Array::pull = (args...)->
		output = []
		for arg in args
			index = @indexOf arg
			output.push @splice(index, 1)[0] if index isnt -1
		output = output[0] if args.length is 1
		output
	# повертає копію масива без вказаних елементів
	Array::without = (args...)->
		arr = @copy()
		arr.pull args...
		arr
	Array::copy = ->
		@concat()
	Array::with = (args...)->
		arr = @copy()
		arr.push arg for arg in args
		arr
	
	# -empty
	Array::is_empty = ->
		@.length == 0
	Array::not_empty = ->
		@.length > 0
	
	# .last()
	Array::last = (n)->
		n ?= 1
		@[@.length - n]
	
	# .includes(el)
	Array::includes = (el)->
		@indexOf(el) > -1
	
	
	# -sort_collection_by_text_in
	Array::sort_collection_by_text_in = (field)->
		@.sort (_a, _b)->
			a = _a[field].prepare_for_sorting()
			b = _b[field].prepare_for_sorting()
			switch
				when a==b then 0
				when a<b then -1
				else 1
	
	#///// ------- -$. ------- ///////////////////////////////////////////////////////////////////////////////
	
	# -preload images
	# $.preload 'popups/img1.png', '/images/img2.png'
	# *якщо шлях без / на початку, будується шлях від /images/
	$.preload = ->
		for src in arguments
			prefix = '/images/'
			prefix = '' if src.match /^\//
			(new Image).src = prefix+src
	
	# -get cookie
	# $.get_cookie 'search'
	$.get_cookie = $.gC = (name)->
		name = escape(name)
		pos = (' '+document.cookie).indexOf(' '+name+'=')
		if pos > -1
			start_pos = pos+name.length+1
			tc = document.cookie+';'
			end_pos = tc.indexOf(';', start_pos)
			decodeURIComponent tc.substring(start_pos, end_pos)
		else
			null
	
	# -del cookie
	# $.del_cookie 'search'
	$.del_cookie = (name)->
		document.cookie = name+'=; expires=Thu, 01 Jan 1970 00:00:01 GMT;'


	$.unprepare_url_param = (str)->
		str.replace(/_/g, ' ').replace(/:under:/g, '_').replace(/:plus:/g, '+')
	
	
	# -blink
	$.fn.blink = (pH={})->
		alpha = pH.alpha ? 0.2
		up_step = pH.up_step ? 0.02
		blinkCount = 0
		# зупиняємо Interval^@.t_blink
		if @.t_blink
			clearInterval @.t_blink
			@.t_blink = null
		@.t_blink = $.run_every 100, =>
			@.css(opacity:( if blinkCount % 2 then '' else alpha ))
			blinkCount++
			alpha += up_step
			alpha = 1 if (alpha > 1)
			if (blinkCount == 8)
				# зупиняємо Interval^@.t_blink
				if @.t_blink
					clearInterval @.t_blink
					@.t_blink = null

	
	$.fn.left_x = ->
		@.offset().left
	$.fn.right_x = ->
		@.left_x()+@.outerWidth()
	$.fn.top_y = ->
		@.offset().top
	$.fn.bottom_y = ->
		@.top_y()+@.outerHeight()
	
	# -prevent selection (-selection, -noSelect)
	# e.prevent_selection()
	$.Event::prevent_selection = ->
		$body.addClass 'noSelect'
		$doc.one 'mouseup', -> $body.removeClass 'noSelect'
	
	$.fn.enable_prevent_selection_on_mousedown = ->
		@.off '.enable_prevent_selection_on_mousedown'
		@.on 'mousedown.enable_prevent_selection_on_mousedown', (e)->
			e.prevent_selection()
	
	# -s 
	# filters_count+' filter'+$.s(filters_count)
	$.s = (number)->
		if (number > 1 || number == 0) then 's' else ''
	
	# -say
	# $.say('%N filter(s)', filters_count)
	$.say = (pattern, number)->
		pattern.replace('%N', number).replace('(s)', $.s number)
	
	# позиціонуємо елемент відносно іншого (-align)
	# @cont.align_to @target, 'left-bottom', calibrate
	$.fn.align_to = (target, mode, calibrate={})->
		# mode: 'left-bottom'
		calibrate.x ?= 0
		calibrate.y ?= 0
		
		offset = target.offset()
		parent_offset = @.parent().offset()
		@.css
			left: offset.left-parent_offset.left
			top: offset.top-parent_offset.top
		[h_mode, v_mode] = mode.split '-'
		dx = switch h_mode
			when 'right' then target.outerWidth()
			when 'center' then Math.round(target.outerWidth()/2)
			else 0
		dy = switch v_mode
			when 'bottom' then target.outerHeight()
			when 'center' then Math.round(target.outerHeight()/2)
			else 0
		@.css
			left: '+='+(dx+calibrate.x)
			top: '+='+(dy+calibrate.y)
				
	$.fn.enable_remove_html_on_paste = ->
		@.f_was_paste = false
		@.off '.enable_remove_html_on_paste'
		@.on 'input.enable_remove_html_on_paste', =>
			# при вставці чистимо текст від форматування і зайвих пробілів
			# курсор ставимо вкінці
			#!(пізніше) курсор бажано ставити після вставленого тексту, а не просто в кінці інпута
			if @.f_was_paste
				@.f_was_paste = false
				@.text @.text().strip()
				@.focusEnd()
			
		# *тут можна при потребі перехопити вміст кліпборда (цей івент йде перед 'input')
		# потрібно додати 2 рядки
		# handlepaste(@b[0], e)
		#		код цієї функції тут — D:\Designing\#Base\JS\handlepaste.js
		# e.originalEvent.clipboardData.getData() — це буде вміст
		@.on 'paste.enable_remove_html_on_paste', =>
			@.f_was_paste = true
		@
	
	# -make editable (-editable)
	$.fn.make_editable = (f_enable=true)->
		@.prop(contenteditable:f_enable)
		if f_enable
			@.addClass 'g_isEditable'
			# робимо, щоб на праву показувалося стандартне меню, але зберігаємо, щоб не втратити cMenu
			if @.data 'events'
				cMenu_handler = (event_handler for event_handler in @.data('events').contextmenu when event_handler.namespace == 'cMenu')[0]
				@.data was_cMenu_handler:cMenu_handler if cMenu_handler
			@.off 'contextmenu.cMenu'
			@.focusEnd()
		else
			@.blur()
			@.removeClass 'g_isEditable'
			# відновлюємо, якщо треба cMenu
			cMenu_handler = @.data 'was_cMenu_handler'
			if cMenu_handler
				@.removeData 'was_cMenu_handler'
				@.on 'contextmenu.cMenu', cMenu_handler
			# *це потрібно, щоб у FF не залишався мигаючий текстовий курсор
			win.getSelection().removeAllRanges() if @.is ':focus'
		@
			
	
	# -sort_children_by_text
	$.fn.sort_children_by_text = ->
		parent = @
		# формуємо масив слів з дівами
		words = []
		parent.children().each -> 
			el = $(@)
			words.push [el.text(), el]
		
		words = words.sort_collection_by_text_in(0)
		
		# пересортовуємо елементи
		for wordA in words
			el = wordA[1]
			el.appendTo parent
			
			
	# @div.force_reflow().addClass('in')
	# *допомагає, якщо css-анімація не спрацьовує при додаванні класа
	$.fn.force_reflow = ->
		# see http://stackoverflow.com/questions/9016307/force-reflow-in-css-transitions-in-bootstrap
		@[0].offsetWidth if $.support.transition
		@
		
	# @div.force_reflow().addClass('in').after_transition => @destroy()
	$.fn.after_transition = (fn)->
		if $.support.transition
			@one $.support.transition.end, fn
		else
			fn()
		
	
	# -make last event (-event, -chain, -first)
	# make last event handler to be first in chain to be able to cancel all other
	# div.make_last_event_handler_to_be_first 'mousedown'
	$.fn.make_last_event_handler_to_be_first = (evnt)->
		# це може бути селектор багатьох елементів, тому потрібно пройтися по всіх
		@.each ->
			el = $(@)
			handlers = el.data('events')[evnt]
			handlers.unshift handlers.pop()

	
	# usage
	# @hide(with_fade:true) if e.click_was_outside @cont
	$.Event::click_was_outside = (block)->
		f_nested_element_clicked = $.contains(block[0], @.target)
		# якщо клік не по блоку і не по дочірньому елементу блока — true
		!(block.is(@.target) || f_nested_element_clicked)

	# -css animate
	# $.is_css_animation_supported()
	$.is_css_animation_supported = ->
		unless $.f_is_css_animation_supported?
			$.f_is_css_animation_supported = false
			
			$.css_animation =
				param_name: 'animation'
				keyframeprefix: ''
			
			if doc.body.style.animationName
				$.f_is_css_animation_supported = true
			else
				domPrefixes = 'Webkit Moz O ms Khtml'.split ' '
				for pfx in domPrefixes
					if doc.body.style[pfx+'AnimationName']?
						$.css_animation.param_name = pfx+'Animation'
						$.css_animation.keyframeprefix = '-'+pfx.toLowerCase()+'-'
						$.f_is_css_animation_supported = true
						break
		$.f_is_css_animation_supported
	

	# -css animation (-animation)
	#	mask.css_animate
	#		animation: 'fade .3s ease-in'
	#		keyframes: "
	#			@~keyframes fade {
	#				from {opacity:1}
	#				to {opacity:0}
	#			}
	#		"
	#		fallback: -> mask.fadeOut 300
	#		on_finish: -> 
	#			mask.remove()
	#			$(win).trigger 'init_mask_removed'
	$.fn.css_animate = (pH)->
		{name, animation, keyframes, fallback, on_finish} = pH
		
		# розпізнаємо готові анімації
		if $.css_animation_by_name[name]
			{animation, keyframes} = $.css_animation_by_name[name]
		
		if $.is_css_animation_supported()
			@.css($.css_animation.keyframeprefix+'animation-fill-mode', 'forwards')
			keyframes = keyframes.replace(/~/g, $.css_animation.keyframeprefix)
			# add keyframes to css
			style_el = $ '<style>', 
								text: keyframes
								type: 'text/css'
			style_el.appendTo('head')
			# start animation
			@.css($.css_animation.param_name, animation)
			# @.on 'webkitTransitionEnd oTransitionEnd otransitionend transitionend msTransitionEnd', ->
			@.on 'animationend webkitAnimationEnd oanimationend MSAnimationEnd', =>
				@.css($.css_animation.param_name, '')
				# on_finish
				on_finish?()
		else
			if fallback?
				$.when(fallback()).then ->
					on_finish?()
	$.fn.stop_css_animation = ->
		if $.is_css_animation_supported()
			@.css($.css_animation.param_name, '')
	
	$.css_animation_by_name =
		blink:
			animation: 'blink 0.6s'
			keyframes: "
				@~keyframes blink {
					0%,            33.34%,         66.68%,           100% {opacity: 1}
						  16.67%,           50.01%,          83.35%         {opacity: 0.5}
				}
			"
		shake:
			animation: 'shake 0.4s'
			keyframes: "
				@~keyframes shake {
					0%, 100% {~transform: translateX(0)}
					20%, 60% {~transform: translateX(-5px)}
					40%, 80% {~transform: translateX(5px)}
				}
			"
		bounceIn:
			animation: 'bounceIn .2s ease-out'
			keyframes: "
				@~keyframes bounceIn {
					0% {
						opacity:0;
						~transform-origin: 40px -30px;
						~transform:scale(.2);
					}
					100% {
						opacity:1;
						~transform-origin: 40px -30px;
						~transform:scale(1);
					}
				}
			"


	# -Keys
	$.key = 
		Enter: 13
		Esc: 27
		Down: 40
		Up: 38
		Left: 37
		Right: 39
		Tab: 9
		Backspace: 8
	
	# ser cursor positions
	# *only for content editable elements
	$.fn.focusEnd = ->
		@.focus()
		text_nodes = @.contents().filter(->@.nodeType == 3)
		last_children = text_nodes.last()
		last_children.remove() if (last_children.text() == ' ')
		last_children = text_nodes.last()
		pos = last_children.text().length
		if pos
			range = doc.createRange()
			sel = win.getSelection()
			# range.setStart(@[0].childNodes[0], pos)
			range.setStart(last_children[0], pos)
			range.collapse(true)
			sel.removeAllRanges()
			sel.addRange(range)
		@
	
	# http://upshots.org/javascript/jquery-hittest
	$.fn.hitTest = (x, y)->
		bounds = @.offset()
		bounds.right = bounds.left + @.outerWidth()
		bounds.bottom = bounds.top + @.outerHeight()
		(x >= bounds.left && x <= bounds.right && y >= bounds.top && y <= bounds.bottom)
	
	
	#  (-o)
	# .o() — shortcut for  o = div.data 'o'
	# .o(obj) — shortcut for  div.data(o:obj)
	$.fn.o = (obj)->
		if obj then @.data(o:obj) else @.data 'o'
	
	# $.run_after 500, ->
	$.run_after = (delay, fn)-> setTimeout fn, delay
	
	# $.run_every 500, ->
	$.run_every = (delay, fn)-> setInterval fn, delay
	
	# підсвічуємо спалахом (-highlight, -hl)
	$.fn.hl = (pH={})->
		# *end_color: '#CCC'
		@.queue =>
			wasBgColor = @.css 'backgroundColor'
			if (wasBgColor == 'transparent' || wasBgColor == "rgba(0, 0, 0, 0)") then wasBgColor = 'white'
			end_color = pH.end_color || wasBgColor
			@.css(backgroundColor:'#FFF2BE')
			@.animate(backgroundColor: end_color, 1000, =>
				# restore transparency
				@.css(backgroundColor:'')
			)
			@.dequeue()

	$.fn.outerHTML = ->
		@.clone().wrap('<b>').parent().html()

	# -Hub
	#	@hub = new Hub
	#		ready: 'once memory'
	#	  -- or --
	# ask_for_username.hub.prepare('checked', 'once')
	# 
	# flags: 
	#		once: Ensures the callback list can only be fired once (like a Deferred).
	#		memory: Keeps track of previous values and will call any callback added after the list has been fired right away with the latest "memorized" values (like a Deferred).
	#		unique: Ensures a callback can only be added once (so there are no duplicates in the list).
	#		stopOnFalse: Interrupts callings when a callback returns false.
	#		* By default a callback list will act like an event callback list and can be "fired" multiple times.
	#!(пізніше) для оптимізації можна в конструктор передавати @ батьківського об’єкра і тоді робити проксі, щоб для батьківського можна було писати .on
	#	// proxy some methods to @hub
	#	for fn in ['on']
	#		@[fn] = $.proxy(@hub, fn)
	# usage
	# @wnd.hub.on 'close', (e)=>
	# 		e.reject() if @assos_ufd_select.dropdown_is_visible()
	class win.Hub
		# *при використанні не забувати у деструкторі @hub.destroy()
		#!(вроді) немає одноразової підписки
		constructor: (flags={})->
			@docsH = {}
			@once_fns = {}
			
			for msg, flag of flags
				@prepare(msg, flag)
			
		fire: (msg_str, args...)->
			dfrd = new $.Deferred()
			for msg in @get_msgs(msg_str)
				@docsH[msg]?.fire(dfrd, args...)
				# якщо для цього івента є фукнції, які мають виконатися once — йдемо по масиву і забираємо ці функції з коллбеків
				if @once_fns[msg]
					for fn in @once_fns[msg]
						@docsH[msg].remove fn
					@once_fns[msg] = []
			dfrd.resolve() unless dfrd.f_wait_for_resolve
			dfrd.promise()
		
		# can be used to set flag for some events
		# also can be used via constructor
		# @hub = new Hub
		# @hub.prepare('ready', 'memory')
		prepare: (msg, flags)->
			@docsH[msg] = $.Callbacks(flags)
		
		# .on 'shown'
		# .on 'hide destroy'
		on: (msg_str, fn)->
			for msg in @get_msgs(msg_str)
				@docsH[msg] ?= $.Callbacks()
				@docsH[msg].add fn
			
		# коллбек викличеться тільки раз, при першому такому fire
		once: (msg_str, fn)->
			for msg in @get_msgs(msg_str)
				@docsH[msg] ?= $.Callbacks()
				@docsH[msg].add fn
				@once_fns[msg] ?= []
				@once_fns[msg].push fn
		
		# можна відключити певний коллбек, передавши функцію
		# або всі, якщо не передати нічого
		off: (msg_str, fn)->
			for msg in @get_msgs(msg_str)
				if fn
					@docsH[msg].remove fn
					@once_fns[msg]?.pull fn
				else
					@docsH[msg].empty()
					@once_fns[msg] = []
		
		get_msgs: (msg_str)->
			msg_str.trim().split /\s+/
		
		destroy: ->
			@docsH = null



	# -SynsAndFormsBlock class
	class win.SynsAndFormsBlock
		
		# -constructor
		constructor: (pH)->
			# keyword (should be in lowerCase)
			# *parent: 'body'
			# *calibrate
			# *zIndex
			# *hide_on_click_outside: true
			{@keyword, @wordsH, @target, calibrate, zIndex, parent, @hide_on_click_outside} = pH
			parent ?= $ 'body'
			
			@cont = $ '<div id="word_forms" class="g_noSelect"><ul></ul></div>'
			@cont.appendTo parent
			ul = @cont.find 'ul'
			
			for word, i in @sorted_words()
				forms = @wordsH[word].sort()
				li = $ "<li><div class='s'>#{word}</div></li>"
				for form in forms
					# *виправляє помилку, якщо серед форм попадається null
					continue if !form
					
					for char, i in word
						break if (form[i] != word[i]) 
					
					if (i>3)
						end_part = form.substr i
						# якщо форма менша по довжині, то показуємо просто 2 останні букви (інакше показується просто '-')
						end_part = form.substr(i-2) if (end_part.length == 0)
						li.append "<div class='i' title='#{form}'>-#{end_part}</div>"
					else
						li.append "<div class='i'>#{form}</div>"
				
				@append_add_form_btn_to li
				
				li.appendTo ul
			
			last_li = $ '<li>'
			
			add_synonym = $ '<div class="s add"> + синонім</div>'
			add_synonym.appendTo last_li
			
			last_li.appendTo ul 
			
			# зразу після додавання активуємо меню для синоніма
			@enable_synonym_menu_for(ul.find('li').children('.s'))
			@enable_synonym_menu_for(ul.find('li:first').children('.s'), {main_form:true})
			@enable_form_menu_for(ul.find('li').children('.i:not(.add)'))
			
			
			# позиціонуємо зразу під елементом
			@cont.align_to @target, 'left-bottom', calibrate
			
			@cont.css {zIndex}
			
			@hub = new Hub
			
			@editing_item = null
			@requests = []
			
			@controller()
					
		append_add_form_btn_to: (el)->
			add_form_btn = $ '<div class="i add" title="Додати форму"> +</div>'
			add_form_btn.appendTo el
			
			
		save_current_active_action: ->
			if @editing_item
				text = @editing_item.text()
				f_form_editing = @editing_item.is '.i'
				f_form_is_same_as_main = f_form_editing && text == @editing_item.data('main_form').text()
				action = if (f_form_editing && !f_form_is_same_as_main || !f_form_editing && text) then 'save' else 'cancel'
				@editing_item.trigger(action)
		
		# спеціальний метод, який чекає завершення всіх поточних запитів і якщо немає помилок — дає resolve
		is_saved: ->
			dfrd = new $.Deferred()
			# чекаємо на звершення всіх запитів
			$.when(@requests...).done =>
				# з затримкою перевіряємо, чи появився попап з помилкою відносно результатів запитів
				# і якщо попап не появився, то робимо resolve()
				$.run_after 250, =>
					dfrd.resolve() if !@error_popup?.is_active()
			dfrd
		
		controller: ->
			
			# -додати синонім (-+ синонім, -+синонім, -add synonym)
			@cont.on 'mousedown', '.s.add', (e) =>
				div = $(e.currentTarget)
				# ігноримо, якщо активний інпут, який якраз появився при кліку на '+'
				if (@editing_item && @editing_item.is('.s') && !@editing_item.text())
					e.preventDefault()
					return true
				
				# зберігаємо поточне активне додавання/редагування слова/форми
				@save_current_active_action()
				
				add_btn_li = div.closest('li')
				new_synonym = $('<li>').hide()
				word_div = $('<div class="s editing"></div>').appendTo(new_synonym).make_editable().enable_remove_html_on_paste()
				new_synonym.insertBefore(add_btn_li)
				new_synonym.slideDown 'fast', -> word_div.focus()
				@editing_item = word_div
			
			# -keydown
			@cont.on 'keydown', '.editing', (e) =>
				word_div = $(e.currentTarget)
				@error_popup?.hide_and_destroy()
				switch e.which
					# якщо cEnter — то не буде ініційовано додавання наступного
					when $.key.Enter
						word_div.trigger(type:'save', adding_next:!e.ctrlKey)
					when $.key.Esc
						word_div.trigger(type:'cancel')
					else return true
				return false
				
			# змінюємо поточний editing_item
			@cont.on 'mouseup', '.editing', (e) =>
				word_div = $(e.currentTarget)
				@editing_item = word_div
				
			# -save synonym
			@cont.on 'save', '.s.editing', (e) =>
				word_div = $(e.currentTarget)
				word = word_div.text().toLowerCase().strip()
				if !word
					@editing_item?.trigger('cancel')
					return false
					
				pH =
					word: word
					synonym_for: @keyword
				request = $.json '/ajax/save_word', pH, (res)=>
					if res.added_word
						word_div.removeClass('editing').make_editable false
						
						word_div.text(res.added_word)
						start_color = '#FFF79B'
						end_color = '#EEEEEE'
						word_div.css(backgroundColor:start_color).animate {backgroundColor:end_color}, 1000, =>
							word_div.css(backgroundColor:'')
							li = word_div.closest('li')
							@append_add_form_btn_to li
							
						@enable_synonym_menu_for(word_div)
						@editing_item = null if (@editing_item?.is word_div)
						@hub.fire 'updated'
						@hub.fire 'synonym_saved', res.added_word
					else if res.error
						# якщо було створено новий інпут — відмінюємо і робимо знову поточним цей
						# *таке буває, якщо клікнути на '+ Синонім' коли поточний ще не збережений
						if @editing_item
							if !@editing_item.is(word_div)
								$.run_after 100, =>
									@editing_item.trigger(type:'cancel')
									@editing_item = word_div
									@editing_item.focus().focusEnd()
							
							@error_popup?.destroy()
							@error_popup = new Popup
								target: word_div
								html: res.error
								calibrate: {x:0, y:0}
								size: 'small'
								hide_and_destroy_on_click:true
							@error_popup.show()
				@requests.push request
						
			# -cancel synonym
			@cont.on 'cancel', '.s.editing', (e) =>
				word_div = $(e.currentTarget)
				word_div.make_editable false
				# якщо це було додавання нового — зибираємо дів
				if !word_div.data('was')
					li = word_div.closest('li')
					li.slideUp -> li.remove()
				@editing_item = null
				
			# -delete synonym
			@cont.on 'delete', '.s', (e) =>
				word_div = $(e.currentTarget)
				pH =
					word: word_div.text().toLowerCase()
					keyword: @keyword
				$.json '/ajax/delete_synonym', pH, (res)=>
					if res.ok
						li = word_div.closest('li')
						li.slideUp -> li.remove()
						@hub.fire 'updated'
						@hub.fire 'synonym_deleted', pH.word
		
			# -додати форму (+form, -add form, +форма)
			@cont.on 'mousedown', '.i.add', (e) =>
				add_btn = $(e.currentTarget)
				word_li = add_btn.closest('li')
				main_form = word_li.children('div:first')
				main_form_text = main_form.text().toLowerCase()
				
				# ігноримо, якщо активний інпут, який якраз появився при кліку на '+'
				if (@editing_item && @editing_item.next().is(add_btn) && @editing_item.text().toLowerCase() == main_form_text)
					e.preventDefault()
					return true
				
				# зберігаємо поточне активне додавання/редагування слова/форми
				@save_current_active_action()
				
				new_form_i = $("<div class='i'>").appendTo(word_li)
				new_form_i.insertBefore(add_btn)
				new_form_i.data('main_form', main_form)
				
				new_form_i.addClass('animating').css(width:4, paddingLeft:0)
				new_form_i.animate {width:main_form.width(), paddingLeft:7}, 'fast', ->
					new_form_i.removeClass('animating').addClass('editing').css(width:'', paddingLeft:'').text(main_form.text()).make_editable().enable_remove_html_on_paste()

				@editing_item = new_form_i
		
		
			# -save form
			@cont.on 'save', '.i.editing', (e) =>
				word_i = $(e.currentTarget)
				word_li = word_i.closest('li')
				main_form = word_li.children('div:first')
				main_form_text = main_form.text().toLowerCase()
				word = word_i.text().toLowerCase().strip()
				if !word
					@editing_item?.trigger('cancel')
					return false
					
				pH =
					word: word
					form_for: main_form_text
				
				request = $.json '/ajax/save_form', pH, (res)=>
					if res.added_form
						word = res.added_form
						
						word_i.removeClass('editing').make_editable false
					
						# показуємо збережене слово, або тільки закінчення
						for char, i in word
							break if (main_form_text[i] != word[i])
						if (i>3)
							end_part = word.substr(i)
							word_i.text('-'+end_part)
						else
							word_i.text(word)
						# прописуємо тайтл
						word_i.attr('title', word)
						
						#!(пізніше) дубль
						start_color = '#FFF79B'
						end_color = '#EEEEEE'
						word_i.css(backgroundColor:start_color).animate {backgroundColor:end_color}, 1000, ->
							word_i.css(backgroundColor:'')
						@enable_form_menu_for(word_i)
						@editing_item = null if @editing_item?.is(word_i)
						# ініціюємо додавання наступного
						word_li.find('.i.add').mousedown() if e.adding_next
						@hub.fire 'updated'
						@hub.fire 'form_saved', word
					else if res.error
						# якщо було створено новий інпут — відмінюємо і робимо знову поточним цей
						# *таке буває, якщо клікнути на '+ Синонім' коли поточний ще не збережений
						if @editing_item
							if !@editing_item.is(word_i)
								$.run_after 100, =>
									@editing_item.trigger(type:'cancel')
									@editing_item = word_i
									@editing_item.focus().focusEnd()
								
							@error_popup?.destroy()
							@error_popup = new Popup
								target: word_i
								html: res.error
								calibrate: {x:0, y:0}
								size: 'small'
								hide_and_destroy_on_click:true
							@error_popup.show()
				@requests.push request
				
			# -cancel form
			@cont.on 'cancel', '.i.editing', (e) =>
				word_i = $(e.currentTarget)
				word_i.removeClass('editing').make_editable false
				# якщо це було додавання нового — зибираємо
				if !word_i.data('was')
					word_i.addClass('animating').css(width:word_i.width()).empty()
					word_i.animate {width:4, paddingLeft:0}, 'fast', ->
						word_i.remove()
				@editing_item = null
			
			# -delete form
			@cont.on 'delete', '.i', (e) =>
				word_i = $(e.currentTarget)
				word_li = word_i.closest('li')
				main_form = word_li.children('div:first')
				pH =
					form: word_i.attr('title') || word_i.text().toLowerCase()
					main_form: main_form.text().toLowerCase()
				$.json '/ajax/delete_form', pH, (res)=>
					if res.ok
						#!(пізніше) дубль
						word_i.addClass('animating').css(width:word_i.width()).empty()
						word_i.animate {width:4, paddingLeft:0}, 'fast', => word_i.remove()
						@hub.fire 'updated'
						@hub.fire 'form_deleted', pH.form
						
			# при кліку десь поза інпутом зберігаємо те що зараз редагується
			@cont.on 'mousedown', (e)=>
				# * тут e.target а не e.currentTarget
				el = $(e.target)
				f_md_on_the_current_editing_item = el.is(@editing_item)
				f_md_on_add_btn = el.is('.add')
				if !(f_md_on_add_btn || f_md_on_the_current_editing_item)
					@save_current_active_action()
			
			# обробляємо клік за межами блока
			$doc.on 'mousedown.SynsAndFormsBlock', (e)=>
				if e.click_was_outside @cont
					@save_current_active_action()
					@hide(with_fade:true) if @hide_on_click_outside
		
		
		
		# -synonym menu, -menu for synonym
		enable_synonym_menu_for: (_for, _pH={})->
			# *_pH.main_form
			type = ''
			special = ''
			
			if _pH.main_form
				type = ':no_delete'
				special = 'Required'
			
			cMenu.enableFor _for, 'synonym'+type, {special:special}, 
				o: -> cMenu.currentTarget
				# -edit word
				on_edit: (b)->
					b.trigger('dblclick')
				on_delete: (b)->
					b.trigger(type:'delete', save:true)
		
						
		enable_form_menu_for: (_for)->
			cMenu.enableFor _for, 'form', {}, 
				o: -> cMenu.currentTarget
				# -edit form
				on_edit: (b)->
					b.trigger('dblclick')
				on_delete: (b)->
					b.trigger(type:'delete', save:true)



		# сортуємо і робимо, щоб на початку була форма, по якій шукали
		sorted_words: ->
			arr = (word for word of @wordsH when (word != @keyword))
			[@keyword].concat arr.sort()
		
		is_visible: ->
			@cont.is ':visible'
			
		show: ->
			@cont.fadeIn('fast')
		
		hide: (pH={})->
			# *with_fade:true
			
			@editing_item?.trigger('cancel')
			
			# *цей рядок має бути після trigger('cancel'), щоб у FF виправити проблему з появою курсора у новому контейнері
			if pH.with_fade
				@cont.fadeOut('fast')
			else
				@cont.hide()
			
		destroy: ->
			$doc.off 'mouseup.SynsAndFormsBlock'
			@cont.remove()
			@error_popup?.destroy()
			@hub.destroy()


	# -SuggestionsBlock class
	class win.SuggestionsBlock
		constructor: (pH={})->
			# keyword (should be in lowerCase)
			# *parent: 'body'
			# *calibrate
			# *zIndex
			# *hide_on_click_outside: true
			# {@keyword, @wordsH, zIndex, parent, @hide_on_click_outside} = pH
			{@target, @calibrate, parent} = pH
			parent ?= $ 'body'
			@calibrate ?= {}
			
			@cur_li = $()
			@items_count = 0
			
			@div = $ '<div id="SuggestionsBlock"><ul></ul></div>'
			@div.appendTo parent
			@ul = @div.find 'ul'
			
			
			@hub = new Hub
			@controller()
			
		controller: ->
			
			# позиціонуємо зразу під елементом
			@align()
			
			# click
			@ul.on 'mousedown', 'li', (e) =>
				li = $(e.currentTarget)
				@hide()
				@hub.fire 'li_clicked', li
				@ul.empty()
				@items_count = 0
				# *без затримки підставляє всі саггести
				$.run_after 50, => @make_suggestions_for_next_group()
			
			# при наведенні на елемент підсвічуємо тільки його
			@ul.on 'mouseenter mouseleave', 'li', (e) =>
				li = $(e.currentTarget)
				@ul.find('li').removeClass 'cur'
				if (e.type == 'mouseenter')
					li.addClass 'cur'
				else
					@cur_li.addClass 'cur'
					
				
				
			# обробляємо клік за межами блока
			$doc.on 'mouseup.SuggestionsBlock', (e)=>
				if e.click_was_outside @div
					@hub.fire('clicked_outside', e).then => @hide(with_fade:true)
		
		use_cur_li: ->
			@cur_li.mousedown()
		
		set_cur_li: (li)->
			@cur_li.removeClass 'cur'
			@cur_li = li
			@cur_li.addClass 'cur'
			
		focus_next: ->
			next_li = @cur_li.next()
			@set_cur_li next_li if next_li[0]
		focus_prev: ->
			prev_li = @cur_li.prev()
			@set_cur_li prev_li if prev_li[0]
		
		align: ->
			@div.align_to @target, 'left-bottom', @calibrate
			@
		
		setup_data: (dataH)->
			@smart_groups = dataH.smart_groups
			@suggestions_data = dataH.suggestions
			@cur_smart_word_index = -1
			@cur_smart_group_n = -1
			@cur_hl_words_count = 1
			@make_suggestions_for_next_group()
		
		clear: ->
			@items_count = 0
			@ul.empty()
			@smart_groups = 
				words_to_results: 0
				results: 0
			
		# returns true якщо підготувало саггести для наснупного слова, тож по результату можна робити показ
		make_suggestions_for_next_group: ->
			@cur_smart_group_n++
			@cur_smart_word_index += @cur_hl_words_count
			if (@cur_smart_word_index < @smart_words_count())
				result_index = @smart_groups.words_to_results[@cur_smart_word_index]
				suggestions_ids = @smart_groups.results[result_index]
				@items_count = suggestions_ids.length
				tmp_ul = $ '<ul>'
				for suggestion_id in suggestions_ids
					name = @suggestions_data[suggestion_id]
					li = $ "<li>#{name}</li>"
					li.data(id:suggestion_id)
					li.appendTo tmp_ul
				
				@ul.empty().append tmp_ul.children()
				tmp_ul.remove()
				@set_cur_li @ul.find 'li:first'
				true
			else
				false
		
		smart_words_count: ->
			@smart_groups.words_to_results.length
		smart_groups_count: ->
			@smart_groups.results.length
		
		# у інпуті має виділити слово/фразу, до якої показуються саггести (це якщо у інпуті багато слів)
		# -hl (-highlight)
		hl_target_word: ->
			@cur_hl_words_count = 1
			# рахуємо кількість слів підряд з цим результатом
			res_index = @smart_groups.words_to_results[@cur_smart_word_index]
			for i in [@cur_smart_word_index+1...@smart_words_count()]
				if (@smart_groups.words_to_results[i] == res_index)
					@cur_hl_words_count++
				else
					break
			#-- 
			
			# підсвічуємо тільки, якщо не остання група
			if (@cur_smart_group_n < @smart_groups_count()-1)
				words = @target.text().split /\s+|(?=\+)/
				hl_words = words.slice(0, @cur_hl_words_count).join ' '
				other_words = words.slice(@cur_hl_words_count).join ' '
				res_html = "<u>#{hl_words}</u> "+other_words.replace(/\s+$/, '&#160;')
				# якщо ще немає такого підвічення — робимо
				if (@target.html() != res_html)
					@target.html res_html
					@target.focusEnd()
			# інакше, на всякий чистимо від підсвітки
			else
				if @target.find('u')[0]
					if (@target.html() != @target.text())
						@target.text @target.text().strip()
						@target.focusEnd()
				
		has_items: ->
			@items_count > 0
		
		is_visible: ->
			@div.is ':visible'
		
		show: ->
			@hl_target_word()
			@div.fadeIn(50)
		
		hide: (pH={})->
			# *with_fade:true
			@div.stop()
			if pH.with_fade
				@div.fadeOut('fast')
			else
				@div.hide()
			
		destroy: ->
			$doc.off '.SuggestionsBlock'
			@div.remove()
			@hub.destroy()


	# -Popup
	#	win.test_popup_b = new Popup
	#		id: 'id_test'
	#		target: $ '#ufd-assos'
	#		type: 'bottom'
	#		size: 'small'
	#		arr_calibrate: {x:'+=10'}
	#		html: "Some very big line<br>for tesing"
	#		hide_on_click: true
	#		hide_on_click_outside: true
	#		hide_and_destroy_on_click: true
	#		hide_and_destroy_on_click_outside: true
	#		hide_and_destroy_after: 1500
	#		save_as_shown_for_user_on_OK: true
	#		block_elements: [@new_subs_btn, '#param_btn, .btn_class']
	#		buttons: 'Ok, Cancel, Спробувати зараз.try_now, Далі ».next'
	#		show_only_if_no_other_popup_shown: true
	#		ignore_click_on: obj — можна вказати об’єкти, клік по яким ігнорити (коли клік ховає попап)
	#		manual_align: ->
	#			@div.css(left:15)
	#			@arr.css(left:20)
	#	test_popup_b.show()
	# <span class="buttons"><b><i>Check</i></b></span> — так можна додати кнопки в тілі
	#	ask_for_username.get_btn('Ok').addClass 'disabled'
	#	ask_for_username.hub.on 'btn_Ok', (e, btn) ->
	#		if !btn.is('.disabled')
	#			w 'ok'
	# events
	#		show — showing initiated
	#		init — popup will be shown (not was_shown_for_user)
	#		shown — div is visible, but transparent yet
	#		fadeIn_end — fully shown
	#		hide — hiding initiated
	#		hidden — hiding finished
	#		destroy — before div.remove
	class win.Popup
		@total_shown: 0
		
		constructor: (pH)->
			# html
			# target — $obj
			# *hint_id: 'db_id' — ID підказки, щоб зберегти як показану для користувача
			# *type — 'right'|'left'|'top'|'bottom' def is 'right'
			# *id — set #id for popup
			# *width — default is ''
			# *hide_on_click: false
			# *hide_on_click_outside: false
			# *hide_and_destroy_on_click: false
			# *hide_and_destroy_on_click_outside: false
			# *show_only_if_no_other_popup_shown: false
			# *size: 'small'
			# *addClass — add class to text_cont
			# *calibrate: {x:1, y:2}
			# *arr_calibrate: {x:1} | {x:'+=10'}
			# *buttons: 'Ok, Cancel, Далі ».next'
			{id, @target, width, @hide_on_click, @hide_on_click_outside, @hide_and_destroy_on_click, @hide_and_destroy_on_click_outside, @type, @calibrate, @arr_calibrate, buttons, @hint_id, @save_as_shown_for_user_on_OK, @ignore_click_on, @manual_align, @block_elements, @hide_and_destroy_after, @show_only_if_no_other_popup_shown} = pH
			width ?= ''
			@type ?= 'right'
			
			@div = $('<div class="popup"><div class="text_cont"></div><div class="arr"></div></div>').appendTo 'body'
			@div.o @
			@div.attr({id}).addClass(@type).addClass(pH.size)
			@text_cont = @div.find('.text_cont')
			@text_cont.addClass(pH.addClass) if pH.addClass
			@text_cont.html pH.html
			@div.css {width}
			@arr = @div.find '.arr'
			@on_mousedown
			
			buttons_part = ''
			if buttons
				# 'Ok, Cancel, Далі ».next'
				for button in buttons.split(/, */)
					cls_part = ''
					# Далі ».next = + class="next" 
					button = button.replace /\.(\w+)$/, (m, cls)->
						cls_part = " class='#{cls}'"
						''
					buttons_part += "<b><i#{cls_part}>#{button}</i></b>"
				buttons_part = "<div class='buttons noSelect'>#{buttons_part}</div>"
				@text_cont.after buttons_part
			
			@hub = new Hub
				init: 'once'
			@f_active = true
			@controller()
			
		controller: ->
			# how to hide on click
			action = switch
				when @hide_on_click, @hide_on_click_outside then @hide
				when @hide_and_destroy_on_click, @hide_and_destroy_on_click_outside then @hide_and_destroy
			
			f_for_click_outside = @hide_on_click_outside || @hide_and_destroy_on_click_outside
			if action
				@on_mousedown = (e)=>
					f_ignore_click_on_ok = @ignore_click_on && e.click_was_outside(@ignore_click_on) || !@ignore_click_on
					if (f_for_click_outside && e.click_was_outside(@div) && f_ignore_click_on_ok || !f_for_click_outside)
						action.call(@)
					# інакше, якщо клік не має заховати попап — слухаємо наступний клік
					else
						$doc.one 'mousedown', @on_mousedown
				
			# buttons fire action on click
			@div.find('.buttons').on 'click', 'b', (e) =>
				b = $(e.currentTarget)
				i = b.find 'i'
				# як ключ використовуємо або клас елемента <i> (краще при багатомовності), або текст кнопки
				key = i.attr('class') || b.text().replace(' ', '_')
				@hub.fire 'btn_'+key, b
			
			# save_as_shown_for_user_on_OK
			if (@hint_id && @save_as_shown_for_user_on_OK)
				@hub.on 'btn_Ok', (e, btn)=>
					return if btn?.is '.disabled'
					@save_as_shown_for_user()
					@hide_and_destroy()
					
			# block_elements
			if @block_elements
				@hub.on 'shown', =>
					# селектори перетворюємо на об’єкт
					@block_elements = 
						for element in @block_elements
							# приводимо jQuery-об’єкта^element
							element = $ element if element not instanceof $
							element
							
					@block_element(element) for element in @block_elements
			
					# unblock_elements
					@hub.on 'hide destroy', => 
						for element in @block_elements
							# приводимо jQuery-об’єкта^element
							element = $ element if element not instanceof $
							element.off '.Popup'
			
			# якщо є текст .required
			required_text = @text_cont.find('.required')
			if required_text[0]
				@get_btn('Ok').addClass 'disabled'
				@hub.on 'btn_Ok', (e, btn)=>
					if btn?.is('.disabled')
						required_text.blink()
			
			if @hide_and_destroy_after
				#- активуємо Timeout^@t_hide_delay, @hide_and_destroy_after
				if @t_hide_delay
					clearTimeout @t_hide_delay
					@t_hide_delay = null
				@t_hide_delay = $.run_after @hide_and_destroy_after, =>
					@hide_and_destroy()
					@t_hide_delay = null
			
			
			if @on_mousedown
				@hub.on 'shown', =>
					#- run after^200
					st_callback = =>
						$doc.one 'mousedown', @on_mousedown
					setTimeout st_callback, 200
				@hub.on 'hide destroy', =>
					$doc.off 'mousedown', @on_mousedown
		# controller
		
		save_as_shown_for_user: ->
			if g_db
				if !@was_shown_for_user()
					$.json '/ajax/hint_shown', {id:@hint_id}, =>
						# пушимо в масив
						g_db.user_data.hints_shown ?= []
						g_db.user_data.hints_shown.push @hint_id
		
		block_element: (element)->
			instead_of_click = (e)=>
				e.stopImmediatePropagation()
				# анімацію викликаємо лише на один івента, щоб їх кілька не викликалося
				if e.type == 'mousedown' || e.type == 'contextmenu'
					# blink_bg_color
					@div.css_animate
						animation: 'blink_bg_color 0.5s'
						keyframes: "
							@~keyframes blink_bg_color {
								0%,            33.34%,         66.68%,           100% {background-color:#FFF3C8}
									  16.67%,           50.01%,          83.35%         {background-color:#FFFAE8}
							}
						"
				false
			for evnt in ['mousedown', 'click', 'mouseup', 'contextmenu']
				element.on evnt+'.Popup', instead_of_click
				element.make_last_event_handler_to_be_first evnt
		
		additionally_block_elements: (els)->
			els = [els] if els not instanceof Array
			for el in els
				# приводимо jQuery-об’єкта^el
				el = $ el if el not instanceof $
				@block_elements.push el
				@block_element el
				
		
		was_shown_for_user: ->
			g_db?.user_data.hints_shown?.includes(@hint_id)
		
		is_active: ->
			@f_active
			
		is_not_active: ->
			!@is_active()
		
		align: ->
			if !@target?
				console.error "Popup '%s': target undefined ", (@id || @hint_id)
				return 
			switch @type
				when 'right'
					@div.align_to @target, 'right-center', @calibrate
					@div.css(left:'+='+@arr.outerWidth())
					
				when 'left'
					@div.align_to @target, 'left-center', @calibrate
					@div.css(left:'-='+(@div.outerWidth()+@arr.outerWidth()-1))
					
				when 'top'
					@div.align_to @target, 'center-top', @calibrate
					@div.css(top:'-='+(@div.outerHeight()+@arr.outerHeight()))
				
				when 'bottom'
					@div.align_to @target, 'center-bottom', @calibrate
					@div.css(top:'+='+(@arr.outerHeight()-1))
					
			switch @type
				when 'left', 'right'
					@div.css(top:'-='+Math.round(@div.outerHeight()/2))
				when 'top', 'bottom'
					@div.css(left:'-='+Math.round(@div.outerWidth()/2))
			
			# arr position
			switch @type
				when 'right', 'left'
					y = Math.round((@div.outerHeight()-@arr.outerHeight())/2)
					@arr.css top:y
				when 'top', 'bottom'
					x = Math.round((@div.outerWidth()-@arr.outerWidth())/2)
					@arr.css left:x
			
			# arr calibration
			if @arr_calibrate
				@arr.css
					left: @arr_calibrate.x
					top: @arr_calibrate.y
			
		show: (pH={})->
			@hub.fire 'show'
			return if @is_visible()
			if (@hint_id && @was_shown_for_user() && !pH.force)
				@destroy()
				return
			if @show_only_if_no_other_popup_shown && @constructor.total_shown>0
				return
			@hub.fire 'init'
			@align()
			@manual_align?()
			@div.fadeIn 'fast', => @hub.fire 'fadeIn_end'
			@constructor.total_shown++
			@hub.fire 'shown'
		
		hide: (mode='fast')->
			@hub.fire 'hide'
			return if !@is_visible()
			@div.stop().fadeOut mode, =>
				# *тут потрібно таки ховати, бо якщо попап ховається разом з вікном, то fadeOut погано працює, бо не ховає дів
				@div.hide()
				@hub.fire 'hidden'
				@constructor.total_shown--
			$.when @div
			
		is_visible: ->
			@div.css('display') != 'none'
		
		hide_nofade: ->
			@hide(0)
			
		hide_and_destroy: (mode='fast')->
			@hide(mode).then => @destroy()
			
		get_btn: (text)->
			@div.find('.buttons b').has("i.#{text}, i:contains(#{text})")
		
		activate_hint_hl: (setH)->
			$.each setH, (hint_el, hl_objects)=>
				hint_el = @text_cont.find(hint_el)
				hint_el.off('.Popup')
				if (hl_objects.length == 1)
					hl_object = hl_objects
					hint_el.on 'mouseenter.Popup mouseleave.Popup', (e)->
						if e.type == 'mouseenter'
							hl_object.addClass 'g_hint_hl'
						else
							hl_object.removeClass 'g_hint_hl'
				# якщо елементів багато — перебігаємо підсвіткою
				else
					on_hover = ->
						hl_objects.each (i, el)->
							f_last_item = i == hl_objects.length-1
							obj = $ el
							speed = 130
							#- активуємо Timeout^t_o, i*speed
							if t_o
								clearTimeout t_o
								t_o = null
							t_o = $.run_after i*speed, =>
								obj.addClass 'g_hint_hl'
								#- run after^speed+20
								st_callback = =>
									obj.removeClass 'g_hint_hl'
									# *друга перевірка тут потрібна проти зациклення
									if (f_last_item && obj.data 't_o')
										# repeat
										#- активуємо Timeout^t_repeat_delay, 500
										if t_repeat_delay
											clearTimeout t_repeat_delay
											t_repeat_delay = null
										t_repeat_delay = $.run_after 500, =>
											on_hover()
											t_repeat_delay = null
										obj.data {t_repeat_delay}
								setTimeout st_callback, speed+20
								t_o = null
									
							obj.data {t_o}
					
					hint_el.on 'mouseenter.Popup mouseleave.Popup', (e)->
						if e.type == 'mouseenter'
							on_hover()
						else
							hl_objects.each (i, el)->
								obj = $ el
								# зупиняємо таймери
								t_o = obj.data 't_o'
								# зупиняємо Timeout^t_o
								if t_o
									clearTimeout t_o
									t_o = null
								obj.removeData 't_o'
								t_repeat_delay = obj.data 't_repeat_delay'
								# зупиняємо Timeout^t_repeat_delay
								if t_repeat_delay
									clearTimeout t_repeat_delay
									t_repeat_delay = null
								obj.removeData 't_repeat_delay'
			
		# *метод має викликатися перед show()
		move_and_close_with_wnd: (wnd)->
			wnd = wnd.wnd if (wnd not instanceof Wnd)
			# робимо, щоб попап рухався з вікном
			@div.appendTo wnd.div
			# ховаємо попап при закритті вікна
			wnd.hub.once 'close', => @hide_nofade() if @is_active()
		
			
			
		destroy: ->
			return if not @f_active
			# зупиняємо Timeout^@t_hide_delay
			if @t_hide_delay
				clearTimeout @t_hide_delay
				@t_hide_delay = null
			@hub.fire 'destroy'
			@f_active = false
			@div.remove()
			@hub.destroy()
			
	# -UFD
	# *в момент new MyUFDSelect елементи вроді мають бути видимі на сторінці, але можуть бути visibility:hidden, бо інакше не уникнути помітної перебудови
	# @assos_ufd_select = new MyUFDSelect(select:@assos_select)
	#	@assos_ufd_select.hub.on 'update', -> enable_menu_for_select_items()
	#	@assos_ufd_select.hub.on 'scroll', -> cMenu.currentMenu?.hide()
	#	// повертаємо promise, щоб можна було почекати на селект @make_select().then => 
	#	$.when @assos_ufd_select.ready()
	#	@select.ready().then => @div.css(visibility:'visible')
	class win.MyUFDSelect
		constructor: (pH)->
			{@select, options, @do_on_Enter, @do_on_Esc} = pH
			options ?= {wrapperEl:'b', listMaxVisible: 15, calculateZIndex:true, addEmphasis:true}
			@select.ufd(options)
			@ufd = @select.data 'ufd'
			
			@hub = new Hub
			@controller()
		
		controller: ->
			@ufd.input.on 'keydown', (e)=>
				switch e.which
					when $.key.Down
						if !@dropdown_is_visible()
							@ufd.filter(true)
							$.run_after 2, => @ufd.showList()
						else
						@ufd.selectNext()
						e.stopImmediatePropagation()
					when $.key.Up
						if !@dropdown_is_visible()
							@ufd.filter(true)
							$.run_after 2, => @ufd.showList()
						else
						@ufd.selectPrev()
						e.stopImmediatePropagation()
					when $.key.Left, $.key.Right
						e.stopImmediatePropagation()
					when $.key.Enter
						@do_on_Enter?(e)
					when $.key.Esc
						@do_on_Esc?(e)
				return true
			
			@ufd.input.on 'keyup', (e)=>
				switch e.which
					when $.key.Down, $.key.Up, $.key.Left, $.key.Right then e.stopImmediatePropagation()
					when $.key.Enter
						e.stopImmediatePropagation() if @do_on_Enter
					when $.key.Esc
						e.stopImmediatePropagation() if @do_on_Esc
				return true
				
			@ufd.input.make_last_event_handler_to_be_first 'keydown'
			@ufd.input.make_last_event_handler_to_be_first 'keyup'
			
			# scroll event
			@ufd.listScroll.on 'scroll', => @hub.fire 'scroll'
			
		fix_height: ->
			list_scroll = @ufd.listScroll
			h = parseInt list_scroll.css('height')
			list_scroll.css('max-height':h, height:'')
		
		ready: ->
			# робимо затримку, щоб встиг побудуватися селект
			@select.delay 200
			$.when @select
			
		visible_suggestions_count: ->
			@ufd.visibleCount
		
		shows_no_suggestions: ->
			@ufd.visibleCount == 0
			
		dropdown_is_visible: ->
			@ufd.listVisible()
		
		related_option_for: (li)->
			index = li.attr 'name'
			@select.find('option').eq(index)
		
		hide_dropdown: ->
			@ufd.hideList()
			
		# динамічне видалення елемента з дропдаунта і відповідного оптіона з селекта
		delete_item: (li)->
			@fix_height()
			li.slideUp 'fast', =>
				@related_option_for(li).remove()
				li.remove()
				# оновлення значень 'name'
				@get_list_elements().each (index)-> $(@).attr('name', index)
				@update()
				@ufd.showList()
		
		get_list_elements: ->
			@ufd.listWrapper.find('li')
		
		update: ->
			@ufd.changeOptions()
			@hub.fire 'update'
			
		destroy: ->
			@hub.destroy()
			@select.ufd 'destroy'			
			
			
	# -RadShade (-shade)
	# перевірити центр:
	# g_db.rad_shade.set_spot({r:200})
	class win.RadShade
		constructor: (pH={})->
			{set_spot} = pH
			@W = 6000
			@H = 4000
			@build_content()
			@div.o @
			@set_spot set_spot if set_spot

		build_content: ->
			@div = $('<div class="g_RadShade"></div>').appendTo 'body'
			@div.svg
				settings:
					width: @W
					height: @H
			@svg = @div.svg 'get'
			defs = @svg.defs()
			
			@grad = $ @svg.radialGradient(
				defs
				# id
				'grad'
				# [0] is offset, [1] is colour, [2] is opacity (optional)
				[[0.1, '#000', 0], [0.6, '#000', 0.5]]
				# cx, cy, r, fx, fy
				# fx (number, optional) is the x-coordinate of the gradient focus.
				'0%', '0%', '30%', null, null
				{spreadMethod: 'pad'}
			)
			
			@svg.rect(0, 0, @W, @H, {fill: 'url(#grad)', stroke:'none', opacity:0.7});
		
		set_spot: (pH)->
			{x, y, r, target, calibrate} = pH
			calibrate ?= {}
			calibrate.x ?= 0
			calibrate.y ?= 0
			
			if target
				x = target.left_x()+Math.round(target.outerWidth()/2)
				y = target.top_y()+Math.round(target.outerHeight()/2)
				
			x += calibrate.x if x?
			y += calibrate.y if y?
			
			@grad.attr(cx:(x/@W*100)+'%') if x?
			@grad.attr(cy:(y/@H*100)+'%') if y?
			@grad.attr(r:(r/@W*100)+'%') if r?
			@
		
		is_visible: ->
			@div.is ':visible'
		
		show: ->
			@div.off $.support.transition.end
			@div.show()
			@div.force_reflow().css(opacity:1)
		
		hide: ->
			@div.css(opacity:0)
			@div.one $.support.transition.end, => @div.hide()

		destroy: ->
			@div.svg 'destroy'
			@div.remove()
	
	
	
	# init
	$ ->
	
		# -transition
		# *should be in the init section
		# if $.support.transition
		# 		@div.one $.support.transition.end, func
		$.support.transition = ( ->
			transitionEnd = ( ->
				el = document.createElement('trans')
				transEndEventNames =
					'WebkitTransition' : 'webkitTransitionEnd'
					'MozTransition'    : 'transitionend'
					'OTransition'      : 'oTransitionEnd otransitionend'
					'transition'       : 'transitionend'
				for name, cssName of transEndEventNames
					if el.style[name]?
						return cssName
			)()
			transitionEnd &&
				end: transitionEnd
		)()

	
	
		
)(jQuery, window, document)
