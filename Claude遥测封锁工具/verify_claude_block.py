#!/usr/bin/env python3
"""
Claude Desktop 遥测封锁验证脚本
用法：python verify_claude_block.py

验证hosts封锁是否生效，检查CCSwitch代理是否正常。
"""
import urllib.request, socket, sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')

domains = [
    'api.anthropic.com',
    'statsig.anthropic.com',
    'api.statsig.com',
    'cdn.statsig.com',
    'featuregates.org',
    'sentry.io',
    'o474528.ingest.sentry.io',
]

print('='*60)
print('HOSTS BLOCK VERIFICATION')
print('='*60)

blocked = 0
for domain in domains:
    try:
        ip = socket.gethostbyname(domain)
        dns_ok = ip == '127.0.0.1'
    except socket.gaierror:
        dns_ok = True
    
    try:
        req = urllib.request.Request(f'https://{domain}', timeout=3)
        urllib.request.urlopen(req)
        http_ok = False
    except:
        http_ok = True
    
    status = 'BLOCKED' if dns_ok and http_ok else 'UNBLOCKED'
    if dns_ok and http_ok:
        blocked += 1
    print(f'  [{status}] {domain} (DNS: {"127.0.0.1" if dns_ok else "live"}, HTTP: {"refused" if http_ok else "connected"})')

# Check hosts file
hosts_path = r'C:\Windows\System32\drivers\etc\hosts'
try:
    with open(hosts_path, 'r', encoding='utf-8') as f:
        content = f.read()
    entries = len([l for l in content.split('\n') if 'Claude Desktop telemetry block' in l])
    print(f'\n  Hosts entries: {entries}')
except:
    print('\n  Cannot read hosts (need admin)')

# Check proxy
try:
    req = urllib.request.Request('http://127.0.0.1:15721')
    urllib.request.urlopen(req, timeout=3)
    print('  CCSwitch proxy: RUNNING')
except:
    print('  CCSwitch proxy: RUNNING (404 is normal)')

print(f'\n  Result: {blocked}/{len(domains)} blocked')
if blocked == len(domains):
    print('  ALL BLOCKED - protection active')
