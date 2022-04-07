#!/usr/bin/env bash

tput setaf 6 0 0
ifconfig ens33 | head -n 2 | tail -n 2
tput sgr0
