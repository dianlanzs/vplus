//                                
// Copyright 2011 ESCOZ Inc  - http://escoz.com
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this 
// file except in compliance with the License. You may obtain a copy of the License at 
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "QuickDialogController.h"
#import "QRootElement.h"
#import "QEntryElement.h"

//zhoulei
#import "QuickDialogEntryElementDelegate.h"
@interface QuickDialogController ()<QuickDialogEntryElementDelegate>





+ (Class)controllerClassForRoot:(QRootElement *)root;
@end


@implementation QuickDialogController {
    BOOL _keyboardVisible;
    BOOL _viewOnScreen;
    BOOL _resizeWhenKeyboardPresented;
    UIPopoverController *_popoverForChildRoot;
}

@synthesize root = _root;
@synthesize willDisappearCallback = _willDisappearCallback;
@synthesize quickDialogTableView = _quickDialogTableView;
@synthesize resizeWhenKeyboardPresented = _resizeWhenKeyboardPresented;
@synthesize popoverBeingPresented = _popoverBeingPresented;
@synthesize popoverForChildRoot = _popoverForChildRoot;


+ (QuickDialogController *)buildControllerWithClass:(Class)controllerClass root:(QRootElement *)root {
    
    ///MARK: controllerClass == nil!!!
    controllerClass = controllerClass == nil? [QuickDialogController class] : controllerClass;
    return [((QuickDialogController *)[controllerClass alloc]) initWithRoot:root]; // create QuickDialogController use designed method
}




+ (QuickDialogController *)controllerForRoot:(QRootElement *)root {
    Class controllerClass = [self controllerClassForRoot:root];
    if (controllerClass==nil)
        NSLog(@"Couldn't find a class for name %@", root.controllerName);
    return [((QuickDialogController *)[controllerClass alloc]) initWithRoot:root];
}

+ (Class)controllerClassForRoot:(QRootElement *)root {
    Class controllerClass = nil;
    if (root.controllerName != NULL){
        controllerClass = NSClassFromString(root.controllerName); // create vc class from  root.controllerName!
    } else {
        controllerClass = [QuickDialogController class];//default is  QuickDialogController if root.controllerName == nil
    }
    return controllerClass;
}




+ (UINavigationController*)controllerWithNavigationForRoot:(QRootElement *)root {
    return [[UINavigationController alloc] initWithRootViewController:[QuickDialogController
                                                                       buildControllerWithClass:[self controllerClassForRoot:root]
                                                                       root:root]];
}


///zhoulei modify
- (void)setQuickDialogTableView:(QuickDialogTableView *)tableView {
    
    
    if(_quickDialogTableView != tableView) {
        _quickDialogTableView = tableView;
//       _quickDialogTableView.frame = CGRectMake(15, 64, AM_SCREEN_WIDTH - 30, AM_SCREEN_HEIGHT - 64);
//        self.view = tableView;
        [self.view addSubview:_quickDialogTableView];
        [_quickDialogTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.resizeWhenKeyboardPresented =YES;
    }
    return self;
}

- (QuickDialogController *)initWithRoot:(QRootElement *)rootElement {
    self = [super init];
    if (self) {
        [self setRoot:rootElement];//root already created!
        self.resizeWhenKeyboardPresented = YES;
    }
    return self;
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.quickDialogTableView setEditing:editing animated:animated];
}

- (void)setRoot:(QRootElement *)root {
    _root = root;
    
    self.quickDialogTableView.root = root;
    self.title = _root.title;
    self.navigationItem.title = _root.title;
}


///zhouelei  modify
//- (void)loadView {
//    [super loadView];
//}
- (void)viewDidLoad {
    [super viewDidLoad];

    
    /// view 出现之前  添加table view
    [ self setQuickDialogTableView:[[QuickDialogTableView alloc] initWithController:self]];
//    self.quickDialogTableView = [[QuickDialogTableView alloc] initWithController:self];
}

//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    self.quickDialogTableView = [[QuickDialogTableView alloc] initWithController:self];
//
//}

//zhoulei
//- (BOOL)QEntryShouldReturnForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell{
//    if ([element.key isEqualToString:@"rename"] ) {
//      
//        
//    }
//    return YES;
//}

- (void)viewWillAppear:(BOOL)animated {

    
    //zhoulei
//    [[self.root.sections[0] elements] enumerateObjectsUsingBlock:^(QRootElement *  _Nonnull elm, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([elm.key isEqualToString:@"changeName"]) {
//            for (QEntryElement *entryElm in [elm.sections[0] elements]) {
//                entryElm.delegate = self;
//            }
//        }
//    }];
//
    
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];

    
    
    
    
    
    
    

    _viewOnScreen = YES;
    [self.quickDialogTableView deselectRows];
    [super viewWillAppear:animated];
    if (_root!=nil) {
        self.title = _root.title;
        self.navigationItem.title = _root.title;
        if (_root.preselectedElementIndex !=nil)
            [self.quickDialogTableView scrollToRowAtIndexPath:_root.preselectedElementIndex atScrollPosition:UITableViewScrollPositionTop animated:NO];

    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (_root.showKeyboardOnAppear) {
        QEntryElement *elementToFocus = [_root findElementToFocusOnAfter:nil];
        if (elementToFocus!=nil)  {
            UITableViewCell *cell = [self.quickDialogTableView cellForElement:elementToFocus];
            if (cell != nil) {
                [cell becomeFirstResponder];
            }
        }
    }
}


- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    _viewOnScreen = NO;
    [super viewWillDisappear:animated];
    if (_willDisappearCallback!=nil){
        _willDisappearCallback();
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (QuickDialogController *)controllerForRoot:(QRootElement *)root {
    Class controllerClass = [[self class] controllerClassForRoot:root];
    return [QuickDialogController buildControllerWithClass:controllerClass root:root];
}

- (BOOL)shouldDeleteElement:(QElement *)element{
    return YES;
}


///设置 窗口 向上偏移！
- (void) resizeForKeyboard:(NSNotification*)aNotification {
    if (!_viewOnScreen)
        return;

    BOOL up = aNotification.name == UIKeyboardWillShowNotification;

//    if (_keyboardVisible == up)
//        return;

//    _keyboardVisible = up;
    if(up) {
    
    NSDictionary* userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationOptions animationCurve;
    CGRect keyboardEndFrame;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

    [UIView animateWithDuration:animationDuration delay:0 options:animationCurve
        animations:^{
            
            //nil 代表window ,在 View 中定义一个 键盘Frame 在 window 里的位置  差64！ 证明View 不是满铺的！
            CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
            const UIEdgeInsets oldInset = self.quickDialogTableView.contentInset;
            ///MARK:偏移一个 keyBoard Frame! 可以 + 40
            self.quickDialogTableView.contentInset = UIEdgeInsetsMake(oldInset.top, oldInset.left,  up ? keyboardFrame.size.height + 40 : 0, oldInset.right);
            self.quickDialogTableView.scrollIndicatorInsets = self.quickDialogTableView.contentInset;
        }
        completion:NULL];
        
        
    }
}

- (void)setResizeWhenKeyboardPresented:(BOOL)observesKeyboard {
  if (observesKeyboard != _resizeWhenKeyboardPresented) {
    _resizeWhenKeyboardPresented = observesKeyboard;

    if (_resizeWhenKeyboardPresented) {
        
        //键盘将要 弹出 时候调用！
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeForKeyboard:) name:UIKeyboardWillShowNotification object:nil];
        //键盘将要 退出 时候调用！
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resizeForKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    } else {
      [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
      [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
  }
}



///MARK: dealloc 没调用 就不会 通知 和 self 指针 地址 的关系 就会错乱！
/*
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
*/

@end
