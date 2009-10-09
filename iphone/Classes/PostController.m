
#import "AppDelegate.h"
#import "PostController.h"

@implementation PostController

- (id) init {
	self = [ super initWithStyle: UITableViewStyleGrouped ];
	if (self != nil) {
		self.title = @"Settings";
	}
	return self;
}

- (void) loadView {
	[ super loadView ];
}

- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	[ super didReceiveMemoryWarning ];
}

- (void)dealloc {
	[ super dealloc ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
		case(0):
			return 4;
			break;
		case(1):
			return 3;
			break;
		case(2):
			return 1;
			break;
    }
	
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
		case(0):
			return @"Game Settings";
			break;
		case(1):
			return @"Advanced Settings";
			break;
		case(2):
			return @"About";
			break;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [ NSString stringWithFormat: @"%d:%d", [ indexPath indexAtPosition: 0 ], [ indexPath indexAtPosition:1 ]];
	
    UITableViewCell *cell = [ tableView dequeueReusableCellWithIdentifier: CellIdentifier];
	
    if (cell == nil) {
		cell = [ [ [ UITableViewCell alloc ] initWithFrame: CGRectZero reuseIdentifier: CellIdentifier] autorelease ];
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		switch ([ indexPath indexAtPosition: 0]) {
			case(0):
				switch([ indexPath indexAtPosition: 1]) {
					case(0):
					{
						UISlider *musicVolumeControl = [ [ UISlider alloc ] initWithFrame: CGRectMake(170, 0, 125, 50) ];
						musicVolumeControl.minimumValue = 0.0;
						musicVolumeControl.maximumValue = 10.0;
						musicVolumeControl.tag = 0;
						musicVolumeControl.value = 3.5;
						musicVolumeControl.continuous = YES;
						[musicVolumeControl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
						[ cell addSubview: musicVolumeControl ];
						//cell.text = @"Music Volume";
						[cell.textLabel setText:@"Music Volume"];
						[ musicVolumeControl release ];
					}
						break;
					case(1):
					{
						UISlider *gameVolumeControl = [ [ UISlider alloc ] initWithFrame: CGRectMake(170, 0, 125, 50) ];
						gameVolumeControl.minimumValue = 0.0;
						gameVolumeControl.maximumValue = 10.0;
						gameVolumeControl.tag = 1;
						gameVolumeControl.value = 3.5;
						gameVolumeControl.continuous = YES;
						[gameVolumeControl addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
						[ cell addSubview: gameVolumeControl ];
						//cell.text = @"Game Volume";
						[cell.textLabel setText:@"Game Volume"];
						[ gameVolumeControl release ];
					}
						break;
					case(2):
					{
						UISegmentedControl *difficultyControl = [ [ UISegmentedControl alloc ] initWithFrame: CGRectMake(170, 5, 125, 35) ];
						[ difficultyControl insertSegmentWithTitle: @"Easy" atIndex: 0 animated: NO ];
						[ difficultyControl insertSegmentWithTitle: @"Hard" atIndex: 1 animated: NO ];
						difficultyControl.selectedSegmentIndex = 0;
						difficultyControl.tag = 2;
						[difficultyControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
						[ cell addSubview: difficultyControl ];
						//cell.text = @"Difficulty";
						[cell.textLabel setText:@"Difficulty"];
						[difficultyControl release];
					}
						break;
					case(3):
					{
						UISegmentedControl *actionControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects: @"Check", @"Search", @"Tools", nil]];
						actionControl.frame = CGRectMake(145, 5, 150, 35);
						actionControl.selectedSegmentIndex = 1;
						actionControl.tag = 3;
						[actionControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
						actionControl.segmentedControlStyle = UISegmentedControlStyleBar;
						
						[cell addSubview:actionControl];
						//cell.text = @"Actions";
						[cell.textLabel setText:@"Actions"];
						[actionControl release];
					}
						break;
				}
				break;
			case(1):
				switch ([ indexPath indexAtPosition: 1 ]) {
					case(0):
					{
						UITextField *playerTextField = [ [ UITextField alloc ] initWithFrame: CGRectMake(150, 10, 145, 28) ];
						playerTextField.adjustsFontSizeToFitWidth = YES;
						playerTextField.textColor = [UIColor blackColor];
						playerTextField.font = [UIFont systemFontOfSize:18.0];
						playerTextField.placeholder = @"";
						playerTextField.backgroundColor = [UIColor whiteColor];
						playerTextField.borderStyle = UITextBorderStyleLine;
						playerTextField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
						playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
						playerTextField.textAlignment = UITextAlignmentRight;
						playerTextField.keyboardType = UIKeyboardTypeDefault; // use the default type input method (entire keyboard)
						playerTextField.returnKeyType = UIReturnKeyDone;
						playerTextField.tag = 0;
						playerTextField.delegate = self;
						
						playerTextField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
						playerTextField.text = @"";
						[ playerTextField setEnabled: YES ];
						[ cell addSubview: playerTextField ];
						//cell.text = @"Player";
						[cell.textLabel setText:@"Player"];
						[playerTextField release];
					}
						break;
					case(1):
					{
						UISwitch *resetControl = [ [ UISwitch alloc ] initWithFrame: CGRectMake(200, 10, 0, 0) ];
						resetControl.on = YES;
						resetControl.tag = 1;
						[resetControl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
						[ cell addSubview: resetControl ];
						//cell.text = @"Reset";
						[cell.textLabel setText:@"Reset"];
						[resetControl release];
					}
						break;
					case(2):
					{
						UISwitch *debugControl = [ [ UISwitch alloc ] initWithFrame: CGRectMake(200, 10, 0, 0) ];
						debugControl.on = NO;
						debugControl.tag = 2;
						[debugControl addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
						[ cell addSubview: debugControl ];
						//cell.text = @"Debug";
						[cell.textLabel setText:@"Debug"];
						[debugControl release];
					}
						break;
				}
				break;
			case(2):
			{
				UITextField *versionControl = [ [ UITextField alloc ] initWithFrame: CGRectMake(170, 10, 125, 38) ];
				versionControl.text = @"1.0.0 Rev. B";
				[ cell addSubview: versionControl ];
				
				[ versionControl setEnabled: YES ];
				versionControl.tag = 2;
				versionControl.delegate = self;
				//cell.text = @"Version";
				[cell.textLabel setText:@"Version"];
				[versionControl release];
			}
				break;
		}
    }
	
    return cell;
}

- (void)segmentAction:(UISegmentedControl*)sender {
    if ([activeTextField canResignFirstResponder])
		[activeTextField resignFirstResponder];
	
    NSLog(@"segmentAction: sender = %d, segment = %d", [sender tag], [sender selectedSegmentIndex]);
}

- (void)sliderAction:(UISlider*)sender {
    if ([activeTextField canResignFirstResponder])
		[activeTextField resignFirstResponder];
	NSLog(@"sliderAction: sender = %d, value = %.1f", [sender tag], [sender value]);
}

- (void)switchAction:(UISwitch*)sender {
    if ([activeTextField canResignFirstResponder])
		[activeTextField resignFirstResponder];
    NSLog(@"switchAction: sender = %d, isOn %d", [sender tag], [sender isOn]);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    activeTextField = textField;
    NSLog(@"textFieldShouldBeginEditing: sender = %d, %@", [textField tag], [textField text]);
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing: sender = %d, %@", [textField tag], [textField text]);

	AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	[app showGlobe];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn: sender = %d, %@", [textField tag], [textField text]);
    activeTextField = nil;
    [textField resignFirstResponder];
    return YES;
}


@end
