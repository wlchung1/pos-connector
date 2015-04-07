"use strict";

var appControllers = angular.module("posConnectorAppControllers", ["posConnectorAppServices"]);

appControllers.controller("ordersController", ["$scope", "$routeParams", "$location", "ordersService", "orderService", "jobsService",
  function($scope, $routeParams, $location, ordersService, orderService, jobsService) {
    // Callback for ng-click "pollOrdersFromVend()"
    $scope.pollOrdersFromVend = function () {
      // Prevent user from clicking "Poll Orders from Vend" button multiple times
      $scope.pollOrdersFromVendDisabled = true;

      jobsService.save({flow_type: "ReceiveOrdersFromVendJob"},
        function (data) {
          $.notify("\"Poll orders from Vend\" job submitted", "success");
          $scope.pollOrdersFromVendDisabled = false;
        }, function (error) {
          $.notify("\"Poll orders from Vend\" job rejected: " + error.data.error, "error");
          $scope.pollOrdersFromVendDisabled = false;
        }
      );
    };

    // Callback for ng-click "sendOrdersToQuickbooks()"
    $scope.sendOrdersToQuickbooks = function () {
      // Prevent user from clicking "Send Orders to Quickbooks" button multiple times
      $scope.sendOrdersToQuickbooksDisabled = true;

      if ($scope.selectedOrderIds.length === 0) {
        $.notify("Please check the orders that you want to send to Quickbooks", "error");
        $scope.sendOrdersToQuickbooksDisabled = false;
        return;
      }

      var parameters = {"ids": $scope.selectedOrderIds};
      jobsService.save({flow_type: "SendOrdersToQuickbooksJob", parameters: JSON.stringify(parameters)},
        function (data) {
          $.notify("\"Send orders to Quickbooks\" job submitted", "success");
          $scope.sendOrdersToQuickbooksDisabled = false;
        }, function (error) {
          $.notify("\"Send orders to Quickbooks\" job rejected: " + error.data.error, "error");
          $scope.sendOrdersToQuickbooksDisabled = false;
        }
      );
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

    $scope.selectedOrderIds = [];

    // Keep track of the selected order IDs
    // Make use of UI Grid??
    $scope.toggleSelectedOrder = function (orderId) {
      var toggleIndex = $scope.selectedOrderIds.indexOf(orderId);

      if (toggleIndex > -1) {
        $scope.selectedOrderIds.splice(toggleIndex, 1);
      } else {
        $scope.selectedOrderIds.push(orderId);
      }
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
          console.log(jobs);
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

appControllers.controller("jobController", ["$scope", "$routeParams", "$location", "jobService",
  function ($scope, $routeParams, $location, jobService) {
    // Callback for ng-click "update()"
    $scope.update = function () {
      // Prevent user from clicking Save button multiple times
      $scope.saveDisabled = true;

      var submitting_job = {id: $scope.job.id, context: $scope.job.context};
      if ($scope.job.rerun) {
        submitting_job.status = "Waiting";
      }

      jobService.update(submitting_job,
        function (job) {
          $.notify("Job information saved successfully", "success");
          $location.path("/jobs");
        }, function (error) {
          $.notify("Failed to save job information: " + error.data.error, "error");
          $location.path("/jobs");
        }
      );
    };

    // Callback for ng-click "cancel()"
    $scope.cancel = function () {
      $location.path("/jobs");
    };

    $scope.job = jobService.get({id: $routeParams.id},
      function (job) {
      }, function (error) {
        $.notify("Failed to retrieve job information: " + error.data.error, "error");
      }
    );
    $scope.job.rerun = false;
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
          $location.path("/vend-accounts/" + $scope.vendAccount.id);
        }, function (error) {
          $.notify("Failed to save Vend account information: " + error.data.error, "error");
          $location.path("/vend-accounts/" + $scope.vendAccount.id);
        }
      );
    };

    // Callback for ng-click "cancel()"
    $scope.cancel = function () {
      $location.path("/vend-accounts/" + $scope.vendAccount.id);
    };

    $scope.vendAccount = vendAccountService.get({id: $routeParams.id},
      function (vendAccount) {
      }, function (error) {
        $.notify("Failed to retrieve Vend account information: " + error.data.error, "error");
      }
    );
  }
]);

appControllers.controller("quickbooksAccountController", ["$scope", "$routeParams", "$location", "$window", "quickbooksOauthTokenService", "quickbooksAccountService",
  function ($scope, $routeParams, $location, $window, quickbooksOauthTokenService, quickbooksAccountService) {
    // Callback for ng-click "connect()"
    $scope.connect = function () {
      // Prevent user from clicking Connect to Quickbooks button multiple times
      $scope.connectToQuickbooksDisabled = true;

      var xx = quickbooksOauthTokenService.get(
        function (result) {
          var oauthCallback = encodeURIComponent($window.location.protocol + "//" + $window.location.host + "/quickbooks-oauth-callback");
          $window.open("https://appcenter.intuit.com/Connect/Begin?oauth_callback=" + oauthCallback + "&oauth_token=" + result.oauth_token, "_blank");
          $scope.connectToQuickbooksDisabled = false;
        }, function (error) {
          $.notify("Failed to get OAuth token: " + error.data.error, "error");
          $scope.connectToQuickbooksDisabled = false;
        }
      );
    };

    // Callback for ng-click "edit()"
    $scope.edit = function () {
      $location.path("/quickbooks-accounts/" + $scope.quickbooksAccount.id + "/edit");
    };

    // Callback for ng-click "update()"
    $scope.update = function () {
      // Prevent user from clicking Save button multiple times
      $scope.saveDisabled = true;

      quickbooksAccountService.update($scope.quickbooksAccount,
        function (quickbooksAccount) {
          $.notify("Quickbooks account information saved successfully", "success");
          $location.path("/quickbooks-accounts/" + $scope.quickbooksAccount.id);
        }, function (error) {
          $.notify("Failed to save Quickbooks account information: " + error.data.error, "error");
          $location.path("/quickbooks-accounts/" + $scope.quickbooksAccount.id);
        }
      );
    };

    // Callback for ng-click "cancel()"
    $scope.cancel = function () {
      $location.path("/quickbooks-accounts/" + $scope.quickbooksAccount.id);
    };

    $scope.quickbooksAccount = quickbooksAccountService.get({id: $routeParams.id},
      function (quickbooksAccount) {
      }, function (error) {
        $.notify("Failed to retrieve Quickbooks account information: " + error.data.error, "error");
      }
    );
  }
]);

appControllers.controller("quickbooksOauthCallbackController", ["$scope", "$routeParams", "$location", "quickbooksOauthCallbackService",
  function ($scope, $routeParams, $location, quickbooksOauthCallbackService) {
    $scope.status = "Saving Quickbooks Account Information...Please Wait..."

    var quickbooksAccountId = 1;

    quickbooksOauthCallbackService.update({id: quickbooksAccountId, realm_id: $routeParams.realmId, oauth_verifier: $routeParams.oauth_verifier},
      function (quickbooksAccount) {
        $.notify("Quickbooks account information saved successfully", "success");

        // Use $location.url to clear the query parameters.
        $location.url($location.path());

        // Redirect to view the account information.
        $location.path("/quickbooks-accounts/" + quickbooksAccountId);
      }, function (error) {
        $scope.status = "Failed to save Quickbooks account information"
        $.notify("Failed to save Quickbooks account information: " + error.data.error, "error");
      }
    );
  }
]);
