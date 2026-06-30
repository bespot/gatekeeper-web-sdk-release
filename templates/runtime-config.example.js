/**
 * Runtime configuration for SafeSDK (UMD integration).
 *
 * Host this file as /runtime-config.js and load it BEFORE safe-sdk.umd.min.js.
 * Replace placeholder values with your deployment configuration.
 * Do not commit production secrets to version control.
 */
globalThis.__SAFE_SDK_CONFIG__ = {
  baseUrl: 'bespot-gatekeeper-base-url', // e.g. 'https://gatekeeper.bespotcompany.com'
  apiKey: 'your-api-key', // e.g. '13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs'
  applicationId: 'your-app-id', // e.g. 'mywebapp.mycompany.com'
  applicationVersion: 'your-app-version', // e.g. '2.4.1'
}
