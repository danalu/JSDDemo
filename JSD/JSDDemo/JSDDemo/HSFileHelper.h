//
//  FileHelper.h
//  Common
//
//  Created by Dana on 13-12-28.
//
//

#import <Foundation/Foundation.h>

/**
 manage the data persistence.
 */

@interface HSFileHelper : NSObject

+ (NSString*)getDocumentDirectory;

+ (id)decodeContentFromFile:(NSString*)pFileName key:(NSString*)key;

+ (BOOL)encodeContent:(id)pContent toFile:(NSString*)pFileName key:(NSString*)key;

+ (void)createFolderIfNotExistForFile:(NSString*)pFileName;

+ (void)deletePersistenceFileForFile:(NSString*)pFileName;

+ (void)deletePersistenceFileForDirectory:(NSString*)pDirectoryPath;

+ (void)saveData:(NSData*)pData toFile:(NSString*)pFileName;

+ (NSData*)getDataWithFileName:(NSString*)pFileName;

+ (id)getValueFromUserDefaults:(NSString*)pKey;

+ (void)saveValueToUserDefaults:(id)pValue key:(NSString*)pKey;

@end
