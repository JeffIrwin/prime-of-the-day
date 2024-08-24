#!/usr/bin/env bash

# `set -x` will leak secrets
set -e

# Default arguments
dry_run="false"

while test $# -gt 0 ; do
	#echo "$1"

	if [[ "$1" == "--dry" ]] ; then
		dry_run="true"

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

# get state header from store repo
cp store/prime-of-the-day/state.h .

# get a prime number
g++ -o main main.cpp
prime=$(./main | tail -1)
echo "prime = $prime"

# set the text payload to be posted
text="$prime"

# i got most of these palettes from https://coolors.co/palettes/trending

npalette=19
ipalette=$(( $RANDOM % $npalette ))
echo "ipalette = $ipalette"

if [[ "$ipalette" == "0" ]] ; then

	# green on blue
	fg_color="#66ddaa"
	bg_color="#114499"
	mg_color="#5588cc" # margin

elif [[ "$ipalette" == "1" ]] ; then

	# cream on brown
	fg_color="#fefae0"
	bg_color="#bc6c25"
	mg_color="#dda15e" # margin

elif [[ "$ipalette" == "2" ]] ; then

	# dark blue on light blue
	fg_color="#023047"
	bg_color="#8ecae6"
	mg_color="#219ebc" # margin

elif [[ "$ipalette" == "3" ]] ; then

	# dark blue on light blue
	fg_color="#8ecae6"
	bg_color="#023047"
	mg_color="#219ebc" # margin

elif [[ "$ipalette" == "4" ]] ; then

	# light pink on dark pink
	fg_color="#ffe5ec"
	bg_color="#fb6f92"
	mg_color="#ff8fab" # margin

elif [[ "$ipalette" == "5" ]] ; then

	# dark pink on light pink
	fg_color="#fb6f92"
	bg_color="#ffe5ec"
	mg_color="#ffc2d1" # margin

elif [[ "$ipalette" == "6" ]] ; then

	# dark green on light green
	fg_color="#4ffb72"
	bg_color="#e5ffec"
	mg_color="#c2ffd1" # margin

elif [[ "$ipalette" == "7" ]] ; then

	# dark blue on light blue
	fg_color="#6f92fb"
	bg_color="#e5ecff"
	mg_color="#c2d1ff" # margin

elif [[ "$ipalette" == "8" ]] ; then

	# light blue on dark blue
	fg_color="#e5ecff"
	bg_color="#6f92fb"
	mg_color="#8fabff" # margin

elif [[ "$ipalette" == "9" ]] ; then

	# light green on dark green
	fg_color="#e5ffec"
	bg_color="#3fdb62"
	mg_color="#8fffab" # margin

elif [[ "$ipalette" == "10" ]] ; then

	# gray on black (navy mg)
	fg_color="#e5e5e5"
	bg_color="#000000"
	mg_color="#14213d" # margin

elif [[ "$ipalette" == "11" ]] ; then

	# light on dark blue
	fg_color="#caf0f8"
	bg_color="#03045e"
	mg_color="#0077b6" # margin

elif [[ "$ipalette" == "12" ]] ; then

	# dark on light blue
	fg_color="#03045e"
	bg_color="#caf0f8"
	mg_color="#90e0ef" # margin

elif [[ "$ipalette" == "13" ]] ; then

	# light on dark green
	fg_color="#c7f9cc"
	bg_color="#22577a"
	mg_color="#38a3a5" # margin

elif [[ "$ipalette" == "14" ]] ; then

	# dark on light green
	fg_color="#22577a"
	bg_color="#c7f9cc"
	mg_color="#80ed99" # margin

elif [[ "$ipalette" == "15" ]] ; then

	# light on dark blue grey
	fg_color="#e0e1dd"
	bg_color="#0d1b2a"
	mg_color="#1b263b" # margin

elif [[ "$ipalette" == "16" ]] ; then

	# dark on light blue grey
	fg_color="#0d1b2a"
	bg_color="#e0e1dd"
	mg_color="#778da9" # margin

elif [[ "$ipalette" == "17" ]] ; then

	# light on dark brown
	fg_color="#ede0d4"
	bg_color="#7f5539"
	mg_color="#9c6644" # margin

elif [[ "$ipalette" == "18" ]] ; then

	# dark on light brown
	fg_color="#7f5539"
	bg_color="#ede0d4"
	mg_color="#e6ccb2" # margin

else
	echo -e "\e[91;1mError: bad palette index\e[0m"

fi

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

GH_USER=JeffIrwin
subdir="prime-of-the-day"

# push the image to github. all threads image posts must have a public image
# url, so it needs to be uploaded somewhere else before posting on threads
mkdir -p store/$subdir/
mv "$image_file" store/$subdir/
pushd store
git add ./$subdir/
git config --unset-all http.https://github.com/.extraheader || true  # fails locally
git config --global user.email "jirwin505@gmail.com"
git config --global user.name "Jeff Irwin"
git commit -am "auto image commit from prime-of-the-day"
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

## TODO: put this into production and move it after the dry run exit, remove
## the plain text post.
#
#response=$(curl -i -X POST \
#	"$url/$user_id/threads" \
#	-d "media_type=IMAGE" \
#	-d "image_url=$image_url" \
#	-d "text=$text" \
#	-d "access_token=$token")
#creation_id=$(echo $response \
#	| grep -o '{"id":.*}' \
#	| grep -o "[0-9]*")
#curl -i -X POST \
#	"$url/$user_id/threads_publish" \
#	-d "creation_id=$creation_id" \
#	-d "access_token=$token"

if [[ "$dry_run" == "true" ]] ; then
	echo "dry run"
	exit 0
fi
echo "wet run"

# posting consists of two steps.  first create a container, then publish it

# create a content container for the post and save the response which includes
# its creation id
response=$(curl -i -X POST \
	"$url/$user_id/threads" \
	-d "media_type=TEXT" \
	-d "text=$text" \
	-d "access_token=$token")

creation_id=$(echo $response \
	| grep -o '{"id":.*}' \
	| grep -o "[0-9]*")

# publish the post
curl -i -X POST \
	"$url/$user_id/threads_publish" \
	-d "creation_id=$creation_id" \
	-d "access_token=$token"

echo

#****************

# read a number from the state header file, increment it, and write it back to
# the file in place

state_file="store/prime-of-the-day/state.h"
count=$(grep -o '\<[0-9]*\>' "$state_file")
((count+=1))
#echo "count = $count"

sed -i "s/\<[0-9]*\>/$count/" "$state_file"

pushd store
git add ./$subdir/
git commit -am "auto state commit from prime-of-the-day"
git push https://token:$GH_PA_TOKEN@github.com/$GH_USER/store
popd  # from store

