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

appServices.factory("jobCreationService", ["$resource", function ($resource) {
  return $resource("/api/job-creation/:flowType", null, {
    "save": {method: "POST", params: {flowType: "@flow_type"}},
  })
}]);

appServices.factory("jobsService", ["$resource", function ($resource) {
  return $resource("/api/jobs", null, {
    "query": {method: "GET", isArray: true}
  })
}]);

appServices.factory("vendAccountService", ["$resource", function ($resource) {
  return $resource("/api/vend-accounts/:id", null, {
    "get": {method: "GET"},
    "update": {method: "PUT", params: {id: "@id"}}
  });
}]);
