(function(){var c,j,s;c=function(c){c.length=0};j=function(c){return c.join("")};if(exports)exports.parse=function(r,o){var k,d,g,h,e,b,a,p,l,m,i,f,n,q;l=p=0;e=o.createDocumentFragment();m=[];k=[];d=[];i=[];g={};a=function(){var a,b;b=o.createElement(j(m));for(a in g)b.setAttribute(a,g[a]);e.appendChild(b);e=b;c(i);c(m);c(k);c(d);for(a in g)delete g[a];l=0};h=function(){e=e.parentNode};b=function(){g[j(k)]=j(d);c(k);c(d);l=2};for(b=[{"<":[function(){if(i.length>0)e.appendChild(o.createTextNode(j(i))),c(i)},1],"":[i,0]},{"/":[9],"":[m,2]},{" ":[3],"/":[8],">":[a],"":[m]},{"=":[4],"/":[8],">":[a],"":[k]},{'"':[5],"'":[6],"":[d,7]},{'"':[b],"":[d]},{"'":[b],"":[d]},{" ":[b,2],">":[b,a],"/":[b,8]},{">":[a,h]},{">":[h,0]}];h=r[p++];){a=b[l];a=a[h]||a[""]||[];n=0;for(q=a.length;n<q;n++)f=a[n],f.call?f():/^\d/.test(f)?l=f:f.push&&f.push(h)}return e}}).call(this);
