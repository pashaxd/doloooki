'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "285815ff638f0354ca9072d5831de5a3",
"version.json": "c758eebe0e7178c5ab0c46e131a13ad6",
"index.html": "7af65663671ecabd9b8d623dc8b63062",
"/": "7af65663671ecabd9b8d623dc8b63062",
"main.dart.js": "75c7895af389d26265a588e908c11973",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "2f5a0ba247ed50df6c23a6a81176cdfd",
"assets/AssetManifest.json": "b0bd6800d48e5c3b3576853f1525e444",
"assets/NOTICES": "ef6b24b131a547babdd080a2319ae1b5",
"assets/FontManifest.json": "b2ff538738fb9a2c6b070544a4629770",
"assets/AssetManifest.bin.json": "0a0450d1b5b0f97b76566d9a1e6b8386",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "5241753519fee4fa5bffbb06e6d27ce7",
"assets/fonts/MaterialIcons-Regular.otf": "834a7250cd25a7a4dd825c3ca0015c3b",
"assets/assets/logo/logo.png": "f49a7a9d1bb5f51bf2fcb21ddb74afa0",
"assets/assets/icons/bottom_navigation/obrazi.png": "de7378d5e4144634a13e6173ec65c99a",
"assets/assets/icons/bottom_navigation/stylist.png": "2c0201b938f08f2ea0a0982ed96a7373",
"assets/assets/icons/bottom_navigation/garderob.png": "9850dd80d1e7a19431247526e56e452e",
"assets/assets/icons/bottom_navigation/profile.png": "8aa75c4a02cf975e5c3d7ec6942e1829",
"assets/assets/icons/bottom_navigation/recomendation.png": "c380ec361b651772525b3936125fa585",
"assets/assets/icons/stylist/voka.svg": "78bfee656113f6a718ea97f9a2fa40be",
"assets/assets/icons/stylist/gallery.svg": "b33eacfc98e8f596e93996800b260b0f",
"assets/assets/icons/stylist/check.svg": "5fe8b926d5dc2fdb226eee914c4e7aa7",
"assets/assets/icons/stylist/people.svg": "658fbad9d1a137b634b8f5a9cfb423ae",
"assets/assets/icons/stylist/skirt.svg": "b29c53cf37b4cf90a389d5b016a7d052",
"assets/assets/icons/stylist/consult.svg": "d15a8b6fcd891b0fa1b5962a95df8380",
"assets/assets/icons/stylist/send.svg": "6851a9351526de8b3a294baf7d546b8d",
"assets/assets/icons/stylist/star.svg": "94c8b9cd42e5acf980edda37a19f0ac5",
"assets/assets/icons/stylist/rate.svg": "c14bc22fb6d6d045a2ddae3af8d953c9",
"assets/assets/icons/patterns/svg/armour.svg": "2dfe987721d7eb7728a1f7e7c4b11e51",
"assets/assets/icons/patterns/svg/krutilka.svg": "c009bf1bc13d8ef2531d07b6ff2e32b2",
"assets/assets/icons/patterns/svg/size.svg": "9a01c6a82b33c47b3dec736d5c890035",
"assets/assets/icons/patterns/svg/cursor.svg": "79b2030ca12eb12ecbf1e13120dad4c8",
"assets/assets/icons/patterns/svg/sloi.svg": "0a39230048e032eda475634d89d8f71f",
"assets/assets/icons/sms/i.svg": "365622b3cf2074cf231d7213d07ef3f0",
"assets/assets/icons/left_navigation/settings.svg": "ac30d6b28a343e24d073e7f2f88d98b0",
"assets/assets/icons/left_navigation/recomendations.svg": "f6a903baa77235a2ac7ee24ec1dc8625",
"assets/assets/icons/left_navigation/consultations.svg": "2f0e64016c31ef3816d24e6db1a090cf",
"assets/assets/icons/left_navigation/users.svg": "0d7ded41eee95e5cbc32f86d8f98cd31",
"assets/assets/icons/profile/notifs.svg": "90ba0cf06da60b804c3b602c19d0a3d0",
"assets/assets/icons/profile/logout.svg": "ce301620c5c6d6974b2f372e06649b75",
"assets/assets/icons/profile/galery.svg": "e9e5736bc20a1add8e65b40eabe5bab5",
"assets/assets/icons/profile/usloviya.svg": "f4e57fe48ad6bde882b1ca4159e5155e",
"assets/assets/icons/profile/camera.svg": "c9e4fbc7ad5988fc036b4db54f571616",
"assets/assets/icons/profile/faq.svg": "3b316bdc415456781483516969e0c475",
"assets/assets/icons/profile/lichnoe.svg": "dc3f9a126ab3b947b51fbc858eec4f48",
"assets/assets/icons/profile/version.svg": "951152115ac0cae304429508ba082cb0",
"assets/assets/icons/auth_pc/success.svg": "5b34b7af4115771560eee36bab100366",
"assets/assets/icons/profile.png": "8a081abb011b144e0cf18a33f8d8243f",
"assets/assets/icons/supcription/card.png": "8a3be68196e0fc01ad957cf7202e2d3d",
"assets/assets/icons/supcription/garderob.png": "414062eb9e71d253091148798eaf14c4",
"assets/assets/icons/supcription/star.png": "2ae758e2d346cabe2015aec7a826e7f4",
"assets/assets/icons/supcription/fon.png": "fb0fcaa7780c24c0d64f630435cd3f08",
"assets/assets/icons/supcription/platye.png": "061b3e5c72867aad2c4707ae2dd58277",
"assets/assets/icons/supcription/recomendations.png": "e2b39301114e8a9cc1f3b927edf7e921",
"assets/assets/icons/avatar_pick.png": "08b262caa9d8c926dcd9af367fca645c",
"assets/assets/icons/notifications/notifs.svg": "aa80699fc5c4821ade243b452f4e914e",
"assets/assets/icons/notifications/green.png": "f97fbd32fa2d126f7beade8038a40459",
"assets/assets/icons/notifications/red.png": "5f821448fbe7a770d9bf56ef57b3cba9",
"assets/assets/fonts/Montserrat/33107994939.ttf": "88932dadc42e1bba93b21a76de60ef7a",
"assets/assets/fonts/Montserrat/26023618743.ttf": "9c46095118380d38f12e67c916b427f9",
"assets/assets/onboarding/3rd.png": "3f27fd381500ec12d085157a8fdafc9c",
"assets/assets/onboarding/1st.png": "49ebbfcfc37e40d2da21fde1166889a5",
"assets/assets/onboarding/onboarding_video.mp4": "f220b3371a6bfca3eac120be3eab759b",
"assets/assets/onboarding/4th.png": "9d1e73c3499671257070307728081b9a",
"assets/assets/onboarding/2nd.png": "538be02e2d2c317aae019ee7f16c5e55",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
