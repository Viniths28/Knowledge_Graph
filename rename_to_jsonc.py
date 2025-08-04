import os, pathlib

ROOT = pathlib.Path(__file__).parent
for path in ROOT.glob('*.json'):
    new_path = path.with_suffix('.jsonc')
    if not new_path.exists():
        path.rename(new_path)
        print(f'Renamed {path.name} -> {new_path.name}')
    else:
        print(f'Skipped {path.name}: target already exists') 