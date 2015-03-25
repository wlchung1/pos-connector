"use strict";

var appDirectives = angular.module("posConnectorAppDirectives", []);

appDirectives.directive("backButton", ["$window", function($window) {
  return {
    restrict: "A",
    link: function (scope, element, attrs) {
      element.bind("click", function () {
        $window.history.back();
      });
    }
  }
}]);
