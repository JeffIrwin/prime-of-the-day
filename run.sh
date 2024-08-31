#!/usr/bin/env bash

# `set -x` will leak secrets
set -eu

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
#
#          fg        bg        mg         name
palettes=("#66ddaa" "#114499" "#5588cc"  "green on blue"
          "#fefae0" "#bc6c25" "#dda15e"  "cream on brown"
          "#023047" "#8ecae6" "#219ebc"  "dark blue on light blue"
          "#8ecae6" "#023047" "#219ebc"  "light blue on dark blue"
          "#ffe5ec" "#fb6f92" "#ff8fab"  "light pink on dark pink"
          "#fb6f92" "#ffe5ec" "#ffc2d1"  "dark pink on light pink"
          "#4ffb72" "#e5ffec" "#c2ffd1"  "dark green on light green"
          "#6f92fb" "#e5ecff" "#c2d1ff"  "dark blue on light blue"
          "#e5ecff" "#6f92fb" "#8fabff"  "light blue on dark blue"
          "#e5ffec" "#3fdb62" "#8fffab"  "light green on dark green"
          "#e5e5e5" "#000000" "#14213d"  "gray on black (navy mg)"
          "#caf0f8" "#03045e" "#0077b6"  "light on dark blue"
          "#03045e" "#caf0f8" "#90e0ef"  "dark on light blue"
          "#c7f9cc" "#22577a" "#38a3a5"  "light on dark green"
          "#22577a" "#c7f9cc" "#80ed99"  "dark on light green"
          "#e0e1dd" "#0d1b2a" "#1b263b"  "light on dark blue grey"
          "#0d1b2a" "#e0e1dd" "#778da9"  "dark on light blue grey"
          "#ede0d4" "#7f5539" "#9c6644"  "light on dark brown"
          "#7f5539" "#ede0d4" "#e6ccb2"  "dark on light brown"
)

npalettes=$(( ${#palettes[@]} / 4 ))
echo "npalettes = $npalettes"
ipalette=$(( $RANDOM % $npalettes ))
#ipalette=7
echo "ipalette = $ipalette"

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

if [[ "$dry_run" == "true" ]] ; then
	echo "dry run"
	exit 0
fi
echo "wet run"

#type="text"
type="image"

if [[ "$type" == "text" ]] ; then

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

elif [[ "$type" == "image" ]] ; then

	response=$(curl -i -X POST \
		"$url/$user_id/threads" \
		-d "media_type=IMAGE" \
		-d "image_url=$image_url" \
		-d "text=$text" \
		-d "access_token=$token")
	creation_id=$(echo $response \
		| grep -o '{"id":.*}' \
		| grep -o "[0-9]*")
	curl -i -X POST \
		"$url/$user_id/threads_publish" \
		-d "creation_id=$creation_id" \
		-d "access_token=$token"

else
	echo -e "\e[91;1mError: bad post type\e[0m"
	exit -2
fi

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

