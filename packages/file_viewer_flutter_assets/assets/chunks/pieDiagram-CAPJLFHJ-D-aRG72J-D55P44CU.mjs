import{a as ut}from"./chunk-BDAGGVEQ.mjs";import{a as q}from"./chunk-JCLYBJXB.mjs";import{a as pt}from"./chunk-AHBBM2ZC.mjs";import"./chunk-LB6TW6SL.mjs";import{a as ot}from"./chunk-W3NG3PJE.mjs";import{q as ct}from"./chunk-FHFSP7R2.mjs";import{a as st}from"./chunk-VFOLI7HO.mjs";import{a as $}from"./chunk-GFFERDM6.mjs";import{Z as it,_ as lt}from"./chunk-2EARK56B.mjs";import{j as P}from"./chunk-HTO6362Y.mjs";import{$ as rt,Q,V as X,W as Y,X as Z,Y as tt,Z as et,_ as at,aa as nt,s as K}from"./chunk-GMUPTIL4.mjs";import"./chunk-JJD7WD6F.mjs";import{e as F}from"./chunk-L2LBHEZ6.mjs";import{a as p}from"./chunk-NNTI5FQZ.mjs";import"./chunk-M6L4U24C.mjs";function vt(t,r){return r<t?-1:r>t?1:r>=t?0:NaN}function St(t){return t}function $t(){var t=St,r=vt,f=null,s=$(0),c=$(P),A=$(0);function n(e){var l,w=(e=st(e)).length,x,C,b=0,d=new Array(w),i=new Array(w),y=+s.apply(this,arguments),k=Math.min(P,Math.max(-P,c.apply(this,arguments)-y)),T,R=Math.min(Math.abs(k)/w,A.apply(this,arguments)),g=R*(k<0?-1:1),v;for(l=0;l<w;++l)(v=i[d[l]=l]=+t(e[l],l,e))>0&&(b+=v);for(r!=null?d.sort(function(M,h){return r(i[M],i[h])}):f!=null&&d.sort(function(M,h){return f(e[M],e[h])}),l=0,C=b?(k-w*g)/b:0;l<w;++l,y=T)x=d[l],v=i[x],T=y+(v>0?v*C:0)+g,i[x]={data:e[x],index:l,value:v,startAngle:y,endAngle:T,padAngle:R};return i}return n.value=function(e){return arguments.length?(t=typeof e=="function"?e:$(+e),n):t},n.sortValues=function(e){return arguments.length?(r=e,f=null,n):r},n.sort=function(e){return arguments.length?(f=e,r=null,n):f},n.startAngle=function(e){return arguments.length?(s=typeof e=="function"?e:$(+e),n):s},n.endAngle=function(e){return arguments.length?(c=typeof e=="function"?e:$(+e),n):c},n.padAngle=function(e){return arguments.length?(A=typeof e=="function"?e:$(+e),n):A},n}var dt=K.pie,_={sections:new Map,showData:!1,config:dt},W=_.sections,U=_.showData,bt=structuredClone(dt),gt={getConfig:p(()=>structuredClone(bt),"getConfig"),clear:p(()=>{W=new Map,U=_.showData,X()},"clear"),setDiagramTitle:at,getDiagramTitle:rt,setAccTitle:Y,getAccTitle:Z,setAccDescription:tt,getAccDescription:et,addSection:p(({label:t,value:r})=>{if(r<0)throw new Error(`"${t}" has invalid value: ${r}. Negative values are not allowed in pie charts. All slice values must be >= 0.`);W.has(t)||(W.set(t,r),F.debug(`added new section: ${t}, with value: ${r}`))},"addSection"),getSections:p(()=>W,"getSections"),setShowData:p(t=>{U=t},"setShowData"),getShowData:p(()=>U,"getShowData")},At=p((t,r)=>{pt(t,r),r.setShowData(t.showData),t.sections.map(r.addSection)},"populateDb"),Ct={parse:p(async t=>{let r=await ct("pie",t);F.debug(r),At(r,gt)},"parse")},Tt=p(t=>`
  .pieCircle{
    stroke: ${t.pieStrokeColor};
    stroke-width : ${t.pieStrokeWidth};
    opacity : ${t.pieOpacity};
  }
  .pieCircle.highlighted{
    scale: 1.05;
    opacity: 1;
  }
  .pieCircle.highlightedOnHover:hover{
    transition-duration: 250ms;
    scale: 1.05;
    opacity: 1;
  }
  .pieOuterCircle{
    stroke: ${t.pieOuterStrokeColor};
    stroke-width: ${t.pieOuterStrokeWidth};
    fill: none;
  }
  .pieTitleText {
    text-anchor: middle;
    font-size: ${t.pieTitleTextSize};
    fill: ${t.pieTitleTextColor};
    font-family: ${t.fontFamily};
  }
  .slice {
    font-family: ${t.fontFamily};
    fill: ${t.pieSectionTextColor};
    font-size:${t.pieSectionTextSize};
    // fill: white;
  }
  .legend text {
    fill: ${t.pieLegendTextColor};
    font-family: ${t.fontFamily};
    font-size: ${t.pieLegendTextSize};
  }
`,"getStyles"),Dt=p(t=>{let r=[...t.values()].reduce((s,c)=>s+c,0),f=[...t.entries()].map(([s,c])=>({label:s,value:c})).filter(s=>s.value/r*100>=1);return $t().value(s=>s.value).sort(null)(f)},"createPieArcs"),Lt={parser:Ct,db:gt,renderer:{draw:p((t,r,f,s)=>{F.debug(`rendering pie chart
`+t);let c=s.db,A=nt(),n=lt(c.getConfig(),A.pie),e=40,l=18,w=4,x=450,C=x,b=ot(r),d=b.append("g");d.attr("transform","translate(225,225)");let{themeVariables:i}=A,[y]=it(i.pieOuterStrokeWidth);y??(y=2);let k=n.legendPosition,T=n.textPosition,R=n.donutHole>0&&n.donutHole<=.9?n.donutHole:0,g=Math.min(C,x)/2-e,v=q().innerRadius(R*g).outerRadius(g),M=q().innerRadius(g*T).outerRadius(g*T),h=d.append("g");h.append("circle").attr("cx",0).attr("cy",0).attr("r",g+y/2).attr("class","pieOuterCircle");let z=c.getSections(),ht=Dt(z),mt=[i.pie1,i.pie2,i.pie3,i.pie4,i.pie5,i.pie6,i.pie7,i.pie8,i.pie9,i.pie10,i.pie11,i.pie12],B=0;z.forEach(a=>{B+=a});let j=ht.filter(a=>(a.data.value/B*100).toFixed(0)!=="0"),N=ut(mt).domain([...z.keys()]);h.selectAll("mySlices").data(j).enter().append("path").attr("d",v).attr("fill",a=>N(a.data.label)).attr("class",a=>{let o="pieCircle";return n.highlightSlice==="hover"?o+=" highlightedOnHover":n.highlightSlice===a.data.label&&(o+=" highlighted"),o}),h.selectAll("mySlices").data(j).enter().append("text").text(a=>(a.data.value/B*100).toFixed(0)+"%").attr("transform",a=>"translate("+M.centroid(a)+")").style("text-anchor","middle").attr("class","slice");let ft=d.append("text").text(c.getDiagramTitle()).attr("x",0).attr("y",-200).attr("class","pieTitleText"),O=[...z.entries()].map(([a,o])=>({label:a,value:o})),S=d.selectAll(".legend").data(O).enter().append("g").attr("class","legend");S.append("rect").attr("width",l).attr("height",l).style("fill",a=>N(a.label)).style("stroke",a=>N(a.label)),S.append("text").attr("x",22).attr("y",14).text(a=>c.getShowData()?`${a.label} [${a.value}]`:a.label);let D=Math.max(...S.selectAll("text").nodes().map(a=>a?.getBoundingClientRect().width??0)),H=x,E=490,u=22,L=O.length*u;switch(k){case"center":S.attr("transform",(a,o)=>{let m=u*O.length/2,V=-D/2-22,yt=o*u-m;return"translate("+V+","+yt+")"});break;case"top":H+=L,S.attr("transform",(a,o)=>{let m=g;return`translate(${-D/2-22}, ${o*u-m})`}),h.attr("transform",()=>`translate(0, ${L+u})`);break;case"bottom":H+=L,S.attr("transform",(a,o)=>{let m=-D/2-22,V=o*u- -207;return"translate("+m+","+V+")"});break;case"left":E+=22+D,S.attr("transform",(a,o)=>{let m=u*O.length/2;return"translate(-207,"+(o*u-m)+")"}),h.attr("transform",()=>`translate(${D+l+w}, 0)`);break;default:E+=22+D,S.attr("transform",(a,o)=>{let m=u*O.length/2;return"translate(216,"+(o*u-m)+")"})}let G=ft.node()?.getBoundingClientRect().width??0,wt=C/2-G/2,xt=C/2+G/2,I=Math.min(0,wt),J=Math.max(E,xt)-I;b.attr("viewBox",`${I} 0 ${J} ${H}`),Q(b,H,J,n.useMaxWidth)},"draw")},styles:Tt};export{Lt as diagram};
