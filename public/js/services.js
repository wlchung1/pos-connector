"use strict";

var appServices = angular.module("posConnectorAppServices", ["ngResource"]);

appServices.factory("ordersService", ["$resource", function ($resource) {
  return $resource("/api/orders", null, {
    "query": {method: "GET", isArray: true}
  })
}]);

appServices.factory("orderService", ["$resource", function ($resource) {
  return $resource("/api/orders/:id", null, {
    "get": {method: "GET"}
  })
}]);

appServices.factory("jobsService", ["$resource", function ($resource) {
  return $resource("/api/jobs", null, {
    "query": {method: "GET", isArray: true},
    "save": {method: "POST"}
  })
}]);

appServices.factory("jobService", ["$resource", function ($resource) {
  return $resource("/api/jobs/:id", null, {
    "get": {method: "GET"},
    "update": {method: "PUT", params: {id: "@id"}}
  });
}]);

appServices.factory("vendAccountService", ["$resource", function ($resource) {
  return $resource("/api/vend-accounts/:id", null, {
    "get": {method: "GET"},
    "update": {method: "PUT", params: {id: "@id"}}
  });
}]);

appServices.factory("quickbooksOauthTokenService", ["$resource", function ($resource) {
  return $resource("/api/quickbooks-authorization/get-oauth-token", null, {
    "get": {method: "GET"}
  })
}]);

appServices.factory("quickbooksOauthCallbackService", ["$resource", function ($resource) {
  return $resource("/api/quickbooks-authorization/oauth-callback", null, {
    "update": {method: "PUT"}
  })
}]);

appServices.factory("quickbooksAccountService", ["$resource", function ($resource) {
  return $resource("/api/quickbooks-accounts/:id", null, {
    "get": {method: "GET"},
    "update": {method: "PUT", params: {id: "@id"}}
  });
}]);
