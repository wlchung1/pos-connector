"use strict";

var app = angular.module("posConnectorApp", ["ngRoute", "posConnectorAppControllers", "posConnectorAppDirectives"]);

app.config(function ($routeProvider, $locationProvider) {
  $routeProvider.when("/orders", {templateUrl: "partials/order/list.html", controller: "ordersController"});
  $routeProvider.when("/orders/:id", {templateUrl: "partials/order/show.html", controller: "orderController"});
  $routeProvider.when("/jobs", {templateUrl: "partials/job/list.html", controller: "jobsController"});
  $routeProvider.when("/jobs/:id/edit", {templateUrl: "partials/job/edit.html", controller: "jobController"});
  $routeProvider.when("/vend-accounts/:id", {templateUrl: "partials/vend-account/show.html", controller: "vendAccountController"});
  $routeProvider.when("/vend-accounts/:id/edit", {templateUrl: "partials/vend-account/edit.html", controller: "vendAccountController"});
  $routeProvider.when("/quickbooks-accounts/:id", {templateUrl: "partials/quickbooks-account/show.html", controller: "quickbooksAccountController"});
  $routeProvider.when("/quickbooks-accounts/:id/edit", {templateUrl: "partials/quickbooks-account/edit.html", controller: "quickbooksAccountController"});
  $routeProvider.when("/quickbooks-oauth-callback", {templateUrl: "partials/quickbooks-account/oauth-callback.html", controller: "quickbooksOauthCallbackController"});
  $routeProvider.otherwise({redirectTo: "/orders"});

  // Use the HTML5 History API
  $locationProvider.html5Mode(true);
});

$.notify.defaults({globalPosition: "top left"});
