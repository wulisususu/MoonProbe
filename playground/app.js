import { prepare_request_json, evaluate_response_report_json } from "./moonprobe_bridge.js";

const DEMO_REQUESTS = [
  {name:"创建 Todo",method:"POST",url:"{{base_url}}/todos",headers:[{name:"Content-Type",value:"application/json"}],query:[],auth:{type:"none"},body:{title:"MoonProbe demo",completed:false,userId:1},timeout_ms:5000,assertions:[{type:"status_is",expected:201},{type:"json_exists",path:"$.id"}]},
  {name:"获取 Todo 列表",method:"GET",url:"{{base_url}}/todos",headers:[],query:[{name:"_limit",value:"3"}],auth:{type:"none"},timeout_ms:5000,assertions:[{type:"status_is",expected:200},{type:"response_time_less_than",ms:3000}]},
  {name:"获取单个 Todo",method:"GET",url:"{{base_url}}/todos/1",headers:[],query:[],auth:{type:"none"},timeout_ms:5000,assertions:[{type:"status_is",expected:200},{type:"json_equals",path:"$.id",expected:1}]},
  {name:"更新 Todo",method:"PATCH",url:"{{base_url}}/todos/1",headers:[{name:"Content-Type",value:"application/json"}],query:[],auth:{type:"none"},body:{completed:true},timeout_ms:5000,assertions:[{type:"status_is",expected:200},{type:"json_equals",path:"$.completed",expected:true}]},
  {name:"删除 Todo",method:"DELETE",url:"{{base_url}}/todos/1",headers:[],query:[],auth:{type:"none"},timeout_ms:5000,assertions:[{type:"status_is",expected:200}]}
];

const state={selected:0,results:new Map(),running:false};
const el=id=>document.getElementById(id);
const pretty=value=>JSON.stringify(value,null,2);
const envJson=()=>JSON.stringify({base_url:el("baseUrl").value.trim()});

function parseEditor(id,fallback){const text=el(id).value.trim();return text?JSON.parse(text):fallback}
function escapeHtml(value){return String(value).replace(/[&<>"']/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"}[c]))}

function renderRequestList(){
  el("requestList").innerHTML=DEMO_REQUESTS.map((r,i)=>{
    const result=state.results.get(i);const cls=result?(result.passed?"pass":"fail"):"";
    return `<button class="request-item ${state.selected===i?"active":""}" data-index="${i}"><span class="method-tag">${r.method}</span><span>${r.name}</span><span class="result-dot ${cls}"></span></button>`;
  }).join("");
  document.querySelectorAll(".request-item").forEach(btn=>btn.addEventListener("click",()=>selectRequest(Number(btn.dataset.index))));
}

function selectRequest(index){
  state.selected=index;const r=DEMO_REQUESTS[index];
  el("method").value=r.method;el("url").value=r.url;
  el("headers").value=pretty(r.headers||[]);el("query").value=pretty(r.query||[]);
  el("auth").value=pretty(r.auth||{type:"none"});
  el("body").value=r.body===undefined?"":(typeof r.body==="string"?r.body:pretty(r.body));
  el("tests").value=pretty(r.assertions||[]);
  renderRequestList();const existing=state.results.get(index);existing?showResult(existing):resetResponse();
}

function currentRequest(){
  const rawBody=el("body").value.trim();let body;
  if(rawBody){try{body=JSON.parse(rawBody)}catch{body=rawBody}}
  const request={name:DEMO_REQUESTS[state.selected]?.name||"演示请求",method:el("method").value,url:el("url").value.trim(),headers:parseEditor("headers",[]),query:parseEditor("query",[]),auth:parseEditor("auth",{type:"none"}),timeout_ms:DEMO_REQUESTS[state.selected]?.timeout_ms||5000,assertions:parseEditor("tests",[])};
  if(rawBody)request.body=body;return request;
}

function makeFetchUrl(prepared){const url=new URL(prepared.url);for(const item of prepared.query||[])url.searchParams.append(item.name,item.value);return url.toString()}
function fetchOptions(prepared){
  const headers=new Headers();for(const item of prepared.headers||[])headers.set(item.name,item.value);
  if(prepared.auth?.type==="bearer")headers.set("Authorization",`Bearer ${prepared.auth.token}`);
  if(prepared.auth?.type==="basic")headers.set("Authorization",`Basic ${btoa(`${prepared.auth.username}:${prepared.auth.password}`)}`);
  const options={method:prepared.method,headers};
  if(prepared.body?.kind!=="empty"&&!["GET","HEAD"].includes(prepared.method)){options.body=prepared.body.value;if(prepared.body.kind==="json"&&!headers.has("Content-Type"))headers.set("Content-Type","application/json")}
  return options;
}

async function executeRequest(request,index=state.selected){
  const requestText=JSON.stringify(request);
  const envelope=JSON.parse(prepare_request_json(requestText,envJson()));
  if(!envelope.ok)throw new Error(envelope.error);
  const prepared=envelope.request;const controller=new AbortController();
  const timer=setTimeout(()=>controller.abort(),prepared.timeout_ms);const started=performance.now();let response;
  try{response=await fetch(makeFetchUrl(prepared),{...fetchOptions(prepared),signal:controller.signal})}finally{clearTimeout(timer)}
  const duration=Math.round(performance.now()-started);const body=await response.text();const headers=[];
  response.headers.forEach((value,name)=>headers.push({name,value}));
  const browserResponse={status:response.status,headers,body,duration_ms:duration};
  const report=JSON.parse(evaluate_response_report_json(requestText,JSON.stringify(browserResponse)));
  if(report.ok===false)throw new Error(report.error);
  const rr=report.requests[0];const result={passed:rr.passed,status:rr.status,duration_ms:rr.duration_ms,body,assertions:rr.assertions||[],report};
  state.results.set(index,result);return result;
}

function resetResponse(){el("responseTitle").textContent="等待发送";el("metrics").innerHTML="";el("responseBody").textContent="点击“发送请求”执行当前 API 请求。";el("assertions").innerHTML="";el("assertionSummary").textContent="—"}
const ASSERTION_KIND_LABELS={
  status_is:"状态码等于",
  status_between:"状态码范围",
  header_exists:"响应头存在",
  header_contains:"响应头包含",
  body_contains:"响应体包含",
  json_exists:"JSON 字段存在",
  json_equals:"JSON 字段等于",
  response_time_less_than:"响应时间小于"
};
const ASSERTION_MESSAGE_LABELS={
  "status matched":"状态码符合预期",
  "status did not match":"状态码与预期不符",
  "status is inside the expected range":"状态码位于预期范围内",
  "status is outside the expected range":"状态码超出预期范围",
  "header exists":"响应头存在",
  "header is missing":"缺少指定响应头",
  "header contains expected text":"响应头包含预期内容",
  "header does not contain expected text":"响应头未包含预期内容",
  "body contains expected text":"响应体包含预期内容",
  "body does not contain expected text":"响应体未包含预期内容",
  "JSON path exists":"JSON 字段存在",
  "JSON path does not exist":"JSON 字段不存在",
  "JSON value matched":"JSON 值符合预期",
  "JSON value did not match":"JSON 值与预期不符",
  "response time is below the limit":"响应时间低于限制",
  "response time exceeded the limit":"响应时间超过限制",
  "response body is not valid JSON":"响应体不是有效 JSON"
};
function assertionKindLabel(kind){return ASSERTION_KIND_LABELS[kind]||kind}
function assertionMessageLabel(message){return ASSERTION_MESSAGE_LABELS[message]||message}

function showResult(result){
  el("responseTitle").textContent=result.passed?"请求验证通过":"请求验证失败";
  el("metrics").innerHTML=`<span class="metric ${result.passed?"pass":"fail"}">HTTP ${result.status}</span><span class="metric">${result.duration_ms} ms</span>`;
  let shown=result.body;try{shown=pretty(JSON.parse(result.body))}catch{}
  el("responseBody").textContent=shown||"<empty body>";const passed=result.assertions.filter(x=>x.passed).length;
  el("assertionSummary").textContent=`${passed} / ${result.assertions.length} 项通过`;
  el("assertions").innerHTML=result.assertions.length?result.assertions.map(a=>`<div class="assertion ${a.passed?"pass":"fail"}"><span class="icon">${a.passed?"✓":"×"}</span><div><strong>${assertionKindLabel(a.kind)}</strong><small>${assertionMessageLabel(a.message)} · 预期 ${escapeHtml(a.expected)} · 实际 ${escapeHtml(a.actual)}</small></div></div>`).join(""):'<div class="empty-state">No assertions configured.</div>';
}

async function sendCurrent(){
  const button=el("send");button.disabled=true;button.textContent="发送中…";
  try{const result=await executeRequest(currentRequest());showResult(result);renderRequestList()}
  catch(error){el("responseTitle").textContent="请求执行错误";el("metrics").innerHTML='<span class="metric fail">ERROR</span>';el("responseBody").textContent=error.name==="AbortError"?"请求超时。":String(error.message||error);el("assertions").innerHTML="";el("assertionSummary").textContent="未执行断言"}
  finally{button.disabled=false;button.textContent="发送请求"}
}

async function runCollection(){
  if(state.running)return;state.running=true;el("runCollection").disabled=true;el("runCollection").textContent="运行中…";
  const rows=[];let passed=0;
  for(let i=0;i<DEMO_REQUESTS.length;i++){
    let row;
    try{const result=await executeRequest(DEMO_REQUESTS[i],i);if(result.passed)passed++;row={ok:result.passed,name:DEMO_REQUESTS[i].name,status:result.status,duration:result.duration_ms,note:result.assertions.find(x=>!x.passed)?.message||"全部断言通过"}}
    catch(error){row={ok:false,name:DEMO_REQUESTS[i].name,status:"—",duration:"—",note:String(error.message||error)}}
    rows.push(row);renderRequestList();renderCollectionRows(rows,passed);if(!row.ok)break;
  }
  state.running=false;el("runCollection").disabled=false;el("runCollection").textContent="运行全部";
}

function renderCollectionRows(rows,passed){
  el("collectionRows").innerHTML=rows.map(row=>`<div class="collection-row"><span class="${row.ok?"ok":"bad"}">${row.ok?"✓":"×"}</span><strong>${row.name}</strong><span>HTTP ${row.status}</span><span class="muted">${row.duration} ms</span><span class="muted">${escapeHtml(row.note)}</span></div>`).join("");
  const failed=rows.length-passed;el("collectionSummary").textContent=failed?`${passed} 项通过 · ${failed} 项失败`:`${passed} / ${rows.length} 项通过`;
}

document.querySelectorAll(".tab").forEach(button=>button.addEventListener("click",()=>{
  document.querySelectorAll(".tab").forEach(x=>x.classList.toggle("active",x===button));
  document.querySelectorAll(".tab-panel").forEach(panel=>panel.classList.toggle("active",panel.dataset.panel===button.dataset.tab));
}));
el("send").addEventListener("click",sendCurrent);el("runCollection").addEventListener("click",runCollection);selectRequest(0);
