
#import <SenTestingKit/SenTestingKit.h>
#import "Action.h"

@interface FakeAction : Action
@property (nonatomic, assign) BOOL showHelp;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *numbers;
@end

@implementation FakeAction
+ (NSArray *)options {
  // Some bogus actions to help exercise the plumbing.
  return @[
           [Action actionOptionWithName:@"help" aliases:@[@"h"] description:@"show help" setFlag:@selector(setShowHelp:)],
           [Action actionOptionWithName:@"name" aliases:nil description:@"set name" paramName:@"NAME" mapTo:@selector(setName:)],
           [Action actionOptionWithMatcher:^(NSString *str){
             return (BOOL)(([str intValue] > 0) ? YES : NO);
           }
                               description:@"a number"
                                 paramName:@"NUMBER"
                                     mapTo:@selector(addNumber:)],
           ];
}

- (id)init
{
  if (self = [super init]) {
    self.numbers = [NSMutableArray array];
  }
  return self;
}

- (void)addNumber:(NSString *)number
{
  [self.numbers addObject:@([number intValue])];
}

@end

@interface ActionTests : SenTestCase
@end

@implementation ActionTests

- (void)testActionUsage
{
  assertThat([FakeAction actionUsage],
             equalTo(@"    -help                    show help\n"
                     @"    -name NAME               set name\n"
                     @"    NUMBER                   a number\n"));
}

- (void)testFlagOptionSetsFlag
{
  NSMutableArray *arguments = [NSMutableArray arrayWithArray:@[
                               @"-help",
                               ]];
  FakeAction *action = [[[FakeAction alloc] init] autorelease];
  assertThatBool(action.showHelp, equalToBool(NO));
  
  NSString *errorMessage = nil;
  NSUInteger consumed = [action consumeArguments:arguments errorMessage:&errorMessage];
  assertThat(errorMessage, equalTo(nil));

  assertThatInteger(consumed, equalToInteger(1));
  assertThatInteger(arguments.count, equalToInteger(0));
  assertThatBool(action.showHelp, equalToBool(YES));
}

- (void)testAliasesAreRespected
{
  NSMutableArray *arguments = [NSMutableArray arrayWithArray:@[
                               @"-h",
                               ]];
  FakeAction *action = [[[FakeAction alloc] init] autorelease];
  assertThatBool(action.showHelp, equalToBool(NO));
  
  NSString *errorMessage = nil;
  NSUInteger consumed = [action consumeArguments:arguments errorMessage:&errorMessage];
  assertThat(errorMessage, equalTo(nil));

  assertThatInteger(consumed, equalToInteger(1));
  assertThatInteger(arguments.count, equalToInteger(0));
  assertThatBool(action.showHelp, equalToBool(YES));
}

- (void)testMapOptionSetsValue
{
  NSMutableArray *arguments = [NSMutableArray arrayWithArray:@[
                               @"-name", @"SomeName",
                               ]];
  FakeAction *action = [[[FakeAction alloc] init] autorelease];

  NSString *errorMessage = nil;
  NSUInteger consumed = [action consumeArguments:arguments errorMessage:&errorMessage];
  assertThat(errorMessage, equalTo(nil));

  assertThatInteger(consumed, equalToInteger(2));
  assertThatInteger(arguments.count, equalToInteger(0));
  assertThat(action.name, equalTo(@"SomeName"));
}

- (void)testMatcherOptionSetsValue
{
  NSMutableArray *arguments = [NSMutableArray arrayWithArray:@[
                               @"1", @"2",
                               ]];
  FakeAction *action = [[[FakeAction alloc] init] autorelease];

  NSString *errorMessage = nil;
  NSUInteger consumed = [action consumeArguments:arguments errorMessage:&errorMessage];
  assertThat(errorMessage, equalTo(nil));

  assertThatInteger(consumed, equalToInteger(2));
  assertThatInteger(arguments.count, equalToInteger(0));
  assertThat(action.numbers, equalTo(@[@1, @2]));
}

@end