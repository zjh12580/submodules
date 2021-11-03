//
//  TaskModel.h
//  tasks
//
//  Created by zhaojh on 2021/11/2.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    Task_Enter,
    Task_Wait,
    Task_Done,
} TaskStatus;

@interface TaskModel : NSObject

@property(nonatomic,copy) NSString *timeString;
@property(nonatomic,copy) NSString *status;
@end

@interface TaskGroupModel : NSObject

@property(nonatomic,assign) NSInteger timeSp;
@property(nonatomic,assign) TaskStatus status;
@property(nonatomic,strong) NSMutableArray<TaskModel*> *group;

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_group_t taskGroup;

@end


