import {chromium} from 'playwright';
import fs from 'node:fs';
const [url='http://127.0.0.1:4182/', label='baseline']=process.argv.slice(2);
fs.mkdirSync('output/playwright',{recursive:true});
const browser=await chromium.launch({headless:true,executablePath:process.env.CHROME_PATH||'C:/Users/limou/AppData/Local/ms-playwright/chromium-1248/chrome-win64/chrome.exe',args:['--enable-unsafe-webgpu','--ignore-gpu-blocklist']});
try {
 const page=await browser.newPage({viewport:{width:1440,height:810},deviceScaleFactor:1});
 const errors=[],failedRequests=[];
 page.on('pageerror',e=>errors.push(e.message));
 page.on('response',r=>{if(r.status()>=400)failedRequests.push({url:r.url(),status:r.status()});});
 await page.goto(url);
 await page.waitForFunction(()=>window.__lake?.completed>12||window.__lake?.errors?.length,undefined,{timeout:300000});
 const initial=await page.evaluate(()=>({backend:window.__lake.backend,errors:window.__lake.errors,firstCompleteMs:window.__lake.firstCompleteMs}));
 if(initial.errors.length)throw Error(initial.errors.join('\n'));
 await page.evaluate(()=>{window.__lake.freezeTime=0;document.querySelector('#menu').style.display='none';document.querySelector('#fullscreen').style.display='none';});
 for(const [name,pose] of [['reference',[0,12,52.5,0,1.3,-70]],['cabin',[50,11,5,40.5,7,-10.5]],['bridge',[-16,5,24,-9,1.6,18]]]) {
  await page.evaluate(p=>window.__lake.pose(...p),pose);
  const n=await page.evaluate(()=>window.__lake.completed);
  await page.waitForFunction(n=>window.__lake.completed>n+20,n,{timeout:60000});
  await page.evaluate(()=>window.__lake.renderer.backend.device.queue.onSubmittedWorkDone());
  await page.screenshot({path:`output/playwright/${label}-${name}.png`});
 }
 const result=await page.evaluate(()=>({errors:window.__lake.errors,source:window.__lake.source,resources:window.__lake.renderer.info.memory,framebuffer:window.__lake.framebuffer,retainedTriangles:window.__lake.retainedSceneTriangles,completed:window.__lake.completed}));
 fs.writeFileSync(`output/playwright/${label}.json`,JSON.stringify({url,...initial,...result,errors:[...errors,...result.errors],failedRequests},null,2));
 console.log(JSON.stringify({label,...initial,...result,errors:[...errors,...result.errors],failedRequests}));
 if(errors.length||result.errors.length||failedRequests.length)throw Error('Browser validation failed');
} finally {await browser.close();}
