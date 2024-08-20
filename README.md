
# prime-of-the-day

a new prime number, every day on threads [@prime_of_the_day](https://www.threads.net/@prime_of_the_day)

## Dependencies

- curl
- g++
- gsfonts
- imagemagick

## Description

This is a bit of an exercise in ci/cd orchestration, but nothing particularly
interesting.  In short, this repo generates prime numbers and posts them to
threads.

The prime number generation is done in a short C++ program.

The more interesting part is the bash script which posts the prime to
[threads](threads.net) using the [threads
API](https://developers.facebook.com/docs/threads/), and the github actions yaml
config file which runs everything on a schedule once a day.

