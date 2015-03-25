"use strict";

var app = angular.module("posConnectorApp", ["ngRoute", "posConnectorAppControllers", "posConnectorAppDirectives"]);

app.config(function ($routeProvider, $locationProvider) {
  $routeProvider.when("/", {templateUrl: "partials/order/list.html", controller: "ordersController"});
  $routeProvider.when("/orders/:id/view", {templateUrl: "partials/order/view.html", controller: "orderController"});
  $routeProvider.when("/jobs", {templateUrl: "partials/job/list.html", controller: "jobsController"});
  $routeProvider.when("/vend-accounts/:id/view", {templateUrl: "partials/vend-account/view.html", controller: "vendAccountController"});
  $routeProvider.when("/vend-accounts/:id/edit", {templateUrl: "partials/vend-account/edit.html", controller: "vendAccountController"});
  $routeProvider.otherwise({redirectTo: "/"});

  // Use the HTML5 History API
  $locationProvider.html5Mode(true);
});

$.notify.defaults({globalPosition: "top left"});
