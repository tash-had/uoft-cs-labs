//
//  TSLabsViewController.m
//  uoft-cs-labs
//
//  Created by Tash-had Saqif on 2017-10-16.
//  Copyright © 2017 Tash-had Saqif. All rights reserved.
//

#import "TSLabsViewController.h"
#import "BNRWebViewController.h"

@interface TSLabsViewController ()
@property (nonatomic) NSURLSession *session;
@property (nonatomic, copy) NSArray *labs;
//@property (nonatomic, strong) IBOutlet UIView *LabCellQuickView;
@property (nonatomic) NSMutableArray *LabCellQuickViewsArray;
@end

@implementation TSLabsViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.labs count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    NSDictionary *lab = self.labs[indexPath.row];
    

//    NSURL *URL = [NSURL URLWithString:lab[@"url"]];
//    self.webViewController.title = lab[@"title"];
//    self.webViewController.URL = URL;
//    [self.navigationController pushViewController:self.webViewController animated:YES];
    


    cell.tag = indexPath.row;
    // Get this cells UIView
    UIView *cellQuickView = [_LabCellQuickViewsArray objectAtIndex:cell.tag];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = cellQuickView;
    
    
    // Prepare Data
    int availableInt = [[lab objectForKey:@"available"] intValue];
    float percentFloat = [[lab objectForKey:@"percent"] floatValue];
    NSString *freeOrBusy;
    if (percentFloat >= 60.0){
        freeOrBusy = @"BUSY";
        cellQuickView.backgroundColor = [UIColor redColor];
    }else{
        freeOrBusy = @"FREE";
        cellQuickView.backgroundColor = [UIColor greenColor];
    }
    
    // Set Data
    for (UIView *v in cellQuickView.subviews){
        if ([v isKindOfClass:[UILabel class]]){
            UILabel *newLabel = (UILabel *)v;
            
            if ([newLabel.text  isEqual: @"DENSITY"]){
                newLabel.text = freeOrBusy;
            }else if (![newLabel.text isEqualToString:@"FREE"] && ![newLabel.text isEqualToString:@"BUSY"]){
                newLabel.text =  [NSString stringWithFormat:@"%d", availableInt];
            }
        }
    }
    // Set view to cell
    cell.accessoryView = cellQuickView;
    
    
    NSMutableString *s = [[NSMutableString alloc] initWithString:lab[@"name"]];
    cell.textLabel.text = (s);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (instancetype)initWithStyle:(UITableViewStyle)style{
    self = [super initWithStyle:style];
    if (self){
        self.navigationItem.title = @"Labs";
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:nil];
        [self fetchFeed];
    }
    return self;
}

- (void)fetchFeed{
    NSString *requestString = @"https://cobalt.qas.im/api/1.0/cdf/labs?key=9tpqQhzrMf9EUhm5NvAV7ccTmpHGfD18";
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
//        NSString *json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"%@", jsonObject);
        self.labs = jsonObject[@"labs"];
        
        // Create array with cellQuickView's
        _LabCellQuickViewsArray = [[NSMutableArray alloc] init];
        for (int i = 0;i < [_labs count];i++){
            UIView *cellQuickView = [[[NSBundle mainBundle] loadNibNamed:@"LabCellQuickView" owner:self options:nil] objectAtIndex:0];
            [_LabCellQuickViewsArray addObject:cellQuickView];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    [dataTask resume];
    

}

//-(UIView *)LabCellQuickView{
//
//    if (!_LabCellQuickView){
//        // Load LabCellQuickView.xib
//
//        [[NSBundle mainBundle] loadNibNamed:@"LabCellQuickView" owner:self options:nil];
//    }
//    return _LabCellQuickView;
//}
@end
