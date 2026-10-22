import {chromium} from 'playwright';
import fs from 'node:fs';
const pass=process.env.REVIEW_PASS??'1';
const browser=await chromium.launch({headless:true,executablePath:'C:/Users/limou/AppData/Local/ms-playwright/chromium-1248/chrome-win64/chrome.exe',args:['--enable-unsafe-webgpu','--ignore-gpu-blocklist']});
const page=await browser.newPage({viewport:{width:1440,height:810},deviceScaleFactor:1});const errors=[];page.on('pageerror',e=>errors.push(e.message));
const poses=[['reference',[0,12,52.5,0,1.3,-70]],['aerial',[85,115,105,-5,2,-22.5]],['west',[-75,18,5,-255,35,90]],['east',[80,18,35,245,45,145]],['reverse',[0,12,55,0,32,205]],['cabin',[50,11,5,40.5,7,-10.5]],['bridge',[-7,6,28,-9,1.6,18]],['forest',[61,16,-22,53,14,-37]],['shore',[-35,5,12,-20,6,-45]]];
try{
 await page.goto('http://127.0.0.1:4182/');await page.waitForFunction(()=>window.__lake?.completed>8||window.__lake?.errors?.length,undefined,{timeout:240000});
 await page.evaluate(()=>{const a=window.__lake;if(a.errors.length)throw Error(a.errors.join());a.freezeTime=0;document.querySelector('#menu').style.display='none';document.querySelector('#fullscreen').style.visibility='hidden';});
 const views=[];
 for(const [name,pose]of poses){
  const start=await page.evaluate(p=>{window.__lake.pose(...p);return window.__lake.completed;},pose);await page.waitForFunction(n=>window.__lake.completed>n+8,start,{timeout:60000});
  await page.screenshot({path:`../renders/pass${pass}_${name}.png`});views.push(await page.evaluate(name=>({name,completed:window.__lake.completed,errors:window.__lake.errors}),name));
 }
 const stats=await page.evaluate(()=>{const a=window.__lake;return {backend:a.backend,firstCompleteMs:a.firstCompleteMs,shaderPrepareMs:a.shaderPrepareMs,retainedSceneTriangles:a.retainedSceneTriangles,source:a.source,framebuffer:a.framebuffer,treeImpostors:a.treeImpostors,errors:a.errors};});
 fs.writeFileSync(`../comparisons/pass${pass}_review.json`,JSON.stringify({pass,views,stats,errors},null,2));console.log(JSON.stringify({pass,stats,errors}));
}finally{await browser.close();}
