
#import <UIKit/UIKit.h>

@interface PostController:
	UITableViewController <UITextFieldDelegate> {
		UITextField *activeTextField;
	}
	- (id) init;
	- (void) dealloc;
	- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
	- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
	- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
	- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
