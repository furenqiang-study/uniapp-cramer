pip3.11 install -r requirements.txt
pm2 start main.py --name uniapp-api --interpreter python3.11 -- --host 0.0.0.0 --port 8022