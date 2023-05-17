#! /bin/bash

docker run --rm -v ${PWD}:/workdir <Container ID> uplatex <Title>.tex
docker run --rm -v ${PWD}:/workdir <Container ID> dvipdfmx <Title>.dvi
