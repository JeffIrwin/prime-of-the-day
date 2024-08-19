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
		echo -e "\e[33mwarning: unknown argument \"$1\" ignored\e[0m"

	fi

	shift
done

#source secrets.sh
#echo "user_id = ${user_id:0:3}********"
#echo "token = ${token:0:3}********"

# you can save secrets in secrets.sh for local testing and source it above. here
# are some example dummy contents of such a file:
#
#     #!/usr/bin/env bash
#
#     export token=ABC123abc           # should be ~187 chars
#     export user_id=8070318659720523  # should be ~16 chars
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

# get a prime number
g++ -o main main.cpp
prime=$(./main | tail -1)
echo "prime = $prime"

# set the text payload to be posted
text="$prime"

fg_color="#66ddaa"
bg_color="#114499"
mg_color="#5588cc" # margin
#fg_color="#88eecc"
#bg_color="#112277"
#mg_color="#5588cc" # margin

# use imagemagick (`convert`) to make an image of given `label` text.  threads
# api has a maximum image width of 1440 pixels, so use 1100 here (700 + 2 * (100
# + 100) including content plus borders)
#
# TODO: randomize colors? or at least cycle between several presets
#
image_file="prime.png"
which convert
#convert -list font
#text="1,047,491"
convert \
	-background "$bg_color" \
	-fill "$fg_color" \
	-size 700x \
	label:"$text" \
	-bordercolor "$bg_color" -border 100x100 \
	-bordercolor "$mg_color" -border 100x100 \
	"$image_file"
#-pointsize 140 \
#-bordercolor "$bg_color" -border 50x50 \
#-bordercolor "$mg_color" -border 50x50 \

GH_USER=JeffIrwin

# push the image to github. all threads image posts must have a public image
# url, so it needs to be uploaded somewhere else before posting on threads
set -x
ls -ltrh "$image_file"
mkdir -p store/prime-of-the-day/
mv "$image_file" store/prime-of-the-day/
pushd store
git status
git log -1
git add ./prime-of-the-day/
git config --unset-all http.https://github.com/.extraheader || true
git config --global user.email "jirwin505@gmail.com"
git config --global user.name "Jeff Irwin"
git commit -am "auto ci/cd commit from prime-of-the-day"
git remote -v
#git push
echo "GH_PA_TOKEN = ${GH_PA_TOKEN:0:3}********"
#git push --set-upstream https://user:$GH_PA_TOKEN@github.com/$GH_USER/store main
git push --prune https://token:$GH_PA_TOKEN@github.com/$GH_USER/store
store_hash=$(git rev-parse HEAD)  # commit hash in store repo
popd  # from store
set +x

url="https://graph.threads.net/v1.0"

# use permalink url. i've seen github not update immediately on "main" branch
# even after push. e.g.
#
#     https://raw.githubusercontent.com/JeffIrwin/store/4dff2a34a63f0d4750a8e5d4a6e739595bc4564c/prime-of-the-day/prime.png
#
image_url="https://raw.githubusercontent.com/$GH_USER/store/$store_hash/prime-of-the-day/$image_file"
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
##-d "image_url=https://raw.githubusercontent.com/JeffIrwin/store/main/prime-of-the-day/prime.png" \

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

#echo "response = $response"

creation_id=$(echo $response \
	| grep -o '{"id":.*}' \
	| grep -o "[0-9]*")

#echo "creation_id = $creation_id"

# publish the post
curl -i -X POST \
	"$url/$user_id/threads_publish" \
	-d "creation_id=$creation_id" \
	-d "access_token=$token"

echo

