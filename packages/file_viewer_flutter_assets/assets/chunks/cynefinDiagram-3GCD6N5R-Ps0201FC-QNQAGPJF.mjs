import{a as yt}from"./chunk-AHBBM2ZC.mjs";import{a as pt}from"./chunk-W3NG3PJE.mjs";import{q as mt}from"./chunk-FHFSP7R2.mjs";import{_ as Y}from"./chunk-2EARK56B.mjs";import"./chunk-HTO6362Y.mjs";import{$ as ft,D as V,Q as rt,V as ot,W as it,X as st,Y as ct,Z as lt,_ as dt,q as Z,s as at}from"./chunk-GMUPTIL4.mjs";import"./chunk-JJD7WD6F.mjs";import{e as j}from"./chunk-L2LBHEZ6.mjs";import{a as o}from"./chunk-NNTI5FQZ.mjs";import"./chunk-M6L4U24C.mjs";var ht=o(()=>({domains:new Map,transitions:[]}),"createDefaultData"),q=ht(),G={getDomains:o(()=>q.domains,"getDomains"),getTransitions:o(()=>q.transitions,"getTransitions"),setDomains:o(t=>{if(t)for(let e of t){let n=e.domain,a=(e.items??[]).map(c=>({label:c.label}));q.domains.set(n,{name:n,items:a})}},"setDomains"),setTransitions:o(t=>{t&&(q.transitions=t.filter(e=>e.from===e.to?(j.warn(`Cynefin: self-loop transition on domain "${e.from}" is not meaningful and will be skipped.`),!1):!0).map(e=>({from:e.from,to:e.to,label:e.label||void 0})))},"setTransitions"),getConfig:o(()=>Y({...at.cynefin,...V().cynefin}),"getConfig"),clear:o(()=>{ot(),q=ht()},"clear"),setAccTitle:it,getAccTitle:st,setDiagramTitle:dt,getDiagramTitle:ft,getAccDescription:lt,setAccDescription:ct},Tt=o(t=>{yt(t,G),G.setDomains(t.domains),G.setTransitions(t.transitions)},"populate"),St={parse:o(async t=>{let e=await mt("cynefin",t);j.debug(e),Tt(e)},"parse")};function O(t){let e=t+1831565813|0;return e=Math.imul(e^e>>>15,e|1),e^=e+Math.imul(e^e>>>7,e|61),((e^e>>>14)>>>0)/4294967296}o(O,"seededRandom");function $t(t){let e=0;for(let n=0;n<t.length;n++){let a=t.charCodeAt(n);e=(e<<5)-e+a,e|=0}return e}o($t,"hashString");function gt(t,e){return typeof t=="number"&&Number.isFinite(t)&&t!==0?t:$t(e)}o(gt,"resolveSeed");function ut(t,e,n,a){let c=t/2,p=a??t*.015,D=7,I=e/D,d=[];for(let r=0;r<=D;r++){let m=O(n+r*17)*p*2-p;d.push({x:c+m,y:r*I})}let k=`M${d[0].x},${d[0].y}`;for(let r=0;r<d.length-1;r++){let m=d[r],s=d[r+1],f=(m.y+s.y)/2,b=r%2===0?1:-1,h=p*1.5*b*O(n+r*31+7),R=m.x+h,F=f,W=s.x-h;k+=` C${R},${F} ${W},${f} ${s.x},${s.y}`}return k}o(ut,"generateFoldPath");function bt(t,e,n,a){let c=e/2,p=a??e*.015,D=7,I=t/D,d=[];for(let r=0;r<=D;r++){let m=O(n+r*23)*p*2-p;d.push({x:r*I,y:c+m})}let k=`M${d[0].x},${d[0].y}`;for(let r=0;r<d.length-1;r++){let m=d[r],s=d[r+1],f=(m.x+s.x)/2,b=r%2===0?1:-1,h=p*1.5*b*O(n+r*37+11),R=f,F=m.y+h,W=f,H=s.y-h;k+=` C${R},${F} ${W},${H} ${s.x},${s.y}`}return k}o(bt,"generateHorizontalBoundary");function wt(t,e){let n=t/2,a=e*.5,c=e,p=t*.03;return[`M${n},${a}`,`C${n+p},${a+(c-a)*.2}`,`${n-p*1.5},${a+(c-a)*.55}`,`${n+p*.5},${a+(c-a)*.75}`,`C${n-p},${a+(c-a)*.85}`,`${n+p*.3},${a+(c-a)*.95}`,`${n},${c}`].join(" ")}o(wt,"generateCliffPath");function Ct(t,e,n,a){return[`M${t-n},${e}`,`A${n},${a} 0 1,1 ${t+n},${e}`,`A${n},${a} 0 1,1 ${t-n},${e}`,"Z"].join(" ")}o(Ct,"generateConfusionPath");var xt={complex:{model:"Probe \u2192 Sense \u2192 Respond",practice:"Emergent Practices"},complicated:{model:"Sense \u2192 Analyse \u2192 Respond",practice:"Good Practices"},clear:{model:"Sense \u2192 Categorise \u2192 Respond",practice:"Best Practices"},chaotic:{model:"Act \u2192 Sense \u2192 Respond",practice:"Novel Practices"},confusion:{model:"",practice:"Disorder"}},vt=o((t,e)=>{let n=t/2,a=e/2;return{complex:{cx:n/2,cy:a/2,x:0,y:0,w:n,h:a},complicated:{cx:n+n/2,cy:a/2,x:n,y:0,w:n,h:a},chaotic:{cx:n/2,cy:a+a/2,x:0,y:a,w:n,h:a},clear:{cx:n+n/2,cy:a+a/2,x:n,y:a,w:n,h:a},confusion:{cx:n,cy:a,x:n*.7,y:a*.7,w:n*.6,h:a*.6}}},"getDomainLayouts"),zt=o(()=>{let t=Z(),e=V();return Y(t,e.themeVariables).cynefin},"getCynefinDomainColors"),_=3,Lt={draw:o((t,e,n,a)=>{let c=a.db,p=c.getDomains(),D=c.getTransitions(),I=c.getDiagramTitle(),d=c.getAccTitle(),k=c.getAccDescription(),r=c.getConfig(),m=zt();j.debug("Rendering Cynefin diagram");let s=r.width,f=r.height,b=r.padding,h=r.showDomainDescriptions,R=r.boundaryAmplitude,F=s+b*2,W=f+b*2,H={complex:m.complexBg,complicated:m.complicatedBg,clear:m.clearBg,chaotic:m.chaoticBg,confusion:m.confusionBg},B=pt(e);rt(B,W,F,r.useMaxWidth??!0),B.attr("viewBox",`0 0 ${F} ${W}`),d&&B.append("title").text(d),k&&B.append("desc").text(k);let A=B.append("g").attr("transform",`translate(${b}, ${b})`),E=vt(s,f),J=gt(r.seed,e),Dt=A.append("g").attr("class","cynefin-backgrounds"),Q=["complex","complicated","chaotic","clear"];for(let l of Q){let i=E[l];Dt.append("rect").attr("class","cynefinDomain").attr("x",i.x).attr("y",i.y).attr("width",i.w).attr("height",i.h).attr("fill",H[l]).attr("fill-opacity",.4).attr("stroke","none")}let X=A.append("g").attr("class","cynefin-boundaries");X.append("path").attr("class","cynefinBoundary").attr("d",ut(s,f,J,R)).attr("fill","none"),X.append("path").attr("class","cynefinBoundary").attr("d",bt(s,f,J+100,R)).attr("fill","none"),X.append("path").attr("class","cynefinCliff").attr("d",wt(s,f)).attr("fill","none");let kt=s*.15,Bt=f*.15;A.append("path").attr("class","cynefinConfusion").attr("d",Ct(s/2,f/2,kt,Bt)).attr("fill",H.confusion).attr("fill-opacity",.5);let K=A.append("g").attr("class","cynefin-labels");for(let l of Q){let i=E[l];K.append("text").attr("class","cynefinDomainLabel").attr("x",i.cx).attr("y",h?i.cy-30:i.cy).attr("text-anchor","middle").attr("dominant-baseline","middle").text(l.charAt(0).toUpperCase()+l.slice(1))}if(K.append("text").attr("class","cynefinDomainLabel").attr("x",s/2).attr("y",h?f/2-10:f/2).attr("text-anchor","middle").attr("dominant-baseline","middle").text("Confusion"),h){let l=A.append("g").attr("class","cynefin-subtitles");for(let i of Q){let x=E[i],y=xt[i];l.append("text").attr("class","cynefinSubtitle").attr("x",x.cx).attr("y",x.cy-10).attr("text-anchor","middle").attr("dominant-baseline","middle").text(y.model),l.append("text").attr("class","cynefinSubtitle").attr("x",x.cx).attr("y",x.cy+5).attr("text-anchor","middle").attr("dominant-baseline","middle").text(y.practice)}l.append("text").attr("class","cynefinSubtitle").attr("x",s/2).attr("y",f/2+8).attr("text-anchor","middle").attr("dominant-baseline","middle").text(xt.confusion.practice)}let tt=A.append("g").attr("class","cynefin-items"),N=26;for(let l of["complex","complicated","chaotic","clear","confusion"]){let i=p.get(l);if(!i||i.items.length===0)continue;let x=E[l],y=l==="confusion",z=i.items,L=0;y&&i.items.length>_&&(L=i.items.length-_,z=i.items.slice(0,_));let T;if(y){let g=h?22:14;T=x.cy+g}else T=x.cy+(h?25:15);if([...z].forEach((g,S)=>{let w=T+S*30,v=tt.append("g"),M=v.append("text").attr("class","cynefinItemText").attr("x",0).attr("y",N/2).attr("text-anchor","middle").attr("dominant-baseline","central").text(g.label),u=g.label.length*7,$=M.node();if($&&typeof $.getBBox=="function"){let U=$.getBBox();U.width>0&&(u=U.width)}let C=u+20,P=x.cx-C/2;v.attr("transform",`translate(${P}, ${w})`),v.insert("rect","text").attr("class","cynefinItem").attr("x",0).attr("y",0).attr("width",C).attr("height",N).attr("rx",4).attr("ry",4).attr("fill",H[l]).attr("fill-opacity",.95),M.attr("x",C/2).attr("y",N/2)}),L>0){let g=T+z.length*30,S=`+${L} more`,w=tt.append("g"),v=w.append("text").attr("class","cynefinItemText").attr("x",0).attr("y",N/2).attr("text-anchor","middle").attr("dominant-baseline","central").text(S),M=S.length*7,u=v.node();if(u&&typeof u.getBBox=="function"){let P=u.getBBox();P.width>0&&(M=P.width)}let $=M+20,C=x.cx-$/2;w.attr("transform",`translate(${C}, ${g})`),w.insert("rect","text").attr("class","cynefinItemOverflow").attr("x",0).attr("y",0).attr("width",$).attr("height",N).attr("rx",4).attr("ry",4).attr("fill",H[l]).attr("fill-opacity",.6),v.attr("x",$/2).attr("y",N/2)}}if(D.length>0){let l=B.select("defs").empty()?B.append("defs"):B.select("defs"),i=`cynefin-arrow-${e}`;l.append("marker").attr("id",i).attr("viewBox","0 0 10 10").attr("refX",9).attr("refY",5).attr("markerWidth",6).attr("markerHeight",6).attr("orient","auto-start-reverse").append("path").attr("d","M 0 0 L 10 5 L 0 10 z").attr("class","cynefinArrowHead");let x=A.append("g").attr("class","cynefin-arrows");D.forEach(y=>{let z=E[y.from],L=E[y.to];if(!z||!L)return;if(y.from===y.to){j.warn(`Cynefin renderer: skipping self-loop on domain "${y.from}"`);return}let T=z.cx,g=z.cy,S=L.cx,w=L.cy,v=(T+S)/2,M=(g+w)/2,u=S-T,$=w-g,C=Math.sqrt(u*u+$*$),P=C*.15,U=-$/C,At=u/C,et=v+U*P,nt=M+At*P;x.append("path").attr("class","cynefinArrowLine").attr("d",`M${T},${g} Q${et},${nt} ${S},${w}`).attr("fill","none").attr("marker-end",`url(#${i})`),y.label&&x.append("text").attr("class","cynefinArrowLabel").attr("x",et).attr("y",nt-6).attr("text-anchor","middle").attr("dominant-baseline","auto").text(y.label)})}I&&A.append("text").attr("class","cynefinTitle").attr("x",s/2).attr("y",-b/2).attr("text-anchor","middle").attr("dominant-baseline","middle").text(I)},"draw")},Mt=o(()=>{let t=Z(),e=V();return Y(t,e.themeVariables).cynefin},"getCynefinTheme"),Nt={parser:St,db:G,renderer:Lt,styles:o(()=>{let t=Mt();return`
	.cynefinDomain {
		stroke: none;
	}
	.cynefinDomainLabel {
		font-size: ${t.domainFontSize}px;
		font-weight: bold;
		fill: ${t.labelColor};
	}
	.cynefinSubtitle {
		font-size: ${t.itemFontSize-1}px;
		fill: ${t.textColor};
		font-style: italic;
	}
	.cynefinItem {
		fill-opacity: 0.95;
		stroke: ${t.boundaryColor};
		stroke-width: 1;
	}
	.cynefinItemText {
		font-size: ${t.itemFontSize}px;
		fill: ${t.textColor};
	}
	.cynefinItemOverflow {
		fill-opacity: 0.6;
		stroke: ${t.boundaryColor};
		stroke-width: 1;
		stroke-dasharray: 3 2;
	}
	.cynefinBoundary {
		stroke: ${t.boundaryColor};
		stroke-width: ${t.boundaryWidth};
		stroke-dasharray: 6 3;
	}
	.cynefinCliff {
		stroke: ${t.cliffColor};
		stroke-width: ${t.cliffWidth};
	}
	.cynefinConfusion {
		stroke: ${t.boundaryColor};
		stroke-width: 1.5;
		stroke-dasharray: 4 2;
	}
	.cynefinArrowLine {
		stroke: ${t.arrowColor};
		stroke-width: ${t.arrowWidth};
		fill: none;
	}
	.cynefinArrowHead {
		fill: ${t.arrowColor};
		stroke: none;
	}
	.cynefinArrowLabel {
		font-size: ${t.itemFontSize-1}px;
		fill: ${t.textColor};
	}
	.cynefinTitle {
		font-size: ${t.domainFontSize+2}px;
		font-weight: bold;
		fill: ${t.labelColor};
	}
	`},"styles")};export{Nt as diagram};
