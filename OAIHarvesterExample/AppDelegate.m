/*********************************************************************************************
 
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
 
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/.
 
**********************************************************************************************/

#import "AppDelegate.h"

#import "IdentifyViewController.h"

AppDelegate* oaiApp;

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [_viewController release];
    
    [_managedObjectContext release];
    [_managedObjectModel release];
    [_persistentStoreCoordinator release];
    
    [super dealloc];
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    oaiApp = self;
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[IdentifyViewController alloc] initWithNibName:@"IdentifyView" bundle:nil] autorelease];
    CustonNavigationController *navController = [[CustonNavigationController alloc] initWithRootViewController:self.viewController];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    
    
    /*OAIHarvester *harvester = [[OAIHarvester alloc] initWithBaseURL:@"http://helios-eie.ekt.gr/heliosoa-oai/request"];
    //OAIHarvester *harvester = [[OAIHarvester alloc] initWithBaseURL:@"http://www.collectconcept.de/oai.php"];
    harvester.metadataPrefix = @"oai_dc";
    NSError *error = nil;
    
    NSLog(@"repo name = %@", harvester.identify.repositoryName);
    NSLog(@"baseURL = %@", harvester.identify.baseURL);
    NSLog(@"granularity = %@", harvester.identify.granularity);
    for (NSString *email in harvester.identify.adminEmails){
        NSLog(@"admin email = %@", email);
    }
    for (NSString *compression in harvester.identify.compressions){
        NSLog(@"compression = %@", compression);
    }
    
    NSLog(@"-----------------------");
    
    for (MetadataFormat *format in harvester.metadataFormats){
        NSLog(@"%@: %@", format.prefix, format.namespce);
    }
    
    NSLog(@"-----------------------");
    
    for (Set *set in harvester.sets){
        NSLog(@"%@: %@", set.fullSpec, set.name);
    }
    
    harvester.setSpec = ((Set *)[harvester.sets objectAtIndex:0]).fullSpec;
    
    NSLog(@"-----------------------");
    
    NSArray *records = [harvester listRecordsWithResumptionToken:nil error:&error];
    if (error){
        NSLog(@"error = %@", [error localizedDescription]);
    }
    else {
        if ([harvester hasNextRecords]){
            NSArray *records2 = [harvester getNextRecordsWithError:&error];
            
            
            Record *record = [records2 objectAtIndex:0];
            NSLog(@"identifier = %@", record.recordHeader.identifier);
            NSLog(@"status = %i", record.recordHeader.status);
            NSLog(@"datestamp = %@", record.recordHeader.datestamp);
            for (NSString *set in record.recordHeader.setSpecs){
                NSLog(@"set = %@", set);
            }
            NSLog(@"namespace: %@", record.recordMetadata.namespce);
            NSLog(@"schemaLoacation: %@", record.recordMetadata.schemaLocation);
            for (MetadataElement *metadata in record.recordMetadata.metadataElements){
                NSLog(@"%@: %@", metadata.name, metadata.value);
            }
        }
    }
    
    NSArray *identifiers = [harvester listIdentifiersWithResumptionToken:nil error:&error];
    if (error){
        NSLog(@"error = %@", [error localizedDescription]);
    }
    else {
        if ([harvester hasNextIdentifiers]){
            NSArray *identifiers = [harvester getNextIdentifiersWithError:&error];
            Identifier *identfier = [identifiers objectAtIndex:0];
            NSLog(@"identifier = %@", identfier.identifier);
            Record *record = [harvester getRecordWithIdentifier:identfier.identifier error:&error];
            NSLog(@"identifier = %@", record.recordHeader.identifier);
            NSLog(@"status = %i", record.recordHeader.status);
            NSLog(@"datestamp = %@", record.recordHeader.datestamp);
            for (NSString *set in record.recordHeader.setSpecs){
                NSLog(@"set = %@", set);
            }
            NSLog(@"namespace: %@", record.recordMetadata.namespce);
            NSLog(@"schemaLoacation: %@", record.recordMetadata.schemaLocation);
            for (MetadataElement *metadata in record.recordMetadata.metadataElements){
                NSLog(@"%@: %@", metadata.name, metadata.value);
            }

        }
    }*/
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) saveContextWithError:(NSError **)error
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error2 = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error2]) {
            //*error = [[[FactoryError alloc] initWithDomain:@"" code:0 userInfo:nil] autorelease];
        }
    }
    else {
        //*error = [[[FactoryError alloc] initWithDomain:@"" code:0 userInfo:nil] autorelease];
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"oai" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"oai.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
