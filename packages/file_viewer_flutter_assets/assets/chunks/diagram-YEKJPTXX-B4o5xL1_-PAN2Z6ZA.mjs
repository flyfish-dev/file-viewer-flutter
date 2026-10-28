import{a as P}from"./chunk-AHBBM2ZC.mjs";import{a as R}from"./chunk-W3NG3PJE.mjs";import{q as z}from"./chunk-FHFSP7R2.mjs";import{_ as y}from"./chunk-2EARK56B.mjs";import"./chunk-HTO6362Y.mjs";import{$ as F,D as b,Q as k,V as T,W as A,X as O,Y as S,Z as I,_ as E,q as M,s as L}from"./chunk-GMUPTIL4.mjs";import"./chunk-JJD7WD6F.mjs";import{e as w}from"./chunk-L2LBHEZ6.mjs";import{a as o}from"./chunk-NNTI5FQZ.mjs";import"./chunk-M6L4U24C.mjs";var x={showLegend:!0,ticks:5,max:null,min:0,graticule:"circle"},v=32,D={axes:[],curves:[],options:x},p=structuredClone(D),j=L.radar,H=o(()=>y({...j,...b().radar}),"getConfig"),B=o(()=>p.axes,"getAxes"),U=o(()=>p.curves,"getCurves"),q=o(()=>p.options,"getOptions"),Z=o(a=>{p.axes=a.map(t=>({name:t.name,label:t.label??t.name}))},"setAxes"),J=o(a=>{p.curves=a.map(t=>({name:t.name,label:t.label??t.name,entries:K(t.entries)}))},"setCurves"),K=o(a=>{if(a[0].axis==null)return a.map(e=>e.value);let t=B();if(t.length===0)throw new Error("Axes must be populated before curves for reference entries");return t.map(e=>{let r=a.find(s=>s.axis?.$refText===e.name);if(r===void 0)throw new Error("Missing entry for axis "+e.label);return r.value})},"computeCurveEntries"),h={getAxes:B,getCurves:U,getOptions:q,setAxes:Z,setCurves:J,setOptions:o(a=>{let t=a.reduce((e,r)=>(e[r.name]=r,e),{});p.options={showLegend:t.showLegend?.value??x.showLegend,ticks:t.ticks?.value??x.ticks,max:t.max?.value??x.max,min:t.min?.value??x.min,graticule:t.graticule?.value??x.graticule},p.options.ticks>v&&(w.warn(`Radar diagram ticks (${p.options.ticks}) exceeds maximum allowed (${v}). Using ${v} instead.`),p.options.ticks=v)},"setOptions"),getConfig:H,clear:o(()=>{T(),p=structuredClone(D)},"clear"),setAccTitle:A,getAccTitle:O,setDiagramTitle:E,getDiagramTitle:F,getAccDescription:I,setAccDescription:S},N=o(a=>{P(a,h);let{axes:t,curves:e,options:r}=a;h.setAxes(t),h.setCurves(e),h.setOptions(r)},"populate"),Q={parse:o(async a=>{let t=await z("radar",a);w.debug(t),N(t)},"parse")},X=o((a,t,e,r)=>{let s=r.db,l=s.getAxes(),c=s.getCurves(),i=s.getOptions(),n=s.getConfig(),d=s.getDiagramTitle(),g=Y(R(t),n),m=i.max??Math.max(...c.map($=>Math.max(...$.entries))),u=i.min,f=Math.min(n.width,n.height)/2;tt(g,l,f,i.ticks,i.graticule),et(g,l,f,n),G(g,l,c,u,m,i.graticule,n),_(g,c,i.showLegend,n),g.append("text").attr("class","radarTitle").text(d).attr("x",0).attr("y",-n.height/2-n.marginTop)},"draw"),Y=o((a,t)=>{let e=t.width+t.marginLeft+t.marginRight,r=t.height+t.marginTop+t.marginBottom,s={x:t.marginLeft+t.width/2,y:t.marginTop+t.height/2};return k(a,r,e,t.useMaxWidth??!0),a.attr("viewBox",`0 0 ${e} ${r}`).attr("overflow","visible"),a.append("g").attr("transform",`translate(${s.x}, ${s.y})`)},"drawFrame"),tt=o((a,t,e,r,s)=>{if(s==="circle")for(let l=0;l<r;l++){let c=e*(l+1)/r;a.append("circle").attr("r",c).attr("class","radarGraticule")}else if(s==="polygon"){let l=t.length;for(let c=0;c<r;c++){let i=e*(c+1)/r,n=t.map((d,g)=>{let m=2*g*Math.PI/l-Math.PI/2;return`${i*Math.cos(m)},${i*Math.sin(m)}`}).join(" ");a.append("polygon").attr("points",n).attr("class","radarGraticule")}}},"drawGraticule"),et=o((a,t,e,r)=>{let s=t.length;for(let l=0;l<s;l++){let c=t[l].label,i=2*l*Math.PI/s-Math.PI/2,n=Math.cos(i),d=Math.sin(i);a.append("line").attr("x1",0).attr("y1",0).attr("x2",e*r.axisScaleFactor*n).attr("y2",e*r.axisScaleFactor*d).attr("class","radarAxisLine");let g=n>.01?"start":n<-.01?"end":"middle",m=d>.01?"hanging":d<-.01?"auto":"central",u=4;a.append("text").text(c).attr("x",e*r.axisLabelFactor*n+u*n).attr("y",e*r.axisLabelFactor*d+u*d).attr("text-anchor",g).attr("dominant-baseline",m).attr("class","radarAxisLabel")}},"drawAxes");function G(a,t,e,r,s,l,c){let i=t.length,n=Math.min(c.width,c.height)/2;e.forEach((d,g)=>{if(d.entries.length!==i)return;let m=d.entries.map((u,f)=>{let $=2*Math.PI*f/i-Math.PI/2,C=W(u,r,s,n);return{x:C*Math.cos($),y:C*Math.sin($)}});l==="circle"?a.append("path").attr("d",V(m,c.curveTension)).attr("class",`radarCurve-${g}`):l==="polygon"&&a.append("polygon").attr("points",m.map(u=>`${u.x},${u.y}`).join(" ")).attr("class",`radarCurve-${g}`)})}o(G,"drawCurves");function W(a,t,e,r){return r*(Math.min(Math.max(a,t),e)-t)/(e-t)}o(W,"relativeRadius");function V(a,t){let e=a.length,r=`M${a[0].x},${a[0].y}`;for(let s=0;s<e;s++){let l=a[(s-1+e)%e],c=a[s],i=a[(s+1)%e],n=a[(s+2)%e],d={x:c.x+(i.x-l.x)*t,y:c.y+(i.y-l.y)*t},g={x:i.x-(n.x-c.x)*t,y:i.y-(n.y-c.y)*t};r+=` C${d.x},${d.y} ${g.x},${g.y} ${i.x},${i.y}`}return`${r} Z`}o(V,"closedRoundCurve");function _(a,t,e,r){if(!e)return;let s=(r.width/2+r.marginRight)*3/4,l=-(r.height/2+r.marginTop)*3/4,c=20;t.forEach((i,n)=>{let d=a.append("g").attr("transform",`translate(${s}, ${l+n*c})`);d.append("rect").attr("width",12).attr("height",12).attr("class",`radarLegendBox-${n}`),d.append("text").attr("x",16).attr("y",0).attr("class","radarLegendText").text(i.label)})}o(_,"drawLegend");var at={draw:X},rt=o((a,t)=>{let e="";for(let r=0;r<a.THEME_COLOR_LIMIT;r++){let s=a[`cScale${r}`];e+=`
		.radarCurve-${r} {
			color: ${s};
			fill: ${s};
			fill-opacity: ${t.curveOpacity};
			stroke: ${s};
			stroke-width: ${t.curveStrokeWidth};
		}
		.radarLegendBox-${r} {
			fill: ${s};
			fill-opacity: ${t.curveOpacity};
			stroke: ${s};
		}
		`}return e},"genIndexStyles"),st=o(a=>{let t=M(),e=b(),r=y(t,e.themeVariables);return{themeVariables:r,radarOptions:y(r.radar,a)}},"buildRadarStyleOptions"),pt={parser:Q,db:h,renderer:at,styles:o(({radar:a}={})=>{let{themeVariables:t,radarOptions:e}=st(a);return`
	.radarTitle {
		font-size: ${t.fontSize};
		color: ${t.titleColor};
		dominant-baseline: hanging;
		text-anchor: middle;
	}
	.radarAxisLine {
		stroke: ${e.axisColor};
		stroke-width: ${e.axisStrokeWidth};
	}
	.radarAxisLabel {
		font-size: ${e.axisLabelFontSize}px;
		color: ${e.axisColor};
	}
	.radarGraticule {
		fill: ${e.graticuleColor};
		fill-opacity: ${e.graticuleOpacity};
		stroke: ${e.graticuleColor};
		stroke-width: ${e.graticuleStrokeWidth};
	}
	.radarLegendText {
		text-anchor: start;
		font-size: ${e.legendFontSize}px;
		dominant-baseline: hanging;
	}
	${rt(t,e)}
	`},"styles")};export{pt as diagram};
