var exec = require('cordova/exec');

exports.init = function (instCode, groupID, success, error) {
    exec(success, error, 'HP2CordovaPlugin', 'init', [instCode, groupID]);
};
exports.updateDataBase = function (instCode, cardDataList, success, error) {
    exec(success, error, 'HP2CordovaPlugin', 'updateDataBase', [instCode, cardDataList]);
};
exports.getVersion = function (instCode, success, error) {
    exec(success, error, 'HP2CordovaPlugin', 'getVersion', [instCode]);
};
exports.isAvailable = function (instCode, success, error) {
    exec(success, error, 'HP2CordovaPlugin', 'isAvailable', [instCode]);
};
exports.isAvailableForCard = function (instCode, panId, success, error) {
    exec(success, error, 'HP2CordovaPlugin', 'isAvailableForCard', [instCode, panId]);
};
exports.getCards = function (instCode, success, error) {
    exec(success, error, 'HP2CordovaPlugin', 'getCards', [instCode]);
};
exports.executeProvisioning = function (instCode, cardholderName, panSuffix, cardDescr, panId, pnp, pushRecId, success, error) {
    exec(success, error, 'HP2CordovaPlugin', 'executeProvisioning', [instCode, cardholderName, panSuffix, cardDescr, panId, pnp, pushRecId]);
};
exports.executeProvisioningOfEncryptedCard = function (instCode, cardholderName, panSuffix, cardDescr, panId, pnp, encCard, success, error) {
    exec(success, error, 'HP2CordovaPlugin', 'executeProvisioningOfEncryptedCard', [instCode, cardholderName, panSuffix, cardDescr, panId, pnp, encCard]);
};
exports.saveDataToKeychain = function (data, dkey, success, error) {
    exec(success, error, 'HP2CordovaPlugin', 'saveDataToKeychain', [data, dkey]);
};
