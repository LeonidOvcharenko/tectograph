"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win
	
	# -theme
	class win.ThemeGen
		constructor: (options)->
			defaults =
				title: ''
				basefontsize: 7812.5 # px at level #0
				K: 2.5               # interlevel scale
				xSpace: 2.5          # × fontsize
				xStroke: 0.02        # × fontsize
				xCellp: 0.16         # × fontsize
				xImgsize: 10         # × fontsize
				xWidth: 20           # × fontsize
				minfontsize: 5.98    # px — 6 in Chrome
				max_imgwidth: 300    # px
				margin: 20           # px
				markersize: 5        # px
				fontFamily: "PT Sans"
				lineHeight: 1.25
				rel_opacity: 0.8
				toplevel: 1
				slideshow: 2000
				color:
					text: '#000000'
					background: '#FFFFFF'
					selected:
						stroke: '#8DBEFF'
						fill: '#FFFFE2'
					stroke: '#C0C0C0'
					mask: '#C0C0C0'
					found: '#E5FF00'
					bullet: '#C0C0C0'
					emphasis: '#F08010'
					link: '#4F7FCE'
					link_hover: '#2020F0'
			$.extend true, @, defaults, options
			
			Levels = 10
			# generate font sizes
			@sizes = [@basefontsize]
			@sizes.push @sizes[i]/@K for i in [0...Levels]
			# generate spaces, strokes, cellp, imgsize
			@spaces  = []
			@strokes = []
			@cellp   = []
			@imgsize = []
			@width   = []
			for i in [0...Levels]
				s = @sizes[i]
				@spaces.push s*@xSpace
				@strokes.push s*@xStroke
				@cellp.push s*@xCellp
				@imgsize.push s*@xImgsize
				@width.push s*@xWidth
			# max zoom: min stroke = 1px
			@maxzoom = 1/@strokes[@strokes.length-1]
			# min zoom: fontsize[toplevel+1] = minfontsize
			@minzoom = @minfontsize / @sizes[@toplevel+1]
		
		threshold: (s)->
			for fs, i in @sizes
				if @minfontsize > fs*s
					return i
			@sizes.length
	
	win.Themes = []
	
	# -default theme settings
	win.Themes.push new ThemeGen
		title: 'Веб'
		basefontsize: 7812.5 # px at level #0
		K: 2.5
		max_imgwidth: 300 # px
		margin: 20        # px
		markersize: 5     # px
		fontFamily: "PT Sans"
		lineHeight: 1.25
		slideshow: 2000
		color:
			selected:
				stroke: '#8DBEFF' # '#E88DFF' # '#3071A9' 
				fill: '#FFFFE2'
			bullet: '#C0C0C0'
			mask: '#C0C0C0'
			emphasis: '#F08010'
			link: '#4F7FCE'
			link_hover: '#2020F0'
	
	win.Themes.push new ThemeGen
		title: 'Презентация'
		K: 2.5
		fontFamily: 'Trebuchet MS'
		lineHeight: 1.33
		color:
			background: '#F4F4F3'
			text: '#36424E'
			bullet: '#36424E'
			stroke: '#36424E'
			mask: '#D5D8D6'
			emphasis: '#70A3EF'
			link: '#7491BC'
			link_hover: '#70A3EF'
			selected:
				stroke: '#2D261D'
				fill: '#2D261D'
	
	win.Themes.push new ThemeGen
		title: 'Книга'
		K: 2.5
		fontFamily: 'Georgia'
		lineHeight: 1.33
		color:
			bullet: '#A0A0A0'
			mask: '#A0A0A0'
			emphasis: '#FF3333'
	
	win.Themes.push new ThemeGen
		title: 'Старая книга'
		K: 2.5
		fontFamily: 'Georgia'
		lineHeight: 1.5
		color:
			background: '#FDE7B2'
			text: '#371C07'
			bullet: '#BD8E58'
			stroke: '#63481E'
			mask: '#BD8E58'
			emphasis: '#862400' # '#BD8E58'
			link: '#B4794A'
			link_hover: '#FFDA73'
			selected:
				stroke: '#2D261D'
				fill: '#2D261D'
	
	win.Themes.push new ThemeGen
		title: 'Печатная машинка'
		K: 2
		fontFamily: 'courier new'
		color:
			emphasis: '#FF3333'
		
	win.Themes.push new ThemeGen
		title: 'Рукопись 1'
		K: 2
		xStroke: 0.085
		markersize: 1.5
		fontFamily: 'comic sans ms'
		lineHeight: 1.15

	win.Themes.push new ThemeGen
		title: 'Рукопись 2'
		K: 2.25
		fontFamily: 'Neucha'
		lineHeight: 1.15
		color:
			emphasis: '#F9AF33'
		
	win.Theme = win.Themes[0]

)(jQuery, window, document)