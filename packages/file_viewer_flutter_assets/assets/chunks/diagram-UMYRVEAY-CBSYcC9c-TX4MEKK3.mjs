import{a as Y}from"./chunk-AHBBM2ZC.mjs";import{a as A}from"./chunk-W3NG3PJE.mjs";import{q as H}from"./chunk-FHFSP7R2.mjs";import{_ as x}from"./chunk-2EARK56B.mjs";import"./chunk-HTO6362Y.mjs";import{$ as D,D as v,Q as P,V as z,W as S,X as F,Y as W,Z as E,_ as T,s as C}from"./chunk-GMUPTIL4.mjs";import"./chunk-JJD7WD6F.mjs";import{e as y}from"./chunk-L2LBHEZ6.mjs";import{a as b}from"./chunk-NNTI5FQZ.mjs";import"./chunk-M6L4U24C.mjs";var $,q=C.packet,L=($=class{constructor(){this.packet=[],this.setAccTitle=S,this.getAccTitle=F,this.setDiagramTitle=T,this.getDiagramTitle=D,this.getAccDescription=E,this.setAccDescription=W}getConfig(){let t=x({...q,...v().packet});return t.showBits&&(t.paddingY+=10),t}getPacket(){return this.packet}pushWord(t){t.length>0&&this.packet.push(t)}clear(){z(),this.packet=[]}},b($,"PacketDB"),$),I=1e4,N=b((t,e)=>{Y(t,e);let r=-1,i=[],s=1,{bitsPerRow:l}=e.getConfig();for(let{start:a,end:o,bits:d,label:h}of t.blocks){if(a!==void 0&&o!==void 0&&o<a)throw new Error(`Packet block ${a} - ${o} is invalid. End must be greater than start.`);if(a??(a=r+1),a!==r+1)throw new Error(`Packet block ${a} - ${o??a} is not contiguous. It should start from ${r+1}.`);if(d===0)throw new Error(`Packet block ${a} is invalid. Cannot have a zero bit field.`);for(o??(o=a+(d??1)-1),d??(d=o-a+1),r=o,y.debug(`Packet block ${a} - ${r} with label ${h}`);i.length<=l+1&&e.getPacket().length<I;){let[c,p]=O({start:a,end:o,bits:d,label:h},s,l);if(i.push(c),c.end+1===s*l&&(e.pushWord(i),i=[],s++),!p)break;({start:a,end:o,bits:d,label:h}=p)}}e.pushWord(i)},"populate"),O=b((t,e,r)=>{if(t.start===void 0)throw new Error("start should have been set during first phase");if(t.end===void 0)throw new Error("end should have been set during first phase");if(t.start>t.end)throw new Error(`Block start ${t.start} is greater than block end ${t.end}.`);if(t.end+1<=e*r)return[t,void 0];let i=e*r-1,s=e*r;return[{start:t.start,end:i,label:t.label,bits:i-t.start},{start:s,end:t.end,label:t.label,bits:t.end-s}]},"getNextFittingBlock"),M={parser:{yy:void 0},parse:b(async t=>{let e=await H("packet",t),r=M.parser?.yy;if(!(r instanceof L))throw new Error("parser.parser?.yy was not a PacketDB. This is due to a bug within Mermaid, please report this issue at https://github.com/mermaid-js/mermaid/issues.");y.debug(e),N(e,r)},"parse")},U=b((t,e,r,i)=>{let s=i.db,l=s.getConfig(),{rowHeight:a,paddingY:o,bitWidth:d,bitsPerRow:h}=l,c=s.getPacket(),p=s.getDiagramTitle(),u=a+o,n=u*(c.length+1)-(p?0:a),k=d*h+2,f=A(e);f.attr("viewBox",`0 0 ${k} ${n}`),P(f,n,k,l.useMaxWidth);for(let[g,m]of c.entries())X(f,m,g,l);f.append("text").text(p).attr("x",k/2).attr("y",n-u/2).attr("dominant-baseline","middle").attr("text-anchor","middle").attr("class","packetTitle")},"draw"),X=b((t,e,r,{rowHeight:i,paddingX:s,paddingY:l,bitWidth:a,bitsPerRow:o,showBits:d,bitOrder:h})=>{let c=t.append("g"),p=r*(i+l)+l,u=h==="descending";for(let n of e){let k=n.end-n.start+1,f=n.start%o,g=(u?o-f-k:f)*a+1,m=k*a-s;if(c.append("rect").attr("x",g).attr("y",p).attr("width",m).attr("height",i).attr("class","packetBlock"),c.append("text").attr("x",g+m/2).attr("y",p+i/2).attr("class","packetLabel").attr("dominant-baseline","middle").attr("text-anchor","middle").text(n.label),!d)continue;let[R,j]=u?[n.end,n.start]:[n.start,n.end],w=k===1,B=p-2;c.append("text").attr("x",g+(w?m/2:0)).attr("y",B).attr("class","packetByte start").attr("dominant-baseline","auto").attr("text-anchor",w?"middle":"start").text(R),w||c.append("text").attr("x",g+m).attr("y",B).attr("class","packetByte end").attr("dominant-baseline","auto").attr("text-anchor","end").text(j)}},"drawWord"),_={draw:U},G={byteFontSize:"10px",startByteColor:"black",endByteColor:"black",labelColor:"black",labelFontSize:"12px",titleColor:"black",titleFontSize:"14px",blockStrokeColor:"black",blockStrokeWidth:"1",blockFillColor:"#efefef"},at={parser:M,get db(){return new L},renderer:_,styles:b(({packet:t}={})=>{let e=x(G,t);return`
	.packetByte {
		font-size: ${e.byteFontSize};
	}
	.packetByte.start {
		fill: ${e.startByteColor};
	}
	.packetByte.end {
		fill: ${e.endByteColor};
	}
	.packetLabel {
		fill: ${e.labelColor};
		font-size: ${e.labelFontSize};
	}
	.packetTitle {
		fill: ${e.titleColor};
		font-size: ${e.titleFontSize};
	}
	.packetBlock {
		stroke: ${e.blockStrokeColor};
		stroke-width: ${e.blockStrokeWidth};
		fill: ${e.blockFillColor};
	}
	`},"styles")};export{at as diagram};
