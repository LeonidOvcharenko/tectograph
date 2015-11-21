// svg.filter.js 0.4 - Copyright (c) 2013-2014 Wout Fierens - Licensed under the MIT license
;(function(){function t(e){if(Array.isArray(e))e=new SVG.Array(e);return e.toString().replace(/^\s+/,"").replace(/\s+$/,"").replace(/\s+/g," ")}function n(e){if(!Array.isArray(e))return e;for(var t=0,n=e.length,r=[];t<n;t++)r.push(e[t]);return r.join(" ")}SVG.Filter=function(){this.constructor.call(this,SVG.create("filter"))};SVG.Filter.prototype=new SVG.Parent;SVG.extend(SVG.Filter,{source:"SourceGraphic",sourceAlpha:"SourceAlpha",background:"BackgroundImage",backgroundAlpha:"BackgroundAlpha",fill:"FillPaint",stroke:"StrokePaint",put:function(e,t){this.add(e,t);return e.attr({"in":this.source,result:e})},blend:function(e,t,n){return this.put(new SVG.BlendEffect).attr({"in":e,in2:t,mode:n||"normal"})},colorMatrix:function(e,n){if(e=="matrix")n=t(n);return this.put(new SVG.ColorMatrixEffect).attr({type:e,values:typeof n=="undefined"?null:n})},convolveMatrix:function(e){e=t(e);return this.put(new SVG.ConvolveMatrixEffect).attr({order:Math.sqrt(e.split(" ").length),kernelMatrix:e})},componentTransfer:function(e){var t=new SVG.ComponentTransferEffect;t.rgb=new SVG.Set;["r","g","b","a"].forEach(function(e){t[e]=(new(SVG["Func"+e.toUpperCase()])).attr("type","identity");t.rgb.add(t[e]);t.node.appendChild(t[e].node)});if(e){if(e.rgb){["r","g","b"].forEach(function(n){t[n].attr(e.rgb)});delete e.rgb}for(var n in e)t[n].attr(e[n])}return this.put(t)},composite:function(e,t,n){return this.put(new SVG.CompositeEffect).attr({"in":e,in2:t,operator:n})},flood:function(e){return this.put(new SVG.FloodEffect).attr({"flood-color":e})},offset:function(e,t){return this.put(new SVG.OffsetEffect).attr({dx:e,dy:t})},image:function(e){return this.put(new SVG.ImageEffect).attr("href",e,SVG.xlink)},merge:function(){},gaussianBlur:function(){return this.put(new SVG.GaussianBlurEffect).attr("stdDeviation",n(Array.prototype.slice.call(arguments)))},toString:function(){return"url(#"+this.attr("id")+")"}});SVG.extend(SVG.Defs,{filter:function(e){var t=this.put(new SVG.Filter);if(typeof e==="function")e.call(t,t);return t}});SVG.extend(SVG.Container,{filter:function(e){return this.defs().filter(e)}});SVG.extend(SVG.Element,SVG.G,SVG.Nested,{filter:function(e){this.filterer=e instanceof SVG.Element?e:this.doc().filter(e);this.attr("filter",this.filterer);return this.filterer},unfilter:function(e){if(this.filterer&&e===true)this.filterer.remove();delete this.filterer;return this.attr("filter",null)}});SVG.Effect=function(){};SVG.Effect.prototype=new SVG.Element;SVG.extend(SVG.Effect,{"in":function(e){return this.attr("in",e)},result:function(){return this.attr("id")+"Out"},toString:function(){return this.result()}});var e=["blend","colorMatrix","componentTransfer","composite","convolveMatrix","diffuseLighting","displacementMap","flood","gaussianBlur","image","merge","morphology","offset","specularLighting","tile","turbulence","distantLight","pointLight","spotLight"];e.forEach(function(t){var n=t.charAt(0).toUpperCase()+t.slice(1);SVG[n+"Effect"]=function(){this.constructor.call(this,SVG.create("fe"+n))};SVG[n+"Effect"].prototype=["componentTransfer"].indexOf(n)>-1?new SVG.Parent:new SVG.Effect;e.forEach(function(e){SVG[n+"Effect"].prototype[e]=function(){return this.parent[e].apply(this.parent,arguments).in(this)}})});["r","g","b","a"].forEach(function(e){SVG["Func"+e.toUpperCase()]=function(){this.constructor.call(this,SVG.create("feFunc"+e.toUpperCase()))};SVG["Func"+e.toUpperCase()].prototype=new SVG.Element});SVG.extend(SVG.FloodEffect,{});SVG.filter={sepiatone:[.343,.669,.119,0,0,.249,.626,.13,0,0,.172,.334,.111,0,0,0,0,0,1,0]}}).call(this);