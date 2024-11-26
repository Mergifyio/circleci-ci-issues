#!/bin/bash

set -e -x

mergify ci junit-upload "${FILES}"
