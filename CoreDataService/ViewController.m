//
//  ViewController.m
//  CoreDataService
//
//  Created by Ben Ford on 7/30/13.
//  Copyright (c) 2013 Ben Ford. All rights reserved.
//

#import "ViewController.h"
#import "CoreDataService.h"
#import "AllManagedObjects.h"

@interface ViewController ()

@end

@implementation ViewController
{
    NSTimer *timer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    Person *person = [CoreDataService fetchEntity:NSStringFromClass([Person class]) byAttribute:@"name" withValue:@"Bob"];

    if (person == nil) {
        person = [CoreDataService makeObjectWithEntityName:NSStringFromClass([Person class])];
        person.name = @"Bob";
        [CoreDataService save];
    }

    timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(checkForRecord:) userInfo:nil repeats:NO];
}

- (void)checkForRecord:(NSTimer *)timer
{
    Person *person = [CoreDataService fetchEntity:NSStringFromClass([Person class]) byAttribute:@"name" withValue:@"Bob"];
    NSLog(@"Person: %@", person);

    timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(checkForRecord:) userInfo:nil repeats:NO];
}
@end
