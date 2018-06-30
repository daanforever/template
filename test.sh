#!/bin/bash

rm -rf test.app; rails new -m $1 test.app; pushd test.app; bin/rails s; bin/spring stop; popd
