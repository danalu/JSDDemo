//
//  FileHelper.m
//  Common
//
//  Created by Dana on 13-12-28.
//
//

#import "HSFileHelper.h"


@implementation HSFileHelper

+ (NSString*)getDocumentDirectory
{
	NSArray* documentsDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (documentsDirectories.count > 0) {
		NSString *documentsDirectory = [documentsDirectories objectAtIndex:0];
		return documentsDirectory;
	}
	return nil;
}

+ (id)decodeContentFromFile:(NSString*)pFileName key:(NSString*)key
{
    NSData* data = [NSData dataWithContentsOfFile:pFileName];
    
    if ([data length] <= 0) {
        return nil;
    }
    
    NSKeyedUnarchiver* unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    id content = [unArchiver decodeObjectForKey:key];

    [unArchiver finishDecoding];
    
    return content;
}

+ (BOOL)encodeContent:(id)pContent toFile:(NSString*)pFileName key:(NSString*)key
{
    BOOL result;
    
    NSMutableData* data = [NSMutableData data];
    NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];

    [archiver encodeObject:pContent forKey:key];
    [archiver finishEncoding];    

    [HSFileHelper createFolderIfNotExistForFile:pFileName];
    result = [data writeToFile:pFileName atomically:YES];

    return result;
}

+ (void)deletePersistenceFileForFile:(NSString*)pFileName {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:pFileName]) {
        [fileManager removeItemAtPath:pFileName error:nil];
    }
}

+ (void)deletePersistenceFileForDirectory:(NSString*)pDirectoryPath {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    BOOL isDirectoryPath;
    if ([fileManager fileExistsAtPath:pDirectoryPath isDirectory:&isDirectoryPath]) {
        [fileManager removeItemAtPath:pDirectoryPath error:nil];
    }
}

+ (void)createFolderIfNotExistForFile:(NSString*)pFileName
{
    NSString* fileFolder = [pFileName stringByDeletingLastPathComponent];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:fileFolder]) {
            [fileManager createDirectoryAtPath:fileFolder
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
    }

}

+ (void)saveData:(NSData*)pData toFile:(NSString*)pFileName {
    [HSFileHelper createFolderIfNotExistForFile:pFileName];
    
    [pData writeToFile:pFileName atomically:YES];
}

+ (NSData*)getDataWithFileName:(NSString*)pFileName {
    return [NSData dataWithContentsOfFile:pFileName];
}

+ (id)getValueFromUserDefaults:(NSString*)pKey {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:pKey];
}

+ (void)saveValueToUserDefaults:(id)pValue key:(NSString*)pKey {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:pValue forKey:pKey];
    [userDefaults synchronize];
}

@end
