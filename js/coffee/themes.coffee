"use strict";
!(($, win, doc) ->
	$doc = $ doc
	$win = $ win
	
	# -theme
	class win.ThemeGen
		constructor: (options)->
			defaults =
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
					selected:
						stroke: '#8DBEFF'
						fill: '#FFFFE2'
					stroke: '#C0C0C0'
					mask: '#C0C0C0'
					found: '#E5FF00'
					bullet: '#C0C0C0'
					emphasis: '#F08010'
					link: '#A0A0F0'
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
	
	# -default theme settings
	win.Theme = new ThemeGen
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
			link: '#A0A0F0'
			link_hover: '#2020F0'
	
	win.ThemeSerif = new ThemeGen
		K: 2.5
		fontFamily: 'Georgia'
		lineHeight: 1.33
		color:
			bullet: '#A0A0A0'
			mask: '#A0A0A0'
	
	win.ThemeMonospace = new ThemeGen
		K: 2
		fontFamily: 'courier new'
		
	win.ThemeScript = new ThemeGen
		K: 2
		xStroke: 0.085
		markersize: 1.5
		fontFamily: 'comic sans ms'
		lineHeight: 1.15

	win.ThemeScript2 = new ThemeGen
		K: 2.25
		fontFamily: 'Neucha'
		lineHeight: 1.15

)(jQuery, window, document)