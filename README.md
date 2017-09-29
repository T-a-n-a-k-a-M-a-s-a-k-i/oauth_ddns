# OAUTH DDNS

This tool provides a very simple DDNS using OAUTH authentication.

## Running
  
    $ bundle install
    $ cp config_example.yml config.yml
    $ vim config.yml
    $ cat config.yml
    ddns_domain: example
    twitter_key: YOUR TWITTER KEY
    twitter_secret: YOUR TWITTER SECRET
    $rackup -o "0.0.0.0" -p 80

## TODO

0. Add Tests
1. Add more provider authentication
