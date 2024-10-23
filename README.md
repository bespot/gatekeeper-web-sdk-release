# README

This is the release repository of Bespot Gatekeeper Web SDK, with all the necessary information to use it in your web applications.


## Creating your bundle 

In order to use the web SDK you have to download this repository and create your specific application's bundle, by doing the following:

1. Clone the repo: 
```bash
git clone git@github.com:bespot/gatekeeper-web-sdk-release.git
```

2. Install the necessary dependencies
```bash
npm install
```

3. Copy the .env.sample file as .env and fill in the necessary values, replacing the ones in the sample file. These should have been communicated with you already.
```bash
cp .env.sample .env 
```
```bash
API_KEY=your-api-key-goes-here
APPLICATION_ID=your-application-id-goes-here
```

4. Run the build command
```bash
npm run build
```

5. Use one of the two files in the `dist` directory, according to your needs:

    - `gatekeeper.esm.min.js` is in the ES modules format
    - `gatekeeper.umd.min.js` is in the UMD format


## Using the SDK

With your application bundle embedded in your application, you can now use the SDK. Accotding to your bundle and desired methods, you should have an `SDK` object in your hands.

**TODO**: Add examples for all possible bundle usages.

### Register

Before using the SDK to run checks you need to register the current user of your application:
```js
SDK.register() 
// or you can provide a userId as well
SDK.register({ userId: 'your_app_user_id_here' })
```

### Check

With the above registration complete, you can know run checks whenever you deem it appropriate
```js
const result = SDK.check()
// result is of the following format:
// {
//    action: 'string'
//    ticket: 'string'
// }
```
**TODO**: Add more info about actions and tickets

### Setting the User ID

If you haven't registered with a `userId`, you can set the user Id at any time.
```js
SDK.setUserId('your_app_user_id_here')
```
