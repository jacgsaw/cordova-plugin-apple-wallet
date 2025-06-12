// HP2CordovaPlugin.h

#import <Cordova/CDV.h>

NS_ASSUME_NONNULL_BEGIN

@interface HP2CordovaPlugin : CDVPlugin

- (void)init:(CDVInvokedUrlCommand*)command;
- (void)updateDataBase:(CDVInvokedUrlCommand*)command;
- (void)isAvailable:(CDVInvokedUrlCommand*)command;
- (void)getVersion:(CDVInvokedUrlCommand*)command;
- (void)isAvailableForCard:(CDVInvokedUrlCommand*)command;
- (void)getCards:(CDVInvokedUrlCommand*)command;
- (void)executeProvisioning:(CDVInvokedUrlCommand*)command;
- (void)executeProvisioningOfEncryptedCard:(CDVInvokedUrlCommand*)command;

@end

NS_ASSUME_NONNULL_END
