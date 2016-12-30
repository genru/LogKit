//
//  LCLogFilesTableViewController.m
//  Logcat
//
//  Created by Chris Kap on 12/9/16.
//  Copyright © 2016 Chris Kap. All rights reserved.
//

#import "LCLogFilesTableViewController.h"
#import "LCWebViewController.h"
#import "Logcat.h"

@interface LCLogFilesTableViewController ()
@property (nonatomic, strong) NSArray* files;
@end

static NSString* kCellIdentity = @"file_cell";

@implementation LCLogFilesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"logs";
    if (self.navigationController.viewControllers.count==1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismissSelf:)];
    }

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentity];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dismissSelf:(id) sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) loadData {
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
    NSString* logDirectory = [docsDir stringByAppendingString:@"/Log"];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator* enumerator = [fileManager enumeratorAtPath:logDirectory];
//    [enumerator skipDescendants];
    self.files = [enumerator.allObjects arrayByAddingObjectsFromArray:[[Logcat sharedInstance].logFileManager sortedLogFileNames]];
//    self.files = [[Logcat sharedInstance].logFileManager sortedLogFileNames];
}

- (void) deleteFile:(NSIndexPath*) indexPath error:( NSError  * _Nullable * _Nullable) err {
    NSString* path = [NSString stringWithFormat:@"%@/%@/%@/%@", NSHomeDirectory(), @"Documents", @"Log", self.files[indexPath.row]];
    [[NSFileManager defaultManager] removeItemAtPath:path error:err];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.files.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentity forIndexPath:indexPath];
    // Configure the cell...
    NSString* name = self.files[indexPath.row];
    cell.textLabel.text = name;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSError* err = nil;
        [self deleteFile:indexPath error:&err];
        if(err) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error" message:err.userInfo.description preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        [self loadData];
        [tableView reloadData];
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}



#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    LCWebViewController *detailViewController = [[LCWebViewController alloc] init];
    NSString* fileName = self.files[indexPath.row];
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:  @"Documents"];
    fileName = [NSString stringWithFormat:@"%@/%@/%@", docsDir, @"Log", self.files[indexPath.row]];
    NSURL* url = [NSURL fileURLWithPath:fileName];
    detailViewController.fileUrl = url;
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
