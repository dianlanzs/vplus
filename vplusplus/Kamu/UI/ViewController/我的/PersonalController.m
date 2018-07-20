//
//  PersonalController.m
//  Kamu
//
//  Created by YGTech on 2018/7/11.
//  Copyright © 2018 com.Kamu.cme. All rights reserved.
//

#import "PersonalController.h"
#import "LoginController.h"
#import "AppDelegate.h"
#import "UIImage+CutRound.h"

@interface PersonalController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
 //section0 header
@property (nonatomic, strong) UIButton  *portraitBtn;
@property (nonatomic, strong) UILabel  *nameLabel;

//section1 footer
@property (nonatomic, strong) BButton *logoutBtn;


///DataBuilder Created
@property (nonatomic, strong) QSection *section0;
@property (nonatomic, strong) UIImageView *customHeader;
@property (nonatomic, strong) UIView *customFooter;

@end

@implementation PersonalController

- (QSection *)section0 {
    _section0 = [self.root.sections objectAtIndex:0];
    return _section0;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel labelWithText:USER.user_email withFont:[UIFont systemFontOfSize:21] color:[UIColor blackColor] aligment:NSTextAlignmentCenter];
    }
    
    return _nameLabel;
}
- (BButton *)logoutBtn {
    
    if (!_logoutBtn) {
        _logoutBtn = [[BButton alloc] initWithFrame:CGRectZero color:[UIColor redColor]];
        [_logoutBtn setTitle:@"退出登录" forState:UIControlStateNormal];
        [_logoutBtn addTarget:self action:@selector(userLogout:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logoutBtn;
}
- (void)userLogout:(id)sender {
    self.userLogout(USER);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    ///HEADER
    self.customHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 300)];
    [self.customHeader setUserInteractionEnabled:YES];
    [self.customHeader setImage:[UIImage imageNamed:@"ucDefault"]]; ///USER
    [self.customHeader addSubview:self.portraitBtn];
    [self.customHeader addSubview:self.nameLabel];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    [self.customHeader addGestureRecognizer:tapGesture];
    [self.portraitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.customHeader);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.portraitBtn.mas_bottom).offset(20.f);
        make.leading.trailing.equalTo(self.customHeader).offset(15.f);
    }];
    
    [self.root.sections[0] setHeaderView:self.customHeader];
    
    
    
    
    
    
    /// FOOTER
    self.customFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 200)];
    [self.customFooter addSubview:self.logoutBtn];
    [self.logoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customFooter).offset(20.f);
        make.leading.equalTo(self.customFooter).offset(20.f);
        make.trailing.equalTo(self.customFooter).offset(-20.f);

        make.height.mas_equalTo(40.f);
    }];
    [self.root.sections[0] setFooterView:self.customFooter];
   

 
    
   



    ///disable tableview offset automitc bug
    if (@available(iOS 11.0, *)) {
        self.quickDialogTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self. automaticallyAdjustsScrollViewInsets = NO; ///deprated in ios 11
    }

}

- (void)clickImage {
    [self readPhotosWithTag:1001];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    ///set nav clear
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.navigationController.navigationBar.translucent = YES;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
 
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    self.navigationController.navigationBar.translucent = NO;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)portraitBtn {
    if (!_portraitBtn) {
        _portraitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_portraitBtn setContentMode:UIViewContentModeScaleAspectFill];
        [_portraitBtn setImage:[UIImage imageWithData:USER.user_portrait] forState:UIControlStateNormal];
        [_portraitBtn.layer setBorderColor:[UIColor groupTableViewBackgroundColor].CGColor];
        [_portraitBtn addTarget:self action:@selector(changePortrait:) forControlEvents:UIControlEventTouchUpInside];
        [_portraitBtn.layer setBorderWidth:1.f];
        [_portraitBtn.layer setCornerRadius:50.f];
        [_portraitBtn.layer setMasksToBounds:YES];
        [_portraitBtn setBackgroundColor:[UIColor lightTextColor]];

    }
    return _portraitBtn;
}
- (void)changePortrait:(id)sender {
    
    [self readPhotosWithTag:1000];
}


- (void)readPhotosWithTag:(NSInteger)tag {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        UIImagePickerController *pickerImage = [[UIImagePickerController alloc]init];
        [pickerImage.view setTag:tag];
        
        pickerImage.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        pickerImage.allowsEditing = YES;
        pickerImage.delegate = self;
        [self presentViewController:pickerImage animated:YES completion:nil];
    }]];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        UIImagePickerController *pickerImage = [[UIImagePickerController alloc]init];
        [pickerImage.view setTag:tag];

        pickerImage.sourceType = UIImagePickerControllerSourceTypeCamera;
        pickerImage.allowsEditing = YES;
        pickerImage.delegate = self;
        [self presentViewController:pickerImage animated:YES completion:nil];
    }]];
    
    
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];

}



///该代理方法仅适用于只选取图片时
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *selectedPhoto = info[ UIImagePickerControllerEditedImage];
    
    if (picker.view.tag == 1000) {
        [self.portraitBtn setImage:[selectedPhoto cutRoundImage] forState:UIControlStateNormal];
        [RLM transactionWithBlock:^{
            USER.user_portrait  = UIImageJPEGRepresentation(selectedPhoto, 1.0);
        }];
        
    }else if (picker.view.tag == 1001){
        [self.customHeader setImage:selectedPhoto];
        [RLM transactionWithBlock:^{
            USER.user_cover  = UIImageJPEGRepresentation(selectedPhoto, 1.0);
        }];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
//        if (UIImagePNGRepresentation(selectedPhoto) == nil){
//            user.userPhoto = UIImageJPEGRepresentation(selectedPhoto, 1.0);
//        }else {
//               user.userPhoto = UIImagePNGRepresentation(selectedPhoto);
//        }
