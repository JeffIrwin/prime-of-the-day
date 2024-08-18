#!/usr/bin/env bash

# `set -x` will leak secrets
set -e

# Default arguments
dry_run="false"

pos=0
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
# TODO: include links to meta help docs, random blogs, etc.
#
# for automated github actions, these secrets are stored as github secrets and
# injected into environment variables in main.yml

# image posting example:
#
#     curl -i -X POST "https://graph.threads.net/v1.0/USER_ID/threads" -d "media_type=IMAGE" -d "image_url=https://www.jeffirwin.xyz/favicon.png" -d "text=#BronzFonz" -d "access_token=TOKEN"

# get a prime number
g++ -o main main.cpp
prime=$(./main | tail -1)
echo "prime = $prime"

# set the text payload to be posted
text="$prime"

if [[ "$dry_run" == "true" ]] ; then
	echo "dry run"
	exit 0
fi
echo "wet run"
exit 0 # TODO

url="https://graph.threads.net/v1.0"

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

