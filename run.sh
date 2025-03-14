#!/usr/bin/env bash

# `set -x` will leak secrets
set -eu

# Default arguments
dry_run="false"
loc_run="false"
skeet="false"

while test $# -gt 0 ; do
	#echo "$1"

	if [[ "$1" == "--dry" ]] ; then
		dry_run="true"

	elif [[ "$1" == "--skeet" ]] ; then
		skeet="true"

	elif [[ "$1" == "--local" || "$1" == "-l" ]] ; then
		loc_run="true"

	else
		echo -e "\e[33mWarning: unknown argument \"$1\" ignored\e[0m"

	fi

	shift
done

#source secrets.sh
#echo "user_id = ${user_id:0:3}********"
#echo "token = ${token:0:3}********"

#===============================================================================

# you can save secrets in secrets.sh for local testing and source it above. here
# are some example dummy contents of such a file:
#
#     #!/usr/bin/env bash
#
#     export token=ABC123abc           # threads access token, ~187 chars
#     export user_id=8070318659720523  # threads user id, ~16 chars
#     export GH_PA_TOKEN=ghp_abc123    # github personal access token, ~65 chars
#
# to get your access token, go here:
#
#     https://developers.facebook.com/apps/477298921791552/use_cases/customize/?use_case_enum=THREADS_API
#
# and then, use cases -> customize -> settings -> generate access token.  from
# the token, get your user id with the curl GET command shown below.  export
# both the user id and the access token as environment variables in secrets.sh
#
# given only an access token, you can get your user_id like this, replacing
# TOKEN with your token:
#
#     curl -s -X GET "https://graph.threads.net/v1.0/me?fields=id,username,name,threads_profile_picture_url,threads_biography&access_token=TOKEN"
#
# really you only need the `id`, but it's nice to show how to get the
# `username`, `name`, etc. too.
#
# for automated github actions, these secrets are stored as github secrets and
# injected into environment variables in main.yml
#
# for more help, see these resources:
#
#   - https://developers.facebook.com/docs/threads/posts
#   - https://developers.facebook.com/docs/instagram-basic-display-api/overview/#user-token-generator
#   - https://github.com/fbsamples/threads_api
#   - https://blog.disane.dev/en/threads-api-is-here/
#   - https://blog.nevinpjohn.in/posts/threads-api-public-authentication/
#
# a key difference that i took from some of the resources above is that i
# couldn't figure out how to get an access code. those blogs then exchanged the
# access code for a short-lived access token, and then exchanged the short-lived
# access token for a long-lived access token. it seems a lot easier to me to
# simply directly generate a long-lived access token on developers.facebook.com

#===============================================================================

# Functions

check_response()
{
	response=$1
	echo "starting check_response()"
	echo "response = $response"
	if [[ $(echo "$response" | grep '"error"') ]] ; then
		exit -3
	fi
}

configure_github()
{
	git config --unset-all http.https://github.com/.extraheader || true  # fails locally
	git config --global user.email "jirwin505@gmail.com"
	git config --global user.name "Jeff Irwin"
}

#===============================================================================

# Get state header and cache from store repo
subdir="prime-of-the-day"
if [[ "$skeet" == "true" ]]; then
	cp store/$subdir/state-skeet.h ./state.h
else
	cp store/$subdir/state.h .
fi

# Threads and bsky can share the same cache because they re-write in its
# entirety without shrinking, although they have different state.h cadences
cp store/$subdir/cache.tgz . || true
tar xvf cache.tgz || true

# Get a prime number
g++ -o main main.cpp

#prime=$(./main | tail -1)
output=$(./main)
echo "output =
{"
echo "$output"
echo "}"
prime=$(echo "$output" | tail -1)  # double quotes are required for newlines

echo "prime = $prime"

# Set the text payload to be posted
text="$prime"

# i got most of these palettes from https://coolors.co/palettes/trending
#
#          fg        bg        mg         name
palettes=("#66ddaa" "#114499" "#5588cc"  "green on blue"
          "#fefae0" "#bc6c25" "#dda15e"  "cream on brown"
          "#023047" "#8ecae6" "#219ebc"  "dark blue on light blue 1"
          "#8ecae6" "#023047" "#219ebc"  "light blue on dark blue 1"
          "#ffe5ec" "#fb6f92" "#ff8fab"  "light pink on dark pink"
          "#fb6f92" "#ffe5ec" "#ffc2d1"  "dark pink on light pink"
          "#4ffb72" "#e5ffec" "#c2ffd1"  "dark green on light green"
          "#6f92fb" "#e5ecff" "#c2d1ff"  "dark blue on light blue 2"
          "#e5ecff" "#6f92fb" "#8fabff"  "light blue on dark blue 2"
          "#e5ffec" "#3fdb62" "#8fffab"  "light green on dark green"
          "#e5e5e5" "#000000" "#14213d"  "grey on black (navy mg)"
          "#caf0f8" "#03045e" "#0077b6"  "light on dark blue"
          "#03045e" "#caf0f8" "#90e0ef"  "dark on light blue"
          "#c7f9cc" "#22577a" "#38a3a5"  "light on dark green"
          "#22577a" "#c7f9cc" "#80ed99"  "dark on light green"
          "#e0e1dd" "#0d1b2a" "#1b263b"  "light on dark blue grey"
          "#0d1b2a" "#e0e1dd" "#778da9"  "dark on light blue grey"
          "#ede0d4" "#7f5539" "#9c6644"  "light on dark brown"
          "#7f5539" "#ede0d4" "#e6ccb2"  "dark on light brown"
          "#ffff00" "#ff0000" "#ffff00"  "hotdog (shoutout badcop)"
          "#f1faee" "#1d3557" "#457b9d"  "white on blue"
          "#1d3557" "#f1faee" "#a8dadc"  "blue on white"
          "#101010" "#eddea4" "#f7a072"  "black on peach"
          "#ebebeb" "#540b0e" "#9e2a2b"  "white on burgundy"
          "#22223b" "#f2e9e4" "#c9ada7"  "dark blue on grey"
          "#f2e9e4" "#22223b" "#4a4e69"  "grey on dark blue"
          #"#ffcdb2" "#6d6875" "#b5838d"  "aoeu"
          "#6d6875" "#ffcdb2" "#ffb4a2"  "grey on tan"
          #"#8c1c13" "#e7d7c1" "#a78a7f"  "red on tan"
          "#e7d7c1" "#8c1c13" "#bf4342"  "tan on red"
          "#ffffff" "#231942" "#5e548e"  "white on purple"
          "#000000" "#e0b1cb" "#be95c4"  "black on purple"
          "#ffd380" "#00202e" "#003f5c"  "yellow on blue"
          "#00202e" "#ffd380" "#ffa600"  "blue on yellow"
          "#f50538" "#000000" "#3d010e"  "red on black"
          "#000000" "#f50538" "#b6042a"  "black on red"
          "#0c080a" "#c7a5aa" "#b19297"  "black on grey"
          "#c7a5aa" "#0c080a" "#21191c"  "grey on black"
          #"#aeedec" "#f3082f" "#00bcb0"  "green on red"
          "#d0ddd9" "#ca3f37" "#124938"  "green on red"
          "#d4685e" "#e6ebe6" "#7d9285"  "red on green"
)

# Seed based on the state because the default seed seems not fair (it might be
# based on system time, which is bad for cron jobs).  We don't really need an
# RNG at all for palette selection.  We could just cycle through the palettes in
# the same order repeatedly based on the state, but some pseudorandomness seems
# nice

if [[ "$skeet" == "true" ]]; then
	state_file="store/$subdir/state-skeet.h"
else
	state_file="store/$subdir/state.h"
fi

seed=$(grep -o '\<[0-9]*\>' "$state_file")
echo "seed = $seed"
RANDOM=$seed
#echo "RANDOM = $RANDOM"

npalettes=$(( ${#palettes[@]} / 4 ))
echo "npalettes = $npalettes"
ipalette=$(( $RANDOM % $npalettes ))
#ipalette=7
#ipalette=$(( $npalettes - 1 ))
echo "ipalette = $ipalette"

# TODO: add option to save images using all palettes in a local dry run (no
# pushing)

fg_color=${palettes[$(( $ipalette * 4 + 0 ))]}  # foreground
bg_color=${palettes[$(( $ipalette * 4 + 1 ))]}  # background
mg_color=${palettes[$(( $ipalette * 4 + 2 ))]}  # margin
plt_name=${palettes[$(( $ipalette * 4 + 3 ))]}

#echo "fg_color = $fg_color"
echo "the color palette is $plt_name"

# use imagemagick (`convert`) to make an image of text.  threads api has a
# maximum image width of 1440 pixels, so use 1100 here (700 + 2 * (100 + 100),
# including content plus borders)

image_file="prime.png"
#which convert
#convert --version
#convert -list font
#text="1,047,491"

font="fonts/cormorant-garamond/CormorantGaramond-Regular.ttf"
#font="fonts/computer-modern/cmunrm.ttf"

# order of cmd args matters.  font must be *before* label
#
# "trim" crops based on content which is helpful for fonts with more space at
# top than bottom
#
convert \
	-background "$bg_color" \
	-fill "$fg_color" \
	-size 700x \
	-font "$font" \
	label:"$text" \
	-trim \
	-bordercolor "$bg_color" -border 100x100 \
	-bordercolor "$mg_color" -border 100x100 \
	"$image_file"

if [[ "$loc_run" == "true" ]] ; then
	echo "local dry run"
	exit 0
fi

GH_USER=JeffIrwin

if [[ "$skeet" == "true" ]]; then

	#===============================================================================
	# ********  Bluesky posting  ********
	# ***********************************
	
	# c.f. run-skeeter.sh (for local prototype testing)
	
	# One-time setup:
	# - sudo npm i -g typescript
	# - sudo npm i -g ts-node
	# - npm install
	npm install
	
	# Get image dimensions:
	#
	#     identify -ping -format '%w %h\n' store/prime-of-the-day/prime.png
	#
	# `identify` is part of imagemagick
	#
	img_width=$( identify -ping -format '%w' "$image_file")
	img_height=$(identify -ping -format '%h' "$image_file")
	
	# Inject secrets into .env file
	echo "BLUESKY_USERNAME=prime-of-the-day.bsky.social" > .env
	echo "BLUESKY_PASSWORD=$BLUESKY_PASSWORD" >> .env
	
	# Compile ts to js
	npx tsc
	
	if [[ "$dry_run" == "true" ]] ; then
		echo "dry run"
		exit 0
	fi
	echo "wet run"
	
	# Run js
	node skeeter.js "$image_file" "$text" "$img_width" "$img_height"
	
	# Get ready for a state header commit later
	pushd store
	configure_github
	popd  # from store

else
	#===============================================================================
	# ********  Threads posting  ********
	# ***********************************
	
	# push the image to github. all threads image posts must have a public image
	# url, so it needs to be uploaded somewhere else before posting on threads
	mkdir -p store/$subdir/
	mv "$image_file" store/$subdir/
	pushd store
	git add ./$subdir/
	configure_github
	git commit -am "auto image commit from prime-of-the-day"
	git pull --rebase
	git push https://token:$GH_PA_TOKEN@github.com/$GH_USER/store
	store_hash=$(git rev-parse HEAD)  # commit hash in store repo
	popd  # from store
	
	url="https://graph.threads.net/v1.0"
	
	# use permalink url. i've seen github not update immediately on "main" branch
	# even after push. e.g.
	#
	#     https://raw.githubusercontent.com/JeffIrwin/store/4dff2a34a63f0d4750a8e5d4a6e739595bc4564c/prime-of-the-day/prime.png
	#
	image_url="https://raw.githubusercontent.com/$GH_USER/store/$store_hash/$subdir/$image_file"
	echo "image_url = $image_url"
	
	if [[ "$dry_run" == "true" ]] ; then
		echo "dry run"
		exit 0
	fi
	echo "wet run"
	
	#===============================================================================
	
	#type="text"
	type="image"
	
	if [[ "$type" == "text" ]] ; then
	
		# posting consists of two steps.  first create a container, then publish it
	
		# create a content container for the post and save the response which includes
		# its creation id
		response=$(curl --fail-with-body -i -X POST \
			"$url/$user_id/threads" \
			-d "media_type=TEXT" \
			-d "text=$text" \
			-d "access_token=$token")
		check_response "$response"
	
		creation_id=$(echo $response \
			| grep -o '{"id":.*}' \
			| grep -o "[0-9]*")
	
		# publish the post
		response=$(curl --fail-with-body -i -X POST \
			"$url/$user_id/threads_publish" \
			-d "creation_id=$creation_id" \
			-d "access_token=$token")
		check_response "$response"
	
	elif [[ "$type" == "image" ]] ; then
	
		response=$(curl --fail-with-body -i -X POST \
			"$url/$user_id/threads" \
			-d "media_type=IMAGE" \
			-d "image_url=$image_url" \
			-d "text=$text" \
			-d "access_token=$token")
		check_response "$response"
	
		creation_id=$(echo $response \
			| grep -o '{"id":.*}' \
			| grep -o "[0-9]*")
		response=$(curl --fail-with-body -i -X POST \
			"$url/$user_id/threads_publish" \
			-d "creation_id=$creation_id" \
			-d "access_token=$token")
		check_response "$response"
	
	else
		echo -e "\e[91;1mError: bad post type\e[0m"
		exit -2
	fi
	
	#===============================================================================
fi
# ********  end bluesky/threads if/else  ********
#===============================================================================

echo

#****************

# Compress cache to reduce file size for git
#
# With 300,000 primes, cache.bin is 2.3 MB and cache.tgz is 445 KB.  As primes
# get much bigger, I expect compression to be less effective.  For small primes,
# most of the 8 bytes of a size_t are zeros
#
# Files over 100 MB are blocked by github.  Over that, git LFS is needed
#
tar czf cache.tgz cache.bin
cp cache.tgz store/$subdir/

# read a number from the state header file, increment it, and write it back to
# the file in place
#
# this happens for both bluesky and threads, although the name of the state file
# differs (they may post at different cadences or have outages that get them out
# of sync)

count=$(grep -o '\<[0-9]*\>' "$state_file")
((count+=1))
#echo "count = $count"

sed -i "s/\<[0-9]*\>/$count/" "$state_file"

pushd store
git add ./$subdir/
git commit -am "auto state/cache commit from prime-of-the-day"

# This could fail in a race condition -- there are multiple github actions yml
# files working concurrently.  Might need to put this and other push in a retry
# loop
#
# At least the skeet job and thread job modify different files, so there should
# never be a conflict
git pull --rebase
git push https://token:$GH_PA_TOKEN@github.com/$GH_USER/store

popd  # from store

