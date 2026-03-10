#!/bin/bash

source ./common.sh
app_name=payment

check_root
python_setup
app_setup
systemd_setup
print_time