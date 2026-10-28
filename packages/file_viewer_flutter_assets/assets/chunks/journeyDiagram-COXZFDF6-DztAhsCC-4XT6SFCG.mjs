import{a as Q}from"./chunk-JCLYBJXB.mjs";import{a as ft}from"./chunk-F623ZP5B.mjs";import{a as yt,b as pt,c as dt,f as X}from"./chunk-WZV47FOD.mjs";import"./chunk-GFFERDM6.mjs";import"./chunk-HTO6362Y.mjs";import{$ as ut,Q as st,V as at,W as rt,X as ot,Y as lt,Z as ct,_ as ht,aa as P}from"./chunk-GMUPTIL4.mjs";import{g as N}from"./chunk-L2LBHEZ6.mjs";import{a}from"./chunk-NNTI5FQZ.mjs";import"./chunk-M6L4U24C.mjs";var G=(function(){var e=a(function(i,o,s,c){for(s=s||{},c=i.length;c--;s[i[c]]=o);return s},"o"),t=[6,8,10,11,12,14,16,17,18],r=[1,9],p=[1,10],n=[1,11],h=[1,12],u=[1,13],y=[1,14],f={trace:a(function(){},"trace"),yy:{},symbols_:{error:2,start:3,journey:4,document:5,EOF:6,line:7,SPACE:8,statement:9,NEWLINE:10,title:11,acc_title:12,acc_title_value:13,acc_descr:14,acc_descr_value:15,acc_descr_multiline_value:16,section:17,taskName:18,taskData:19,$accept:0,$end:1},terminals_:{2:"error",4:"journey",6:"EOF",8:"SPACE",10:"NEWLINE",11:"title",12:"acc_title",13:"acc_title_value",14:"acc_descr",15:"acc_descr_value",16:"acc_descr_multiline_value",17:"section",18:"taskName",19:"taskData"},productions_:[0,[3,3],[5,0],[5,2],[7,2],[7,1],[7,1],[7,1],[9,1],[9,2],[9,2],[9,1],[9,1],[9,2]],performAction:a(function(i,o,s,c,d,l,k){var m=l.length-1;switch(d){case 1:return l[m-1];case 2:this.$=[];break;case 3:l[m-1].push(l[m]),this.$=l[m-1];break;case 4:case 5:this.$=l[m];break;case 6:case 7:this.$=[];break;case 8:c.setDiagramTitle(l[m].substr(6)),this.$=l[m].substr(6);break;case 9:this.$=l[m].trim(),c.setAccTitle(this.$);break;case 10:case 11:this.$=l[m].trim(),c.setAccDescription(this.$);break;case 12:c.addSection(l[m].substr(8)),this.$=l[m].substr(8);break;case 13:c.addTask(l[m-1],l[m]),this.$="task"}},"anonymous"),table:[{3:1,4:[1,2]},{1:[3]},e(t,[2,2],{5:3}),{6:[1,4],7:5,8:[1,6],9:7,10:[1,8],11:r,12:p,14:n,16:h,17:u,18:y},e(t,[2,7],{1:[2,1]}),e(t,[2,3]),{9:15,11:r,12:p,14:n,16:h,17:u,18:y},e(t,[2,5]),e(t,[2,6]),e(t,[2,8]),{13:[1,16]},{15:[1,17]},e(t,[2,11]),e(t,[2,12]),{19:[1,18]},e(t,[2,4]),e(t,[2,9]),e(t,[2,10]),e(t,[2,13])],defaultActions:{},parseError:a(function(i,o){if(o.recoverable)this.trace(i);else{var s=new Error(i);throw s.hash=o,s}},"parseError"),parse:a(function(i){var o=this,s=[0],c=[],d=[null],l=[],k=this.table,m="",b=0,B=0,I=0,$t=2,et=1,Tt=l.slice.call(arguments,1),x=Object.create(this.lexer),E={yy:{}};for(var z in this.yy)Object.prototype.hasOwnProperty.call(this.yy,z)&&(E.yy[z]=this.yy[z]);x.setInput(i,E.yy),E.yy.lexer=x,E.yy.parser=this,typeof x.yylloc>"u"&&(x.yylloc={});var W=x.yylloc;l.push(W);var Mt=x.options&&x.options.ranges;typeof E.yy.parseError=="function"?this.parseError=E.yy.parseError:this.parseError=Object.getPrototypeOf(this).parseError;function St(v){s.length=s.length-2*v,d.length=d.length-v,l.length=l.length-v}a(St,"popStack");function it(){var v=c.pop()||x.lex()||et;return typeof v!="number"&&(v instanceof Array&&(c=v,v=c.pop()),v=o.symbols_[v]||v),v}a(it,"lex");for(var _,q,A,w,U,j={},D,M,nt,O;;){if(A=s[s.length-1],this.defaultActions[A]?w=this.defaultActions[A]:((_===null||typeof _>"u")&&(_=it()),w=k[A]&&k[A][_]),typeof w>"u"||!w.length||!w[0]){var H="";O=[];for(D in k[A])this.terminals_[D]&&D>$t&&O.push("'"+this.terminals_[D]+"'");x.showPosition?H="Parse error on line "+(b+1)+`:
`+x.showPosition()+`
Expecting `+O.join(", ")+", got '"+(this.terminals_[_]||_)+"'":H="Parse error on line "+(b+1)+": Unexpected "+(_==et?"end of input":"'"+(this.terminals_[_]||_)+"'"),this.parseError(H,{text:x.match,token:this.terminals_[_]||_,line:x.yylineno,loc:W,expected:O})}if(w[0]instanceof Array&&w.length>1)throw new Error("Parse Error: multiple actions possible at state: "+A+", token: "+_);switch(w[0]){case 1:s.push(_),d.push(x.yytext),l.push(x.yylloc),s.push(w[1]),_=null,q?(_=q,q=null):(B=x.yyleng,m=x.yytext,b=x.yylineno,W=x.yylloc,I>0&&I--);break;case 2:if(M=this.productions_[w[1]][1],j.$=d[d.length-M],j._$={first_line:l[l.length-(M||1)].first_line,last_line:l[l.length-1].last_line,first_column:l[l.length-(M||1)].first_column,last_column:l[l.length-1].last_column},Mt&&(j._$.range=[l[l.length-(M||1)].range[0],l[l.length-1].range[1]]),U=this.performAction.apply(j,[m,B,b,E.yy,w[1],d,l].concat(Tt)),typeof U<"u")return U;M&&(s=s.slice(0,-1*M*2),d=d.slice(0,-1*M),l=l.slice(0,-1*M)),s.push(this.productions_[w[1]][0]),d.push(j.$),l.push(j._$),nt=k[s[s.length-2]][s[s.length-1]],s.push(nt);break;case 3:return!0}}return!0},"parse")};f.lexer=(function(){return{EOF:1,parseError:a(function(i,o){if(this.yy.parser)this.yy.parser.parseError(i,o);else throw new Error(i)},"parseError"),setInput:a(function(i,o){return this.yy=o||this.yy||{},this._input=i,this._more=this._backtrack=this.done=!1,this.yylineno=this.yyleng=0,this.yytext=this.matched=this.match="",this.conditionStack=["INITIAL"],this.yylloc={first_line:1,first_column:0,last_line:1,last_column:0},this.options.ranges&&(this.yylloc.range=[0,0]),this.offset=0,this},"setInput"),input:a(function(){var i=this._input[0];return this.yytext+=i,this.yyleng++,this.offset++,this.match+=i,this.matched+=i,i.match(/(?:\r\n?|\n).*/g)?(this.yylineno++,this.yylloc.last_line++):this.yylloc.last_column++,this.options.ranges&&this.yylloc.range[1]++,this._input=this._input.slice(1),i},"input"),unput:a(function(i){var o=i.length,s=i.split(/(?:\r\n?|\n)/g);this._input=i+this._input,this.yytext=this.yytext.substr(0,this.yytext.length-o),this.offset-=o;var c=this.match.split(/(?:\r\n?|\n)/g);this.match=this.match.substr(0,this.match.length-1),this.matched=this.matched.substr(0,this.matched.length-1),s.length-1&&(this.yylineno-=s.length-1);var d=this.yylloc.range;return this.yylloc={first_line:this.yylloc.first_line,last_line:this.yylineno+1,first_column:this.yylloc.first_column,last_column:s?(s.length===c.length?this.yylloc.first_column:0)+c[c.length-s.length].length-s[0].length:this.yylloc.first_column-o},this.options.ranges&&(this.yylloc.range=[d[0],d[0]+this.yyleng-o]),this.yyleng=this.yytext.length,this},"unput"),more:a(function(){return this._more=!0,this},"more"),reject:a(function(){if(this.options.backtrack_lexer)this._backtrack=!0;else return this.parseError("Lexical error on line "+(this.yylineno+1)+`. You can only invoke reject() in the lexer when the lexer is of the backtracking persuasion (options.backtrack_lexer = true).
`+this.showPosition(),{text:"",token:null,line:this.yylineno});return this},"reject"),less:a(function(i){this.unput(this.match.slice(i))},"less"),pastInput:a(function(){var i=this.matched.substr(0,this.matched.length-this.match.length);return(i.length>20?"...":"")+i.substr(-20).replace(/\n/g,"")},"pastInput"),upcomingInput:a(function(){var i=this.match;return i.length<20&&(i+=this._input.substr(0,20-i.length)),(i.substr(0,20)+(i.length>20?"...":"")).replace(/\n/g,"")},"upcomingInput"),showPosition:a(function(){var i=this.pastInput(),o=new Array(i.length+1).join("-");return i+this.upcomingInput()+`
`+o+"^"},"showPosition"),test_match:a(function(i,o){var s,c,d;if(this.options.backtrack_lexer&&(d={yylineno:this.yylineno,yylloc:{first_line:this.yylloc.first_line,last_line:this.last_line,first_column:this.yylloc.first_column,last_column:this.yylloc.last_column},yytext:this.yytext,match:this.match,matches:this.matches,matched:this.matched,yyleng:this.yyleng,offset:this.offset,_more:this._more,_input:this._input,yy:this.yy,conditionStack:this.conditionStack.slice(0),done:this.done},this.options.ranges&&(d.yylloc.range=this.yylloc.range.slice(0))),c=i[0].match(/(?:\r\n?|\n).*/g),c&&(this.yylineno+=c.length),this.yylloc={first_line:this.yylloc.last_line,last_line:this.yylineno+1,first_column:this.yylloc.last_column,last_column:c?c[c.length-1].length-c[c.length-1].match(/\r?\n?/)[0].length:this.yylloc.last_column+i[0].length},this.yytext+=i[0],this.match+=i[0],this.matches=i,this.yyleng=this.yytext.length,this.options.ranges&&(this.yylloc.range=[this.offset,this.offset+=this.yyleng]),this._more=!1,this._backtrack=!1,this._input=this._input.slice(i[0].length),this.matched+=i[0],s=this.performAction.call(this,this.yy,this,o,this.conditionStack[this.conditionStack.length-1]),this.done&&this._input&&(this.done=!1),s)return s;if(this._backtrack){for(var l in d)this[l]=d[l];return!1}return!1},"test_match"),next:a(function(){if(this.done)return this.EOF;this._input||(this.done=!0);var i,o,s,c;this._more||(this.yytext="",this.match="");for(var d=this._currentRules(),l=0;l<d.length;l++)if(s=this._input.match(this.rules[d[l]]),s&&(!o||s[0].length>o[0].length)){if(o=s,c=l,this.options.backtrack_lexer){if(i=this.test_match(s,d[l]),i!==!1)return i;if(this._backtrack){o=!1;continue}else return!1}else if(!this.options.flex)break}return o?(i=this.test_match(o,d[c]),i!==!1?i:!1):this._input===""?this.EOF:this.parseError("Lexical error on line "+(this.yylineno+1)+`. Unrecognized text.
`+this.showPosition(),{text:"",token:null,line:this.yylineno})},"next"),lex:a(function(){var i=this.next();return i||this.lex()},"lex"),begin:a(function(i){this.conditionStack.push(i)},"begin"),popState:a(function(){return this.conditionStack.length-1>0?this.conditionStack.pop():this.conditionStack[0]},"popState"),_currentRules:a(function(){return this.conditionStack.length&&this.conditionStack[this.conditionStack.length-1]?this.conditions[this.conditionStack[this.conditionStack.length-1]].rules:this.conditions.INITIAL.rules},"_currentRules"),topState:a(function(i){return i=this.conditionStack.length-1-Math.abs(i||0),i>=0?this.conditionStack[i]:"INITIAL"},"topState"),pushState:a(function(i){this.begin(i)},"pushState"),stateStackSize:a(function(){return this.conditionStack.length},"stateStackSize"),options:{"case-insensitive":!0},performAction:a(function(i,o,s,c){switch(s){case 0:break;case 1:break;case 2:return 10;case 3:break;case 4:break;case 5:return 4;case 6:return 11;case 7:return this.begin("acc_title"),12;case 8:return this.popState(),"acc_title_value";case 9:return this.begin("acc_descr"),14;case 10:return this.popState(),"acc_descr_value";case 11:this.begin("acc_descr_multiline");break;case 12:this.popState();break;case 13:return"acc_descr_multiline_value";case 14:return 17;case 15:return 18;case 16:return 19;case 17:return":";case 18:return 6;case 19:return"INVALID"}},"anonymous"),rules:[/^(?:%(?!\{)[^\n]*)/i,/^(?:[^\}]%%[^\n]*)/i,/^(?:[\n]+)/i,/^(?:\s+)/i,/^(?:#[^\n]*)/i,/^(?:journey\b)/i,/^(?:title\s[^#\n;]+)/i,/^(?:accTitle\s*:\s*)/i,/^(?:(?!\n||)*[^\n]*)/i,/^(?:accDescr\s*:\s*)/i,/^(?:(?!\n||)*[^\n]*)/i,/^(?:accDescr\s*\{\s*)/i,/^(?:[\}])/i,/^(?:[^\}]*)/i,/^(?:section\s[^#:\n;]+)/i,/^(?:[^#:\n;]+)/i,/^(?::[^#\n;]+)/i,/^(?::)/i,/^(?:$)/i,/^(?:.)/i],conditions:{acc_descr_multiline:{rules:[12,13],inclusive:!1},acc_descr:{rules:[10],inclusive:!1},acc_title:{rules:[8],inclusive:!1},INITIAL:{rules:[0,1,2,3,4,5,6,7,9,11,14,15,16,17,18,19],inclusive:!0}}}})();function g(){this.yy={}}return a(g,"Parser"),g.prototype=f,f.Parser=g,new g})();G.parser=G;var Ct=G,V="",K=[],L=[],R=[],Et=a(function(){K.length=0,L.length=0,V="",R.length=0,at()},"clear"),At=a(function(e){V=e,K.push(e)},"addSection"),Pt=a(function(){return K},"getSections"),It=a(function(){let e=gt(),t=100,r=0;for(;!e&&r<t;)e=gt(),r++;return L.push(...R),L},"getTasks"),jt=a(function(){let e=[];return L.forEach(t=>{t.people&&e.push(...t.people)}),[...new Set(e)].sort()},"updateActors"),Vt=a(function(e,t){let r=t.substr(1).split(":"),p=0,n=[];r.length===1?(p=Number(r[0]),n=[]):(p=Number(r[0]),n=r[1].split(","));let h=n.map(y=>y.trim()),u={section:V,type:V,people:h,task:e,score:p};R.push(u)},"addTask"),Bt=a(function(e){let t={section:V,type:V,description:e,task:e,classes:[]};L.push(t)},"addTaskOrg"),gt=a(function(){let e=a(function(r){return R[r].processed},"compileTask"),t=!0;for(let[r,p]of R.entries())e(r),t=t&&p.processed;return t},"compileTasks"),mt={getConfig:a(()=>P().journey,"getConfig"),clear:Et,setDiagramTitle:ht,getDiagramTitle:ut,setAccTitle:rt,getAccTitle:ot,setAccDescription:lt,getAccDescription:ct,addSection:At,getSections:Pt,getTasks:It,addTask:Vt,addTaskOrg:Bt,getActors:a(function(){return jt()},"getActors")},Lt=a(e=>`.label {
    font-family: ${e.fontFamily};
    color: ${e.textColor};
  }
  .mouth {
    stroke: #666;
  }

  line {
    stroke: ${e.textColor}
  }

  .legend {
    fill: ${e.textColor};
    font-family: ${e.fontFamily};
  }

  .label text {
    fill: #333;
  }
  .label {
    color: ${e.textColor}
  }

  .face {
    ${e.faceColor?`fill: ${e.faceColor}`:"fill: #FFF8DC"};
    stroke: #999;
  }

  .node rect,
  .node circle,
  .node ellipse,
  .node polygon,
  .node path {
    fill: ${e.mainBkg};
    stroke: ${e.nodeBorder};
    stroke-width: 1px;
  }

  .node .label {
    text-align: center;
  }
  .node.clickable {
    cursor: pointer;
  }

  .arrowheadPath {
    fill: ${e.arrowheadColor};
  }

  .edgePaths .path {
    stroke: ${e.lineColor};
    stroke-width: 1.5px;
  }

  .flowchart-link {
    stroke: ${e.lineColor};
    fill: none;
  }

  .edgeLabel {
    background-color: ${e.edgeLabelBackground};
    rect {
      opacity: 0.5;
    }
    text-align: center;
  }

  .cluster rect {
  }

  .cluster text {
    fill: ${e.titleColor};
  }

  div.mermaidTooltip {
    position: absolute;
    text-align: center;
    max-width: 200px;
    padding: 2px;
    font-family: ${e.fontFamily};
    font-size: 12px;
    background: ${e.tertiaryColor};
    border: 1px solid ${e.border2};
    border-radius: 2px;
    pointer-events: none;
    z-index: 100;
  }

  .task-type-0, .section-type-0  {
    ${e.fillType0?`fill: ${e.fillType0}`:""};
  }
  .task-type-1, .section-type-1  {
    ${e.fillType0?`fill: ${e.fillType1}`:""};
  }
  .task-type-2, .section-type-2  {
    ${e.fillType0?`fill: ${e.fillType2}`:""};
  }
  .task-type-3, .section-type-3  {
    ${e.fillType0?`fill: ${e.fillType3}`:""};
  }
  .task-type-4, .section-type-4  {
    ${e.fillType0?`fill: ${e.fillType4}`:""};
  }
  .task-type-5, .section-type-5  {
    ${e.fillType0?`fill: ${e.fillType5}`:""};
  }
  .task-type-6, .section-type-6  {
    ${e.fillType0?`fill: ${e.fillType6}`:""};
  }
  .task-type-7, .section-type-7  {
    ${e.fillType0?`fill: ${e.fillType7}`:""};
  }

  .actor-0 {
    ${e.actor0?`fill: ${e.actor0}`:""};
  }
  .actor-1 {
    ${e.actor1?`fill: ${e.actor1}`:""};
  }
  .actor-2 {
    ${e.actor2?`fill: ${e.actor2}`:""};
  }
  .actor-3 {
    ${e.actor3?`fill: ${e.actor3}`:""};
  }
  .actor-4 {
    ${e.actor4?`fill: ${e.actor4}`:""};
  }
  .actor-5 {
    ${e.actor5?`fill: ${e.actor5}`:""};
  }
  ${ft()}
`,"getStyles"),tt=a(function(e,t){return yt(e,t)},"drawRect"),Rt=a(function(e,t){let r=e.append("circle").attr("cx",t.cx).attr("cy",t.cy).attr("class","face").attr("r",15).attr("stroke-width",2).attr("overflow","visible"),p=e.append("g");p.append("circle").attr("cx",t.cx-15/3).attr("cy",t.cy-15/3).attr("r",1.5).attr("stroke-width",2).attr("fill","#666").attr("stroke","#666"),p.append("circle").attr("cx",t.cx+15/3).attr("cy",t.cy-15/3).attr("r",1.5).attr("stroke-width",2).attr("fill","#666").attr("stroke","#666");function n(y){let f=Q().startAngle(Math.PI/2).endAngle(3*(Math.PI/2)).innerRadius(7.5).outerRadius(6.8181818181818175);y.append("path").attr("class","mouth").attr("d",f).attr("transform","translate("+t.cx+","+(t.cy+2)+")")}a(n,"smile");function h(y){let f=Q().startAngle(3*Math.PI/2).endAngle(5*(Math.PI/2)).innerRadius(7.5).outerRadius(6.8181818181818175);y.append("path").attr("class","mouth").attr("d",f).attr("transform","translate("+t.cx+","+(t.cy+7)+")")}a(h,"sad");function u(y){y.append("line").attr("class","mouth").attr("stroke",2).attr("x1",t.cx-5).attr("y1",t.cy+7).attr("x2",t.cx+5).attr("y2",t.cy+7).attr("class","mouth").attr("stroke-width","1px").attr("stroke","#666")}return a(u,"ambivalent"),t.score>3?n(p):t.score<3?h(p):u(p),r},"drawFace"),_t=a(function(e,t){let r=e.append("circle");return r.attr("cx",t.cx),r.attr("cy",t.cy),r.attr("class","actor-"+t.pos),r.attr("fill",t.fill),r.attr("stroke",t.stroke),r.attr("r",t.r),r.class!==void 0&&r.attr("class",r.class),t.title!==void 0&&r.append("title").text(t.title),r},"drawCircle"),bt=a(function(e,t){return dt(e,t)},"drawText"),Ft=a(function(e,t){function r(n,h,u,y,f){return n+","+h+" "+(n+u)+","+h+" "+(n+u)+","+(h+y-f)+" "+(n+u-f*1.2)+","+(h+y)+" "+n+","+(h+y)}a(r,"genPoints");let p=e.append("polygon");p.attr("points",r(t.x,t.y,50,20,7)),p.attr("class","labelBox"),t.y=t.y+t.labelMargin,t.x=t.x+.5*t.labelMargin,bt(e,t)},"drawLabel"),Dt=a(function(e,t,r){let p=e.append("g"),n=X();n.x=t.x,n.y=t.y,n.fill=t.fill,n.width=r.width*t.taskCount+r.diagramMarginX*(t.taskCount-1),n.height=r.height,n.class="journey-section section-type-"+t.num,n.rx=3,n.ry=3,tt(p,n),wt(r)(t.text,p,n.x,n.y,n.width,n.height,{class:"journey-section section-type-"+t.num},r,t.colour)},"drawSection"),J=-1,Ot=a(function(e,t,r,p){let n=t.x+r.width/2,h=e.append("g");J++,h.append("line").attr("id",p+"-task"+J).attr("x1",n).attr("y1",t.y).attr("x2",n).attr("y2",450).attr("class","task-line").attr("stroke-width","1px").attr("stroke-dasharray","4 2").attr("stroke","#666"),Rt(h,{cx:n,cy:300+(5-t.score)*30,score:t.score});let u=X();u.x=t.x,u.y=t.y,u.fill=t.fill,u.width=r.width,u.height=r.height,u.class="task task-type-"+t.num,u.rx=3,u.ry=3,tt(h,u);let y=t.x+14;t.people.forEach(f=>{let g=t.actors[f].color,i={cx:y,cy:t.y,r:7,fill:g,stroke:"#000",title:f,pos:t.actors[f].position};_t(h,i),y+=10}),wt(r)(t.task,h,u.x,u.y,u.width,u.height,{class:"task"},r,t.colour)},"drawTask"),Nt=a(function(e,t){pt(e,t)},"drawBackgroundRect"),wt=(function(){function e(n,h,u,y,f,g,i,o){p(h.append("text").attr("x",u+f/2).attr("y",y+g/2+5).style("font-color",o).style("text-anchor","middle").text(n),i)}a(e,"byText");function t(n,h,u,y,f,g,i,o,s){let{taskFontSize:c,taskFontFamily:d}=o,l=n.split(/<br\s*\/?>/gi);for(let k=0;k<l.length;k++){let m=k*c-c*(l.length-1)/2,b=h.append("text").attr("x",u+f/2).attr("y",y).attr("fill",s).style("text-anchor","middle").style("font-size",c).style("font-family",d);b.append("tspan").attr("x",u+f/2).attr("dy",m).text(l[k]),b.attr("y",y+g/2).attr("dominant-baseline","central").attr("alignment-baseline","central"),p(b,i)}}a(t,"byTspan");function r(n,h,u,y,f,g,i,o){let s=h.append("switch"),c=s.append("foreignObject").attr("x",u).attr("y",y).attr("width",f).attr("height",g).attr("position","fixed").append("xhtml:div").style("display","table").style("height","100%").style("width","100%");c.append("div").attr("class","label").style("display","table-cell").style("text-align","center").style("vertical-align","middle").text(n),t(n,s,u,y,f,g,i,o),p(c,i)}a(r,"byFo");function p(n,h){for(let u in h)u in h&&n.attr(u,h[u])}return a(p,"_setTextAttrs"),function(n){return n.textPlacement==="fo"?r:n.textPlacement==="old"?e:t}})(),F={drawRect:tt,drawCircle:_t,drawSection:Dt,drawText:bt,drawLabel:Ft,drawTask:Ot,drawBackgroundRect:Nt,initGraphics:a(function(e,t){J=-1,e.append("defs").append("marker").attr("id",t+"-arrowhead").attr("refX",5).attr("refY",2).attr("markerWidth",6).attr("markerHeight",4).attr("orient","auto").append("path").attr("d","M 0,0 V 4 L6,2 Z")},"initGraphics")},Yt=a(function(e){Object.keys(e).forEach(function(t){T[t]=e[t]})},"setConf"),S={},Y=0;function vt(e){let t=P().journey,r=t.maxLabelWidth;Y=0;let p=60;Object.keys(S).forEach(n=>{let h=S[n].color,u={cx:20,cy:p,r:7,fill:h,stroke:"#000",pos:S[n].position};F.drawCircle(e,u);let y=e.append("text").attr("visibility","hidden").text(n),f=y.node().getBoundingClientRect().width;y.remove();let g=[];if(f<=r)g=[n];else{let i=n.split(" "),o="";y=e.append("text").attr("visibility","hidden"),i.forEach(s=>{let c=o?`${o} ${s}`:s;if(y.text(c),y.node().getBoundingClientRect().width>r){if(o&&g.push(o),o=s,y.text(s),y.node().getBoundingClientRect().width>r){let d="";for(let l of s)d+=l,y.text(d+"-"),y.node().getBoundingClientRect().width>r&&(g.push(d.slice(0,-1)+"-"),d=l);o=d}}else o=c}),o&&g.push(o),y.remove()}g.forEach((i,o)=>{let s={x:40,y:p+7+o*20,fill:"#666",text:i,textMargin:t.boxTextMargin??5},c=F.drawText(e,s).node().getBoundingClientRect().width;c>Y&&c>t.leftMargin-c&&(Y=c)}),p+=Math.max(20,g.length*20)})}a(vt,"drawActorLegend");var T=P().journey,C=0,zt=a(function(e,t,r,p){let n=P(),h=n.journey.titleColor,u=n.journey.titleFontSize,y=n.journey.titleFontFamily,f=n.securityLevel,g;f==="sandbox"&&(g=N("#i"+t));let i=f==="sandbox"?N(g.nodes()[0].contentDocument.body):N("body");$.init();let o=i.select("#"+t);F.initGraphics(o,t);let s=p.db.getTasks(),c=p.db.getDiagramTitle(),d=p.db.getActors();for(let I in S)delete S[I];let l=0;d.forEach(I=>{S[I]={color:T.actorColours[l%T.actorColours.length],position:l},l++}),vt(o),C=T.leftMargin+Y,$.insert(0,0,C,Object.keys(S).length*50),Wt(o,s,0,t);let k=$.getBounds();c&&o.append("text").text(c).attr("x",C).attr("font-size",u).attr("font-weight","bold").attr("y",25).attr("fill",h).attr("font-family",y);let m=k.stopy-k.starty+2*T.diagramMarginY,b=C+k.stopx+2*T.diagramMarginX;st(o,m,b,T.useMaxWidth),o.append("line").attr("x1",C).attr("y1",T.height*4).attr("x2",b-C-4).attr("y2",T.height*4).attr("stroke-width",4).attr("stroke","black").attr("marker-end","url(#"+t+"-arrowhead)");let B=c?70:0;o.attr("viewBox",`${k.startx} -25 ${b} ${m+B}`),o.attr("preserveAspectRatio","xMinYMin meet"),o.attr("height",m+B+25)},"draw"),$={data:{startx:void 0,stopx:void 0,starty:void 0,stopy:void 0},verticalPos:0,sequenceItems:[],init:a(function(){this.sequenceItems=[],this.data={startx:void 0,stopx:void 0,starty:void 0,stopy:void 0},this.verticalPos=0},"init"),updateVal:a(function(e,t,r,p){e[t]===void 0?e[t]=r:e[t]=p(r,e[t])},"updateVal"),updateBounds:a(function(e,t,r,p){let n=P().journey,h=this,u=0;function y(f){return a(function(g){u++;let i=h.sequenceItems.length-u+1;h.updateVal(g,"starty",t-i*n.boxMargin,Math.min),h.updateVal(g,"stopy",p+i*n.boxMargin,Math.max),h.updateVal($.data,"startx",e-i*n.boxMargin,Math.min),h.updateVal($.data,"stopx",r+i*n.boxMargin,Math.max),f!=="activation"&&(h.updateVal(g,"startx",e-i*n.boxMargin,Math.min),h.updateVal(g,"stopx",r+i*n.boxMargin,Math.max),h.updateVal($.data,"starty",t-i*n.boxMargin,Math.min),h.updateVal($.data,"stopy",p+i*n.boxMargin,Math.max))},"updateItemBounds")}a(y,"updateFn"),this.sequenceItems.forEach(y())},"updateBounds"),insert:a(function(e,t,r,p){let n=Math.min(e,r),h=Math.max(e,r),u=Math.min(t,p),y=Math.max(t,p);this.updateVal($.data,"startx",n,Math.min),this.updateVal($.data,"starty",u,Math.min),this.updateVal($.data,"stopx",h,Math.max),this.updateVal($.data,"stopy",y,Math.max),this.updateBounds(n,u,h,y)},"insert"),bumpVerticalPos:a(function(e){this.verticalPos=this.verticalPos+e,this.data.stopy=this.verticalPos},"bumpVerticalPos"),getVerticalPos:a(function(){return this.verticalPos},"getVerticalPos"),getBounds:a(function(){return this.data},"getBounds")},Z=T.sectionFills,xt=T.sectionColours,Wt=a(function(e,t,r,p){let n=P().journey,h="",u=r+(n.height*2+n.diagramMarginY),y=0,f="#CCC",g="black",i=0;for(let[o,s]of t.entries()){if(h!==s.section){f=Z[y%Z.length],i=y%Z.length,g=xt[y%xt.length];let d=0,l=s.section;for(let m=o;m<t.length&&t[m].section==l;m++)d=d+1;let k={x:o*n.taskMargin+o*n.width+C,y:50,text:s.section,fill:f,num:i,colour:g,taskCount:d};F.drawSection(e,k,n),h=s.section,y++}let c=s.people.reduce((d,l)=>(S[l]&&(d[l]=S[l]),d),{});s.x=o*n.taskMargin+o*n.width+C,s.y=u,s.width=n.diagramMarginX,s.height=n.diagramMarginY,s.colour=g,s.fill=f,s.num=i,s.actors=c,F.drawTask(e,s,n,p),$.insert(s.x,s.y,s.x+s.width+n.taskMargin,450)}},"drawTasks"),kt={setConf:Yt,draw:zt},Gt={parser:Ct,db:mt,renderer:kt,styles:Lt,init:a(e=>{kt.setConf(e.journey),mt.clear()},"init")};export{Gt as diagram};
