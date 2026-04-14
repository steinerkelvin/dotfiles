---
name: uv-scripts
description: Use uv with PEP 723 inline metadata to run Python scripts with dependencies instead of installing packages globally
---

# Python Scripts with uv

**ALWAYS use `uv` to run Python scripts with dependencies** instead of installing
packages globally with pip. Use inline metadata (PEP 723) for script dependencies.

```python
#!/usr/bin/env -S uv run
# /// script
# dependencies = [
#   "requests",
#   "pandas",
# ]
# ///

import requests
import pandas as pd
# ... your code
```

Run with: `uv run script.py` or make executable with proper shebang.
