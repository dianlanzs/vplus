//
//  CamNameController.m
//  Kamu
//
//  Created by YGTech on 2018/2/11.
//  Copyright © 2018年 com.Kamu.cme. All rights reserved.
//

#import "CamNameController.h"

@interface CamNameController ()



@property (nonatomic, strong) QSection *section1;
@property (nonatomic, strong) QEntryElement *elm_modifyName;
@end

@implementation CamNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self section1_modifyName];

    

}


- (QEntryElement *)section1_modifyName {
    if (!_elm_modifyName) {
        _elm_modifyName = [self.section1.elements objectAtIndex:0];
        _elm_modifyName.delegate = self;
    }
    return _elm_modifyName;
}

- (QSection *)section1 {
    
    if (!_section1) {
        _section1 = [self.root.sections objectAtIndex:0];
    }
    
    return _section1;
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self.root setValue:self.section1_modifyName.textValue];
}


//- (void)QEntryMustReturnForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell{
//    [[NSUserDefaults standardUserDefaults] setObject:self.cell_camName.textValue forKey:@"camName"];
//}

//字符 光标 range 改变
- (BOOL)QEntryShouldChangeCharactersInRange:(NSRange)range withString:(NSString *)string forElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell{
    
    return YES;
}

//***
- (void)QEntryEditingChangedForElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell{
    
}

//1.开始编辑
- (void)QEntryDidBeginEditingElement:(QEntryElement *)element  andCell:(QEntryTableViewCell *)cell{
    
}
//字符  已经改变了
- (void)QEntryDidEndEditingElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell{
    
}

//**点完成之后**
- (BOOL)QEntryShouldReturnForElement:(QEntryElement *)element andCell:(QEntryTableViewCell *)cell{
    
    if (self.elm_modifyName.textValue) {
        
        
        
        Device *nvr = self.section1.object;
        Device *device =  [[Device objectsWhere:[NSString stringWithFormat:@"nvr_id = '%@'",nvr.nvr_id]] firstObject];
        [[RLMRealm defaultRealm] transactionWithBlock:^{
            device.nvr_name = self.elm_modifyName.textValue;
        }];
        
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"deviceNameChanged" object:self.elm_modifyName.textValue];
    }
  
    return YES;
}








@end
