#!/bin/bash
[[ -z $(lsb_release -a 2>&1 | grep -i ubuntu) ]] && echo "debian" || echo "ubuntu"