/**
 * Runtime configuration for SafeSDK (UMD integration).
 *
 * Host this file as /runtime-config.js and load it BEFORE safe-sdk.umd.min.js.
 * Replace placeholder values with your deployment configuration.
 * Do not commit production secrets to version control.
 */
globalThis.__SAFE_SDK_CONFIG__ = {
  baseUrl: 'https://gatekeeper.example.com',
  apiKey: '13CTrcYiya9NNnRyd3jXA21CULPPDSqM90sdFnGs',
  applicationId: 'mywebapp.mycompany.com',
  applicationVersion: '1.0.0',
}
