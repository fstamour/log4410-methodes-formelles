#!/bin/sh

make run-q1 | grep -i 'Client 0' --color=always | less -R

