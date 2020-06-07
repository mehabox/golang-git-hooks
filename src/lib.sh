#!/bin/bash

function echoWhiteBold {
  echo -e "\e[1;37m${1}\e[0m"
}

function echoWarning {
  echo -e "\e[1;33m${1}\e[0m"
}

function echoSuccess {
  echo -e "\e[1;37;42m${1}\e[0m"
}

function echoError {
  echo -e "\e[1;31m${1}\e[0m"
}