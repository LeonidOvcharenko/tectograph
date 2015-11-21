// svg.export.js 0.1.1 - Copyright (c) 2014 Wout Fierens - Licensed under the MIT license

;(function() {

  // Add export method to SVG.Element 
  SVG.extend(SVG.Element, {
    // Build node string
    exportSvg: function(options, level) {
      var i, il, width, height, well, clone
        , name = this.node.nodeName
        , node = ''
      
      /* ensure options */
      options = options || {}
      
      if (options.exclude == null || !options.exclude.call(this)) {
        /* ensure defaults */
        options = options || {}
        level = level || 0
        
        /* set context */
        if (this instanceof SVG.Doc) {
          /* define doctype */
          node += whitespaced('<?xml version="1.0" encoding="UTF-8"?>', options.whitespace, level)
          
          /* store current width and height */
          width  = this.attr('width')
          height = this.attr('height')
          
          /* set required size */
          if (options.width)
            this.attr('width', options.width)
          if (options.height)
            this.attr('height', options.height)
        }
          
        /* open node */
        node += whitespaced('<' + name + this.attrToString() + '>', options.whitespace, level)
        
        /* reset size and add description */
        if (this instanceof SVG.Doc) {
          this.attr({
            width:  width
          , height: height
          })
          
          node += whitespaced('<desc>Created with svg.js [http://svgjs.com]</desc>', options.whitespace, level + 1)
          /* Add defs... */
					node += this.defs().exportSvg(options, level + 1);
        }
        
        /* add children */
        if (this instanceof SVG.Parent) {
          for (i = 0, il = this.children().length; i < il; i++) {
            if (SVG.Absorbee && this.children()[i] instanceof SVG.Absorbee) {
              clone = this.children()[i].node.cloneNode(true)
              well  = document.createElement('div')
              well.appendChild(clone)
              node += well.innerHTML
            } else {
              node += this.children()[i].exportSvg(options, level + 1)
            }
          }

        } else if (this instanceof SVG.Text || this instanceof SVG.TSpan) {
          for (i = 0, il = this.node.childNodes.length; i < il; i++)
            if (this.node.childNodes[i].instance instanceof SVG.TSpan)
              node += this.node.childNodes[i].instance.exportSvg(options, level + 1)
            else
              node += this.node.childNodes[i].nodeValue.replace(/&/g,'&amp;')

        } else if (SVG.ComponentTransferEffect && this instanceof SVG.ComponentTransferEffect) {
          this.rgb.each(function() {
            node += this.exportSvg(options, level + 1)
          })

        }
        
        /* close node */
        node += whitespaced('</' + name + '>', options.whitespace, level)
      }
      
      return node
    }
    // Set specific export attibutes
  , exportAttr: function(attr) {
      /* acts as getter */
      if (arguments.length == 0)
        return this.data('svg-export-attr')
      
      /* acts as setter */
      return this.data('svg-export-attr', attr)
    }
    // Convert attributes to string
  , attrToString: function() {
      var i, key, value
        , attr = []
        , data = this.exportAttr()
        , exportAttrs = this.attr()
      
      /* ensure data */
      if (typeof data == 'object')
        for (key in data)
          if (key != 'data-svg-export-attr')
            exportAttrs[key] = data[key]
      
      /* build list */
      for (key in exportAttrs) {
        value = exportAttrs[key]
        
        /* enfoce explicit xlink namespace */
        if (key == 'xlink') {
          key = 'xmlns:xlink'
        } else if (key == 'href') {
          if (!exportAttrs['xlink:href'])
            key = 'xlink:href'
        }

        /* normailse value */
        if (typeof value === 'string')
          value = value.replace(/"/g,"'")
        
        /* build value */
        if (key != 'data-svg-export-attr' && key != 'href') {
          if (key != 'stroke' || parseFloat(exportAttrs['stroke-width']) > 0)
            attr.push(key + '="' + value + '"')
        }
        
      }

      return attr.length ? ' ' + attr.join(' ') : ''
    }
    
  })
  
  /////////////
  // helpers
  /////////////

  // Whitespaced string
  function whitespaced(value, add, level) {
    if (add) {
      var whitespace = ''
        , space = add === true ? '  ' : add || ''
      
      /* build indentation */
      for (i = level - 1; i >= 0; i--)
        whitespace += space
      
      /* add whitespace */
      value = whitespace + value + '\n'
    }
    
    return value;
  }

}).call(this);
