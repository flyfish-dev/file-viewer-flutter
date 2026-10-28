import{h as Kt}from"./chunk-WZV47FOD.mjs";import{a as qt}from"./chunk-OFY5Z3YT.mjs";import{b as Xt,c as Jt}from"./chunk-VDHDRJP2.mjs";import{a as Qt}from"./chunk-HP3DTGHW.mjs";import"./chunk-HPGV6P7Q.mjs";import"./chunk-PML24UA7.mjs";import"./chunk-BADMPF6P.mjs";import"./chunk-RCEWJAQE.mjs";import"./chunk-QBHIM66R.mjs";import"./chunk-VFOLI7HO.mjs";import"./chunk-GFFERDM6.mjs";import"./chunk-KFKCVKXY.mjs";import"./chunk-S4IBTULB.mjs";import"./chunk-DFFNJ5LC.mjs";import"./chunk-MGH4ZMRU.mjs";import"./chunk-DHO277E3.mjs";import{b as Ut,c as zt,d as Ht,e as Vt}from"./chunk-TGW5PM2W.mjs";import{$ as Mt,R as jt}from"./chunk-2EARK56B.mjs";import"./chunk-HTO6362Y.mjs";import{$ as Wt,P,V as Rt,W as Ft,X as Yt,Y as Bt,Z as Pt,_ as Gt,aa as I,h as Nt}from"./chunk-GMUPTIL4.mjs";import"./chunk-JJD7WD6F.mjs";import{e as _,g as yt}from"./chunk-L2LBHEZ6.mjs";import{a as u}from"./chunk-NNTI5FQZ.mjs";import"./chunk-M6L4U24C.mjs";var mt,xt=(function(){var t=u(function(o,c,p,S){for(p=p||{},S=o.length;S--;p[o[S]]=c);return p},"o"),e=[1,2],r=[1,3],s=[1,4],h=[2,4],a=[1,9],y=[1,11],g=[1,16],n=[1,17],f=[1,18],b=[1,19],E=[1,33],C=[1,20],Y=[1,21],O=[1,22],d=[1,23],w=[1,24],D=[1,26],R=[1,27],$=[1,28],N=[1,29],B=[1,30],st=[1,31],it=[1,32],rt=[1,35],ot=[1,36],nt=[1,37],at=[1,38],z=[1,34],m=[1,4,5,16,17,19,21,22,24,25,26,27,28,29,33,35,37,38,41,45,48,51,52,53,54,57],lt=[1,4,5,14,15,16,17,19,21,22,24,25,26,27,28,29,33,35,37,38,39,40,41,45,48,51,52,53,54,57],Lt=[4,5,16,17,19,21,22,24,25,26,27,28,29,33,35,37,38,41,45,48,51,52,53,54,57],kt={trace:u(function(){},"trace"),yy:{},symbols_:{error:2,start:3,SPACE:4,NL:5,SD:6,document:7,line:8,statement:9,classDefStatement:10,styleStatement:11,cssClassStatement:12,idStatement:13,DESCR:14,"-->":15,HIDE_EMPTY:16,scale:17,WIDTH:18,COMPOSIT_STATE:19,STRUCT_START:20,STRUCT_STOP:21,STATE_DESCR:22,AS:23,ID:24,FORK:25,JOIN:26,CHOICE:27,CONCURRENT:28,note:29,notePosition:30,NOTE_TEXT:31,direction:32,acc_title:33,acc_title_value:34,acc_descr:35,acc_descr_value:36,acc_descr_multiline_value:37,CLICK:38,STRING:39,HREF:40,classDef:41,CLASSDEF_ID:42,CLASSDEF_STYLEOPTS:43,DEFAULT:44,style:45,STYLE_IDS:46,STYLEDEF_STYLEOPTS:47,class:48,CLASSENTITY_IDS:49,STYLECLASS:50,direction_tb:51,direction_bt:52,direction_rl:53,direction_lr:54,eol:55,";":56,EDGE_STATE:57,STYLE_SEPARATOR:58,left_of:59,right_of:60,$accept:0,$end:1},terminals_:{2:"error",4:"SPACE",5:"NL",6:"SD",14:"DESCR",15:"-->",16:"HIDE_EMPTY",17:"scale",18:"WIDTH",19:"COMPOSIT_STATE",20:"STRUCT_START",21:"STRUCT_STOP",22:"STATE_DESCR",23:"AS",24:"ID",25:"FORK",26:"JOIN",27:"CHOICE",28:"CONCURRENT",29:"note",31:"NOTE_TEXT",33:"acc_title",34:"acc_title_value",35:"acc_descr",36:"acc_descr_value",37:"acc_descr_multiline_value",38:"CLICK",39:"STRING",40:"HREF",41:"classDef",42:"CLASSDEF_ID",43:"CLASSDEF_STYLEOPTS",44:"DEFAULT",45:"style",46:"STYLE_IDS",47:"STYLEDEF_STYLEOPTS",48:"class",49:"CLASSENTITY_IDS",50:"STYLECLASS",51:"direction_tb",52:"direction_bt",53:"direction_rl",54:"direction_lr",56:";",57:"EDGE_STATE",58:"STYLE_SEPARATOR",59:"left_of",60:"right_of"},productions_:[0,[3,2],[3,2],[3,2],[7,0],[7,2],[8,2],[8,1],[8,1],[9,1],[9,1],[9,1],[9,1],[9,2],[9,3],[9,4],[9,1],[9,2],[9,1],[9,4],[9,3],[9,6],[9,1],[9,1],[9,1],[9,1],[9,4],[9,4],[9,1],[9,2],[9,2],[9,1],[9,5],[9,5],[10,3],[10,3],[11,3],[12,3],[32,1],[32,1],[32,1],[32,1],[55,1],[55,1],[13,1],[13,1],[13,3],[13,3],[30,1],[30,1]],performAction:u(function(o,c,p,S,k,i,W){var l=i.length-1;switch(k){case 3:return S.setRootDoc(i[l]),i[l];case 4:this.$=[];break;case 5:i[l]!="nl"&&(i[l-1].push(i[l]),this.$=i[l-1]);break;case 6:case 7:this.$=i[l];break;case 8:this.$="nl";break;case 12:this.$=i[l];break;case 13:let ht=i[l-1];ht.description=S.trimColon(i[l]),this.$=ht;break;case 14:this.$={stmt:"relation",state1:i[l-2],state2:i[l]};break;case 15:let dt=S.trimColon(i[l]);this.$={stmt:"relation",state1:i[l-3],state2:i[l-1],description:dt};break;case 19:this.$={stmt:"state",id:i[l-3],type:"default",description:"",doc:i[l-1]};break;case 20:var j=i[l],H=i[l-2].trim();if(i[l].match(":")){var K=i[l].split(":");j=K[0],H=[H,K[1]]}this.$={stmt:"state",id:j,type:"default",description:H};break;case 21:this.$={stmt:"state",id:i[l-3],type:"default",description:i[l-5],doc:i[l-1]};break;case 22:this.$={stmt:"state",id:i[l],type:"fork"};break;case 23:this.$={stmt:"state",id:i[l],type:"join"};break;case 24:this.$={stmt:"state",id:i[l],type:"choice"};break;case 25:this.$={stmt:"state",id:S.getDividerId(),type:"divider"};break;case 26:this.$={stmt:"state",id:i[l-1].trim(),note:{position:i[l-2].trim(),text:i[l].trim()}};break;case 29:this.$=i[l].trim(),S.setAccTitle(this.$);break;case 30:case 31:this.$=i[l].trim(),S.setAccDescription(this.$);break;case 32:this.$={stmt:"click",id:i[l-3],url:i[l-2],tooltip:i[l-1]};break;case 33:this.$={stmt:"click",id:i[l-3],url:i[l-1],tooltip:""};break;case 34:case 35:this.$={stmt:"classDef",id:i[l-1].trim(),classes:i[l].trim()};break;case 36:this.$={stmt:"style",id:i[l-1].trim(),styleClass:i[l].trim()};break;case 37:this.$={stmt:"applyClass",id:i[l-1].trim(),styleClass:i[l].trim()};break;case 38:S.setDirection("TB"),this.$={stmt:"dir",value:"TB"};break;case 39:S.setDirection("BT"),this.$={stmt:"dir",value:"BT"};break;case 40:S.setDirection("RL"),this.$={stmt:"dir",value:"RL"};break;case 41:S.setDirection("LR"),this.$={stmt:"dir",value:"LR"};break;case 44:case 45:this.$={stmt:"state",id:i[l].trim(),type:"default",description:""};break;case 46:this.$={stmt:"state",id:i[l-2].trim(),classes:[i[l].trim()],type:"default",description:""};break;case 47:this.$={stmt:"state",id:i[l-2].trim(),classes:[i[l].trim()],type:"default",description:""}}},"anonymous"),table:[{3:1,4:e,5:r,6:s},{1:[3]},{3:5,4:e,5:r,6:s},{3:6,4:e,5:r,6:s},t([1,4,5,16,17,19,22,24,25,26,27,28,29,33,35,37,38,41,45,48,51,52,53,54,57],h,{7:7}),{1:[2,1]},{1:[2,2]},{1:[2,3],4:a,5:y,8:8,9:10,10:12,11:13,12:14,13:15,16:g,17:n,19:f,22:b,24:E,25:C,26:Y,27:O,28:d,29:w,32:25,33:D,35:R,37:$,38:N,41:B,45:st,48:it,51:rt,52:ot,53:nt,54:at,57:z},t(m,[2,5]),{9:39,10:12,11:13,12:14,13:15,16:g,17:n,19:f,22:b,24:E,25:C,26:Y,27:O,28:d,29:w,32:25,33:D,35:R,37:$,38:N,41:B,45:st,48:it,51:rt,52:ot,53:nt,54:at,57:z},t(m,[2,7]),t(m,[2,8]),t(m,[2,9]),t(m,[2,10]),t(m,[2,11]),t(m,[2,12],{14:[1,40],15:[1,41]}),t(m,[2,16]),{18:[1,42]},t(m,[2,18],{20:[1,43]}),{23:[1,44]},t(m,[2,22]),t(m,[2,23]),t(m,[2,24]),t(m,[2,25]),{30:45,31:[1,46],59:[1,47],60:[1,48]},t(m,[2,28]),{34:[1,49]},{36:[1,50]},t(m,[2,31]),{13:51,24:E,57:z},{42:[1,52],44:[1,53]},{46:[1,54]},{49:[1,55]},t(lt,[2,44],{58:[1,56]}),t(lt,[2,45],{58:[1,57]}),t(m,[2,38]),t(m,[2,39]),t(m,[2,40]),t(m,[2,41]),t(m,[2,6]),t(m,[2,13]),{13:58,24:E,57:z},t(m,[2,17]),t(Lt,h,{7:59}),{24:[1,60]},{24:[1,61]},{23:[1,62]},{24:[2,48]},{24:[2,49]},t(m,[2,29]),t(m,[2,30]),{39:[1,63],40:[1,64]},{43:[1,65]},{43:[1,66]},{47:[1,67]},{50:[1,68]},{24:[1,69]},{24:[1,70]},t(m,[2,14],{14:[1,71]}),{4:a,5:y,8:8,9:10,10:12,11:13,12:14,13:15,16:g,17:n,19:f,21:[1,72],22:b,24:E,25:C,26:Y,27:O,28:d,29:w,32:25,33:D,35:R,37:$,38:N,41:B,45:st,48:it,51:rt,52:ot,53:nt,54:at,57:z},t(m,[2,20],{20:[1,73]}),{31:[1,74]},{24:[1,75]},{39:[1,76]},{39:[1,77]},t(m,[2,34]),t(m,[2,35]),t(m,[2,36]),t(m,[2,37]),t(lt,[2,46]),t(lt,[2,47]),t(m,[2,15]),t(m,[2,19]),t(Lt,h,{7:78}),t(m,[2,26]),t(m,[2,27]),{5:[1,79]},{5:[1,80]},{4:a,5:y,8:8,9:10,10:12,11:13,12:14,13:15,16:g,17:n,19:f,21:[1,81],22:b,24:E,25:C,26:Y,27:O,28:d,29:w,32:25,33:D,35:R,37:$,38:N,41:B,45:st,48:it,51:rt,52:ot,53:nt,54:at,57:z},t(m,[2,32]),t(m,[2,33]),t(m,[2,21])],defaultActions:{5:[2,1],6:[2,2],47:[2,48],48:[2,49]},parseError:u(function(o,c){if(c.recoverable)this.trace(o);else{var p=new Error(o);throw p.hash=c,p}},"parseError"),parse:u(function(o){var c=this,p=[0],S=[],k=[null],i=[],W=this.table,l="",j=0,H=0,K=0,ht=2,dt=1,ke=i.slice.call(arguments,1),T=Object.create(this.lexer),M={yy:{}};for(var bt in this.yy)Object.prototype.hasOwnProperty.call(this.yy,bt)&&(M.yy[bt]=this.yy[bt]);T.setInput(o,M.yy),M.yy.lexer=T,M.yy.parser=this,typeof T.yylloc>"u"&&(T.yylloc={});var _t=T.yylloc;i.push(_t);var be=T.options&&T.options.ranges;typeof M.yy.parseError=="function"?this.parseError=M.yy.parseError:this.parseError=Object.getPrototypeOf(this).parseError;function _e(L){p.length=p.length-2*L,k.length=k.length-L,i.length=i.length-L}u(_e,"popStack");function It(){var L=S.pop()||T.lex()||dt;return typeof L!="number"&&(L instanceof Array&&(S=L,L=S.pop()),L=c.symbols_[L]||L),L}u(It,"lex");for(var x,Tt,U,A,Et,V={},ut,F,Ot,pt;;){if(U=p[p.length-1],this.defaultActions[U]?A=this.defaultActions[U]:((x===null||typeof x>"u")&&(x=It()),A=W[U]&&W[U][x]),typeof A>"u"||!A.length||!A[0]){var $t="";pt=[];for(ut in W[U])this.terminals_[ut]&&ut>ht&&pt.push("'"+this.terminals_[ut]+"'");T.showPosition?$t="Parse error on line "+(j+1)+`:
`+T.showPosition()+`
Expecting `+pt.join(", ")+", got '"+(this.terminals_[x]||x)+"'":$t="Parse error on line "+(j+1)+": Unexpected "+(x==dt?"end of input":"'"+(this.terminals_[x]||x)+"'"),this.parseError($t,{text:T.match,token:this.terminals_[x]||x,line:T.yylineno,loc:_t,expected:pt})}if(A[0]instanceof Array&&A.length>1)throw new Error("Parse Error: multiple actions possible at state: "+U+", token: "+x);switch(A[0]){case 1:p.push(x),k.push(T.yytext),i.push(T.yylloc),p.push(A[1]),x=null,Tt?(x=Tt,Tt=null):(H=T.yyleng,l=T.yytext,j=T.yylineno,_t=T.yylloc,K>0&&K--);break;case 2:if(F=this.productions_[A[1]][1],V.$=k[k.length-F],V._$={first_line:i[i.length-(F||1)].first_line,last_line:i[i.length-1].last_line,first_column:i[i.length-(F||1)].first_column,last_column:i[i.length-1].last_column},be&&(V._$.range=[i[i.length-(F||1)].range[0],i[i.length-1].range[1]]),Et=this.performAction.apply(V,[l,H,j,M.yy,A[1],k,i].concat(ke)),typeof Et<"u")return Et;F&&(p=p.slice(0,-1*F*2),k=k.slice(0,-1*F),i=i.slice(0,-1*F)),p.push(this.productions_[A[1]][0]),k.push(V.$),i.push(V._$),Ot=W[p[p.length-2]][p[p.length-1]],p.push(Ot);break;case 3:return!0}}return!0},"parse")};kt.lexer=(function(){return{EOF:1,parseError:u(function(o,c){if(this.yy.parser)this.yy.parser.parseError(o,c);else throw new Error(o)},"parseError"),setInput:u(function(o,c){return this.yy=c||this.yy||{},this._input=o,this._more=this._backtrack=this.done=!1,this.yylineno=this.yyleng=0,this.yytext=this.matched=this.match="",this.conditionStack=["INITIAL"],this.yylloc={first_line:1,first_column:0,last_line:1,last_column:0},this.options.ranges&&(this.yylloc.range=[0,0]),this.offset=0,this},"setInput"),input:u(function(){var o=this._input[0];return this.yytext+=o,this.yyleng++,this.offset++,this.match+=o,this.matched+=o,o.match(/(?:\r\n?|\n).*/g)?(this.yylineno++,this.yylloc.last_line++):this.yylloc.last_column++,this.options.ranges&&this.yylloc.range[1]++,this._input=this._input.slice(1),o},"input"),unput:u(function(o){var c=o.length,p=o.split(/(?:\r\n?|\n)/g);this._input=o+this._input,this.yytext=this.yytext.substr(0,this.yytext.length-c),this.offset-=c;var S=this.match.split(/(?:\r\n?|\n)/g);this.match=this.match.substr(0,this.match.length-1),this.matched=this.matched.substr(0,this.matched.length-1),p.length-1&&(this.yylineno-=p.length-1);var k=this.yylloc.range;return this.yylloc={first_line:this.yylloc.first_line,last_line:this.yylineno+1,first_column:this.yylloc.first_column,last_column:p?(p.length===S.length?this.yylloc.first_column:0)+S[S.length-p.length].length-p[0].length:this.yylloc.first_column-c},this.options.ranges&&(this.yylloc.range=[k[0],k[0]+this.yyleng-c]),this.yyleng=this.yytext.length,this},"unput"),more:u(function(){return this._more=!0,this},"more"),reject:u(function(){if(this.options.backtrack_lexer)this._backtrack=!0;else return this.parseError("Lexical error on line "+(this.yylineno+1)+`. You can only invoke reject() in the lexer when the lexer is of the backtracking persuasion (options.backtrack_lexer = true).
`+this.showPosition(),{text:"",token:null,line:this.yylineno});return this},"reject"),less:u(function(o){this.unput(this.match.slice(o))},"less"),pastInput:u(function(){var o=this.matched.substr(0,this.matched.length-this.match.length);return(o.length>20?"...":"")+o.substr(-20).replace(/\n/g,"")},"pastInput"),upcomingInput:u(function(){var o=this.match;return o.length<20&&(o+=this._input.substr(0,20-o.length)),(o.substr(0,20)+(o.length>20?"...":"")).replace(/\n/g,"")},"upcomingInput"),showPosition:u(function(){var o=this.pastInput(),c=new Array(o.length+1).join("-");return o+this.upcomingInput()+`
`+c+"^"},"showPosition"),test_match:u(function(o,c){var p,S,k;if(this.options.backtrack_lexer&&(k={yylineno:this.yylineno,yylloc:{first_line:this.yylloc.first_line,last_line:this.last_line,first_column:this.yylloc.first_column,last_column:this.yylloc.last_column},yytext:this.yytext,match:this.match,matches:this.matches,matched:this.matched,yyleng:this.yyleng,offset:this.offset,_more:this._more,_input:this._input,yy:this.yy,conditionStack:this.conditionStack.slice(0),done:this.done},this.options.ranges&&(k.yylloc.range=this.yylloc.range.slice(0))),S=o[0].match(/(?:\r\n?|\n).*/g),S&&(this.yylineno+=S.length),this.yylloc={first_line:this.yylloc.last_line,last_line:this.yylineno+1,first_column:this.yylloc.last_column,last_column:S?S[S.length-1].length-S[S.length-1].match(/\r?\n?/)[0].length:this.yylloc.last_column+o[0].length},this.yytext+=o[0],this.match+=o[0],this.matches=o,this.yyleng=this.yytext.length,this.options.ranges&&(this.yylloc.range=[this.offset,this.offset+=this.yyleng]),this._more=!1,this._backtrack=!1,this._input=this._input.slice(o[0].length),this.matched+=o[0],p=this.performAction.call(this,this.yy,this,c,this.conditionStack[this.conditionStack.length-1]),this.done&&this._input&&(this.done=!1),p)return p;if(this._backtrack){for(var i in k)this[i]=k[i];return!1}return!1},"test_match"),next:u(function(){if(this.done)return this.EOF;this._input||(this.done=!0);var o,c,p,S;this._more||(this.yytext="",this.match="");for(var k=this._currentRules(),i=0;i<k.length;i++)if(p=this._input.match(this.rules[k[i]]),p&&(!c||p[0].length>c[0].length)){if(c=p,S=i,this.options.backtrack_lexer){if(o=this.test_match(p,k[i]),o!==!1)return o;if(this._backtrack){c=!1;continue}else return!1}else if(!this.options.flex)break}return c?(o=this.test_match(c,k[S]),o!==!1?o:!1):this._input===""?this.EOF:this.parseError("Lexical error on line "+(this.yylineno+1)+`. Unrecognized text.
`+this.showPosition(),{text:"",token:null,line:this.yylineno})},"next"),lex:u(function(){var o=this.next();return o||this.lex()},"lex"),begin:u(function(o){this.conditionStack.push(o)},"begin"),popState:u(function(){return this.conditionStack.length-1>0?this.conditionStack.pop():this.conditionStack[0]},"popState"),_currentRules:u(function(){return this.conditionStack.length&&this.conditionStack[this.conditionStack.length-1]?this.conditions[this.conditionStack[this.conditionStack.length-1]].rules:this.conditions.INITIAL.rules},"_currentRules"),topState:u(function(o){return o=this.conditionStack.length-1-Math.abs(o||0),o>=0?this.conditionStack[o]:"INITIAL"},"topState"),pushState:u(function(o){this.begin(o)},"pushState"),stateStackSize:u(function(){return this.conditionStack.length},"stateStackSize"),options:{"case-insensitive":!0},performAction:u(function(o,c,p,S){function k(){let i=c.yytext.indexOf("%%");if(i===0)return!1;if(i>0){let W=c.yytext.slice(0,i),l=c.yytext.slice(i);l&&o.lexer.unput(l),c.yytext=W}return!0}switch(u(k,"processId"),p){case 0:return 38;case 1:return 40;case 2:return 39;case 3:return 44;case 4:return 51;case 5:return 52;case 6:return 53;case 7:return 54;case 8:return 5;case 9:break;case 10:break;case 11:break;case 12:break;case 13:return this.pushState("SCALE"),17;case 14:return 18;case 15:this.popState();break;case 16:return this.begin("acc_title"),33;case 17:return this.popState(),"acc_title_value";case 18:return this.begin("acc_descr"),35;case 19:return this.popState(),"acc_descr_value";case 20:this.begin("acc_descr_multiline");break;case 21:this.popState();break;case 22:return"acc_descr_multiline_value";case 23:return this.pushState("CLASSDEF"),41;case 24:return this.popState(),this.pushState("CLASSDEFID"),"DEFAULT_CLASSDEF_ID";case 25:return this.popState(),this.pushState("CLASSDEFID"),42;case 26:return this.popState(),43;case 27:return this.pushState("CLASS"),48;case 28:return this.popState(),this.pushState("CLASS_STYLE"),49;case 29:return this.popState(),50;case 30:return this.pushState("STYLE"),45;case 31:return this.popState(),this.pushState("STYLEDEF_STYLES"),46;case 32:return this.popState(),47;case 33:return this.pushState("SCALE"),17;case 34:return 18;case 35:this.popState();break;case 36:this.pushState("STATE");break;case 37:return this.popState(),c.yytext=c.yytext.slice(0,-8).trim(),25;case 38:return this.popState(),c.yytext=c.yytext.slice(0,-8).trim(),26;case 39:return this.popState(),c.yytext=c.yytext.slice(0,-10).trim(),27;case 40:return this.popState(),c.yytext=c.yytext.slice(0,-8).trim(),25;case 41:return this.popState(),c.yytext=c.yytext.slice(0,-8).trim(),26;case 42:return this.popState(),c.yytext=c.yytext.slice(0,-10).trim(),27;case 43:return 51;case 44:return 52;case 45:return 53;case 46:return 54;case 47:this.pushState("STATE_STRING");break;case 48:return this.pushState("STATE_ID"),"AS";case 49:return k()?(this.popState(),"ID"):void 0;case 50:this.popState();break;case 51:return"STATE_DESCR";case 52:throw new Error('Error: State name must be a single word. Found: "'+c.yytext.trim()+'"');case 53:return 19;case 54:this.popState();break;case 55:return this.popState(),this.pushState("struct"),20;case 56:return this.popState(),21;case 57:break;case 58:return this.begin("NOTE"),29;case 59:return this.popState(),this.pushState("NOTE_ID"),59;case 60:return this.popState(),this.pushState("NOTE_ID"),60;case 61:this.popState(),this.pushState("FLOATING_NOTE");break;case 62:return this.popState(),this.pushState("FLOATING_NOTE_ID"),"AS";case 63:break;case 64:return"NOTE_TEXT";case 65:return k()?(this.popState(),"ID"):void 0;case 66:return k()?(this.popState(),this.pushState("NOTE_TEXT"),24):void 0;case 67:return this.popState(),c.yytext=c.yytext.substr(2).trim(),31;case 68:return this.popState(),c.yytext=c.yytext.slice(0,-8).trim(),31;case 69:return 6;case 70:return 6;case 71:return 16;case 72:return 57;case 73:return k()?24:void 0;case 74:return c.yytext=c.yytext.trim(),14;case 75:return 15;case 76:return 28;case 77:return 58;case 78:return 5;case 79:return"INVALID"}},"anonymous"),rules:[/^(?:click\b)/i,/^(?:href\b)/i,/^(?:"[^"]*")/i,/^(?:default\b)/i,/^(?:.*direction\s+TB[^\n]*)/i,/^(?:.*direction\s+BT[^\n]*)/i,/^(?:.*direction\s+RL[^\n]*)/i,/^(?:.*direction\s+LR[^\n]*)/i,/^(?:[\n]+)/i,/^(?:[\s]+)/i,/^(?:((?!\n)\s)+)/i,/^(?:#[^\n]*)/i,/^(?:%%(?!\{)[^\n]*)/i,/^(?:scale\s+)/i,/^(?:\d+)/i,/^(?:\s+width\b)/i,/^(?:accTitle\s*:\s*)/i,/^(?:(?!\n||)*[^\n]*)/i,/^(?:accDescr\s*:\s*)/i,/^(?:(?!\n||)*[^\n]*)/i,/^(?:accDescr\s*\{\s*)/i,/^(?:[\}])/i,/^(?:[^\}]*)/i,/^(?:classDef\s+)/i,/^(?:DEFAULT\s+)/i,/^(?:\w+\s+)/i,/^(?:[^\n]*)/i,/^(?:class\s+)/i,/^(?:(\w+)+((,\s*\w+)*))/i,/^(?:[^\n]*)/i,/^(?:style\s+)/i,/^(?:[\w,]+\s+)/i,/^(?:[^\n]*)/i,/^(?:scale\s+)/i,/^(?:\d+)/i,/^(?:\s+width\b)/i,/^(?:state\s+)/i,/^(?:.*<<fork>>)/i,/^(?:.*<<join>>)/i,/^(?:.*<<choice>>)/i,/^(?:.*\[\[fork\]\])/i,/^(?:.*\[\[join\]\])/i,/^(?:.*\[\[choice\]\])/i,/^(?:.*direction\s+TB[^\n]*)/i,/^(?:.*direction\s+BT[^\n]*)/i,/^(?:.*direction\s+RL[^\n]*)/i,/^(?:.*direction\s+LR[^\n]*)/i,/^(?:["])/i,/^(?:\s*as\s+)/i,/^(?:[^\n\{]*)/i,/^(?:["])/i,/^(?:[^"]*)/i,/^(?:\w+\s+\w+.*?\{)/i,/^(?:[^\n\s\{]+)/i,/^(?:\n)/i,/^(?:\{)/i,/^(?:\})/i,/^(?:[\n])/i,/^(?:note\s+)/i,/^(?:left of\b)/i,/^(?:right of\b)/i,/^(?:")/i,/^(?:\s*as\s*)/i,/^(?:["])/i,/^(?:[^"]*)/i,/^(?:[^\n]*)/i,/^(?:\s*[^:\n\s\-]+)/i,/^(?:\s*:[^:\n;]+)/i,/^(?:[\s\S]*?\n\s*end note\b)/i,/^(?:stateDiagram\s+)/i,/^(?:stateDiagram-v2\s+)/i,/^(?:hide empty description\b)/i,/^(?:\[\*\])/i,/^(?:[^:\n\s\-\{]+)/i,/^(?:\s*:(?:[^:\n;]|:[^:\n;])+)/i,/^(?:-->)/i,/^(?:--)/i,/^(?::::)/i,/^(?:$)/i,/^(?:.)/i],conditions:{LINE:{rules:[10,11,12],inclusive:!1},struct:{rules:[10,11,12,23,27,30,36,43,44,45,46,56,57,58,72,73,74,75,76,77],inclusive:!1},FLOATING_NOTE_ID:{rules:[65],inclusive:!1},FLOATING_NOTE:{rules:[62,63,64],inclusive:!1},NOTE_TEXT:{rules:[67,68],inclusive:!1},NOTE_ID:{rules:[66],inclusive:!1},NOTE:{rules:[59,60,61],inclusive:!1},STYLEDEF_STYLEOPTS:{rules:[],inclusive:!1},STYLEDEF_STYLES:{rules:[32],inclusive:!1},STYLE_IDS:{rules:[],inclusive:!1},STYLE:{rules:[31],inclusive:!1},CLASS_STYLE:{rules:[29],inclusive:!1},CLASS:{rules:[28],inclusive:!1},CLASSDEFID:{rules:[26],inclusive:!1},CLASSDEF:{rules:[24,25],inclusive:!1},acc_descr_multiline:{rules:[21,22],inclusive:!1},acc_descr:{rules:[19],inclusive:!1},acc_title:{rules:[17],inclusive:!1},SCALE:{rules:[14,15,34,35],inclusive:!1},ALIAS:{rules:[],inclusive:!1},STATE_ID:{rules:[49],inclusive:!1},STATE_STRING:{rules:[50,51],inclusive:!1},FORK_STATE:{rules:[],inclusive:!1},STATE:{rules:[10,11,12,37,38,39,40,41,42,47,48,52,53,54,55],inclusive:!1},ID:{rules:[10,11,12],inclusive:!1},INITIAL:{rules:[0,1,2,3,4,5,6,7,8,9,11,12,13,16,18,20,23,27,30,33,36,55,58,69,70,71,72,73,74,75,77,78,79],inclusive:!0}}}})();function ct(){this.yy={}}return u(ct,"Parser"),ct.prototype=kt,kt.Parser=ct,new ct})();xt.parser=xt;var Te=xt,Ee="TB",oe="TB",Zt="dir",J="state",X="root",vt="relation",$e="classDef",Ce="style",De="applyClass",tt="default",ne="divider",ae="fill:none",le="fill: #333",ce="c",he="markdown",de="normal",Ct="rect",Dt="rectWithTitle",xe="stateStart",ve="stateEnd",wt="divider",te="roundedWithTitle",we="note",Ae="noteGroup",et="statediagram",Le=`${et}-state`,ue="transition",Ie="note",Oe=`${ue} note-edge`,Ne=`${et}-${Ie}`,Re=`${et}-cluster`,Fe=`${et}-cluster-alt`,pe="parent",ye="note",Ye="state",At="----",Be=`${At}${ye}`,ee=`${At}${pe}`,ft=new Map,G=0,me=0,q=new Map,Pe=u((t,e,r,s)=>{if(t===wt&&r?.id!==void 0&&q.has(r.id)){let y=q.get(r.id);return q.set(e,y),y}let h=me++,a=s?void 0:h;return q.set(e,a),a},"colorSlotFor");function St(t="",e=0,r="",s=At){return`${Ye}-${t}${r!==null&&r.length>0?`${s}${r}`:""}-${e}`}u(St,"stateDomId");var Ge=u((t,e,r,s,h,a,y,g)=>{_.trace("items",e),e.forEach(n=>{switch(n.stmt){case J:Z(t,n,r,s,h,a,y,g);break;case tt:Z(t,n,r,s,h,a,y,g);break;case vt:{Z(t,n.state1,r,s,h,a,y,g),Z(t,n.state2,r,s,h,a,y,g);let f=y==="neo",b={id:"edge"+G,start:n.state1.id,end:n.state2.id,arrowhead:"normal",arrowTypeEnd:f?"arrow_barb_neo":"arrow_barb",style:ae,labelStyle:"",label:P.sanitizeText(n.description??"",I()),arrowheadStyle:le,labelpos:ce,labelType:he,thickness:de,classes:ue,look:y};h.push(b),G++}}})},"setupDoc"),se=u((t,e=oe)=>{let r=e;if(t.doc)for(let s of t.doc)s.stmt==="dir"&&(r=s.value);return r},"getDir");function Q(t,e,r){if(!e.id||e.id==="</join></fork>"||e.id==="</choice>")return;e.cssClasses&&(Array.isArray(e.cssCompiledStyles)||(e.cssCompiledStyles=[]),e.cssClasses.split(" ").forEach(h=>{let a=r.get(h);a&&(e.cssCompiledStyles=[...e.cssCompiledStyles??[],...a.styles])}));let s=t.find(h=>h.id===e.id);s?Object.assign(s,e):t.push(e)}u(Q,"insertOrUpdateNode");function ge(t){return t?.classes?.join(" ")??""}u(ge,"getClassesFromDbInfo");function fe(t){return t?.styles??[]}u(fe,"getStylesFromDbInfo");var Z=u((t,e,r,s,h,a,y,g)=>{let n=e.id,f=r.get(n),b=ge(f),E=fe(f),C=I(),Y=b.trim()!==""||E.length>0;if(_.info("dataFetcher parsedItem",e,f,E),n!=="root"){let O=Ct;e.start===!0?O=xe:e.start===!1&&(O=ve),e.type!==tt&&(O=e.type),ft.get(n)||ft.set(n,{id:n,shape:O,description:P.sanitizeText(n,C),cssClasses:`${b} ${Le}`,cssStyles:E});let d=ft.get(n);e.description&&(Array.isArray(d.description)?(d.shape=Dt,d.description.push(e.description)):d.description?.length&&d.description.length>0?(d.shape=Dt,d.description===n?d.description=[e.description]:d.description=[d.description,e.description]):(d.shape=Ct,d.description=e.description),d.description=P.sanitizeTextOrArray(d.description,C)),d.description?.length===1&&d.shape===Dt&&(d.type==="group"?d.shape=te:d.shape=Ct),!d.type&&e.doc&&(_.info("Setting cluster for XCX",n,se(e)),d.type="group",d.isGroup=!0,d.dir=se(e),d.shape=e.type===ne?wt:te,d.colorIndex=Pe(d.shape,n,t,Y),d.cssClasses=`${d.cssClasses} ${Re} ${a?Fe:""}`);let w={labelStyle:"",shape:d.shape,label:d.description,cssClasses:d.cssClasses,cssCompiledStyles:[],cssStyles:d.cssStyles,id:n,dir:d.dir,domId:St(n,G),type:d.type,isGroup:d.type==="group",colorIndex:d.colorIndex,padding:8,rx:10,ry:10,look:y,labelType:"markdown"};if(w.shape===wt&&(w.label=""),t&&t.id!=="root"&&(_.trace("Setting node ",n," to be child of its parent ",t.id),w.parentId=t.id),w.centerLabel=!0,e.note){let D={labelStyle:"",shape:we,label:e.note.text,labelType:"markdown",cssClasses:Ne,cssStyles:[],cssCompiledStyles:[],id:n+Be+"-"+G,domId:St(n,G,ye),type:"node",isGroup:!1,padding:C.flowchart?.padding,look:y,position:e.note.position},R=n+ee,$={labelStyle:"",shape:Ae,label:e.note.text,cssClasses:d.cssClasses,cssStyles:[],id:n+ee,domId:St(n,G,pe),type:"group",isGroup:!0,padding:16,look:y,position:e.note.position};G++,$.id=R,D.parentId=R,Q(s,$,g),Q(s,D,g),Q(s,w,g);let N=n,B=D.id;e.note.position==="left of"&&(N=D.id,B=n),h.push({id:N+"-"+B,start:N,end:B,arrowhead:"none",arrowTypeEnd:"",style:ae,labelStyle:"",classes:Oe,pattern:"dashed",arrowheadStyle:le,labelpos:ce,labelType:he,thickness:de,look:y})}else Q(s,w,g)}e.doc&&(_.trace("Adding nodes children "),Ge(e,e.doc,r,s,h,!a,y,g))},"dataFetcher"),We=u(()=>{ft.clear(),G=0,me=0,q.clear()},"reset"),Se=u((t,e=oe)=>{if(!t.doc)return e;let r=e;for(let s of t.doc)s.stmt==="dir"&&(r=s.value);return r},"getDir"),je={getClasses:u(function(t,e){return e.db.getClasses()},"getClasses"),draw:u(async function(t,e,r,s){_.info("REF0:"),_.info("Drawing state diagram (v2)",e);let{securityLevel:h,state:a,layout:y}=I();s.db.extract(s.db.getRootDocV2());let g=s.db.getData(),n=qt(e,h);g.type=s.type,g.layoutAlgorithm=Jt(y),g.nodeSpacing=a?.nodeSpacing||50,g.rankSpacing=a?.rankSpacing||50,I().look==="neo"?g.markers=["barbNeo"]:g.markers=["barb"],g.diagramId=e,await Xt(g,n);let f=8;try{(typeof s.db.getLinks=="function"?s.db.getLinks():new Map).forEach((b,E)=>{let C=typeof E=="string"?E:typeof E?.id=="string"?E.id:"",Y=g.nodes.find($=>$.id===C);if(!C){_.warn("\u26A0\uFE0F Invalid or missing stateId from key:",JSON.stringify(E));return}let O=n.node()?.querySelectorAll("g.node, g.rough-node"),d;if(O?.forEach($=>{let N=$.textContent?.trim();($.id===Y?.domId||N===C)&&(d=$)}),!d){_.warn("\u26A0\uFE0F Could not find node matching text:",C);return}let w=d.parentNode;if(!w){_.warn("\u26A0\uFE0F Node has no parent, cannot wrap:",C);return}let D=document.createElementNS("http://www.w3.org/2000/svg","a"),R=b.url.replace(/^"+|"+$/g,"");if(D.setAttributeNS("http://www.w3.org/1999/xlink","xlink:href",R),D.setAttribute("target","_blank"),b.tooltip){let $=b.tooltip.replace(/^"+|"+$/g,"");D.setAttribute("title",$),d.setAttribute("title",$)}w.replaceChild(D,d),D.appendChild(d),_.info("\u{1F517} Wrapped node in <a> tag for:",C,b.url)})}catch(b){_.error("\u274C Error injecting clickable links:",b)}Mt.insertTitle(n,"statediagramTitleText",a?.titleTopMargin??25,s.db.getDiagramTitle()),Qt(n,f,et,a?.useMaxWidth??!0)},"draw"),getDir:Se},v={START_NODE:"[*]",START_TYPE:"start",END_NODE:"[*]",END_TYPE:"end",COLOR_KEYWORD:"color",FILL_KEYWORD:"fill",BG_FILL:"bgFill",STYLECLASS_SEP:","},ie=u(()=>new Map,"newClassesList"),re=u(()=>({relations:[],states:new Map,documents:{}}),"newDoc"),gt=u(t=>JSON.parse(JSON.stringify(t)),"clone"),Me=(mt=class{constructor(t){this.version=t,this.nodes=[],this.edges=[],this.rootDoc=[],this.classes=ie(),this.documents={root:re()},this.currentDocument=this.documents.root,this.startEndCount=0,this.dividerCnt=0,this.links=new Map,this.funs=[],this.getAccTitle=Yt,this.setAccTitle=Ft,this.getAccDescription=Pt,this.setAccDescription=Bt,this.setDiagramTitle=Gt,this.getDiagramTitle=Wt,this.clear(),this.setRootDoc=this.setRootDoc.bind(this),this.getDividerId=this.getDividerId.bind(this),this.setDirection=this.setDirection.bind(this),this.trimColon=this.trimColon.bind(this),this.bindFunctions=this.bindFunctions.bind(this)}extract(t){this.clear(!0);for(let s of Array.isArray(t)?t:t.doc)switch(s.stmt){case J:this.addState(s.id.trim(),s.type,s.doc,s.description,s.note);break;case vt:this.addRelation(s.state1,s.state2,s.description);break;case $e:this.addStyleClass(s.id.trim(),s.classes);break;case Ce:this.handleStyleDef(s);break;case De:this.setCssClass(s.id.trim(),s.styleClass);break;case"click":this.addLink(s.id,s.url,s.tooltip)}let e=this.getStates(),r=I();We(),Z(void 0,this.getRootDocV2(),e,this.nodes,this.edges,!0,r.look,this.classes);for(let s of this.nodes)if(Array.isArray(s.label)){if(s.description=s.label.slice(1),s.isGroup&&s.description.length>0)throw new Error(`Group nodes can only have label. Remove the additional description for node [${s.id}]`);s.label=s.label[0]}}handleStyleDef(t){let e=t.id.trim().split(","),r=t.styleClass.split(",");for(let s of e){let h=this.getState(s);if(!h){let a=s.trim();this.addState(a),h=this.getState(a)}h&&(h.styles=r.map(a=>a.replace(/;/g,"")?.trim()))}}setRootDoc(t){_.info("Setting root doc",t),this.rootDoc=t,this.version===1?this.extract(t):this.extract(this.getRootDocV2())}docTranslator(t,e,r){if(e.stmt===vt){this.docTranslator(t,e.state1,!0),this.docTranslator(t,e.state2,!1);return}if(e.stmt===J&&(e.id===v.START_NODE?(e.id=t.id+(r?"_start":"_end"),e.start=r):e.id=e.id.trim()),e.stmt!==X&&e.stmt!==J||!e.doc)return;let s=[],h=[];for(let a of e.doc)if(a.type===ne){let y=gt(a);y.doc=gt(h),s.push(y),h=[]}else h.push(a);if(s.length>0&&h.length>0){let a={stmt:J,id:jt(),type:"divider",doc:gt(h)};s.push(gt(a)),e.doc=s}e.doc.forEach(a=>this.docTranslator(e,a,!0))}getRootDocV2(){return this.docTranslator({id:X,stmt:X},{id:X,stmt:X,doc:this.rootDoc},!0),{id:X,doc:this.rootDoc}}addState(t,e=tt,r=void 0,s=void 0,h=void 0,a=void 0,y=void 0,g=void 0){let n=t?.trim();if(!this.currentDocument.states.has(n))_.info("Adding state ",n,s),this.currentDocument.states.set(n,{stmt:J,id:n,descriptions:[],type:e,doc:r,note:h,classes:[],styles:[],textStyles:[]});else{let f=this.currentDocument.states.get(n);if(!f)throw new Error(`State not found: ${n}`);f.doc||(f.doc=r),f.type||(f.type=e)}if(s&&(_.info("Setting state description",n,s),(Array.isArray(s)?s:[s]).forEach(f=>this.addDescription(n,f.trim()))),h){let f=this.currentDocument.states.get(n);if(!f)throw new Error(`State not found: ${n}`);f.note=h,f.note.text=P.sanitizeText(f.note.text,I())}a&&(_.info("Setting state classes",n,a),(Array.isArray(a)?a:[a]).forEach(f=>this.setCssClass(n,f.trim()))),y&&(_.info("Setting state styles",n,y),(Array.isArray(y)?y:[y]).forEach(f=>this.setStyle(n,f.trim()))),g&&(_.info("Setting state styles",n,y),(Array.isArray(g)?g:[g]).forEach(f=>this.setTextStyle(n,f.trim())))}clear(t){this.nodes=[],this.edges=[],this.funs=[this.setupToolTips.bind(this)],this.documents={root:re()},this.currentDocument=this.documents.root,this.startEndCount=0,this.classes=ie(),t||(this.links=new Map,Rt())}getState(t){return this.currentDocument.states.get(t)}getStates(){return this.currentDocument.states}logDocuments(){_.info("Documents = ",this.documents)}getRelations(){return this.currentDocument.relations}addLink(t,e,r){this.links.set(t,{url:e,tooltip:r}),_.warn("Adding link",t,e,r)}getLinks(){return this.links}startIdIfNeeded(t=""){return t===v.START_NODE?(this.startEndCount++,`${v.START_TYPE}${this.startEndCount}`):t}startTypeIfNeeded(t="",e=tt){return t===v.START_NODE?v.START_TYPE:e}endIdIfNeeded(t=""){return t===v.END_NODE?(this.startEndCount++,`${v.END_TYPE}${this.startEndCount}`):t}endTypeIfNeeded(t="",e=tt){return t===v.END_NODE?v.END_TYPE:e}addRelationObjs(t,e,r=""){let s=this.startIdIfNeeded(t.id.trim()),h=this.startTypeIfNeeded(t.id.trim(),t.type),a=this.startIdIfNeeded(e.id.trim()),y=this.startTypeIfNeeded(e.id.trim(),e.type);this.addState(s,h,t.doc,t.description,t.note,t.classes,t.styles,t.textStyles),this.addState(a,y,e.doc,e.description,e.note,e.classes,e.styles,e.textStyles),this.currentDocument.relations.push({id1:s,id2:a,relationTitle:P.sanitizeText(r,I())})}addRelation(t,e,r){if(typeof t=="object"&&typeof e=="object")this.addRelationObjs(t,e,r);else if(typeof t=="string"&&typeof e=="string"){let s=this.startIdIfNeeded(t.trim()),h=this.startTypeIfNeeded(t),a=this.endIdIfNeeded(e.trim()),y=this.endTypeIfNeeded(e);this.addState(s,h),this.addState(a,y),this.currentDocument.relations.push({id1:s,id2:a,relationTitle:r?P.sanitizeText(r,I()):void 0})}}addDescription(t,e){let r=this.currentDocument.states.get(t),s=e.startsWith(":")?e.replace(":","").trim():e;r?.descriptions?.push(P.sanitizeText(s,I()))}cleanupLabel(t){return t.startsWith(":")?t.slice(2).trim():t.trim()}getDividerId(){return this.dividerCnt++,`divider-id-${this.dividerCnt}`}addStyleClass(t,e=""){this.classes.has(t)||this.classes.set(t,{id:t,styles:[],textStyles:[]});let r=this.classes.get(t);e&&r&&e.split(v.STYLECLASS_SEP).forEach(s=>{let h=s.replace(/([^;]*);/,"$1").trim();if(RegExp(v.COLOR_KEYWORD).exec(s)){let a=h.replace(v.FILL_KEYWORD,v.BG_FILL).replace(v.COLOR_KEYWORD,v.FILL_KEYWORD);r.textStyles.push(a)}r.styles.push(h)})}getClasses(){return this.classes}setupToolTips(t){let e=Kt();yt(t).select("svg").selectAll("g.node, g.rough-node").on("mouseover",r=>{let s=yt(r.currentTarget),h=s.attr("title");if(h===null)return;let a=r.currentTarget?.getBoundingClientRect();e.transition().duration(200).style("opacity",".9"),e.style("left",window.scrollX+a.left+(a.right-a.left)/2+"px").style("top",window.scrollY+a.bottom+"px"),e.html(Nt.sanitize(h)),s.classed("hover",!0)}).on("mouseout",r=>{e.transition().duration(500).style("opacity",0),yt(r.currentTarget).classed("hover",!1)})}setCssClass(t,e){t.split(",").forEach(r=>{let s=this.getState(r);if(!s){let h=r.trim();this.addState(h),s=this.getState(h)}s?.classes?.push(e)})}setStyle(t,e){this.getState(t)?.styles?.push(e)}setTextStyle(t,e){this.getState(t)?.textStyles?.push(e)}bindFunctions(t){this.funs.forEach(e=>{e(t)})}getDirectionStatement(){return this.rootDoc.find(t=>t.stmt===Zt)}getDirection(){return this.getDirectionStatement()?.value??Ee}setDirection(t){let e=this.getDirectionStatement();e?e.value=t:this.rootDoc.unshift({stmt:Zt,value:t})}trimColon(t){return t.startsWith(":")?t.slice(1).trim():t.trim()}getData(){let t=I();for(let e of this.nodes)e.wrappingWidth??(e.wrappingWidth=t.state?.wrappingWidth),e.isGroup||(e.minWidth??(e.minWidth=t.state?.minNodeWidth));return{nodes:this.nodes,edges:this.edges,other:{},config:t,direction:Se(this.getRootDocV2())}}getConfig(){return I().state}},u(mt,"StateDB"),mt.relationType={AGGREGATION:0,EXTENSION:1,COMPOSITION:2,DEPENDENCY:3},mt),Ue=u(t=>{let{theme:e,bkgColorArray:r,borderColorArray:s}=t;if(!zt(e,s))return"";let h=Ht(t.look),a=Ut(r),y="";for(let g=0;g<Vt(s);g++){let n=s[g],f=a?`fill: ${r[g%r.length]};`:"",b=`[data-look="${h}"][data-color-id="color-${g}"]`;y+=`

    /* The title strip: \`rect.outer\` spans the whole composite and \`rect.inner\` covers
       the body, so what stays visible of \`outer\` is the band behind the label. */
    ${b}.statediagram-cluster rect.outer {
      stroke: ${n};
      ${f}
    }

    ${b}.statediagram-cluster rect.inner {
      stroke: ${n};
    }

    /* Concurrency regions. Siblings of one composite share a slot, so a divided composite
       reads as one thing split into parts rather than as several composites. */
    ${b}.statediagram-cluster rect.divider {
      stroke: ${n};
      ${f}
    }

    /* handDrawn draws the same container as roughjs shapes rather than plain rects, so it
       needs its own rules. \`roundedWithTitle\` and \`divider\` name those groups \`outer\`,
       \`inner\` and \`divider\` to match the classic branch, which is what lets these
       discriminate -- a bare \`.statediagram-cluster path\` rule reached the body as well and
       tinted the whole composite, losing \`compositeBackground\` and diverging from what
       classic and neo do.

       roughjs emits two paths per shape and marks them: the filled shape carries
       \`stroke="none"\` and the sketched outline carries \`fill="none"\`. Splitting on that is
       what keeps \`fill\` off the outline -- a rough outline is open squiggles, not a closed
       region, so filling it produces smears -- and keeps \`stroke\` off the fill shape, which
       would otherwise gain an edge it was drawn without. */
    ${b}.statediagram-cluster .outer path[stroke='none'] {
      ${f}
    }

    ${b}.statediagram-cluster .outer path[fill='none'] {
      stroke: ${n};
    }

    /* No \`.inner\` rule on purpose. The body shape is left entirely alone under handDrawn,
       where a rect's \`inner\` counterpart cannot be recoloured safely: roughjs draws a
       hachure fill as *stroked* lines, so its fill paths carry \`fill="none"\` exactly like
       the outline and no selector separates them. An \`.inner\` stroke rule therefore
       repainted the hatching of every alt composite in the palette colour instead of
       leaving it on \`altBackground\`. The container still reads as palette-coloured: the
       \`outer\` shape spans the whole composite, so its outline already frames the body. */

    /* Regions split the same way, which is why \`divider\` fills solid rather than taking
       roughjs's default hachure -- see the note on that call. Hatched, both of its paths
       carried \`fill="none"\` and these two rules degenerated: the tint matched nothing and
       the border rule repainted the hatching. */
    ${b}.statediagram-cluster .divider path[stroke='none'] {
      ${f}
    }

    ${b}.statediagram-cluster .divider path[fill='none'] {
      stroke: ${n};
    }
    `}return y},"genColor"),as={parser:Te,get db(){return new Me(2)},renderer:je,styles:u(t=>`
${Ue(t)}
defs [id$="-barbEnd"] {
    fill: ${t.transitionColor};
    stroke: ${t.transitionColor};
  }
g.stateGroup text {
  fill: ${t.nodeBorder};
  stroke: none;
  font-size: 10px;
}
g.stateGroup text {
  fill: ${t.textColor};
  stroke: none;
  font-size: 10px;

}
g.stateGroup .state-title {
  font-weight: bolder;
  fill: ${t.stateLabelColor};
}

g.stateGroup rect {
  fill: ${t.mainBkg};
  stroke: ${t.nodeBorder};
}

g.stateGroup line {
  stroke: ${t.lineColor};
  stroke-width: ${t.strokeWidth||1};
}

.transition {
  stroke: ${t.transitionColor};
  stroke-width: ${t.strokeWidth||1};
  fill: none;
}

.stateGroup .composit {
  fill: ${t.background};
  border-bottom: 1px
}

.stateGroup .alt-composit {
  fill: #e0e0e0;
  border-bottom: 1px
}

.state-note {
  stroke: ${t.noteBorderColor};
  fill: ${t.noteBkgColor};

  text {
    fill: ${t.noteTextColor};
    stroke: none;
    font-size: 10px;
  }
}

.stateLabel .box {
  stroke: none;
  stroke-width: 0;
  fill: ${t.mainBkg};
  opacity: 0.5;
}

.edgeLabel .label rect {
  fill: ${t.labelBackgroundColor};
  opacity: 0.5;
}
.edgeLabel {
  background-color: ${t.edgeLabelBackground};
  p {
    background-color: ${t.edgeLabelBackground};
  }
  rect {
    opacity: 0.5;
    background-color: ${t.edgeLabelBackground};
    fill: ${t.edgeLabelBackground};
  }
  text-align: center;
}
.edgeLabel .label text {
  fill: ${t.transitionLabelColor||t.tertiaryTextColor};
}
.label div .edgeLabel {
  color: ${t.transitionLabelColor||t.tertiaryTextColor};
}

.stateLabel text {
  fill: ${t.stateLabelColor};
  font-size: 10px;
  font-weight: bold;
}

.node circle.state-start {
  fill: ${t.specialStateColor};
  stroke: ${t.specialStateColor};
}

.node .fork-join {
  fill: ${t.specialStateColor};
  stroke: ${t.specialStateColor};
}

.node circle.state-end {
  fill: ${t.innerEndBackground};
  stroke: ${t.background};
  stroke-width: 1.5
}
.end-state-inner {
  fill: ${t.compositeBackground||t.background};
  // stroke: ${t.background};
  stroke-width: 1.5
}

.node rect {
  fill: ${t.stateBkg||t.mainBkg};
  stroke: ${t.stateBorder||t.nodeBorder};
  stroke-width: ${t.strokeWidth||1}px;
}
.node polygon {
  fill: ${t.mainBkg};
  stroke: ${t.stateBorder||t.nodeBorder};;
  stroke-width: ${t.strokeWidth||1}px;
}
[id$="-barbEnd"] {
  fill: ${t.lineColor};
}

.statediagram-cluster rect {
  fill: ${t.compositeTitleBackground};
  stroke: ${t.stateBorder||t.nodeBorder};
  stroke-width: ${t.strokeWidth||1}px;
}

.cluster-label, .nodeLabel {
  color: ${t.stateLabelColor};
  // line-height: 1;
}

.statediagram-cluster rect.outer {
  rx: 5px;
  ry: 5px;
}
.statediagram-state .divider {
  stroke: ${t.stateBorder||t.nodeBorder};
}

.statediagram-state .title-state {
  rx: 5px;
  ry: 5px;
}
.statediagram-cluster.statediagram-cluster .inner {
  fill: ${t.compositeBackground||t.background};
}
.statediagram-cluster.statediagram-cluster-alt .inner {
  fill: ${t.altBackground?t.altBackground:"#efefef"};
}

.statediagram-cluster .inner {
  rx:0;
  ry:0;
}

.statediagram-state rect.basic {
  rx: 5px;
  ry: 5px;
}
.statediagram-state rect.divider {
  stroke-dasharray: 10,10;
  fill: ${t.altBackground?t.altBackground:"#efefef"};
}

.note-edge {
  stroke-dasharray: 5;
}

.statediagram-note rect {
  fill: ${t.noteBkgColor};
  stroke: ${t.noteBorderColor};
  stroke-width: 1px;
  rx: 0;
  ry: 0;
}
.statediagram-note rect {
  fill: ${t.noteBkgColor};
  stroke: ${t.noteBorderColor};
  stroke-width: 1px;
  rx: 0;
  ry: 0;
}

.statediagram-note text {
  fill: ${t.noteTextColor};
}

.statediagram-note .nodeLabel {
  color: ${t.noteTextColor};
}
.statediagram .edgeLabel {
  color: red; // ${t.noteTextColor};
}

[id$="-dependencyStart"], [id$="-dependencyEnd"] {
  fill: ${t.lineColor};
  stroke: ${t.lineColor};
  stroke-width: ${t.strokeWidth||1};
}

.statediagramTitleText {
  text-anchor: middle;
  font-size: 18px;
  fill: ${t.textColor};
}

[data-look="neo"].statediagram-cluster rect {
  fill: ${t.mainBkg};
  stroke: ${t.useGradient?"url("+t.svgId+"-gradient)":t.stateBorder||t.nodeBorder};
  stroke-width: ${t.strokeWidth??1};
}
[data-look="neo"].statediagram-cluster rect.outer {
  rx: ${t.radius}px;
  ry: ${t.radius}px;
  filter: ${t.dropShadow?t.dropShadow.replace("url(#drop-shadow)",`url(${t.svgId}-drop-shadow)`):"none"}
}
`,"getStyles"),init:u(t=>{t.state||(t.state={}),t.state.arrowMarkerAbsolute=t.arrowMarkerAbsolute},"init")};export{as as diagram};
