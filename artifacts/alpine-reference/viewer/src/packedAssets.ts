type PackedAsset = { parts: string[]; originalBytes: number; compressedBytes: number; sha256: string };
let manifest: Promise<Record<string, PackedAsset>> | undefined;

/** Reassemble a losslessly compressed asset without retaining a second compressed copy. */
export async function loadPackedAsset(path: string, progress?: (loaded: number, total: number) => void): Promise<ArrayBuffer> {
 manifest ??= fetch(import.meta.env.BASE_URL+'assets/packed/manifest.json').then(async r=>{
  if(!r.ok)throw Error(`Asset manifest failed (${r.status})`);
  return r.json();
 });
 const entry=(await manifest)[path];
 if(!entry)throw Error(`Packed asset is missing: ${path}`);
 let loaded=0;
 async function* chunks(){
  for(const part of entry.parts){
   const response=await fetch(import.meta.env.BASE_URL+'assets/packed/'+part);
   if(!response.ok||!response.body)throw Error(`Asset download failed (${response.status}): ${part}`);
   const reader=response.body.getReader();
   try{
    for(;;){const {done,value}=await reader.read();if(done)break;loaded+=value.byteLength;progress?.(loaded,entry.compressedBytes);yield value;}
   }finally{reader.releaseLock();}
  }
 }
 const iterator=chunks();
 const stream=new ReadableStream<BufferSource>({
  async pull(controller){try{const next=await iterator.next();if(next.done)controller.close();else controller.enqueue(next.value);}catch(error){controller.error(error);}},
  async cancel(){await iterator.return(undefined);}
 });
 const bytes=await new Response(stream.pipeThrough(new DecompressionStream('gzip'))).arrayBuffer();
 if(bytes.byteLength!==entry.originalBytes)throw Error(`Asset size mismatch: ${path}`);
 return bytes;
}
