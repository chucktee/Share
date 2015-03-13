//
//  CTDatabaseModel.h
//  
//
//  Created by Chuck Toussieng.
//  Copyright 2009. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CTDatabase;

@interface CTDatabaseModel : NSObject {

	NSUInteger primaryKey;
	BOOL savedInDatabase;
}

@property (nonatomic) NSUInteger primaryKey;
@property (nonatomic) BOOL savedInDatabase;

+ (void) assertDatabaseExists;
+ (void) setDatabase: (CTDatabase *) newDatabase;
+ (CTDatabase *) database;
+ (NSString *) tableName;
+ (NSArray *) findWithSql: (NSString *) sql withParameters: (NSArray *) parameters;
+ (NSArray *) findWithSqlWithParameters: (NSString *) sql, ...;
+ (NSArray *) findWithSql: (NSString *) sql;
+ (NSArray *) findByColumn: (NSString *) column value: (id) value;
+ (NSArray *) findByColumn: (NSString *) column unsignedIntegerValue:(NSUInteger) value;
+ (NSArray *) findByColumn: (NSString *) column integerValue: (NSInteger) value;
+ (NSArray *) findByColumn: (NSString *) column doubleValue: (double) value;
+ (id) find: (NSUInteger) primaryKey;
+ (NSArray *) findAll;

- (NSArray *) columns;
- (NSArray *) propertyValues;
- (void) beforeSave;
- (void) save;
- (void) insert;
- (void) update;
- (void) beforeDelete;
- (void) delete;

- (void) testProperties;

@end
