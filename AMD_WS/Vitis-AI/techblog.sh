amd-edf:/mnt/temp/XFeat_WS# bash run_npu_image.bash 
WARNING: /etc/vai.sh was not found; using the current environment.
Fatal Python error: Bus error

Current thread 0x0000ffffb153b020 (most recent call first):
  File "<frozen importlib._bootstrap>", line 488 in _call_with_frames_removed
  File "<frozen importlib._bootstrap_external>", line 1293 in create_module
  File "<frozen importlib._bootstrap>", line 813 in module_from_spec
  File "<frozen importlib._bootstrap>", line 921 in _load_unlocked
  File "<frozen importlib._bootstrap>", line 1331 in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 1360 in _find_and_load
  File "/usr/lib/python3.12/site-packages/numpy/core/overrides.py", line 8 in <module>
  File "<frozen importlib._bootstrap>", line 488 in _call_with_frames_removed
  File "<frozen importlib._bootstrap_external>", line 999 in exec_module
  File "<frozen importlib._bootstrap>", line 935 in _load_unlocked
  File "<frozen importlib._bootstrap>", line 1331 in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 1360 in _find_and_load
  File "<frozen importlib._bootstrap>", line 488 in _call_with_frames_removed
  File "<frozen importlib._bootstrap>", line 1415 in _handle_fromlist
  File "/usr/lib/python3.12/site-packages/numpy/core/multiarray.py", line 10 in <module>
  File "<frozen importlib._bootstrap>", line 488 in _call_with_frames_removed
  File "<frozen importlib._bootstrap_external>", line 999 in exec_module
  File "<frozen importlib._bootstrap>", line 935 in _load_unlocked
  File "<frozen importlib._bootstrap>", line 1331 in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 1360 in _find_and_load
  File "<frozen importlib._bootstrap>", line 488 in _call_with_frames_removed
  File "<frozen importlib._bootstrap>", line 1415 in _handle_fromlist
  File "/usr/lib/python3.12/site-packages/numpy/core/__init__.py", line 24 in <module>
  File "<frozen importlib._bootstrap>", line 488 in _call_with_frames_removed
  File "<frozen importlib._bootstrap_external>", line 999 in exec_module
  File "<frozen importlib._bootstrap>", line 935 in _load_unlocked
  File "<frozen importlib._bootstrap>", line 1331 in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 1360 in _find_and_load
  File "<frozen importlib._bootstrap>", line 488 in _call_with_frames_removed
  File "<frozen importlib._bootstrap>", line 1310 in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 1360 in _find_and_load
  File "/usr/lib/python3.12/site-packages/numpy/__config__.py", line 4 in <module>
  File "<frozen importlib._bootstrap>", line 488 in _call_with_frames_removed
  File "<frozen importlib._bootstrap_external>", line 999 in exec_module
  File "<frozen importlib._bootstrap>", line 935 in _load_unlocked
  File "<frozen importlib._bootstrap>", line 1331 in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 1360 in _find_and_load
  File "/usr/lib/python3.12/site-packages/numpy/__init__.py", line 130 in <module>
  File "<frozen importlib._bootstrap>", line 488 in _call_with_frames_removed
  File "<frozen importlib._bootstrap_external>", line 999 in exec_module
  File "<frozen importlib._bootstrap>", line 935 in _load_unlocked
  File "<frozen importlib._bootstrap>", line 1331 in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 1360 in _find_and_load
  File "/usr/lib/python3.12/site-packages/cv2/__init__.py", line 11 in <module>
  File "<frozen importlib._bootstrap>", line 488 in _call_with_frames_removed
  File "<frozen importlib._bootstrap_external>", line 999 in exec_module
  File "<frozen importlib._bootstrap>", line 935 in _load_unlocked
  File "<frozen importlib._bootstrap>", line 1331 in _find_and_load_unlocked
  File "<frozen importlib._bootstrap>", line 1360 in _find_and_load
  File "/mnt/temp/XFeat_WS/src/run_npu_image.py", line 10 in <module>
Bus error (core dumped)
amd-edf:/mnt/temp/XFeat_WS#
