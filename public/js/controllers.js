"use strict";

var appControllers = angular.module("posConnectorAppControllers", ["posConnectorAppServices"]);

appControllers.controller("ordersController", ["$scope", "$routeParams", "$location", "ordersService", "orderService", "jobCreationService",
  function($scope, $routeParams, $location, ordersService, orderService, jobCreationService) {
    // Callback for ng-click "pollOrders()"
    $scope.pollOrders = function () {
      // Prevent user from clicking Poll Orders button multiple times
      $scope.pollOrdersDisabled = true;

      jobCreationService.save({flow_type: "ReceiveOrdersFromVend"},
        function (data) {
          $.notify("Poll orders job completed", "success");
          $scope.pollOrdersDisabled = false;
        }, function (error) {
          $.notify("Poll orders job failed: " + error.data.error, "error");
          $scope.pollOrdersDisabled = false;
        }
      );
      $.notify("Poll orders request submitted", "info");
    };

    // Callback for ng-click "refresh()"
    $scope.refresh = function () {
      // Prevent user from clicking Refresh button multiple times
      $scope.refreshDisabled = true;

      $scope.orders = ordersService.query(
        function (orders) {
          $scope.refreshDisabled = false;
        }, function (error) {
          $.notify("Failed to refresh orders: " + error.data.error, "error");
          $scope.refreshDisabled = false;
        }
      );
    };

    $scope.refresh();
  }
]);

appControllers.controller("orderController", ["$scope", "$routeParams", "$location", "orderService",
  function ($scope, $routeParams, $location, orderService) {
    $scope.order = orderService.get({id: $routeParams.id},
      function (order) {
      }, function (error) {
        $.notify("Failed to retrieve order information: " + error.data.error, "error");
      }
    );
  }
]);

appControllers.controller("jobsController", ["$scope", "$routeParams", "$location", "jobsService",
  function($scope, $routeParams, $location, jobsService) {
    // Callback for ng-click "refresh()"
    $scope.refresh = function () {
      // Prevent user from clicking Refresh button multiple times
      $scope.refreshDisabled = true;

      $scope.jobs = jobsService.query(
        function (jobs) {
          $scope.refreshDisabled = false;
        }, function (error) {
          $.notify("Failed to refresh jobs: " + error.data.error, "error");
          $scope.refreshDisabled = false;
        }
      );
    };

    $scope.refresh();
  }
]);

appControllers.controller("vendAccountController", ["$scope", "$routeParams", "$location", "vendAccountService",
  function ($scope, $routeParams, $location, vendAccountService) {
    // Callback for ng-click "edit()"
    $scope.edit = function () {
      $location.path("/vend-accounts/" + $scope.vendAccount.id + "/edit");
    };

    // Callback for ng-click "update()"
    $scope.update = function () {
      // Prevent user from clicking Save button multiple times
      $scope.saveDisabled = true;

      vendAccountService.update($scope.vendAccount,
        function (vendAccount) {
          $.notify("Vend account information saved successfully", "success");
          $location.path("/vend-accounts/" + $scope.vendAccount.id + "/view");
        }, function (error) {
          $.notify("Failed to save Vend account information: " + error.data.error, "error");
          $location.path("/vend-accounts/" + $scope.vendAccount.id + "/view");
        }
      );
    };

    // Callback for ng-click "cancel()"
    $scope.cancel = function () {
      $location.path("/vend-accounts/" + $scope.vendAccount.id + "/view");
    };

    $scope.vendAccount = vendAccountService.get({id: $routeParams.id},
      function (vendAccount) {
      }, function (error) {
        $.notify("Failed to retrieve Vend account information: " + error.data.error, "error");
      }
    );
  }
]);
