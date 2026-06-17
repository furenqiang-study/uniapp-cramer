import urllib.request
import json

try:
    req = urllib.request.Request('https://newsnow.busiyi.world/api/news/hottest')
    req.add_header('User-Agent', 'Mozilla/5.0')
    resp = urllib.request.urlopen(req, timeout=15)
    raw = resp.read().decode('utf-8')
    data = json.loads(raw)
    # Print first 2 items to understand structure
    with open('news_api_result.txt', 'w', encoding='utf-8') as f:
        f.write(json.dumps(data[:3] if isinstance(data, list) else data, ensure_ascii=False, indent=2))
        f.write('\n\n--- Total items: ' + str(len(data) if isinstance(data, list) else 'not a list'))
    print('Done! Check news_api_result.txt')
except Exception as e:
    with open('news_api_result.txt', 'w', encoding='utf-8') as f:
        f.write(f'Error: {str(e)}')
    print(f'Error: {e}')