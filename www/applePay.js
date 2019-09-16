cordova.define("cordova-plugin-apple-pay.ApplePay", function(require, exports, module) {
    var exec = require("cordova/exec");

    function ApplePay() {
        this.name = "ApplePay";
    }

    ApplePay.prototype.canAddCard = function(primaryAccountIdentifier, successCallback, errorCallback) {
        exec(successCallback, errorCallback, "ApplePay", "canAddCard", [primaryAccountIdentifier]);
    };

    ApplePay.prototype.bindCard = function(cardHolderName,
                                           primaryAccountSuffix,
                                           localizedDescription,
                                           primaryAccountIdentifier,
                                           paymentNetwork,
                                           cardId,
                                           successCallback,
                                           errorCallback) {
        exec(successCallback, errorCallback, "ApplePay", "bindCard", [
            cardHolderName,
            primaryAccountSuffix,
            localizedDescription,
            primaryAccountIdentifier,
            paymentNetwork,
            cardId
        ]);
    };

    module.exports = new ApplePay();

});
