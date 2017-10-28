#!/bin/bash

#
# File: restart_bluetooth.sh
# Author: eweb
# Copyright eweb, 2017-2017
# Contents:
#
# Date:          Author:  Comments:
# 28th Oct 2017  eweb     #0008 restart blue tooth
#

sudo kextunload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
sudo kextload -b com.apple.iokit.BroadcomBluetoothHostControllerUSBTransport
