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

#import "QFloatElement.h"

@implementation QFloatElement

@synthesize floatValue = _floatValue;
@synthesize minimumValue = _minimumValue;
@synthesize maximumValue = _maximumValue;

- (QFloatElement *)init {
    return [self initWithValue:0.0];
}

- (QFloatElement *)initWithTitle:(NSString *)title value:(float)value {
    self = [super initWithTitle:title Value:nil] ;
    if (self) {
        _floatValue = value;
        _minimumValue = 0.0;
        _maximumValue = 1.0;
        self.enabled = YES;
    }
    return self;
}


- (QElement *)initWithValue:(float)value {
    self = [super init];
    if (self) {
        _floatValue = value;
        _minimumValue = 0.0;
        _maximumValue = 1.0;
        self.enabled = YES;
    }
    return self;
}

- (void)fetchValueIntoObject:(id)obj {
	if (_key==nil)
		return;
    [obj setValue:[NSNumber numberWithFloat:_floatValue] forKey:_key];
}

- (void)valueChanged:(UISlider *)slider {
    self.floatValue = slider.value;
    [self handleEditingChanged];
}

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    QFloatTableViewCell *cell = [[QFloatTableViewCell alloc] initWithFrame:CGRectZero];
    [cell applyAppearanceForElement:self];///QD modify add QFloatTableViewCell  applyAppearanceForElement
    
    cell.textLabel.text = _title;
    cell.detailTextLabel.text = [_value description];
    cell.imageView.image = _image;
    
    [cell.tracking_slider addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    cell.tracking_slider.minimumValue = _minimumValue;
    cell.tracking_slider.maximumValue = _maximumValue;
    cell.tracking_slider.value = _floatValue;
    
    
    cell.accessoryType = self.accessoryType != UITableViewCellAccessoryNone ? self.accessoryType : ( self.sections!= nil || self.controllerAction!=nil ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone);
    cell.selectionStyle = self.sections!= nil || self.controllerAction!=nil ? UITableViewCellSelectionStyleBlue: UITableViewCellSelectionStyleNone;
    
    
    ///QD Float Element  modify
    self.cell = cell;
    return cell;
}

- (void)setNilValueForKey:(NSString *)key;
{
    if ([key isEqualToString:@"floatValue"]){
        self.floatValue = 0;
    }
    else {
        [super setNilValueForKey:key];
    }
}





@end
