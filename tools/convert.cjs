// Build-time source conversion. The delivered game runs only GDScript.
const fs=require('fs'),acorn=require('acorn');
const order=JSON.parse(fs.readFileSync('source/modules.json'));
let mods=order.map(file=>({file,ast:acorn.parse(fs.readFileSync('source/game/'+file,'utf8'),{ecmaVersion:2020,locations:true})}));
const globals=new Set(), functions=new Map();
for(const m of mods)for(const n of m.ast.body){if(n.type==='VariableDeclaration')for(const d of n.declarations)globals.add(d.id.name);if(n.type==='FunctionDeclaration')functions.set(n.id.name,n.params.length);}
for(const g of ['window','document','navigator','performance','localStorage','screen','console'])globals.add(g);
const native=new Set(['textW','drawStr','asinF','coneProfile','meatCol','meatColCalc','meatColQ','hash1','cls','fr','px','rc','hl','vl','ln','disc','ring','ell','ellOut','rrect','rrectOut','dith','fitScreen','fsOn','fsToggle','ptr','audioInit','noiseBuf','beep','noise','swell','pourSndStart','pourSndStop','pourSndLevel','ambSet','ambRain','sndBus','sndElVol','sndVolGuncelle','sndLoad','sndFallback','sndPlay','sndLoop','musNote','musPerc','musTick','musInit','musSet','appPause','appResume','logoYukle','sprYukle','saveGame','loadGame','clearSave','volUygula']);
let fastFunction=false;let dataFiles=[];let serial=0,extras=[],map=[],currentFile='',scope=null,loop=[];
const q=s=>JSON.stringify(s).replace(/\\u([0-9a-f]{4})/gi,(_,x)=>String.fromCharCode(parseInt(x,16)));
const num=v=>Number.isInteger(v)?v+'.0':String(v);
function locals(n){let s=new Set();function walk(n){if(!n)return;if(n.type==='FunctionDeclaration'){s.add(n.id.name);return;}if(n.type==='FunctionExpression')return;if(n.type==='VariableDeclarator')s.add(n.id.name);if(n.type==='CatchClause')s.add(n.param.name);for(const [k,v]of Object.entries(n)){if(k==='loc')continue;if(Array.isArray(v))v.forEach(x=>x&&x.type&&walk(x));else if(v&&v.type)walk(v);}}walk(n);return s;}
const infos=new Map();let scopeSerial=0;
function analyze(n,outer=null,parent=null,key=''){
 if(!n||!n.type)return;
 if(n.type==='FunctionExpression'||n.type==='FunctionDeclaration'){
  const info={id:++scopeSerial,names:locals(n.body),parent:outer,captured:new Set(),free:new Map(),boxed:hasAssignExpression(n.body)};
  n.params.forEach(p=>info.names.add(p.name));infos.set(n,info);analyze(n.body,info,n,'body');return;
 }
 if(n.type==='Identifier'&&outer){
  const skip=parent&&(parent.type==='MemberExpression'&&key==='property'&&!parent.computed||parent.type==='Property'&&key==='key'&&!parent.computed||parent.type==='VariableDeclarator'&&key==='id'||parent.type==='CatchClause'&&key==='param');
  if(!skip){let owner=outer;while(owner&&!owner.names.has(n.name))owner=owner.parent;if(owner&&owner!==outer){owner.captured.add(n.name);let cursor=outer;while(cursor!==owner){cursor.free.set(owner.id+':'+n.name,{owner,name:n.name});cursor=cursor.parent;}}}
 }
 for(const [k,v] of Object.entries(n)){if(k==='loc')continue;if(Array.isArray(v))v.forEach(x=>analyze(x,outer,n,k));else if(v&&v.type)analyze(v,outer,n,k);}
}
function hasAssignExpression(body){let found=false;function walk(n,parent){if(!n||!n.type)return;if(n.type==='FunctionExpression'||n.type==='FunctionDeclaration')return;if((n.type==='AssignmentExpression'||n.type==='UpdateExpression')&&parent&&parent.type!=='ExpressionStatement'&&parent.type!=='ForStatement')found=true;for(const v of Object.values(n)){if(Array.isArray(v))v.forEach(x=>walk(x,n));else if(v&&v.type)walk(v,n);}}walk(body,null);return found;}
for(const m of mods)analyze(m.ast);
function ownerOf(name){let s=scope;while(s){if(s.names.has(name))return s;s=s.parent;}return null;}
function cellPath(owner,name,current=scope){return owner===current?'_cells['+q(name)+']':'_captures['+q(owner.id+':'+name)+']';}
function localPath(name){let owner=ownerOf(name);if(!owner)return null;if(owner!==scope||owner.captured.has(name))return cellPath(owner,name)+'[0]';return owner.boxed?'_v['+q(name)+']':'v_'+name;}
function declarations(names,params,isClosure){let code='';
 if(fastFunction){for(const name of names)code+='\tvar v_'+name+': '+(name==='sp'?'Dictionary':'float')+' = '+(params.some(p=>p.name===name)?'p_'+name:name==='sp'?'{}':'0.0')+'\n';return code;}
 if(scope.captured.size)code+='\tvar _cells: Dictionary = {'+[...scope.captured].map(x=>q(x)+': ['+(!isClosure&&params.some(p=>p.name===x)?'p_'+x:'null')+']').join(', ')+'}\n';
 const unboxed=[...names].filter(x=>!scope.captured.has(x));
 if(scope.boxed)code+='\tvar _v: Dictionary = {'+unboxed.map(x=>q(x)+': '+(!isClosure&&params.some(p=>p.name===x)?'p_'+x:'null')).join(', ')+'}\n';
 else for(const name of unboxed)code+='\tvar v_'+name+': Variant = '+(!isClosure&&params.some(p=>p.name===name)?'p_'+name:'null')+'\n';
 if(isClosure)params.forEach((p,i)=>code+='\t'+localPath(p.name)+' = J.arg(_args, '+i+')\n');
 return code;
}
function functionBody(n){return stmts(n.body.body.filter(x=>x.type==='FunctionDeclaration'),1)+stmts(n.body.body.filter(x=>x.type!=='FunctionDeclaration'),1);}
function ident(name){if(name==='undefined'||name==='NaN')return 'null';if(name==='Infinity')return 'INF';if(name==='Math')return '{"PI": PI}';const p=localPath(name);if(p)return p;if(functions.has(name))return 'J.ref(f_'+name+', '+functions.get(name)+')';if(globals.has(name))return 'j_'+name;throw Error('Unknown identifier '+name+' in '+currentFile);}
function prop(n){return n.computed?ex(n.property):q(n.property.name);}
function truth(n){if(n.type==='LogicalExpression')return '('+truth(n.left)+(n.operator==='&&'?' and ':' or ')+truth(n.right)+')';if(n.type==='UnaryExpression'&&n.operator==='!')return '(not '+truth(n.argument)+')';if(n.type==='BinaryExpression'&&['===','!==','==','!=','<','>','<=','>=','in'].includes(n.operator))return ex(n);return 'J.truth('+ex(n)+')';}
function bin(op,a,b){if(fastFunction&&['===','!=='].includes(op))return '('+a+(op==='==='?' == ':' != ')+b+')';if(fastFunction&&['+','-','*','<','>','<=','>='].includes(op))return '('+a+' '+op+' '+b+')';if(op==='+')return 'J.add('+a+', '+b+')';if(op==='%' )return 'fmod(J.n('+a+'), J.n('+b+'))';if(['&','|','<<','>>'].includes(op))return '(int(J.n('+a+')) '+op+' int(J.n('+b+')))';if(['===','==','!==','!='].includes(op))return (op.includes('!')?'not ':'')+'J.eq('+a+', '+b+')';if(op==='/')return '(float('+a+') / float('+b+'))';if(['<','>','<=','>='].includes(op))return 'J.'+({'<':'lt','>':'gt','<=':'le','>=':'ge'}[op])+'('+a+', '+b+')';if(['-','*'].includes(op))return '('+a+' '+op+' '+b+')';if(op==='in')return 'J.has('+b+', '+a+')';throw Error('bin '+op);}
function assign(n,stmt=false){let val=(!scope&&n.operator==='='?staticValue(n.right,n.left.type==='MemberExpression'?'dictionary_'+(n.left.property.value??n.left.property.name):n.left.name):null)||ex(n.right);if(n.operator!=='=')val=bin(n.operator.slice(0,-1),ex(n.left),val);if(n.left.type==='Identifier'){const target=ident(n.left.name);if(stmt)return target+' = '+val;const lp=localPath(n.left.name);if(lp&&!lp.startsWith('v_'))return 'J.setv('+lp.slice(0,lp.lastIndexOf('['))+', '+(lp.endsWith('[0]')?'0':q(n.left.name))+', '+val+')';return 'J.setv(self, '+q('j_'+n.left.name)+', '+val+')';}if(n.left.type==='MemberExpression')return 'J.setv('+ex(n.left.object)+', '+prop(n.left)+', '+val+')';throw Error('assign '+n.left.type);}
function update(n,stmt=false){const fake={type:'AssignmentExpression',operator:n.operator==='++'?'+=':'-=',left:n.argument,right:{type:'Literal',value:1}};if(stmt)return assign(fake,true);const v=assign(fake);return n.prefix?v:'('+v+(n.operator==='++'?' - 1.0':' + 1.0')+')';}
function closure(n){const name='_closure_'+(++serial),old=scope,oldLoops=loop;scope=infos.get(n);const captured='{'+[...scope.free].map(([key,ref])=>q(key)+': '+cellPath(ref.owner,ref.name,old)).join(', ')+'}';loop=[];let code='func '+name+'(_args: Array, _captures: Dictionary = {}) -> Variant:\n';code+=declarations(scope.names,n.params,true);code+=functionBody(n);code+='\treturn null\n';extras.push(code);scope=old;loop=oldLoops;return name+'.bind('+captured+')';}
function ex(n){if(!n)return 'null';switch(n.type){case'Literal':if(n.regex)return 'J.regex('+q(n.regex.pattern)+', '+q(n.regex.flags)+')';return typeof n.value==='number'?num(n.value):n.value===null?'null':typeof n.value==='boolean'?String(n.value):q(n.value);
case'Identifier':return ident(n.name);
case'ArrayExpression':return '['+n.elements.map(ex).join(', ')+']';
case'ObjectExpression':return '{'+[...new Map(n.properties.map(p=>[String(p.key.name??p.key.value),p])).values()].map(p=>q(String(p.key.name??p.key.value))+': '+ex(p.value)).join(', ')+'}';
case'MemberExpression':if(n.object.type==='Identifier'&&n.object.name==='Math'&&n.property.name==='random')return 'J.ref(random_unit, 0)';if(fastFunction)return ex(n.object)+'['+prop(n)+']';return 'J.getv('+ex(n.object)+', '+prop(n)+')';
case'BinaryExpression':return bin(n.operator,ex(n.left),ex(n.right));
case'LogicalExpression':return n.operator==='||'?'('+ex(n.left)+' if '+truth(n.left)+' else '+ex(n.right)+')':'('+ex(n.right)+' if '+truth(n.left)+' else '+ex(n.left)+')';
case'ConditionalExpression':return '('+ex(n.consequent)+' if '+truth(n.test)+' else '+ex(n.alternate)+')';
case'UnaryExpression':if(n.operator==='!')return '(not '+truth(n.argument)+')';if(n.operator==='typeof')return 'J.kind('+ex(n.argument)+')';if(n.operator==='-')return '(-J.n('+ex(n.argument)+'))';if(n.operator==='delete')return 'J.delv('+ex(n.argument.object)+', '+prop(n.argument)+')';throw Error('unary '+n.operator);
case'AssignmentExpression':return assign(n);
case'UpdateExpression':return update(n);
case'FunctionExpression':return closure(n);
case'NewExpression':if(n.callee.name==='Image')return 'Canvas.new()';if(['Array','Float32Array'].includes(n.callee.name))return 'J.array('+n.arguments.map(ex).join(', ')+')';throw Error('new '+n.callee.name+' '+currentFile+':'+n.loc.start.line);
case'CallExpression':{const c=n.callee,args=n.arguments.map(ex);if(c.type==='Identifier'&&!localPath(c.name)){
if(functions.has(c.name))return 'f_'+c.name+'('+args.slice(0,functions.get(c.name)).join(', ')+')';
if(c.name==='String')return 'J.s('+args[0]+')';if(c.name==='Number')return 'J.n('+args[0]+')';if(c.name==='requestAnimationFrame')return 'null';if(c.name==='setTimeout'||c.name==='setInterval')return 'native_timer('+args.join(', ')+(c.name==='setInterval'?', true':'')+')';
if(c.name==='clearTimeout'||c.name==='clearInterval')return 'native_cancel_timer('+args.join(', ')+')';
if(c.name==='isFinite')return 'is_finite(J.n('+args[0]+'))';if(c.name==='parseFloat')return 'J.n('+args[0]+')';if(c.name==='parseInt')return 'J.parse_int('+args.join(', ')+')';
}
if(c.type==='MemberExpression'&&!c.computed){let k=c.property.name;if(c.object.type==='Identifier'){
const o=c.object.name;if(o==='Math'){if(k==='random')return 'random_unit()';if(k==='round')return 'floor('+args[0]+' + 0.5)';if(k==='max'||k==='min')return args.reduce((a,b)=>k+'('+a+', '+b+')');return k+'('+args.join(', ')+')';}
if(o==='JSON')return k==='parse'?'JSON.parse_string(J.s('+args[0]+'))':'JSON.stringify('+args[0]+')';if(o==='Object'&&k==='keys')return 'J.keys('+args[0]+')';if(o==='document'&&k==='createElement')return 'Canvas.new()';if(o==='document'&&k==='getElementById')return args[0]==='"cv"'?'screen_canvas':'null';if(o==='performance'&&k==='now')return 'clock_ms';
}
if(k==='addEventListener')return 'null';if(fastFunction&&c.object.type==='Identifier'&&c.object.name==='ctx')return 'draw_context.'+k+'('+args.join(', ')+')';return 'J.method('+ex(c.object)+', '+q(k)+', ['+args.join(', ')+'])';}
return 'J.invoke('+ex(c)+', ['+args.join(', ')+'])';}
default:throw Error('ex '+n.type+' '+currentFile+':'+n.loc.start.line);}}
function block(n,d){const b=n.type==='BlockStatement'?n.body:[n];const out=stmts(b,d);return out||'\t'.repeat(d)+'pass\n';}

function literalValue(n){
 if(n.type==='Literal'&&!n.regex)return n.value;
 if(n.type==='UnaryExpression'&&n.operator==='-'&&n.argument.type==='Literal')return -n.argument.value;
 if(n.type==='ArrayExpression')return n.elements.map(literalValue);
 if(n.type==='ObjectExpression')return Object.fromEntries(n.properties.map(p=>[String(p.key.name??p.key.value),literalValue(p.value)]));
 throw Error('not literal');
}
function staticValue(n,name){
 try {const value=literalValue(n);if(!value||typeof value!=='object')return null;let content=JSON.stringify(value,null,'\t');if(content.length<1800)return null;const path='data/'+name.toLowerCase()+'.gd';fs.mkdirSync('data',{recursive:true});fs.writeFileSync(path,'# Editable game data, preserved from '+currentFile+'.\nextends RefCounted\n\nconst VALUE = '+content+'\n');dataFiles.push(path);return 'preload("res://'+path+'").VALUE.duplicate(true)';}catch(e){return null;}
}

function stmts(arr,d){return arr.map(n=>st(n,d)).join('');}
function st(n,d){const t='\t'.repeat(d);switch(n.type){case'ExpressionStatement':if(n.expression.type==='Literal'||n.expression.type==='CallExpression'&&n.expression.callee.type==='MemberExpression'&&n.expression.callee.property.name==='addEventListener')return '';{const e=n.expression.type==='AssignmentExpression'?assign(n.expression,true):n.expression.type==='UpdateExpression'?update(n.expression,true):ex(n.expression);return e==='null'?'':t+e+'\n';}
case'VariableDeclaration':return n.declarations.filter(x=>x.init).map(x=>t+ident(x.id.name)+' = '+(!scope?staticValue(x.init,x.id.name)||ex(x.init):ex(x.init))+'\n').join('');
case'FunctionDeclaration':return t+ident(n.id.name)+' = '+closure(n)+'\n';
case'BlockStatement':return stmts(n.body,d);
case'ReturnStatement':return t+'return '+ex(n.argument)+'\n';
case'IfStatement':return t+'if '+truth(n.test)+':\n'+block(n.consequent,d+1)+(n.alternate?t+'else:\n'+block(n.alternate,d+1):'');
case'ForStatement':{let init=n.init?(n.init.type==='VariableDeclaration'?st(n.init,d):t+(n.init.type==='AssignmentExpression'?assign(n.init,true):ex(n.init))+'\n'):'';let upd=n.update?(n.update.type==='UpdateExpression'?update(n.update,true):n.update.type==='AssignmentExpression'?assign(n.update,true):ex(n.update)):null;loop.push({update:upd});let b=block(n.body,d+1);loop.pop();return init+t+'while '+(n.test?truth(n.test):'true')+':\n'+b+(upd?'\t'.repeat(d+1)+upd+'\n':'');}
case'ForInStatement':{let name=n.left.declarations[0].id.name;loop.push({});let b=block(n.body,d+1);loop.pop();return t+'for _key_'+(++serial)+' in J.keys('+ex(n.right)+'):\n'+t+'\t'+ident(name)+' = _key_'+serial+'\n'+b;}
case'WhileStatement':loop.push({});let b=block(n.body,d+1);loop.pop();return t+'while '+truth(n.test)+':\n'+b;
case'ContinueStatement':{let l=[...loop].reverse().find(x=>!x.switch);return (l?.update?t+l.update+'\n':'')+t+'continue\n';}
case'BreakStatement':return loop.at(-1)?.switch?'':t+'break\n';
case'TryStatement':return st(n.block,d); // Native IO adapters report errors explicitly.
case'SwitchStatement':{let out=t+'match '+ex(n.discriminant)+':\n',labels=[];loop.push({switch:true});for(const c of n.cases){labels.push(c.test?ex(c.test):'_');if(c.consequent.length){out+=t+'\t'+labels.join(', ')+':\n'+(stmts(c.consequent,d+2)||t+'\t\tpass\n');labels=[];}}loop.pop();return out;}
default:throw Error('st '+n.type);}}
let head='# Native GDScript port of My Father\'s Kebab Shop.\n# Source module and function names are preserved for editing.\nextends "res://scripts/native_platform.gd"\n\n';
for(const g of globals)head+=g==='ctx'?'var j_ctx: Variant:\n\tget: return draw_context\n\tset(v): draw_context = v\n':'var j_'+g+': Variant = null\n';head+='\n';let init='func initialize_game() -> void:\n\tj_window = {"__DEV_BUILD": false, "__ERRS": []}\n\tj_navigator = {"maxTouchPoints": 0}\n\tj_localStorage = storage\n';let bodies=[];
for(const m of mods){currentFile=m.file;init+='\t# '+m.file+'\n';for(const n of m.ast.body){if(n.type==='FunctionDeclaration'){
if(native.has(n.id.name))continue;fastFunction=n.id.name==='drawSpit';
let names=locals(n.body);n.params.forEach(x=>names.add(x.name));scope=infos.get(n);loop=[];
let code='# '+m.file+':'+n.loc.start.line+'\nfunc f_'+n.id.name+'('+n.params.map(x=>'p_'+x.name+': Variant = null').join(', ')+') -> Variant:\n';code+=declarations(names,n.params,false);code+=functionBody(n);code+='\treturn null\n';bodies.push(code);scope=null;fastFunction=false;
}else init+=st(n,1);}}
// Special built-ins and constants read through member expressions.
const replaceMath=s=>s.replace(/J\.getv\(j_Math, "PI"\)/g,'PI');
let out=head+init+'\n'+bodies.join('\n')+'\n'+extras.join('\n');out=replaceMath(out);
fs.writeFileSync('scripts/game.gd',out);fs.writeFileSync('tools/conversion_report.json',JSON.stringify({modules:order,functions:functions.size,closures:extras.length,nativeAdapters:[...native],dataFiles,lines:out.split('\n').length},null,2));console.log('Generated',out.length,'bytes',out.split('\n').length,'lines',extras.length,'closures');
