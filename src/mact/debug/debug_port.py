"""Closed standalone source identity; no instruction generation or target input."""
from pathlib import Path
import hashlib
B=Path(__file__).parent
def expand():
 p=B/'authored/DEBUG.S';raw=p.read_bytes();h=hashlib.sha256(raw).hexdigest();return raw,[{'path':'authored/DEBUG.S','sha256':h,'line':i}for i,_ in enumerate(raw.decode('ascii').splitlines(),1)]
