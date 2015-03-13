//
//  CTDatabase.h
//  
//
//  Created by Chuck Toussieng.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface CTDatabase : NSObject {
	
	NSString *pathToDatabase;
	BOOL logging;
	sqlite3 *database;
}

@property (nonatomic, retain) NSString *pathToDatabase;
@property (nonatomic) BOOL logging;

- (id) initWithPath: (NSString *) filePath;
- (id) initWithFileName: (NSString *) fileName;
- (void) open;
- (void) raiseSqliteException: (NSString *) errorMessage;

- (NSArray *) executeSql:(NSString *) sql;
- (NSArray *) executeSql:(NSString *) sql withParameters: (NSArray *) parameters;
- (NSArray *) executeSql: (NSString *) sql withParameters: (NSArray *) parameters withClassForRow: (Class) rowClass;
- (NSArray *) executeSqlWithParameters:(NSString *) sql, ...;
- (NSArray *) columnNamesForStatement:(sqlite3_stmt *) statement;
- (NSArray *) columnTypesForStatement:(sqlite3_stmt *) statement;

- (void) bindArguments:(NSArray *) arguments toStatement: (sqlite3_stmt *) statement queryInfo: (NSDictionary *) queryInfo;
- (int) typeForStatement:(sqlite3_stmt *) statement column: (int) column;
- (int) columnTypeToInt:(NSString *) columnType;
//- (void) copyValuesFromStatement:(sqlite3_stmt *) statement toRow:(NSMutableDictionary *) row queryInfo: (NSDictionary *) queryInfo columnTypes:(NSArray *) columnTypes columnNames: (NSArray *) columnNames;
- (void) copyValuesFromStatement: (sqlite3_stmt *) statement toRow: (id) row queryInfo: (NSDictionary *) queryInfo columnTypes: (NSArray *) columnTypes columnNames: (NSArray *) columnNames;
- (id) valueFromStatement:(sqlite3_stmt *) statement column: (int) column queryInfo: (NSDictionary *) queryInfo columnTypes: (NSArray *) columnTypes;

- (void) beginTransaction;
- (void) commit;
- (void) rollback;
- (NSArray *) tables;
- (NSArray *) tableNames;
- (NSArray *) columnsForTableName: (NSString *) tableName;
- (NSUInteger) lastInsertRowId;


@end
