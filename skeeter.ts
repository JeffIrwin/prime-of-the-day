
import { BskyAgent } from '@atproto/api';
import * as dotenv from 'dotenv';
import * as process from 'process';
import * as fs from 'fs';

dotenv.config();

// Create a Bluesky Agent 
const agent = new BskyAgent({
	service: 'https://bsky.social',
})

function readFileAsUint8Array(filePath) {
    try {
        //const data = await fs.readFile(filePath);
        const data = fs.readFileSync(filePath);
        const uint8Array = new Uint8Array(data);
        return uint8Array;
    } catch (error) {
        console.error('Error reading file:', error);
        throw error;
    }
}

async function main() {
	console.log("starting skeeter.ts");

	//console.log("args = ", process.argv[2]);
	//console.log("args = ", process.argv[3]);
	//console.log("args = ", process.argv[4]);

	const img_name   = process.argv[2];
	const post_text  = process.argv[3];
	const img_width  = process.argv[4];
	const img_height = process.argv[5];

	console.log("img_name   = ", img_name);
	console.log("post_text  = ", post_text);
	console.log("img_width  = ", img_width);
	console.log("img_height = ", img_height);

	//return;

	await agent.login({ identifier: process.env.BLUESKY_USERNAME!, password: process.env.BLUESKY_PASSWORD!})

	const img_data = readFileAsUint8Array(img_name);
	const { data } =
		await agent.uploadBlob(img_data, { encoding: "image/png" })

	await agent.post({
	  text: post_text,
	  embed: {
	    $type: 'app.bsky.embed.images',
	    images: [
	      // can be an array up to 4 values
	      {
	        alt: 'an image of the prime number ' + post_text, // the alt text
	        image: data.blob,
	        aspectRatio: {
	          // a hint to clients.  looks like shit without it, weird cropping/framing
	          width : img_width,
	          height: img_height
	        }
	    }],
	  },
	  createdAt: new Date().toISOString()
	})

	//// Text posts are easy:
	//await agent.login({ identifier: process.env.BLUESKY_USERNAME!, password: process.env.BLUESKY_PASSWORD!})
	//await agent.post({
	//    //text: "🙂"
	//    text: "#bronz fonz"
	//});
	//console.log("Just posted!")

	console.log("ending skeeter.ts");
}

main();

