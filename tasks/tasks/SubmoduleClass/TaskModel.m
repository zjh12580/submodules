//
//  TaskModel.m
//  tasks
//
//  Created by zhaojh on 2021/11/2.
//

#import "TaskModel.h"

@implementation TaskModel

@end


@implementation TaskGroupModel

-(NSMutableArray<TaskModel *> *)group{
    if (!_group) {
        _group = @[].mutableCopy;
    }
    return _group;
}

@end
