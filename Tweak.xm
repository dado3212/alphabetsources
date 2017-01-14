#import <UIKit/UIKit.h>
#import <substrate.h>

@interface Database : NSObject
-(id)sources;
@end

@interface Source : NSObject
-(id)name;
@end

NSMutableDictionary *sources;
NSArray *sourceTitles;

// Maps from the new tableView indexes to the old one so the standard Cydia functions work
static NSIndexPath* remapping(NSIndexPath *newPath) {
  if ([newPath section] == 0 && [newPath row] == 0) {
    return newPath;
  } else {
    int num = 0;
    for (int i = 0; i < [sourceTitles count]; i++) {
      if (i < [newPath section] - 1) {
        num += [[sources objectForKey:[sourceTitles objectAtIndex:i]] count];
      }
    }
    num += [newPath row];
    return [NSIndexPath indexPathForRow:num inSection:1];
  }
}

%hook SourcesController
-(void)reloadData {
  %orig;

  Database *globalDatabase = MSHookIvar<Database *>(self, "database_");

  sources = [[NSMutableDictionary alloc] init];

  // For each source
  for (Source *source in [globalDatabase sources]) {
    // Get the first letter of the source name as the key (uppercase)
    NSString *key = [[[source name] substringToIndex:1] uppercaseString];

    // Update array for that key to include source
    NSMutableArray *array = [[sources objectForKey:key] mutableCopy];
    if (array == nil) {
      array = [[NSMutableArray alloc] init];
    }
    [array addObject:source];
    // Make sure they're alphabetically sorted
    [sources setObject:[array sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
      NSString *first = [(Source*)a name];
      NSString *second = [(Source*)b name];
      return [first localizedCaseInsensitiveCompare:second];
    }] forKey:key];
  }
  sourceTitles = [[sources allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

  // Reload the table so that the sections/rowCounts update
  [MSHookIvar<UITableView *>(self, "list_") reloadData];
}

// Sources + 1 for the "All Sources"
-(int)numberOfSectionsInTableView:(id)arg1 {
  return [sourceTitles count] + 1;
}

-(id)tableView:(id)arg1 titleForHeaderInSection:(int)arg2 {
  if (arg2 == 0) {
    return @"";
  } else {
    return [sourceTitles objectAtIndex:arg2-1];
  }
}

-(int)tableView:(id)arg1 numberOfRowsInSection:(int)arg2 {
  if (arg2 == 0) {
    return 1;
  } else {
    return [[sources objectForKey:[sourceTitles objectAtIndex:arg2-1]] count];
  }
}

-(id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 {
  return %orig(arg1, remapping(arg2));
}

-(void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 {
  %orig(arg1, remapping(arg2));
}

-(char)tableView:(id)arg1 canEditRowAtIndexPath:(id)arg2 {
  return %orig(arg1, remapping(arg2));
}

-(void)tableView:(id)arg1 didEndEditingRowAtIndexPath:(id)arg2 {
  %orig(arg1, remapping(arg2));
}

-(void)tableView:(id)arg1 commitEditingStyle:(int)arg2 forRowAtIndexPath:(id)arg3 {
  %orig(arg1, arg2, remapping(arg3));
}

%new
- (id)sectionIndexTitlesForTableView:(id)tableView {
  return sourceTitles;
}
%end