#- wrapper

"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win
	class win.Template
		constructor: (options)->
			defaults =
				cont: ''
			@opt = $.extend {}, defaults, options
			@cont = $ @opt.cont
			@build_content()
			@controller()
			
		build_content: ->
			T = {}
	
			T.footer = """
				footer.container-fluid
					.row
						.col-xs-12.small
							p
								| © ParetoNews 2014&nbsp;&nbsp;&nbsp;
								a href="#"
									=t 'footer.blog'
								| &nbsp;&middot;&nbsp;
								a href="#"
									=t 'footer.help'
								| &nbsp;&middot;&nbsp;
								a href="#"
									=t 'footer.faq'
								| &nbsp;&middot;&nbsp;
								a href="#"
									=t 'footer.terms'
								| &nbsp;&middot;&nbsp;
								a href="#"
									=t 'footer.privacy'
			"""
			
			@div = $('<div />')
			# @div.appendTo @cont
						
			@create_tpl('application', """
				.content = outlet
			""")
			for tpl of T
				@create_tpl tpl, T[tpl]
		
		controller: ->
		
		compile: (source, data)->
			template = Emblem.compile Handlebars, source
			template(data)
		
		create_tpl: (id, source)->
			# console.log source
			$('body').append "<script type='text/x-emblem' id='#{id}' data-template-name='#{id}'>#{source}</script>"
		
		destroy: ->
			@div.remove()
			@div = null
)(jQuery, window, document)
			
