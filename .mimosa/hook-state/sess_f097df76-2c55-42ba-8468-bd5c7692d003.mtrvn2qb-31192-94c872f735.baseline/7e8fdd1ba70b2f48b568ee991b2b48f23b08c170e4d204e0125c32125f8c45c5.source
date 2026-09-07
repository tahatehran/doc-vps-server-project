#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
FRP Live Dashboard — real-time web monitor for frps (stdlib only).
  GET /        -> RTL Persian live dashboard (self-contained HTML)
  GET /stream  -> Server-Sent Events, JSON snapshot every 2 seconds
Data sources: frps admin API (127.0.0.1:7500), /proc, fail2ban.
Secrets stay on the server; the page is read-only.

Deploy (as root on the FRP server):
  install -m 700 frp-live-dashboard.py /opt/frp-dashboard/dashboard.py
  # systemd unit:
  #   [Service] ExecStart=/usr/bin/python3 /opt/frp-dashboard/dashboard.py
  #   Restart=always   (port 8090, UFW: allow 8090/tcp)
"""
import base64
import json
import os
import re
import subprocess
import threading
import time
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

FRPS_INI = '/etc/frp/frps.ini'
FRPS_API = 'http://127.0.0.1:7500'
TICK = 2          # seconds between snapshots
MAX_HISTORY = 90  # samples kept for the sparkline

_state_lock = threading.Lock()
_state = {'ok': False, 'error': None, 'ts': 0}


def read_ini(path):
    cfg = {}
    section = None
    with open(path, encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#') or line.startswith(';'):
                continue
            m = re.match(r'^\[(.+)\]$', line)
            if m:
                section = m.group(1).lower()
                continue
            if '=' in line:
                k, v = line.split('=', 1)
                key = k.strip().lower()
                if section == 'common':
                    cfg[key] = v.strip().strip('"').strip("'")
    return cfg


CFG = read_ini(FRPS_INI)
AUTH = base64.b64encode(
    ('%s:%s' % (CFG.get('dashboard_user', 'admin'),
                CFG.get('dashboard_pwd', ''))).encode()).decode()


def frps_get(path):
    req = urllib.request.Request(FRPS_API + path,
                                 headers={'Authorization': 'Basic ' + AUTH})
    with urllib.request.urlopen(req, timeout=4) as r:
        return json.loads(r.read().decode())


def cpu_percent():
    def read_times():
        with open('/proc/stat') as f:
            for line in f:
                if line.startswith('cpu '):
                    parts = [int(x) for x in line.split()[1:]]
                    idle = parts[3] + (parts[4] if len(parts) > 4 else 0)
                    return sum(parts), idle
        return 0, 0
    t1, i1 = read_times()
    time.sleep(0.4)
    t2, i2 = read_times()
    dt, di = t2 - t1, i2 - i1
    return round(100.0 * (dt - di) / dt, 1) if dt > 0 else 0.0


def mem_disk():
    mem = {}
    with open('/proc/meminfo') as f:
        for line in f:
            k, v = line.split(':', 1)
            mem[k] = int(v.strip().split()[0])  # kB
    total = mem['MemTotal']; avail = mem['MemAvailable']
    st = os.statvfs('/')
    disk_pct = round(100.0 * (st.f_blocks - st.f_bfree) /
                     (st.f_blocks - st.f_bavail + st.f_bfree), 1) if st.f_blocks else 0
    disk_gb = round((st.f_blocks - st.f_bavail) * st.f_frsize / 2**30, 1)
    disk_total = round(st.f_blocks * st.f_frsize / 2**30, 1)
    return {
        'ramUsedGB': round((total - avail) / 2**20, 2),
        'ramTotalGB': round(total / 2**20, 2),
        'ramPct': round(100.0 * (total - avail) / total, 1),
        'diskUsedGB': disk_gb, 'diskTotalGB': disk_total, 'diskPct': disk_pct,
    }


def net_rates(prev):
    rx = tx = 0
    with open('/proc/net/dev') as f:
        for line in f:
            if '|' in line:
                continue
            parts = line.split(':')
            if len(parts) != 2:
                continue
            iface = parts[0].strip()
            if iface == 'lo':
                continue
            fields = parts[1].split()
            rx += int(fields[0]); tx += int(fields[8])
    if prev and TICK > 0:
        return round(max(0, rx - prev[0]) / TICK, 0), round(max(0, tx - prev[1]) / TICK, 0), (rx, tx)
    return 0, 0, (rx, tx)


def fail2ban_banned():
    try:
        out = subprocess.run(['fail2ban-client', 'status', 'sshd'],
                             capture_output=True, text=True, timeout=5).stdout
        m = re.search(r'Currently banned:\s*(\d+)', out)
        t = re.search(r'Total banned:\s*(\d+)', out)
        return {'current': int(m.group(1)) if m else 0,
                'total': int(t.group(1)) if t else 0}
    except Exception:
        return {'current': -1, 'total': -1}


def listening_ports():
    ports = set()
    for fn in ('/proc/net/tcp', '/proc/net/tcp6'):
        try:
            with open(fn) as f:
                for line in f.readlines()[1:]:
                    p = line.split()
                    if len(p) > 3 and p[3] == '0A':
                        ports.add(int(p[1].split(':')[1], 16))
        except OSError:
            pass
    return sorted(ports)


def frp_snapshot(prev):
    snap = {'frp': None, 'clients': [], 'proxies': [], 'error': None}
    try:
        info = frps_get('/api/v2/system/info').get('data', {})
        st = info.get('status', {})
        cfg = info.get('config', {})
        clients = frps_get('/api/v2/clients').get('data', {}).get('items', [])
        proxies = frps_get('/api/v2/proxies').get('data', {}).get('items', [])
        frp = {
            'version': info.get('version'),
            'bindPort': cfg.get('bindPort'),
            'allowPorts': cfg.get('allowPortsStr'),
            'totalTrafficIn': st.get('totalTrafficIn', 0),
            'totalTrafficOut': st.get('totalTrafficOut', 0),
            'curConns': st.get('curConns', 0),
            'clientCounts': st.get('clientCounts', 0),
            'proxyTypeCount': st.get('proxyTypeCount', {}),
        }
        plist = []
        for p in proxies:
            spec = p.get('spec', {})
            status = p.get('status', {})
            plist.append({
                'name': p.get('name'),
                'type': spec.get('type'),
                'phase': status.get('phase'),
                'todayIn': status.get('todayTrafficIn', 0),
                'todayOut': status.get('todayTrafficOut', 0),
                'curConns': status.get('curConns', 0),
                'lastCloseAt': status.get('lastCloseAt'),
            })
        clist = [{'id': c.get('id'), 'user': c.get('user'),
                  'version': c.get('version'), 'os': c.get('os'),
                  'arch': c.get('arch')} for c in clients]
        snap.update({'frp': frp, 'clients': clist, 'proxies': plist})
        return snap, (frp['totalTrafficIn'], frp['totalTrafficOut'])
    except Exception as e:
        snap['error'] = str(e)[:200]
        return snap, prev


def collector():
    global _state
    prev_net = None
    prev_frp = None
    history = []
    while True:
        s = {}
        s['ts'] = int(time.time())
        s['uptimeSec'] = int(time.time() - os.stat('/proc/1').st_mtime)
        try:
            with open('/proc/loadavg') as f:
                s['load'] = f.read().split()[:3]
        except OSError:
            s['load'] = []
        s['cpuPct'] = cpu_percent()
        s.update(mem_disk())
        r, t, prev_net = net_rates(prev_net)
        s['rxRate'], s['txRate'] = r, t
        s['fail2ban'] = fail2ban_banned()
        s['ports'] = listening_ports()
        # prev_frp holds the totals from the previous tick
        snap, cur_totals = frp_snapshot(prev_frp)
        s['frp'] = snap['frp']; s['clients'] = snap['clients']
        s['proxies'] = snap['proxies']; s['frpError'] = snap['error']
        if prev_frp is not None and cur_totals != prev_frp:
            s['frpInRate'] = round(max(0, cur_totals[0] - prev_frp[0]) / TICK, 0)
            s['frpOutRate'] = round(max(0, cur_totals[1] - prev_frp[1]) / TICK, 0)
        else:
            s['frpInRate'] = s['frpOutRate'] = 0
        prev_frp = cur_totals
        history.append((s['ts'], s['frpInRate'], s['frpOutRate']))
        if len(history) > MAX_HISTORY:
            history.pop(0)
        s['history'] = history[-MAX_HISTORY:]
        with _state_lock:
            _state = {'ok': True, 'ts': s['ts']}
            globals()['_snapshot'] = s
        time.sleep(TICK)


_snapshot = {}
threading.Thread(target=collector, daemon=True).start()
time.sleep(1.5)

PAGE = r'''<!DOCTYPE html>
<html lang="fa" dir="rtl"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>داشبورد لحظه‌ای FRP — nima-server</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:'Segoe UI',Tahoma,Vazirmatn,sans-serif;background:#0d1117;color:#e6edf3;min-height:100vh}
.wrap{max-width:1200px;margin:0 auto;padding:18px}
header{display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:10px;margin-bottom:18px}
h1{font-size:1.45em;background:linear-gradient(90deg,#58a6ff,#3fb950,#d29922);-webkit-background-clip:text;-webkit-text-fill-color:transparent}
.sub{color:#8b949e;font-size:.85em}
.dot{width:11px;height:11px;border-radius:50%;display:inline-block;margin-left:6px;animation:blink 1.2s infinite}
.dot.on{background:#3fb950;box-shadow:0 0 10px #3fb950}
.dot.off{background:#f85149;box-shadow:0 0 10px #f85149}
@keyframes blink{0%,100%{opacity:1}50%{opacity:.45}}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(270px,1fr));gap:14px}
.card{background:#161b22;border:1px solid #30363d;border-radius:12px;padding:16px}
.card h2{font-size:1em;color:#58a6ff;margin-bottom:12px;display:flex;align-items:center;gap:8px}
.kv{display:flex;justify-content:space-between;padding:5px 0;border-bottom:1px dashed #21262d;font-size:.9em}
.kv:last-child{border-bottom:none}
.kv b{font-family:monospace;direction:ltr}
.g{color:#3fb950}.r{color:#f85149}.y{color:#d29922}.m{color:#a371f7}
.bar{height:7px;background:#21262d;border-radius:4px;margin:6px 0 10px;overflow:hidden}
.bar i{display:block;height:100%;border-radius:4px;background:linear-gradient(90deg,#58a6ff,#3fb950);transition:width .8s}
table{width:100%;border-collapse:collapse;font-size:.85em}
th{color:#8b949e;text-align:right;padding:6px 4px;border-bottom:1px solid #30363d}
td{padding:7px 4px;border-bottom:1px dashed #21262d;font-family:monospace}
.badge{padding:2px 9px;border-radius:10px;font-size:.78em;font-family:inherit}
.b-on{background:#0f3517;color:#3fb950;border:1px solid #1f6f37}
.b-off{background:#3d1417;color:#f85149;border:1px solid #802a2e}
canvas{width:100%;height:110px;display:block}
.links{margin-top:14px;text-align:center;color:#8b949e;font-size:.85em}
.links a{color:#58a6ff;text-decoration:none;margin:0 8px}
.big{font-size:1.6em;font-family:monospace;direction:ltr;text-align:center;padding:4px 0}
.err{color:#f85149;font-size:.85em;padding:8px;text-align:center}
footer{text-align:center;color:#484f58;font-size:.78em;margin-top:16px}
</style></head><body><div class="wrap">
<header>
  <div><h1>🌐 داشبورد لحظه‌ای FRP</h1><div class="sub">nima-server · 2.144.21.218 · <span id="clock"></span></div></div>
  <div><span class="dot off" id="live"></span><span class="sub" id="liveTxt">در حال اتصال…</span></div>
</header>
<div class="grid">
  <div class="card"><h2>🖥 وضعیت FRP Server</h2><div id="frp">…</div></div>
  <div class="card"><h2>📈 ترافیک زنده</h2>
    <div class="big"><span class="g" id="rin">0</span> <span style="color:#8b949e">|</span> <span class="y" id="rout">0</span></div>
    <div class="sub" style="text-align:center">↑ ورودی · ↓ خروجی (بر ثانیه)</div>
    <canvas id="chart" width="600" height="110"></canvas>
    <div class="kv"><span>امروز ورودی</span><b class="g" id="tin">—</b></div>
    <div class="kv"><span>امروز خروجی</span><b class="y" id="tout">—</b></div>
    <div class="kv"><span>مجموع کل</span><b id="ttot">—</b></div>
  </div>
  <div class="card"><h2>💻 سیستم</h2><div id="sys">…</div></div>
  <div class="card"><h2>🔐 امنیت</h2><div id="sec">…</div></div>
  <div class="card"><h2>👥 کلاینت‌های متصل</h2><div id="cli">…</div></div>
</div>
<div class="card" style="margin-top:14px"><h2>🔀 پروکسی‌ها (<span id="pcount">0</span>)</h2>
<table><thead><tr><th>نام</th><th>نوع</th><th>وضعیت</th><th>اتصال‌ها</th><th>امروز ورودی</th><th>امروز خروجی</th><th>آخرین فعالیت</th></tr></thead>
<tbody id="prox"></tbody></table></div>
<div class="links">
  <a href="http://2.144.21.218:7500" target="_blank">داشبورد ادمین frps (7500)</a> ·
  <a href="http://2.144.21.218:8090" onclick="return false">این صفحه (8090)</a>
</div>
<footer>به‌روزرسانی هر ۲ ثانیه از طریق Server-Sent Events · بدون کش · داده‌ی فقط‌خواندنی</footer>
</div>
<script>
function fmt(n){if(n==null)return'—';if(n<1024)return n+' B';if(n<1048576)return (n/1024).toFixed(1)+' KB';if(n<1073741824)return (n/1048576).toFixed(1)+' MB';return (n/1073741824).toFixed(2)+' GB'}
function rel(ts){if(!ts)return'—';const d=Math.floor(Date.now()/1000)-ts;if(d<60)return'همین حالا';if(d<3600)return Math.floor(d/60)+' دقیقه پیش';if(d<86400)return Math.floor(d/3600)+' ساعت پیش';return Math.floor(d/86400)+' روز پیش'}
function esc(s){return (s==null?'':String(s)).replace(/[<>&]/g,c=>({'<':'&lt;','>':'&gt;','&':'&amp;'}[c]))}
const hist=[];
function draw(){const c=document.getElementById('chart'),x=c.getContext('2d');
x.clearRect(0,0,c.width,c.height);if(hist.length<2)return;
const mx=Math.max(...hist.map(h=>Math.max(h[1],h[2])),1);
function line(idx,col){x.beginPath();x.strokeStyle=col;x.lineWidth=2;
hist.forEach((h,i)=>{const px=c.width-(hist.length-1-i)*(c.width/(hist.length-1));
const py=c.height-6-(h[idx]/mx)*(c.height-18);i?x.lineTo(px,py):x.moveTo(px,py)});x.stroke()}
line(1,'#3fb950');line(2,'#d29922')}
function render(s){
document.getElementById('clock').textContent=new Date(s.ts*1000).toLocaleTimeString('fa-IR');
const F=s.frp;
document.getElementById('frp').innerHTML = F ? 
 '<div class="kv"><span>نسخه frps</span><b class="g">'+esc(F.version)+'</b></div>'+
 '<div class="kv"><span>وضعیت</span><b class="g">● فعال</b></div>'+
 '<div class="kv"><span>پورت اصلی</span><b>'+esc(F.bindPort)+'</b></div>'+
 '<div class="kv"><span>پورت‌های مجاز تونل</span><b>'+esc(F.allowPorts)+'</b></div>'+
 '<div class="kv"><span>کلاینت متصل</span><b>'+esc(F.clientCounts)+'</b></div>'+
 '<div class="kv"><span>اتصال‌های فعال</span><b>'+esc(F.curConns)+'</b></div>'
 : '<div class="err">⛔ frps پاسخ نمی‌دهد'+(s.frpError?': '+esc(s.frpError):'')+'</div>';
document.getElementById('rin').textContent=fmt(s.frpInRate)+'/s';
document.getElementById('rout').textContent=fmt(s.frpOutRate)+'/s';
document.getElementById('tin').textContent=F?fmt(F.totalTrafficIn):'—';
document.getElementById('tout').textContent=F?fmt(F.totalTrafficOut):'—';
document.getElementById('ttot').textContent=F?fmt(F.totalTrafficIn+F.totalTrafficOut):'—';
if(F){hist.push([s.ts,s.frpInRate,s.frpOutRate]);if(hist.length>90)hist.shift();draw()}
const se=document.getElementById('sec');
const fb=s.fail2ban||{};
se.innerHTML='<div class="kv"><span>fail2ban — بن‌های فعال SSH</span><b class="'+(fb.current>0?'y':'g')+'">'+(fb.current<0?'نامشخص':fb.current)+'</b></div>'+
 '<div class="kv"><span>مجموع بن‌ها از نصب</span><b>'+(fb.total<0?'نامشخص':fb.total)+'</b></div>'+
 '<div class="kv"><span>پورت‌های شنیده‌شده</span><b>'+s.ports.length+'</b></div>'+
 '<div class="kv"><span>لیست پورت‌ها</span><b style="font-size:.8em">'+s.ports.join(', ')+'</b></div>';
const sy=document.getElementById('sys');
sy.innerHTML='<div class="kv"><span>CPU</span><b>'+s.cpuPct+'%</b></div><div class="bar"><i style="width:'+Math.min(100,s.cpuPct)+'%"></i></div>'+
 '<div class="kv"><span>RAM</span><b>'+s.ramUsedGB+' / '+s.ramTotalGB+' GB</b></div><div class="bar"><i style="width:'+Math.min(100,s.ramPct)+'%"></i></div>'+
 '<div class="kv"><span>دیسک</span><b>'+s.diskUsedGB+' / '+s.diskTotalGB+' GB</b></div><div class="bar"><i style="width:'+Math.min(100,s.diskPct)+'%"></i></div>'+
 '<div class="kv"><span>بار سیستم</span><b>'+esc((s.load||[]).join(' · '))+'</b></div>'+
 '<div class="kv"><span>Uptime</span><b>'+Math.floor(s.uptimeSec/86400)+' روز '+Math.floor(s.uptimeSec%86400/3600)+' ساعت</b></div>';
const cl=document.getElementById('cli');
cl.innerHTML = s.clients.length ? s.clients.map(c=>
 '<div class="kv"><span>'+esc(c.id||'?')+'</span><b>'+esc(c.version)+' · '+esc(c.os)+'/'+esc(c.arch)+'</b></div>').join('')
 : '<div class="sub" style="padding:8px 0">هیچ کلاینت متصلی نیست — frpc روی سرور/کلاینت‌ها را اجرا کنید</div>';
document.getElementById('pcount').textContent=s.proxies.length;
document.getElementById('prox').innerHTML=s.proxies.map(p=>
 '<tr><td>'+esc(p.name)+'</td><td><span class="badge b-off" style="color:#58a6ff;border-color:#1f4b6f;background:#0f2033">'+esc(p.type)+'</span></td>'+
 '<td><span class="badge '+(p.phase==='online'?'b-on':'b-off')+'">'+(p.phase==='online'?'● فعال':'○ خاموش')+'</span></td>'+
 '<td>'+esc(p.curConns)+'</td><td class="g">'+fmt(p.todayIn)+'</td><td class="y">'+fmt(p.todayOut)+'</td><td>'+rel(p.lastCloseAt)+'</td></tr>').join('');
}
function connect(){
const es=new EventSource('/stream');
es.onopen=()=>{document.getElementById('live').className='dot on';document.getElementById('liveTxt').textContent='زنده — استریم فعال'};
es.onmessage=e=>{try{render(JSON.parse(e.data))}catch(_){}};
es.onerror=()=>{es.close();document.getElementById('live').className='dot off';
document.getElementById('liveTxt').textContent='قطع شد — اتصال مجدد…';setTimeout(connect,3000)};
}
connect();
</script></body></html>'''


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *a):
        pass

    def _html(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        self.wfile.write(PAGE.encode())

    def _stream(self):
        self.send_response(200)
        self.send_header('Content-Type', 'text/event-stream')
        self.send_header('Cache-Control', 'no-store')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        try:
            while True:
                with _state_lock:
                    data = dict(_snapshot)
                payload = 'data: ' + json.dumps(data, ensure_ascii=False) + '\n\n'
                self.wfile.write(payload.encode())
                self.wfile.flush()
                time.sleep(TICK)
        except (BrokenPipeError, ConnectionResetError, OSError):
            return

    def do_GET(self):
        try:
            if self.path in ('/', '/index.html'):
                self._html()
            elif self.path == '/stream':
                self._stream()
            elif self.path == '/healthz':
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(b'ok')
            else:
                self.send_response(404)
                self.end_headers()
        except (BrokenPipeError, ConnectionResetError):
            pass


if __name__ == '__main__':
    srv = ThreadingHTTPServer(('0.0.0.0', 8090), Handler)
    print('FRP live dashboard on :8090 (SSE every %ds)' % TICK, flush=True)
    srv.serve_forever()
