//
//  MineViewController.m
//  AEFT冷风扇
//
//  Created by 杭州阿尔法特 on 16/3/12.
//  Copyright © 2016年 阿尔法特. All rights reserved.
//

#import "MineViewController.h"
#import "HeadPortraitView.h"
#import "MineTableViewCell.h"
#import "UserMessageViewController.h"


@interface MineViewController ()<UITableViewDataSource , UITableViewDelegate ,  HelpFunctionDelegate>
@property (nonatomic , copy) NSString *systemMessageIsShowPrompt;
@property (nonatomic , strong) UITableView *tableVIew;
@property (nonatomic , strong) UILabel *nameLable;
@property (nonatomic , strong) UserModel *userModel;
@property (nonatomic , strong) UIImage *headImage;
@property (nonatomic , strong) UIImageView *headImageView;
@property (nonatomic , strong) UIImageView *headBackImageView;

@property (nonatomic , strong) HeadPortraitView *headPortraitView;

@property (nonatomic , strong) NSIndexPath *selectedIndexPath;
@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    
    [self setData];
    
    [self setNav];
    
    [self setUI];
    
    [self setNotiFia];
    
}

- (void)setData {
    NSDictionary *parames = @{@"userSn":[kStanderDefault objectForKey:@"userSn"]};
    [kNetWork requestPOSTUrlString:kUserInfoURL parameters:parames isSuccess:^(NSDictionary * _Nullable responseObject) {
        [kPlistTools saveDataToFile:responseObject name:@"UserData"];
        if ([responseObject[@"state"] integerValue] == 0) {
            NSDictionary *user = responseObject[@"data"];
            [kStanderDefault setObject:user[@"sn"] forKey:@"userSn"];
            [kStanderDefault setObject:user[@"id"] forKey:@"userId"];
            
            UserModel *userModel = [[UserModel alloc]init];
            [userModel yy_modelSetWithJSON:user];
            self.userModel = userModel;
            _headPortraitView.userModel = self.userModel;
            
        }
    } failure:^(NSError * _Nonnull error) {
        [kNetWork noNetWork];
    }];
}

- (void)setNotiFia {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getHeadImage:) name:@"headImage" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNiCheng:) name:@"niCheng" object:nil];
}

- (MineTableViewCell *)tableViewindexPathForRow:(NSInteger)row inSection:(NSInteger)section {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:row inSection:section];
    MineTableViewCell *cell = (MineTableViewCell *)[self.tableVIew cellForRowAtIndexPath:indexpath];
    return cell;
}

#pragma mark - 获取代理的数据
- (void)requestData:(HelpFunction *)request didFinishLoadingDtaArray:(NSMutableArray *)data {
    NSDictionary *dic = data[0];
//    NSLog(@"%@" , dic);
    if ([dic[@"state"] integerValue] == 0) {
        
        NSDictionary *user = dic[@"data"];
        
        [kStanderDefault setObject:user[@"sn"] forKey:@"userSn"];
        [kStanderDefault setObject:user[@"id"] forKey:@"userId"];
        
        self.userModel = [[UserModel alloc]init];
        for (NSString *key in [user allKeys]) {
            [self.userModel setValue:user[key] forKey:key];
        }
        _headPortraitView.userModel = self.userModel;
        
    }
}

- (void)requestData:(HelpFunction *)request didFailLoadData:(NSError *)error {
    NSLog(@"%@" , error);
}

#pragma mark - 获取头像
- (void)getHeadImage:(NSNotification *)post {
    
    if (post.userInfo[@"headImage"]) {
        self.headImageView.image = post.userInfo[@"headImage"];
        _headBackImageView.image = _headBackImageView.image = [UIImage boxblurImage:post.userInfo[@"headImage"] withBlurNumber:.3];
    }
}

- (void)getNiCheng:(NSNotification *)post {

    if ([post.userInfo[@"niCheng"] length] != 0) {
        self.nameLable.text = post.userInfo[@"niCheng"];
    }
}


- (void)setNav {
    self.navigationItem.title = @"个人中心";
}

#pragma mark - 设置UI界面
- (void)setUI{

    _headPortraitView = [[HeadPortraitView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, kScreenW / 2.08) Target:self action:@selector(mineAtcion)];
    [self.view addSubview:_headPortraitView];
    self.headBackImageView = _headPortraitView.subviews[0];
    self.headImageView = _headPortraitView.subviews[2];
    self.nameLable = [_headPortraitView.subviews objectAtIndex:3];
    
    self.tableVIew = [[UITableView alloc]initWithFrame:CGRectMake(0, kScreenH / 3.7 + 0, kScreenW, 7 * kScreenH / 14.2 + 2) style:UITableViewStylePlain];
    [self.view addSubview:self.tableVIew];
    self.tableVIew.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    self.tableVIew.scrollEnabled = NO;
    self.tableVIew.delegate = self;
    self.tableVIew.dataSource = self;
    self.tableVIew.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - 头像点击事件
- (void)mineAtcion {
    UserMessageViewController *userVC = [[UserMessageViewController alloc]init];

    userVC.userModel = self.userModel;
    userVC.headImage = self.headImageView.image;
    userVC.navigationItem.title = @"用户信息";
    [self.navigationController pushViewController:userVC animated:YES];
//    self.tabBarController.tabBar.hidden = YES;
}

#pragma mark - TableView的点击事件
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellId = @"id";
    MineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[MineTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId
                ];
    }
    
    cell.indexpath = indexPath;
    cell.backgroundColor = [UIColor colorWithHexString:@"f2f4fb"];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MineTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectedImage.hidden = NO;
    self.selectedIndexPath = indexPath;
    return YES;
}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedIndexPath) {
        MineTableViewCell *cell = [self.tableVIew cellForRowAtIndexPath:self.selectedIndexPath];
        cell.selectedImage.hidden = YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row == 0) {
        [self mineAtcion];
    } else {
        
        MineTableViewCell *cell = [_tableVIew cellForRowAtIndexPath:indexPath];
        
        [UIAlertController creatCancleAndRightAlertControllerWithHandle:^{
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                cell.clearLabel.text = [NSString stringWithFormat:@"当前缓存 : %@" , [cell getBufferSize]];
            }];
            
            [self cleanCacheAndCookie];
            
        } andSuperViewController:self Title:@"清除缓存"];
    }
}

/**清除缓存和cookie*/
- (void)cleanCacheAndCookie{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.contentView.backgroundColor = [UIColor clearColor];
}

//弹出列表方法presentSnsIconSheetView需要设置delegate为self
-(BOOL)isDirectShareInIconActionSheet
{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kScreenH / 14.46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kScreenW / 27;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
