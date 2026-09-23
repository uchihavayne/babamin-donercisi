const fs=require('fs');const {chromium}=require('playwright');
(async()=>{
 const browser=await chromium.launch({executablePath:'/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',headless:true});
 const page=await browser.newPage({viewport:{width:1440,height:810}});
 await page.addInitScript(()=>{window.requestAnimationFrame=()=>0;performance.now=()=>0;let state=123456;Math.random=()=>{state=(Math.imul(state,1664525)+1013904223)>>>0;return state/4294967296;};});
 page.on('pageerror',e=>console.log('PAGE ERROR',e));
 await page.goto('file:///Users/arzuozsoy/Downloads/myfathersdonershop.html');
 await page.waitForFunction(()=>typeof LOGO!=='undefined'&&LOGO.tamam===14);
 await page.evaluate(()=>{window.__now=0;window.__step=(n)=>{for(let i=0;i<n;i++){__now+=1000/60;frame(__now);}};__step(3);});
 async function save(name){const data=await page.evaluate(()=>cv.toDataURL().split(',')[1]);fs.writeFileSync('artifacts/html-'+name+'.png',Buffer.from(data,'base64'));}
 await save('title');
 await page.evaluate(()=>{setLang('tr');proStart();__step(3)});await save('story');
 await page.evaluate(()=>{startDay();__step(10)});await save('play');
 console.log(await page.evaluate(()=>({scene:G.scene,errors:window.__ERRS||[],font:Object.keys(FONT).length})));
 await browser.close();
})();
