import{a as G}from"./chunk-W3NG3PJE.mjs";import{D as R,J as W,Q as q,V,aa as j,q as O}from"./chunk-GMUPTIL4.mjs";import{e as f}from"./chunk-L2LBHEZ6.mjs";import{a as m}from"./chunk-NNTI5FQZ.mjs";var v,z,B="",N="",M="",A=[],b=new Map,C=m(e=>W(e,j()),"sanitizeText"),$=m(e=>{switch(e.type){case"terminal":return{...e,value:C(e.value)};case"nonterminal":return{...e,name:C(e.name)};case"sequence":return{...e,elements:e.elements.map($)};case"choice":return{...e,alternatives:e.alternatives.map($)};case"optional":return{...e,element:$(e.element)};case"repetition":return{...e,element:$(e.element),separator:e.separator?$(e.separator):void 0};case"special":return{...e,text:C(e.text)}}},"sanitizeAstNode"),K=m(()=>{B="",N="",M="",A.length=0,b.clear(),V(),f.debug("[Railroad] Database cleared")},"clear"),H=m(e=>{B=C(e),f.debug("[Railroad] Title set:",e)},"setTitle"),I=m(()=>B,"getTitle"),Q={clear:K,setTitle:H,getTitle:I,addRule:m(e=>{let a={...e,name:C(e.name),definition:$(e.definition),comment:e.comment?C(e.comment):void 0};f.debug("[Railroad] Adding rule:",a.name),b.has(a.name)&&f.warn(`[Railroad] Rule '${a.name}' is already defined. Overwriting.`),A.push(a),b.set(a.name,a)},"addRule"),getRules:m(()=>A,"getRules"),getRule:m(e=>b.get(e),"getRule"),setAccTitle:m(e=>{N=C(e).replace(/^\s+/g,""),f.debug("[Railroad] Accessibility title set:",e)},"setAccTitle"),getAccTitle:m(()=>N,"getAccTitle"),setAccDescription:m(e=>{M=C(e).replace(/\n\s+/g,`
`),f.debug("[Railroad] Accessibility description set:",e)},"setAccDescription"),getAccDescription:m(()=>M,"getAccDescription"),setDiagramTitle:H,getDiagramTitle:I},T={compactMode:!1,padding:10,verticalSeparation:8,horizontalSeparation:10,arcRadius:10,fontSize:14,fontFamily:"monospace",terminalFill:"#FFFFC0",terminalStroke:"#000000",terminalTextColor:"#000000",nonTerminalFill:"#FFFFFF",nonTerminalStroke:"#000000",nonTerminalTextColor:"#000000",lineColor:"#000000",strokeWidth:2,markerFill:"#000000",commentFill:"#E8E8E8",commentStroke:"#888888",commentTextColor:"#666666",specialFill:"#F0E0FF",specialStroke:"#8800CC",ruleNameColor:"#000066",showMarkers:!0,markerRadius:5},X=/^#(?:[\da-f]{3,4}|[\da-f]{6}|[\da-f]{8})$|^(?:rgb|rgba|hsl|hsla|hwb|lab|lch|oklab|oklch)\([\d\s%+,./-]+\)$|^[a-z]+$/i,Y=/^[\w "',.-]+$/,Z=new Set(["compactMode","padding","verticalSeparation","horizontalSeparation","arcRadius","fontSize","fontFamily","terminalFill","terminalStroke","terminalTextColor","nonTerminalFill","nonTerminalStroke","nonTerminalTextColor","lineColor","strokeWidth","markerFill","commentFill","commentStroke","commentTextColor","specialFill","specialStroke","ruleNameColor","showMarkers","markerRadius"]),P=m(e=>e?Object.keys(e).every(a=>a==="railroad"||Z.has(a)):!1,"isRailroadStyleOptions"),_=m(e=>e?"railroad"in e&&e.railroad?e.railroad:P(e)?e:{}:{},"extractRailroadOverrides"),ee=m(e=>{if(!e||P(e))return{};let{railroad:a,svgId:r,theme:t,look:i,...n}=e;return n},"extractThemeOverrides"),d=m((e,a)=>{if(typeof e!="string")return a;let r=e.trim();return X.test(r)?r:a},"sanitizeColorValue"),U=m((e,a)=>{if(typeof e!="string")return a;let r=e.trim();return Y.test(r)?r:a},"sanitizeFontFamilyValue"),S=m((e,a)=>{let r=typeof e=="number"?e:typeof e=="string"?Number.parseFloat(e):NaN;return Number.isFinite(r)&&r>=0?r:a},"sanitizeNumberValue"),te=m(e=>{let a=typeof e=="number"?e:typeof e=="string"?Number.parseFloat(e):NaN;return Number.isFinite(a)&&a>0?a:void 0},"parseThemeFontSize"),re=m(e=>{let a=U(e.fontFamily,T.fontFamily),r=te(e.fontSize)??T.fontSize;return{...T,fontFamily:a,fontSize:r,terminalFill:d(e.secondBkg??e.secondaryColor,T.terminalFill),terminalStroke:d(e.secondaryBorderColor??e.lineColor,T.terminalStroke),terminalTextColor:d(e.secondaryTextColor??e.textColor,T.terminalTextColor),nonTerminalFill:d(e.mainBkg??e.background,T.nonTerminalFill),nonTerminalStroke:d(e.primaryBorderColor??e.lineColor,T.nonTerminalStroke),nonTerminalTextColor:d(e.primaryTextColor??e.textColor,T.nonTerminalTextColor),lineColor:d(e.lineColor,T.lineColor),markerFill:d(e.lineColor,T.markerFill),commentFill:d(e.labelBackground??e.tertiaryColor,T.commentFill),commentStroke:d(e.tertiaryBorderColor??e.lineColor,T.commentStroke),commentTextColor:d(e.tertiaryTextColor??e.textColor,T.commentTextColor),specialFill:d(e.tertiaryColor??e.secondaryColor,T.specialFill),specialStroke:d(e.tertiaryBorderColor??e.secondaryBorderColor,T.specialStroke),ruleNameColor:d(e.titleColor??e.textColor,T.ruleNameColor)}},"buildThemeDefaults"),E=m(e=>{let a=R(),r=re({...O(),...a.themeVariables??{},...ee(e)}),t={...a.railroad??{},..._(e)};return{compactMode:t.compactMode??r.compactMode,padding:S(t.padding,r.padding),verticalSeparation:S(t.verticalSeparation,r.verticalSeparation),horizontalSeparation:S(t.horizontalSeparation,r.horizontalSeparation),arcRadius:S(t.arcRadius,r.arcRadius),fontSize:S(t.fontSize,r.fontSize),fontFamily:U(t.fontFamily,r.fontFamily),terminalFill:d(t.terminalFill,r.terminalFill),terminalStroke:d(t.terminalStroke,r.terminalStroke),terminalTextColor:d(t.terminalTextColor,r.terminalTextColor),nonTerminalFill:d(t.nonTerminalFill,r.nonTerminalFill),nonTerminalStroke:d(t.nonTerminalStroke,r.nonTerminalStroke),nonTerminalTextColor:d(t.nonTerminalTextColor,r.nonTerminalTextColor),lineColor:d(t.lineColor,r.lineColor),strokeWidth:S(t.strokeWidth,r.strokeWidth),markerFill:d(t.markerFill,r.markerFill),commentFill:d(t.commentFill,r.commentFill),commentStroke:d(t.commentStroke,r.commentStroke),commentTextColor:d(t.commentTextColor,r.commentTextColor),specialFill:d(t.specialFill,r.specialFill),specialStroke:d(t.specialStroke,r.specialStroke),ruleNameColor:d(t.ruleNameColor,r.ruleNameColor),showMarkers:t.showMarkers??r.showMarkers,markerRadius:S(t.markerRadius,r.markerRadius)}},"buildRailroadStyleOptions"),se=m(e=>{let{fontFamily:a,fontSize:r,terminalFill:t,terminalStroke:i,terminalTextColor:n,nonTerminalFill:p,nonTerminalStroke:s,nonTerminalTextColor:l,lineColor:u,strokeWidth:o,markerFill:g,commentFill:c,commentStroke:h,commentTextColor:k,specialFill:F,specialStroke:w,ruleNameColor:y}=E(e);return`
  .railroad-diagram {
    font-family: ${a};
    font-size: ${r}px;
  }

  .railroad-terminal rect {
    fill: ${t};
    stroke: ${i};
    stroke-width: ${o}px;
  }

  .railroad-terminal text {
    fill: ${n};
    font-family: ${a};
    font-size: ${r}px;
    text-anchor: middle;
    dominant-baseline: middle;
  }

  .railroad-nonterminal rect {
    fill: ${p};
    stroke: ${s};
    stroke-width: ${o}px;
  }

  .railroad-nonterminal text {
    fill: ${l};
    font-family: ${a};
    font-size: ${r}px;
    text-anchor: middle;
    dominant-baseline: middle;
  }

  .railroad-line {
    stroke: ${u};
    stroke-width: ${o}px;
    fill: none;
  }

  .railroad-start circle,
  .railroad-end circle {
    fill: ${g};
  }

  .railroad-comment ellipse {
    fill: ${c};
    stroke: ${h};
    stroke-width: ${o}px;
  }

  .railroad-comment text {
    fill: ${k};
    font-style: italic;
    font-family: ${a};
    font-size: ${r}px;
    text-anchor: middle;
    dominant-baseline: middle;
  }

  .railroad-special rect {
    fill: ${F};
    stroke: ${w};
    stroke-width: ${o}px;
    stroke-dasharray: 5,3;
  }

  .railroad-special text {
    fill: ${l};
    font-family: ${a};
    font-size: ${r}px;
    text-anchor: middle;
    dominant-baseline: middle;
  }

  .railroad-rule-name {
    font-weight: bold;
    fill: ${y};
    font-family: ${a};
    font-size: ${r}px;
  }

  .railroad-group {
    /* Grouping container, no specific styles */
  }
`},"getStyles"),x=(v=class{constructor(){this.d=""}moveTo(e,a){return this.d+=`M ${e} ${a} `,this}lineTo(e,a){return this.d+=`L ${e} ${a} `,this}horizontalTo(e){return this.d+=`H ${e} `,this}verticalTo(e){return this.d+=`V ${e} `,this}arcTo(e,a,r,t,i,n,p){return this.d+=`A ${e} ${a} ${r} ${t?1:0} ${i?1:0} ${n} ${p} `,this}build(){return this.d.trim()}},m(v,"PathBuilder"),v),ie=(z=class{constructor(e,a=E()){this.textCache=new Map,this.svg=e,this.config=a}measureText(e){if(this.textCache.has(e))return this.textCache.get(e);let a=this.svg.append("text").attr("font-family",this.config.fontFamily).attr("font-size",this.config.fontSize).text(e),r=a.node().getBBox(),t={width:r.width,height:r.height};return a.remove(),this.textCache.set(e,t),t}renderTerminal(e,a){let r=this.measureText(a),t=r.width+this.config.padding*2,i=r.height+this.config.padding*2,n=e.append("g").attr("class","railroad-terminal");return n.append("rect").attr("x",0).attr("y",0).attr("width",t).attr("height",i).attr("rx",10).attr("ry",10),n.append("text").attr("x",t/2).attr("y",i/2).text(a),{element:n.node(),dimensions:{width:t,height:i,up:i/2,down:i/2}}}renderNonTerminal(e,a){let r=this.measureText(a),t=r.width+this.config.padding*2,i=r.height+this.config.padding*2,n=e.append("g").attr("class","railroad-nonterminal");return n.append("rect").attr("x",0).attr("y",0).attr("width",t).attr("height",i),n.append("text").attr("x",t/2).attr("y",i/2).text(a),{element:n.node(),dimensions:{width:t,height:i,up:i/2,down:i/2}}}renderSequence(e,a){let r=a.map(l=>this.renderExpression(e,l)),t=0,i=0,n=0;for(let l of r)t+=l.dimensions.width,i=Math.max(i,l.dimensions.up),n=Math.max(n,l.dimensions.down);t+=(r.length-1)*this.config.horizontalSeparation;let p=e.append("g").attr("class","railroad-sequence"),s=0;for(let l=0;l<r.length;l++){let u=r[l],o=i-u.dimensions.up;if(p.node().appendChild(u.element).setAttribute("transform",`translate(${s}, ${o})`),l<r.length-1){let g=s+u.dimensions.width,c=g+this.config.horizontalSeparation,h=i;p.append("path").attr("class","railroad-line").attr("d",new x().moveTo(g,h).lineTo(c,h).build())}s+=u.dimensions.width+this.config.horizontalSeparation}return{element:p.node(),dimensions:{width:t,height:i+n,up:i,down:n}}}renderChoice(e,a){let r=a.map(g=>this.renderExpression(e,g)),t=0,i=0;for(let g of r)t=Math.max(t,g.dimensions.width),i+=g.dimensions.height;i+=(r.length-1)*this.config.verticalSeparation;let n=this.config.arcRadius,p=n*4,s=t+p,l=e.append("g").attr("class","railroad-choice"),u=0,o=i/2;for(let g of r){let c=u,h=c+g.dimensions.up,k=n*2+(t-g.dimensions.width)/2;l.node().appendChild(g.element).setAttribute("transform",`translate(${k}, ${c})`);let F=new x,w=h>o;h===o?F.moveTo(0,o).lineTo(k,h):F.moveTo(0,o).arcTo(n,n,0,!1,w,n,o+(w?n:-n)).lineTo(n,h-(w?n:-n)).arcTo(n,n,0,!1,!w,n*2,h).lineTo(k,h),l.append("path").attr("class","railroad-line").attr("d",F.build());let y=new x,D=k+g.dimensions.width,J=s-n*2;h===o?y.moveTo(D,h).lineTo(s,o):y.moveTo(D,h).lineTo(J,h).arcTo(n,n,0,!1,!w,s-n,h+(w?-n:n)).lineTo(s-n,o+(w?n:-n)).arcTo(n,n,0,!1,w,s,o),l.append("path").attr("class","railroad-line").attr("d",y.build()),u+=g.dimensions.height+this.config.verticalSeparation}return{element:l.node(),dimensions:{width:s,height:i,up:o,down:i-o}}}renderOptional(e,a){let r=this.renderExpression(e,a),t=this.config.arcRadius,i=t*2,n=r.dimensions.width+t*4,p=r.dimensions.height+i,s=e.append("g").attr("class","railroad-optional"),l=t*2,u=i;s.node().appendChild(r.element).setAttribute("transform",`translate(${l}, ${u})`);let o=u+r.dimensions.up,g=new x().moveTo(0,o).lineTo(t*2,o);s.append("path").attr("class","railroad-line").attr("d",g.build());let c=new x().moveTo(l+r.dimensions.width,o).lineTo(n,o);s.append("path").attr("class","railroad-line").attr("d",c.build());let h=new x().moveTo(0,o).arcTo(t,t,0,!1,!1,t,o-t).lineTo(t,t).arcTo(t,t,0,!1,!0,t*2,0).lineTo(n-t*2,0).arcTo(t,t,0,!1,!0,n-t,t).lineTo(n-t,o-t).arcTo(t,t,0,!1,!1,n,o);return s.append("path").attr("class","railroad-line").attr("d",h.build()),{element:s.node(),dimensions:{width:n,height:p,up:o,down:p-o}}}renderRepetition(e,a,r){let t=this.renderExpression(e,a),i=this.config.arcRadius,n=i*2,p=t.dimensions.width+i*4,s=r===0,l=t.dimensions.height+n+(s?n:0),u=e.append("g").attr("class","railroad-repetition"),o=i*2,g=s?n:0;u.node().appendChild(t.element).setAttribute("transform",`translate(${o}, ${g})`);let c=g+t.dimensions.up;u.append("path").attr("class","railroad-line").attr("d",new x().moveTo(0,c).lineTo(i*2,c).build()),u.append("path").attr("class","railroad-line").attr("d",new x().moveTo(o+t.dimensions.width,c).lineTo(p,c).build());let h=g+t.dimensions.height+i,k=new x().moveTo(o+t.dimensions.width,c).arcTo(i,i,0,!1,!0,o+t.dimensions.width+i,c+i).lineTo(o+t.dimensions.width+i,h).arcTo(i,i,0,!1,!0,o+t.dimensions.width,h+i).lineTo(i*2,h+i).arcTo(i,i,0,!1,!0,i,h).lineTo(i,c+i).arcTo(i,i,0,!1,!0,i*2,c);if(u.append("path").attr("class","railroad-line").attr("d",k.build()),s){let F=new x().moveTo(0,c).arcTo(i,i,0,!1,!1,i,c-i).lineTo(i,i).arcTo(i,i,0,!1,!0,i*2,0).lineTo(p-i*2,0).arcTo(i,i,0,!1,!0,p-i,i).lineTo(p-i,c-i).arcTo(i,i,0,!1,!1,p,c);u.append("path").attr("class","railroad-line").attr("d",F.build())}return{element:u.node(),dimensions:{width:p,height:l,up:c,down:l-c}}}renderSpecial(e,a){let r=this.measureText("? "+a+" ?"),t=r.width+this.config.padding*2,i=r.height+this.config.padding*2,n=e.append("g").attr("class","railroad-special");return n.append("rect").attr("x",0).attr("y",0).attr("width",t).attr("height",i),n.append("text").attr("x",t/2).attr("y",i/2).text("? "+a+" ?"),{element:n.node(),dimensions:{width:t,height:i,up:i/2,down:i/2}}}renderExpression(e,a){switch(a.type){case"terminal":return this.renderTerminal(e,a.value);case"nonterminal":return this.renderNonTerminal(e,a.name);case"sequence":return this.renderSequence(e,a.elements);case"choice":return this.renderChoice(e,a.alternatives);case"optional":return this.renderOptional(e,a.element);case"repetition":return this.renderRepetition(e,a.element,a.min);case"special":return this.renderSpecial(e,a.text);default:throw new Error(`Unknown node type: ${a.type}`)}}renderRule(e,a){let r=this.svg.append("g").attr("class","railroad-rule").attr("transform",`translate(0, ${a})`),t=e.name+" =",i=this.measureText(t).width+20,n=i+20,p=r.append("g"),s=this.renderExpression(p,e.definition),l=Math.max(20,s.dimensions.up),u=l-s.dimensions.up;return p.attr("transform",`translate(${n}, ${u})`),r.append("g").attr("class","railroad-rule-name-group").append("text").attr("class","railroad-rule-name").attr("x",0).attr("y",l).text(t),r.append("g").attr("class","railroad-start").append("circle").attr("cx",i).attr("cy",l).attr("r",this.config.markerRadius),r.append("g").attr("class","railroad-end").append("circle").attr("cx",n+s.dimensions.width+10).attr("cy",l).attr("r",this.config.markerRadius),r.append("path").attr("class","railroad-line").attr("d",new x().moveTo(i+this.config.markerRadius,l).lineTo(n,l).build()),r.append("path").attr("class","railroad-line").attr("d",new x().moveTo(n+s.dimensions.width,l).lineTo(n+s.dimensions.width+10-this.config.markerRadius,l).build()),{height:Math.max(40,u+s.dimensions.height+this.config.padding*2),width:n+s.dimensions.width+10+this.config.markerRadius}}renderDiagram(e){let a=this.config.padding,r=0;for(let t of e){let i=this.renderRule(t,a);a+=i.height+this.config.verticalSeparation,r=Math.max(r,i.width)}return{width:r+this.config.padding*2,height:a+this.config.padding}}},m(z,"RailroadRenderer"),z),L=m((e,a,r)=>{q(e,a.height,a.width,r),e.attr("viewBox",`0 0 ${a.width} ${a.height}`)},"configureRailroadSvgSize"),de={draw:m((e,a,r)=>{f.debug(`[Railroad] Rendering diagram
`+e);try{let t=G(a);t.attr("class","railroad-diagram");let i=R().railroad?.useMaxWidth??!0,n=Q.getRules();if(f.debug(`[Railroad] Rendering ${n.length} rules`),n.length===0){f.warn("[Railroad] No rules to render"),L(t,{height:100,width:200},i);return}L(t,new ie(t,E()).renderDiagram(n),i),f.debug("[Railroad] Render complete")}catch(t){throw f.error("[Railroad] Render error:",t),t}},"draw")};export{Q as a,se as b,de as c};
