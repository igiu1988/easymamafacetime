
@interface PhoneRootViewController : UIViewController
- (UIView *)easyMamaView;
- (void)setEasyMamaView:(UIView *)view;
- (void)setupEasyMamaView;
@end

%hook PhoneRootViewController

%new
- (UIView *)easyMamaView{

	UIView *view = objc_getAssociatedObject(self, @selector(easyMamaView));
	if (!view)
	{
		UIView *contentView = [self valueForKey:@"contentView"];

		view = [[UIView alloc] initWithFrame:[contentView bounds]];
		view.backgroundColor = [UIColor whiteColor];

		UIButton *largeButton  = [UIButton buttonWithType:UIButtonTypeCustom];
	    [largeButton setTitle:@"打给汪洋" forState:UIControlStateNormal];
	    largeButton.frame = CGRectMake(0, 0, [view bounds].size.width, [view bounds].size.height - 20);
	    largeButton.titleLabel.font = [UIFont systemFontOfSize:65];
	    [largeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
	    largeButton.backgroundColor = [UIColor whiteColor];
	    [largeButton addTarget:self action:@selector(easyMamaCall) forControlEvents:UIControlEventTouchDown];
	    [view addSubview:largeButton];

	    UIView *invisibleView = [[UIView alloc] initWithFrame:CGRectMake(0, view.bounds.size.height - 20, view.bounds.size.width, 20)];
	    [view addSubview:invisibleView];
	    invisibleView.backgroundColor = [UIColor whiteColor];
	    invisibleView.userInteractionEnabled = YES;
	    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEasyMamaView)];
	    tap.numberOfTapsRequired = 10;
	    [invisibleView addGestureRecognizer:tap];

	    [self setEasyMamaView:view];

	    // 调试发现 contentView 会有一个或者两个 subview。0 位置的永远是 tabBarController 所在的 view（其实是_UIBackdropView，并不是tabBarController.view），最后一个永远是登录窗口。 所以用这个投机取巧的方法，添加在 index 1 的位置，保证了可以覆盖 tabBarController 显示的内容，但又在登录窗口的下面
		[contentView insertSubview:view atIndex:1];
		view.hidden = YES;
	}
 	return view;

}

%new
- (void)setEasyMamaView:(UIView *)view{
	objc_setAssociatedObject(self, @selector(easyMamaView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/*
	经过调试，showFaceTimeFirstRunViewIfNeeded 会在 viewDidLoad 之后执行。所以如果是要显示登录页，那么在执行完 showFaceTimeFirstRunViewIfNeeded 之后，contentView 的 subviews 肯定是 3 个
*/
- (void)viewDidLoad{
	%orig;

	UIView *contentView = [self valueForKey:@"contentView"];
	if (contentView.subviews.count == 1) {		
		self.easyMamaView.hidden = NO;
	}
}

- (void)showFaceTimeFirstRunViewIfNeeded{
	%orig;

	UIView *contentView = [self valueForKey:@"contentView"];
	if (contentView.subviews.count == 3) {
		self.easyMamaView.hidden = YES;
	}
}

// 在登录完成时会调用这个方法
- (void)firstRunControllerDidFinish:(id)arg1 finished:(BOOL)arg2{
	%orig;

	self.easyMamaView.hidden = NO;
}

%new
- (void)hideEasyMamaView{
	self.easyMamaView.hidden = YES;	
}


%new
- (void)easyMamaCall{
    UITabBarController *tabController = [self valueForKey:@"tabBarViewController"];
    id favController = ((UINavigationController *)(tabController.viewControllers[0])).viewControllers[0];
    UITableView *favTable = [favController valueForKey:@"table"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [favTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:0];
	[favController tableView:favTable didSelectRowAtIndexPath:indexPath];      
}


%end

