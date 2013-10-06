//
//  PhotoBoxFetchedResultsController.h
//  PhotoBox
//
//  Created by Nico Prananta on 10/6/13.
//  Copyright (c) 2013 Touches. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface PhotoBoxFetchedResultsController : NSFetchedResultsController

@property (nonatomic, assign) Class objectClass;

@end
