#!/usr/bin/env python3
"""
Claude Desktop 遥测封锁脚本
用法：右键"以管理员身份运行"PowerShell，然后执行：
  python block_claude_telemetry.py

功能：将Anthropic所有遥测域名指向127.0.0.1，切断Claude Desktop的数据上传。
不影响CCSwitch等本地代理的正常使用。

还原方法：删除hosts文件中 "# Claude Desktop telemetry block" 标记的行，然后刷新DNS：
  ipconfig /flushdns
"""
import os, sys

hosts_path = r'C:\Windows\System32\drivers\etc\hosts'
block = '127.0.0.1'
marker = '# Claude Desktop telemetry block'

domains = [
    'api.anthropic.com',
    'statsig.anthropic.com',
    'api.statsig.com',
    'cdn.statsig.com',
    'featuregates.org',
    'sentry.io',
    'o474528.ingest.sentry.io',
    'otel.otel.svc.cluster.local',
    'collectivist.com',
    'fastly.net',
]

# Check admin rights
try:
    with open(hosts_path, 'r', encoding='utf-8') as f:
        content = f.read()
except PermissionError:
    print('ERROR: 需要管理员权限！')
    print('请右键PowerShell -> 以管理员身份运行，然后执行：')
    print(f'  python {os.path.abspath(__file__)}')
    sys.exit(1)

# Add blocks
added = 0
for domain in domains:
    entry = f'{block}  {domain}  {marker}'
    if domain not in content:
        content += f'\n{entry}'
        added += 1
        print(f'[OK] Blocked {domain}')
    else:
        print(f'[SKIP] {domain} already blocked')

# Write back
with open(hosts_path, 'w', encoding='utf-8') as f:
    f.write(content)

# Flush DNS
os.system('ipconfig /flushdns')

print(f'\nDone: {added} domains blocked.')
print('Claude Desktop telemetry is now blocked.')
print('CCSwitch/proxy on localhost is NOT affected.')
print(f'\nTo undo: remove lines with "{marker}" from {hosts_path}, then run "ipconfig /flushdns"')
