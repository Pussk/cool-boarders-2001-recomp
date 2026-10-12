"""Apply title patches once; reject unrelated framework versions/changes."""
from pathlib import Path
import subprocess
root=Path(__file__).resolve().parent.parent
for patch in sorted((root/'patches').glob('*.patch')):
 args=['git','-C',str(root/'psxrecomp'),'apply','--ignore-space-change','--ignore-whitespace']
 if subprocess.run(args+['--reverse','--check',str(patch)],capture_output=True).returncode==0:
  print('Already applied:',patch.name);continue
 subprocess.run(args+['--check',str(patch)],check=True)
 subprocess.run(args+[str(patch)],check=True)
 print('Applied:',patch.name)
