var CACHE = "safeconvert-v1";
var URLS = ["./", "./index.html", "./manifest.json", "./icon-192.png", "./icon-512.png"];

self.addEventListener("install", function(event) {
  event.waitUntil(caches.open(CACHE).then(function(cache) { return cache.addAll(URLS); }));
  self.skipWaiting();
});

self.addEventListener("activate", function(event) {
  event.waitUntil(caches.keys().then(function(keys) {
    return Promise.all(keys.filter(function(key) { return key !== CACHE; }).map(function(key) { return caches.delete(key); }));
  }));
  self.clients.claim();
});

self.addEventListener("fetch", function(event) {
  var reqUrl;
  try {
    reqUrl = new URL(event.request.url);
  } catch (e) {
    event.respondWith(new Response("Unavailable", {status: 404}));
    return;
  }
  if (reqUrl.origin !== self.location.origin) {
    event.respondWith(new Response("External requests blocked", {status: 403}));
    return;
  }
  event.respondWith(caches.match(event.request).then(function(response) { return response || fetch(event.request); }));
});
