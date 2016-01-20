#!/bin/bash
docker run -p 8888:4567 -v `pwd`:/opt/premailer-api/:ro premailer
