#!/bin/bash

#set -xe
set -e

#echo "user_id = $user_id"
echo "user_id = ${user_id:0:3}********"
echo "USER_ID = ${USER_ID:0:3}********"

# TODO
exit 0

#source secrets.sh

# Image example:
#
#     curl -i -X POST "https://graph.threads.net/v1.0/USER_ID/threads" -d "media_type=IMAGE" -d "image_url=https://www.jeffirwin.xyz/favicon.png" -d "text=#BronzFonz" -d "access_token=TOKEN"

#text="now i have to figure out what to do with this. post \"it's wednesday my dudes\" every wednesday or something"
#text="hello from ec2"
text="7"

# You can get the user id like this:
#
#     curl -s -X GET "https://graph.threads.net/v1.0/me?fields=id,username,name,threads_profile_picture_url,threads_biography&access_token=TOKEN"
#
#user_id=USER_ID

url="https://graph.threads.net/v1.0"

# Secrets are stored in .gitignored secrets.sh.  To get
# secrets, go here:
#
#     https://developers.facebook.com/apps/477298921791552/use_cases/customize/?use_case_enum=THREADS_API
#
# And then, use cases -> customize -> settings ->
# generate access token.  From the token, get your user
# id with the curl GET command shown above.  Export both
# the user id and the access token as environment
# variables in secrets.sh
#

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

curl -i -X POST \
	"$url/$user_id/threads_publish" \
	-d "creation_id=$creation_id" \
	-d "access_token=$token"

echo

