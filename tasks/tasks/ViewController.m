//
//  ViewController.m
//  tasks
//
//  Created by zhaojh on 2021/11/2.
//

#import "ViewController.h"
#import "TableViewCell.h"
#import "TaskModel.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<TaskGroupModel*> *groupDatas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"任务调度";
}

#pragma mark - Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.groupDatas.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    TaskGroupModel* group = self.groupDatas[section];
    return group.group.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TableViewCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:nil options:nil] firstObject];
        cell.selectionStyle = 0;
    }
    TaskGroupModel* model = self.groupDatas[indexPath.section];
    TaskModel* task = model.group[indexPath.row];
    cell.titleLab.text = task.timeString;
    if (model.status == Task_Enter) {
        cell.statusLab.text = @"正在执行任务...";
        cell.statusLab.textColor = [UIColor orangeColor];
    }
    if (model.status == Task_Wait) {
        cell.statusLab.text = @"等待执行任务...";
        cell.statusLab.textColor = [UIColor grayColor];
    }
    if (model.status == Task_Done) {
        cell.statusLab.text = @"任务执行完毕!";
        cell.statusLab.textColor = [UIColor greenColor];
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

#pragma mark - action
- (IBAction)createTaskActionn:(id)sender {
    
    NSDate* date = [NSDate new];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    
    TaskModel* model = [TaskModel new];
    model.timeString = [df stringFromDate:date];
    
    if (self.groupDatas == 0 || [self.groupDatas lastObject].timeSp != timeSp) {
        
        TaskGroupModel* group = [[TaskGroupModel alloc] init];
        group.timeSp = timeSp;
        group.queue = dispatch_queue_create("com.timesp.task", DISPATCH_QUEUE_CONCURRENT);
        group.taskGroup = dispatch_group_create();
        group.status = Task_Wait;
        [group.group addObject:model];
        [self.groupDatas addObject:group];
        
    }else{
        for (TaskGroupModel* group in self.groupDatas) {
            if (group.timeSp == timeSp) {
                [group.group addObject:model];
                
                dispatch_group_enter(group.taskGroup);
                dispatch_group_async(group.taskGroup, group.queue, ^{
                    [NSThread sleepForTimeInterval:10.0];
                    dispatch_group_leave(group.taskGroup);
                });
            }
        }
    }
    [self checkNextTask];
    [self.tableView reloadData];
}


-(void)checkNextTask {
    
    for (TaskGroupModel* model in self.groupDatas) {
        if (model.status == Task_Enter) {
            return;
        }
    }
    for (int i = 0; i < self.groupDatas.count; i++) {
        
        TaskGroupModel* groupModel = self.groupDatas[i];
        if (groupModel.status == Task_Wait) {
            
            groupModel.status = Task_Enter;
            for (TaskModel* model in groupModel.group) {
                
                dispatch_group_enter(groupModel.taskGroup);
                dispatch_group_async(groupModel.taskGroup, groupModel.queue, ^{
                    [NSThread sleepForTimeInterval:10.0];
                    dispatch_group_leave(groupModel.taskGroup);
                });
            }
            dispatch_group_notify(groupModel.taskGroup, dispatch_get_main_queue(), ^{
                NSLog(@"当前时间的任务结束: %ld",groupModel.timeSp);
                groupModel.status = Task_Done;
                groupModel.queue = nil;
                groupModel.taskGroup = nil;
                [self.tableView reloadData];
                [self checkNextTask];
            });
            break;
        }
    }
}

#pragma mark - load
-(NSMutableArray<TaskGroupModel *> *)groupDatas{
    if (!_groupDatas) {
        _groupDatas = @[].mutableCopy;
    }
    return _groupDatas;
}

@end
