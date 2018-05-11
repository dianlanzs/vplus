//
//  ShareCamController.m
//  Kamu
//
//  Created by YGTech on 2018/2/1.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "ShareCamController.h"
#import "UIBarButtonItem+Item.h"
#import "NvrSettingsController.h"


#import "ReactiveObjC.h"
@interface ShareCamController ()<UINavigationControllerDelegate>

@property (nonatomic, strong) UIView *emptyView;
@property (nonatomic, strong) QSection *friends;
@property (nonatomic, strong) QEntryElement *mailEntry;
@property (nonatomic, strong) QEntryElement *nameEntry;
@property (nonatomic, strong) QRootElement *form;
@property (nonatomic, strong) NSMutableArray *dicts;

@property (nonatomic, strong) BButton *inviteBtn;

@end

@implementation ShareCamController

//- (void)valueChange {
//    if (self.nameEntry.textValue.length && self.mailEntry.textValue.length) {
//        [self.inviteBtn setShouldShowDisabled:NO];
//    }
//}

#pragma mark - 生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
  
    //self 加载时候     清空数据
//    [[[self.root.sections objectAtIndex:0] elements] removeAllObjects];
    
    //self 将要消失的时候  清空数据
    __weak typeof (self) weakSelf = self;
//    self.willDisappearCallback = ^{
//        [[[weakSelf.root.sections objectAtIndex:0] elements] removeAllObjects];
//    };
    
 
    
    
    //object: 发送源，发送通知的对象
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valueChange) name:UITextFieldTextDidChangeNotification object:self.nameEntry];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(valueChange) name:UITextFieldTextDidChangeNotification object:self.mailEntry];

//
    
    
//    
//    [RACObserve(self, self.friends.elements) subscribeNext:^(NSMutableArray* _Nullable x) {
//        self.root.value = [NSString stringWithFormat:@"(%ld)",x.count];
//
//    }];
    
    
    
    
    
    self.navigationController.delegate = self;
    [self friends];
    
  
    
    //监听是否有数据，没有空数据展现
//    [self.quickDialogTableView setTableHeaderView:self.emptyView];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem barItemWithimage:[[UIImage imageNamed:@"navigation_add"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] highImage:nil target:self action:@selector(addPerson:) title:@"添加好友"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    self.root.value = [NSString stringWithFormat:@"(%ld)",_friends.elements.count];
    for (MGSwipeTableCell* cell in [self.quickDialogTableView visibleCells]) {
        cell.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    self.root.value = [NSString stringWithFormat:@"(%ld)",_friends.elements.count];

}




#pragma mark - 导航控制器代理 - vc将要展现
//***.CamSettingsVc  清空数据
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {

        if ([viewController isKindOfClass:[NvrSettingsController class]]) {
            NvrSettingsController *nvrSettingsVc = viewController;
            
            //清空临时数据
            QSection *root_s = [nvrSettingsVc.root.sections objectAtIndex:0];
            QRootElement *root_s__authority = [root_s.elements objectAtIndex:2];
            NSMutableArray *elements_authoritzed = [[root_s__authority.sections objectAtIndex:0] elements] ;
            [elements_authoritzed removeAllObjects];
        }
}
- (void)addPerson:(id)sender {
    
   
    //空数据视图取消
    [self.quickDialogTableView setTableHeaderView:nil];
    ///MARK: displayVcForRoot 不需要创建 controllerName 的vc ,也可以重写 自定义设置！！  创建 的是 QuickDialogController
    
    [_inviteBtn setEnabled:NO];
    [self.inviteBtn setShouldShowDisabled:YES];
    [self displayViewControllerForRoot:self.form];
    
//  [self setResizeWhenKeyboardPresented:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}



#pragma mark - MGSwipeCell 代理
///MARK: 点击代理 --> 设置删除功能
- (BOOL)swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    
    //fromExpansion : 是否来自（设置了）扩展
    if (direction == MGSwipeDirectionRightToLeft && index == 0 && fromExpansion == NO) {
        //delete button
        NSIndexPath * path = [self.quickDialogTableView indexPathForCell:cell];

//        [[[self.root.sections objectAtIndex:0] elements] removeObjectAtIndex:path.row];
        
        [self.friends.elements removeObjectAtIndex:path.row];
        ///MARK: 删除临时数据源
        [self.dicts removeObjectAtIndex:path.row];
        
        ///删除 持久化 数据源
        [[NSUserDefaults standardUserDefaults] setObject:self.dicts forKey:@"friends"];

        [self.quickDialogTableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
        return NO; //Don't autohide to improve delete expansion animation
    }
    // @return YES to autohide the current swipe buttons ，隐藏当前的 buttons
    return YES;
}

//返回 button 数组
- (NSArray *)swipeTableCell:(MGSwipeTableCell *) cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings {
    
    //配置的数据
    //    TestData * data = [tests objectAtIndex:[_tableView indexPathForCell:cell].row];
    
    //设置样式
    swipeSettings.transition = MGSwipeTransitionStatic;
    // -------->
    //    if (direction == MGSwipeDirectionLeftToRight) {
    //        expansionSettings.buttonIndex = data.leftExpandableIndex;
    //        expansionSettings.fillOnTrigger = NO;
    //        return [self createLeftButtons:data.leftButtonsCount];
    //    }
    // <--------
    //    if (direction == MGSwipeDirectionRightToLeft) {
    //
    //        //设置 可扩展的 button  为 delete  按钮
    //        expansionSettings.buttonIndex = 0;
    //        //当触发时候 填充  设置 YES ，NO弹回
    //        expansionSettings.fillOnTrigger = NO;
    //        //创建2个button
    //        return [self createRightButtons:1];
    //    }
    
    return [self createRightButtons:1];
    
}
//创建右侧按钮
- (NSArray *)createRightButtons: (int) number {
    
    NSMutableArray *result = [NSMutableArray array];
    NSString *titles[1] = {@"删除"};
    UIColor  *colors[1] = {[UIColor redColor]};
    UIImage *image = [[UIImage imageNamed:@"trash"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    for (int i = 0; i < number; ++i) {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] icon:image backgroundColor:colors[i] padding:10.0f callback:^BOOL(MGSwipeTableCell * _Nonnull cell) {
            NSLog(@"Convenience callback received (right).");
            BOOL autoHide = ( i != 0 );
            return autoHide; //Don't autohide in delete button to improve delete expansion animation
        }];
        
        button.tintColor = [UIColor whiteColor];
        [result addObject:button];
    }
    
    return result;
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:YES];
//
//    self.navigationController
//
//    QSection *s = [self.root.sections objectAtIndex:0] ;
//    [s.elements removeAllObjects];
//
//}
//- (void)dealloc {
//    self.root.sections = nil;
//    
//    
//    CamSettingsController *camVc = (CamSettingsController *) self.navigationController.topViewController;
//    QSection *s = [camVc.root.sections objectAtIndex:0];
//
//    QRootElement *shre_elRoot = [s.elements objectAtIndex:2];
//    NSMutableArray *elements = [[shre_elRoot.sections objectAtIndex:0] elements] ;
//    [elements removeAllObjects];
//    
//}

#pragma mark - 发送 按钮点击
- (void)backToAuthority:(id)sender {
    
    
    
    if (self.nameEntry.textValue.length && self.mailEntry.textValue.length) {
        //存储到 偏好设置里（xml)
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [self.form fetchValueIntoObject:dict];
        [self.dicts addObject:dict];
        //创建系统单例 NSUserDefaults的实例对象
        [[NSUserDefaults standardUserDefaults] setObject:self.dicts forKey:@"friends"];
        
        QLabelElement *authedFriend = [[QLabelElement alloc] initWithTitle:self.nameEntry.textValue Value:@"未收到"];
        [self.friends addElement:authedFriend];
        [self.friends setHeaderView:nil];
        
        //清空输入框值 ，因为模态出来的 对话框 dimiss 不会释放 self.form! 也就不会释放 elements的值
        self.nameEntry.textValue = nil;
        self.mailEntry.textValue = nil;
        [self.quickDialogTableView reloadData];
    }
    
    
    
    [self dismissModalViewController];
}
#pragma mark Required!
- (BButton *)inviteBtn {
    
    if (!_inviteBtn) {
        _inviteBtn = [[BButton alloc] initWithFrame:CGRectMake(20.f, 40.f, AM_SCREEN_WIDTH - 40.f, 40.f) color:[UIColor colorWithHex:@"0066ff"]];
        
        [_inviteBtn setEnabled:NO];
        //只是针对 UI 改动 ，没有设置Enbled
        [_inviteBtn setShouldShowDisabled:YES];
        [_inviteBtn setTitle:@"发送邀请" forState:UIControlStateNormal];
        [_inviteBtn addTarget:self action:@selector(backToAuthority:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _inviteBtn;
}

//表单
- (QRootElement *)form {
    
   
    
    if (!_form) {
        _form = [[QRootElement alloc] init];
        _form.presentationMode = QPresentationModeModalForm;
        _form.title = @"添加好友";
        _form.controllerName = @"addFriend"; //表单在这个控制器里
        _form.grouped = YES;
        
        QSection *section1 = [[QSection alloc] initWithTitle:@"Information"];
        
        
        [section1 addElement:self.mailEntry];
        [section1 addElement:self.nameEntry];
        
        UIView *containerView = [[UIView alloc] init];
        //默认不可点击，颜色灰色
       
        [containerView addSubview:self.inviteBtn];
        [section1 setFooterView:containerView];
        
        [section1.footerView setBounds:CGRectMake(0, 0, AM_SCREEN_WIDTH, 80)];
        [_form addSection:section1];
    
    }
    
    return _form;
}
- (QEntryElement *)mailEntry {
    
    if (!_mailEntry) {
        _mailEntry = [[QEntryElement alloc] initWithTitle:@"邮箱" Value:@"" Placeholder:@"请输入邮箱"];
        _mailEntry.key = _mailEntry.title;
        _mailEntry.delegate = self;
    }
    
    return _mailEntry;
    
}

- (QEntryElement *)nameEntry {
    
    if (!_nameEntry) {
        _nameEntry = [[QEntryElement alloc] initWithTitle:@"姓名" Value:@"" Placeholder:@"请输入联系人名字"];
        _nameEntry.key = _nameEntry.title;
        _nameEntry.delegate = self;
    }
    
    return _nameEntry;
    
}

- (NSMutableArray *)dicts {
    if (!_dicts) {
        _dicts = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"friends"]];
    }
    
    return _dicts;
    
}

@synthesize dicts = _dicts;
- (void)setDicts:(NSMutableArray *)dicts {
    if (dicts != _dicts) {
        _dicts = dicts;
    }
}

@synthesize friends = _friends;
- (void)setFriends:(QSection *)friends {
    
    if (friends != _friends) {
        _friends = friends;
    }
    
}

- (QSection *)friends {
    
    if (!_friends) {
        
        
        _friends = [self.root.sections objectAtIndex:0];
        [_friends setCanDeleteRows:YES];
        NSLog(@"------%@    self.root = %@ , section.rootElement = %@",[self.root.sections[0] elements],self.root,_friends.rootElement);
        NSArray *dicts = [[NSUserDefaults standardUserDefaults] valueForKey:@"friends"];
        
        if (self.dicts.count) {
            _friends.headerView = nil;
            for (NSDictionary *dict in dicts ) {
                
                NSString *contactName = [dict valueForKey:self.nameEntry.key];
                if (contactName.length) {
                    QLabelElement *nameLb = [[QLabelElement alloc] initWithTitle:contactName Value:@"已邀请"];
                    [_friends addElement:nameLb];
                }
            }
        }
    }
    
    return _friends;
    
}

- (UIView *)emptyView {
    
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:self.quickDialogTableView.bounds];
        _emptyView.backgroundColor = [UIColor redColor];
    }
    
    return _emptyView;
}

- (BOOL)QEntryShouldReturnForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell{
   
//    if (!range.location && string.length) {
//        [_inviteBtn setEnabled:NO];
//        [self.inviteBtn setShouldShowDisabled:YES];
//    }else {
    
        if (self.nameEntry.textValue.length && self.mailEntry.textValue.length) {
            [_inviteBtn setEnabled:YES];
            [self.inviteBtn setShouldShowDisabled:NO];
        }
        
        
//    }
    
   
    return YES;
}
    


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    

}

@end
