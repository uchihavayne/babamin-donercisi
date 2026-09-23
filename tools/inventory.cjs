const acorn=require('acorn'),fs=require('fs');
const types={}, calls={}, ops={}, nested=[];
for (const f of fs.readdirSync('source/game')) {
const ast=acorn.parse(fs.readFileSync('source/game/'+f,'utf8'),{ecmaVersion:2020,locations:true});
function walk(n,depth=0){if(!n||!n.type)return;types[n.type]=(types[n.type]||0)+1;if(n.type==='CallExpression' && n.callee.type==='MemberExpression'&&!n.callee.computed){let k=n.callee.property.name;calls[k]=(calls[k]||0)+1;}if(n.operator)ops[n.operator]=(ops[n.operator]||0)+1;if(/Function/.test(n.type)&&depth>0)nested.push([f,n.loc.start.line,n.id?.name,n.params?.map(x=>x.name)]);for (const [k,v] of Object.entries(n)){if(k==='loc')continue;if(Array.isArray(v))v.forEach(x=>walk(x,depth+(/Function/.test(n.type)?1:0)));else if(v&&v.type)walk(v,depth+(/Function/.test(n.type)?1:0));}}
walk(ast);
}console.log(JSON.stringify({types,calls,ops,nested},null,2));
