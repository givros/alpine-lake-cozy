"""Prepare byte-identical runtime assets in GitHub-compatible download chunks."""
from pathlib import Path
import gzip
import hashlib
import json
import shutil
import tempfile

ROOT = Path(__file__).resolve().parent
ASSETS = ROOT / 'public/assets'
ORIGINALS = ROOT.parent / 'original-runtime/assets'
PACKED = ASSETS / 'packed'
FILES = ['alpine-lake.glb', 'adaptive-lod.bin', 'tree-impostors/albedo.bin', 'tree-impostors/normal.bin']
CHUNK = 48 * 1024 * 1024

def digest(path):
    with path.open('rb') as source:
        return hashlib.file_digest(source, 'sha256').hexdigest()

def main():
    PACKED.mkdir(parents=True, exist_ok=True)
    manifest = {}
    for name in FILES:
        original = ORIGINALS / name
        source = original if original.exists() else ASSETS / name
        key = name.replace('/', '-')
        with tempfile.TemporaryDirectory(prefix='alpine-pack-') as tmp:
            compressed = Path(tmp) / 'asset.gz'
            with source.open('rb') as src, compressed.open('wb') as out:
                with gzip.GzipFile(fileobj=out, mode='wb', compresslevel=6, mtime=0, filename='') as dst:
                    shutil.copyfileobj(src, dst, 8 * 1024 * 1024)
            with gzip.open(compressed, 'rb') as restored:
                restored_hash = hashlib.file_digest(restored, 'sha256').hexdigest()
            source_hash = digest(source)
            if restored_hash != source_hash:
                raise RuntimeError(f'Lossless verification failed: {name}')
            parts = []
            with compressed.open('rb') as src:
                while chunk := src.read(CHUNK):
                    part = f'{key}.{len(parts):03d}.gzpart'
                    (PACKED / part).write_bytes(chunk)
                    parts.append(part)
            manifest[name] = dict(parts=parts, originalBytes=source.stat().st_size,
                                  compressedBytes=compressed.stat().st_size, sha256=source_hash)
            print(name, manifest[name]['originalBytes'], '->', manifest[name]['compressedBytes'], flush=True)
        if source != original:
            original.parent.mkdir(parents=True, exist_ok=True)
            source.rename(original)
    (PACKED / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')

if __name__ == '__main__':
    main()
