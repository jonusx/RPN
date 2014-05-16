//
//  MRCViewController.m
//  polishMath
//
//  Created by mathew cruz on 5/15/14.
//  Copyright (c) 2014 mathew cruz. All rights reserved.
//

#import "MRCViewController.h"
#import "MRCPolishCalculator.h"

@interface MRCViewController ()
@property (nonatomic, strong) NSArray *answers;
@end

@implementation MRCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *results = [NSMutableArray new];
    NSArray *calculations = [self arrayToCalculate];
    for (NSString *calculation in calculations) {
        [results addObject:[self stringResultFromString:calculation]];
    }
    
    self.answers = [NSArray arrayWithArray:results];
}

- (NSString *)stringResultFromString:(NSString *)string {
    NSError *error;
    NSNumber *result = [MRCPolishCalculator calculateFromString:string error:&error];
    NSLog(@"%@ = %@ , %@", string, result, error);
    return (!error) ? [NSString stringWithFormat:@"%@ = %@", string, result] : [NSString stringWithFormat:@"%@ = ERROR see console", string] ;
}

//Add more strings to calculate here
- (NSArray *)arrayToCalculate {
    return @[@"1 2 +",
             @"4 2 /",
             @"2 3 4 + *",
             @"3 4 + 5 6 + *",
             @"13 4 -", @"1 +",
             @"a b +",
             @"1 6 8 +"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.answers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resultCell" forIndexPath:indexPath];
    cell.textLabel.text = self.answers[indexPath.row];
    return cell;
}

@end
