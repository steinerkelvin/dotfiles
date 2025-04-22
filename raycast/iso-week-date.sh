#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ISO Week Date
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📅
# @raycast.packageName iso-week-date

# Documentation:
# @raycast.author kelvin_steiner
# @raycast.authorURL https://raycast.com/kelvin_steiner

date +'%Y-W%V'
