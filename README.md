
# prime-of-the-day

a new prime number, every day on threads [@prime_of_the_day](https://www.threads.net/@prime_of_the_day)

## Dependencies

- curl
- g++
- gsfonts
- imagemagick

## Description

This threads bot is a bit of an exercise in ci/cd orchestration, but nothing
particularly interesting.  In short, this repo generates prime numbers and posts
them to threads.

The prime number generation is done in a short C++ program, [main.cpp](main.cpp).

The more interesting part, arguably, is the bash script [run.sh](run.sh) which
posts the prime to [threads](https://www.threads.net) using the [threads
API](https://developers.facebook.com/docs/threads/), and the github actions
[main.yml](.github/workflows/main.yml) config file which runs everything on a
schedule once a day.

The [C++ program](main.cpp) also includes some basic unit tests, invoked by
running it as `main --test`.  By default, running `main` without arguments
prints a single prime number.  _Which_ prime number it prints is where things
get interesting.  There is a dependency on a header file
[state.h](https://github.com/JeffIrwin/store/blob/main/prime-of-the-day/state.h)
which is not part of this repository!  This header contains a single number
that keeps track of which day we're on.  Each day after a thread is posted, that
number gets incremented and committed in the [store
repository](https://github.com/JeffIrwin/store/).  I have it as a separate repo,
not even as a submodule, because I don't want to have garbage commits in this
repo every day.  You will need to clone and copy the state header if you want to
test this program locally:
```
git clone github.com/JeffIrwin/store
cp store/prime-of-the-day/state.h .
```
This repo expects to find `state.h` in the current directory.

I had a couple other ideas for how to manage state.  Initially I hard-coded the
date of the day before I started posting and subtracted that from the current
date.  This isn't perfect and it adds dependency on a date library.  What
happens if I have an outage and miss a day?  What happens if, since github
actions run in UTC, daylight saving throws things off by an hour and that
happens to be just enough to throw the calculation off by a day?

Another idea was to use the github build number for my state.  This would have
limited me to only testing things once a day without any dry runs in between.

Managing the state myself is slightly tedious, what with having to get a github
personal access token to commit to the store repo, and moving the state header
back and forth.  However, it gives me the most control.  I can choose when to
increment the state counter, and when not to.

The [run.sh](run.sh) script has a `--dry` argument which performs a dry run.
Dry runs don't post anything to threads and they don't increment the state.
Also, if any stage of the run fails (e.g. if some token expires), the state
doesn't get incremented since it's the final stage.  This will allow me to fix
any outages and still post every prime in the correct order without any skips or
repeats.  Throughout the course of development, I've moved the dry run exit
point around in the runner, to test out various stages.

The runner script also handles posting to threads, using a couple
[curl](https://curl.se/) commands to the threads API.  The threads API depends
on yet another user ID and token pair.  If you have these, you can save them in
a .gitignored file `secrets.sh` for local testing.  See the comments in
[run.sh](run.sh) for more details.

The github actions config file [main.yml](.github/workflows/main.yml) is the
highest level part of this bot.  The github action runs in two conditions: (1)
on git push events and (2) on a daily schedule.  The push event runs C++ unit
tests and a dry run without posting anything to threads or changing the state.
The scheduled event does a wet run.

<!-- maybe say something about image generation after i put that into a
production -->

