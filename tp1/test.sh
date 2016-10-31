#!/bin/sh

make run-model | grep -i 'Client 0' --color=always | less -R

