import re
with open("b64.txt", "rb") as f:
    b64 = f.read().strip()
    
with open("Scripts-by-AleexLeDev.bat", "rb") as f:
    text = f.read()
    
new_text = re.sub(rb"powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand [A-Za-z0-9+/=]+", b"powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand " + b64, text)

with open("Scripts-by-AleexLeDev.bat", "wb") as f:
    f.write(new_text)
