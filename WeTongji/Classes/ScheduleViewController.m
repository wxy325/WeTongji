//
//  ScheduleViewController.m
//  WeTongji
//
//  Created by 紫川 王 on 12-4-8.
//  Copyright (c) 2012年 Tongji Apple Club. All rights reserved.
//

#import "ScheduleViewController.h"
#import "NSUserDefaults+Addition.h"
#import "ScheduleWeekViewController.h"
#import "ScheduleMonthViewController.h"
#import "Course+Addition.h"
#import "Activity+Addition.h"
#import "WTClient.h"
#import "NSString+Addition.h"
#import "ActivityDetailViewController.h"
#import "CourseDetailViewController.h"
#import "NSNotificationCenter+Addition.h"

typedef enum {
    DayTabBarViewController,
    WeekTabBarViewController,
    MonthTabBarViewController,
} TabBarViewControllerName;

@interface ScheduleViewController ()

@property (nonatomic, strong) ScheduleDayTableViewController *dayViewController;
@property (nonatomic, strong) ScheduleWeekViewController *weekViewController;
@property (nonatomic, strong) ScheduleMonthViewController *monthViewController;
@property (nonatomic, assign) TabBarViewControllerName currentTabBarSubViewControllerName;

@end

@implementation ScheduleViewController

@synthesize dayButton = _dayButton;
@synthesize weekButton = _weekButton;
@synthesize monthButton = _monthButton;
@synthesize todayButton = _todayButton;
@synthesize tabBarBgImageView = _tabBarBgImageView;
@synthesize tabBarSeperatorImageView = _tabBarSeperatorImageView;
@synthesize tabBarView = _tabBarView;

@synthesize dayViewController = _dayViewController;
@synthesize weekViewController = _weekViewController;
@synthesize monthViewController = _monthViewController;
@synthesize currentTabBarSubViewControllerName = _currentTabBarSubViewControllerName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureNavBar];
    [self configureTabBar];
    [self configureTabBarUIStyle];
    [self configureDayTabBarViewController];
    [self configureCourseData];
    [self configureScheduleData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.todayButton = nil;
    self.dayButton = nil;
    self.weekButton = nil;
    self.monthButton = nil;
    self.tabBarSeperatorImageView = nil;
    self.tabBarBgImageView = nil;
    [self clearAllTabBarSubview];
}

#pragma mark -
#pragma mark Logic methods 

- (void)configureScheduleData {
    NSDate *beginDate = [NSDate date];
    NSDate *endDate = [NSUserDefaults getCurrentSemesterEndDate];
    if([beginDate compare:endDate] != NSOrderedAscending)
        return;
    if(beginDate == nil || endDate == nil)
        return;
    WTClient *client = [WTClient client];
    [client setCompletionBlock:^(WTClient *client) {
        if(!client.hasError) {
            NSArray *activites = [client.responseData objectForKey:@"Activities"];
            for(NSDictionary *dict in activites) {
                Activity *activity = [Activity insertActivity:dict inManagedObjectContext:self.managedObjectContext];
                [self.currentUser addScheduleObject:activity];
            }
            
            NSArray *exams = [client.responseData objectForKey:@"Exams"];
            for(NSDictionary *dict in exams) {
                Course *exam = [Course insertExam:dict inManagedObjectContext:self.managedObjectContext];
                [self.currentUser addScheduleObject:exam];
            }
        }
    }];
    
    [client getScheduleWithBeginDate:beginDate endDate:endDate];
}

- (void)configureCourseData {
    BOOL hasCurrentSemesterResult = NO;
    NSDate *todayDate = [NSDate date];
    if([NSUserDefaults getCurrentSemesterEndDate] != nil && [todayDate compare:[NSUserDefaults getCurrentSemesterEndDate]] == NSOrderedAscending) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:[NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext]];
        NSPredicate *ownerPredicate = [NSPredicate predicateWithFormat:@"SELF IN %@", self.currentUser.schedule];
        NSPredicate *beginPredicate = [NSPredicate predicateWithFormat:@"begin_time > %@", [NSUserDefaults getCurrentSemesterBeginDate]];
        NSPredicate *endPredicate = [NSPredicate predicateWithFormat:@"begin_time < %@", [NSUserDefaults getCurrentSemesterEndDate]];
        [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:ownerPredicate, beginPredicate, endPredicate, nil]]];
        NSArray *result = [self.managedObjectContext executeFetchRequest:request error:NULL];
        if(result.count > 0)
            return;
        else 
            hasCurrentSemesterResult = YES;
    }
    
    self.view.userInteractionEnabled = NO;
    WTClient *client = [WTClient client];
    [client setCompletionBlock:^(WTClient *client) {
        if(!client.hasError) {
            
            NSString *semesterBeginString = [NSString stringWithFormat:@"%@", [client.responseData objectForKey:@"SchoolYearStartAt"]];
            NSDate *semesterBeginDate = [semesterBeginString convertToDate];
            NSDate *storedSemesterBeginDate = [NSUserDefaults getCurrentSemesterBeginDate];
            if(!storedSemesterBeginDate || [storedSemesterBeginDate compare:semesterBeginDate] != NSOrderedSame || hasCurrentSemesterResult) {
                
                NSFetchRequest *request = [[NSFetchRequest alloc] init];
                [request setEntity:[NSEntityDescription entityForName:@"Course" inManagedObjectContext:self.managedObjectContext]];
                [request setPredicate:[NSPredicate predicateWithFormat:@"SELF IN %@", self.currentUser.schedule]];            
                NSArray *items = [self.managedObjectContext executeFetchRequest:request error:NULL];
                for(NSManagedObject *object in items)
                    [self.managedObjectContext deleteObject:object];
                
                NSArray *courses = [client.responseData objectForKey:@"Courses"];
                
                NSInteger semesterWeekCount = [[NSString stringWithFormat:@"%@", [client.responseData objectForKey:@"SchoolYearWeekCount"]] integerValue];
                
                NSInteger semesterCourseWeekCount = [[NSString stringWithFormat:@"%@", [client.responseData objectForKey:@"SchoolYearCourseWeekCount"]] integerValue];
                
                NSDate *semesterEndDate = [semesterBeginDate dateByAddingTimeInterval:60 * 60 * 24 * 7 * semesterWeekCount];
                [NSUserDefaults setCurrentSemesterBeginTime:semesterBeginDate endTime:semesterEndDate];
                
                for(NSDictionary *dict in courses) {
                    NSSet *courses = [Course insertCourse:dict withSemesterBeginTime:semesterBeginDate semesterWeekCount:semesterCourseWeekCount owner:self.currentUser inManagedObjectContext:self.managedObjectContext];
                    [self.currentUser addSchedule:courses];
                }
                [NSNotificationCenter postChangeScheduleNotification];
                [self.dayViewController configureTodayCell];
                
                [self saveContext];
                
                [self configureScheduleData];
            }
        }
        self.view.userInteractionEnabled = YES;
    }];
    [client getCourse];
}

#pragma mark -
#pragma mark UI methods

- (void)configureTabBarUIStyle {
    UIStyle style = [NSUserDefaults getCurrentUIStyle];
    if(style == UIStyleBlackChocolate){
        self.tabBarBgImageView.image = [UIImage imageNamed:@"main_tab_bar_bg"];
        self.tabBarSeperatorImageView.image = [UIImage imageNamed:@"main_tab_bar_four_interval_seperator"];
        [self.todayButton setImage:[UIImage imageNamed:@"schedule_btn_today"] forState:UIControlStateNormal];
        [self.dayButton setImage:[UIImage imageNamed:@"schedule_btn_day"] forState:UIControlStateNormal];
        [self.weekButton setImage:[UIImage imageNamed:@"schedule_btn_week"] forState:UIControlStateNormal];
        [self.monthButton setImage:[UIImage imageNamed:@"schedule_btn_month"] forState:UIControlStateNormal];
    } else if(style == UIStyleWhiteChocolate) {
        self.tabBarBgImageView.image = [UIImage imageNamed:@"main_tab_bar_bg_white"];
        self.tabBarSeperatorImageView.image = [UIImage imageNamed:@"main_tab_bar_four_interval_seperator_white"];
        [self.todayButton setImage:[UIImage imageNamed:@"schedule_btn_today_white"] forState:UIControlStateNormal];
        [self.dayButton setImage:[UIImage imageNamed:@"schedule_btn_day_white"] forState:UIControlStateNormal];
        [self.weekButton setImage:[UIImage imageNamed:@"schedule_btn_week_white"] forState:UIControlStateNormal];
        [self.monthButton setImage:[UIImage imageNamed:@"schedule_btn_month_white"] forState:UIControlStateNormal];
    }
}

- (void)configureNavBar {
    UILabel *titleLabel = [UILabel getNavBarTitleLabel:@"日程"];
    self.navigationItem.titleView = titleLabel;
    
    UIBarButtonItem *finishButton = [UIBarButtonItem getFunctionButtonItemWithTitle:@"完成" target:self action:@selector(didClickfinishButton)];
    self.navigationItem.leftBarButtonItem = finishButton;
}

- (void)configureTabBar {
    self.todayButton.highlightedImageView.image = [UIImage imageNamed:@"schedule_btn_today_hl"];
    self.dayButton.highlightedImageView.image = [UIImage imageNamed:@"schedule_btn_day_hl"];
    self.weekButton.highlightedImageView.image = [UIImage imageNamed:@"schedule_btn_week_hl"];
    self.monthButton.highlightedImageView.image = [UIImage imageNamed:@"schedule_btn_month_hl"];
    
    [self.dayButton setSelected:YES];
}

- (void)configureDayTabBarViewController {
    if(self.dayViewController) {
        self.dayViewController.view.hidden = NO;
        return;
    }
    ScheduleDayTableViewController *vc = [[ScheduleDayTableViewController alloc] init];
    CGRect frame =  vc.view.frame;
    frame.origin = CGPointMake(0, 44);
    vc.view.frame = frame;
    self.dayViewController = vc;
    vc.delegate = self;
    [self.view insertSubview:vc.view belowSubview:self.tabBarView];
}

- (void)configureWeekTabBarViewController {
    if(self.weekViewController) {
        self.weekViewController.view.hidden = NO;
        return;
    }
    ScheduleWeekViewController *vc = [[ScheduleWeekViewController alloc] init];
    CGRect frame =  vc.view.frame;
    frame.origin = CGPointMake(0, 44);
    vc.view.frame = frame;
    self.weekViewController = vc;
    [self.view insertSubview:vc.view aboveSubview:self.tabBarView];
}

- (void)configureMonthTabBarViewController {
    if(self.monthViewController) {
        self.monthViewController.view.hidden = NO;
        return;
    }
    ScheduleMonthViewController *vc = [[ScheduleMonthViewController alloc] init];
    CGRect frame =  vc.view.frame;
    frame.origin = CGPointMake(0, 44);
    vc.view.frame = frame;
    self.monthViewController = vc;
    vc.tableViewController.delegate = self;
    [self.view insertSubview:vc.view aboveSubview:self.tabBarView];
}

- (void)clearCurrentTabBarSubViewController {
    self.dayViewController.view.hidden = YES;
    self.weekViewController.view.hidden = YES;
    self.monthViewController.view.hidden = YES;
}

- (void)clearAllTabBarSubview {
    [self.dayViewController.view removeFromSuperview];
    self.dayViewController = nil;
    [self.weekViewController.view removeFromSuperview];
    self.weekViewController = nil;
    [self.monthViewController.view removeFromSuperview];
    self.monthViewController = nil;
}

- (void)configureTabBarSubViewController:(TabBarViewControllerName)viewControllerName {
    if(self.currentTabBarSubViewControllerName == viewControllerName)
        return;
    [self clearCurrentTabBarSubViewController];
    self.currentTabBarSubViewControllerName = viewControllerName;
    if(viewControllerName == DayTabBarViewController) {
        [self configureDayTabBarViewController];
    }
    else if(viewControllerName == WeekTabBarViewController) {
        [self configureWeekTabBarViewController];
    }
    else if(viewControllerName == MonthTabBarViewController) {
        [self configureMonthTabBarViewController];
    }
}

#pragma mark -
#pragma mark IBActions 

- (void)didClickfinishButton {
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)didClickTabBarButton:(UIButton *)sender {
    NSArray *buttonArray = [NSArray arrayWithObjects:self.dayButton, self.weekButton, self.monthButton, nil];
    [buttonArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *btn = obj;
        if(btn == sender) {
            [btn setSelected:YES];
            [self configureTabBarSubViewController:idx];
        }
        else {
            [btn setSelected:NO];
        }
    }];
}

- (IBAction)didClickTodayButton:(UIButton *)sender {
    if(self.currentTabBarSubViewControllerName == DayTabBarViewController) {
        [self.dayViewController didClickTodayButton];
    } else if(self.currentTabBarSubViewControllerName == MonthTabBarViewController) {
        [self.monthViewController didClickTodayButton];
    } else if(self.currentTabBarSubViewControllerName == WeekTabBarViewController) {
        [self.weekViewController didClickTodayButton];
    }
}

#pragma mark -
#pragma mark ScheduleDayTableViewController delegate

- (void)scheduleDayTableViewDidSelectEvent:(Event *)event {
    if(event.what == nil)
        return;
    if([event isMemberOfClass:[Activity class]]) {
        ActivityDetailViewController *vc = [[ActivityDetailViewController alloc] initWithActivity:(Activity *)event];
        [self.navigationController pushViewController:vc animated:YES];
    } else if([event isMemberOfClass:[Course class]]) {
        CourseDetailViewController *vc = [[CourseDetailViewController alloc] initWithCourse:(Course *)event];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
