#!/usr/bin/env bash

export LIBDIR=$params.libraryPath
RepeatMasker $params.rmParams subset.fa -dir .
if ! [-f "subset.fa.masked"]
then
  mv subset.fa subset.fa.masked
fi
