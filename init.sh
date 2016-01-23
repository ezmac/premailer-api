#!/bin/bash
cd /opt/premailer-api/
bundle install --no-deployment --path vendor/bundle
#rackup -p 4567 -o 0.0.0.0
ruby premailer-api.rb -o 0.0.0.0 -p 4567
