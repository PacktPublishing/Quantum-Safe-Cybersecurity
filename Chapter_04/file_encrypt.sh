#!/bin/bash
inputFile=$1
outputFile=$2

if [[ $# -ne 2 ]]; then
	echo "This script requires two arguments."
	exit 1
fi

if [[ -f "$outputFile" ]]; then
	echo "This file already exists."
	exit 1
fi

openssl enc -aes-256-ctr -md sha-512 -pbkdf2 -iter 600000 -in "$inputFile" -out "$outputFile"
shred -uz "$inputFile"
