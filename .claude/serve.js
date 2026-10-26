const http=require('http'),fs=require('fs'),path=require('path');
const root='C:/Flutter pro_2/Rizma_1/build/web';
const types={'.html':'text/html','.js':'application/javascript','.wasm':'application/wasm','.json':'application/json','.png':'image/png','.svg':'image/svg+xml','.otf':'font/otf','.ttf':'font/ttf'};
http.createServer((q,r)=>{let p=decodeURIComponent(q.url.split('?')[0]);if(p==='/')p='/index.html';const f=path.join(root,p);
 fs.readFile(f,(e,d)=>{if(e){fs.readFile(path.join(root,'index.html'),(e2,d2)=>{r.writeHead(200,{'Content-Type':'text/html'});r.end(d2)});return;}
 r.writeHead(200,{'Content-Type':types[path.extname(f)]||'application/octet-stream','Cross-Origin-Opener-Policy':'same-origin','Cross-Origin-Embedder-Policy':'require-corp'});r.end(d);});
}).listen(8093);
