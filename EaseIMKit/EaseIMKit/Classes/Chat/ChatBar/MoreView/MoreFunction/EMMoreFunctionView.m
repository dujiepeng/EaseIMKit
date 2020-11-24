//
//  EMMoreFunctionView.m
//  EaseIM
//
//  Created by 娜塔莎 on 2019/10/23.
//  Copyright © 2019 娜塔莎. All rights reserved.
//

#define pageSize 8

#import "EMMoreFunctionView.h"
#import "HorizontalLayout.h"
#import "UIImage+EaseUI.h"

@implementation EMExtModel
- (instancetype)initWithType:(ExtType)type itemCount:(NSInteger)itemCount
{
    self = [super init];
    if (self) {
        _type = type;
        _itemCount = itemCount;
        return self;
    }
    return self;
}
- (CGFloat)cellLonger
{
    if (_type == ExtTypeChatBar) {
        return 60;
    }
    return 30;
}
- (CGFloat)xOffset
{
    return (self.collectionViewSize.width - self.cellLonger * self.rowCount) / (self.rowCount + 1);
}
- (CGFloat)yOffset
{
    return (self.collectionViewSize.height - (self.cellLonger + 13) * self.columCount) / (self.columCount + 1);
}
- (CGSize)collectionViewSize
{
    if (_type == ExtTypeChatBar) {
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 200);
    }
    return CGSizeMake(self.rowCount * 50 , self.columCount * 50);
}
- (NSInteger)rowCount
{
    if (_type == ExtTypeChatBar) {
        return 4;
    }
    return _itemCount > 6 ? 6 : _itemCount;
}
- (NSInteger)columCount
{
    if (_type == ExtTypeChatBar) {
        return 2;
    }
    return _itemCount > 6 ? 2 : 1;
}
@end


@interface EMMoreFunctionView()<UICollectionViewDataSource,SessionToolbarCellDelegate>
{
    NSMutableArray<UIImage*> *_toolbarImgArray;
    NSMutableArray<NSString*> *_toolbarDescArray;
    BOOL _isCustom;
    NSInteger _itemImgCount;
    NSInteger _itemDescCount;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) EMConversation *conversation;
@property (nonatomic, strong) EMExtModel *model;

@end

@implementation EMMoreFunctionView
//输入扩展功能区
- (instancetype)initInputViewWithConversation:(EMConversation *)conversation
{
    self = [super init];
    if(self){
        _conversation = conversation;
        _toolbarImgArray = [[NSMutableArray<UIImage*> alloc]init];
        [_toolbarImgArray addObject:[UIImage easeUIImageNamed:@"photo-album"]];
        [_toolbarImgArray addObject:[UIImage easeUIImageNamed:@"camera"]];
        [_toolbarImgArray addObject:[UIImage easeUIImageNamed:@"video_conf"]];
        [_toolbarImgArray addObject:[UIImage easeUIImageNamed:@"location"]];
        [_toolbarImgArray addObject:[UIImage easeUIImageNamed:@"icloudFile"]];
        _toolbarDescArray = [NSMutableArray arrayWithArray:@[@"相册",@"相机",@"音视频",@"位置",@"文件"]];
        if (_conversation.type == EMConversationTypeGroupChat) {
            if ([[EMClient.sharedClient.groupManager getGroupSpecificationFromServerWithId:_conversation.conversationId error:nil].owner isEqualToString:EMClient.sharedClient.currentUsername]) {
                [_toolbarImgArray addObject:[UIImage easeUIImageNamed:@"pin_readReceipt"]];
                [_toolbarDescArray addObject:@"群组回执"];
            }
        }
        if (_conversation.type == EMConversationTypeChatRoom) {
            [_toolbarImgArray removeObjectAtIndex:2];
            [_toolbarDescArray removeObject:@"音视频"];
        }
        NSMutableArray<NSString*> *tempDescArray = [self.delegate chatBarExtFunctionItemDescArray:_toolbarDescArray];
        if (tempDescArray && [tempDescArray count] > 0) {
            _toolbarDescArray = tempDescArray;
        }
        NSMutableArray<UIImage*> *tempImgArray = [self.delegate chatBarExtFunctionItemImgArray:_toolbarImgArray];
        if (tempImgArray && [tempImgArray count] > 0) {
            _toolbarImgArray = tempImgArray;
        }
        _itemImgCount = [_toolbarImgArray count];
        _itemDescCount = [_toolbarDescArray count];
        _model = [[EMExtModel alloc]initWithType:ExtTypeChatBar itemCount:_itemImgCount];
        [self _setupUI];
    }
    
    return self;
}
//长按事件
- (instancetype)initLongPressView
{
    self = [super init];
    if(self){
        _toolbarImgArray = [[NSMutableArray<UIImage*> alloc]init];
        [_toolbarImgArray addObject:[UIImage easeUIImageNamed:@"copy"]];
        [_toolbarImgArray addObject:[UIImage easeUIImageNamed:@"copy"]];
        [_toolbarImgArray addObject:[UIImage easeUIImageNamed:@"delete"]];
        [_toolbarImgArray addObject:[UIImage easeUIImageNamed:@"recall"]];
        [_toolbarImgArray addObject:[UIImage easeUIImageNamed:@"icloudFile"]];
        _toolbarDescArray = [NSMutableArray arrayWithArray:@[@"复制",@"转发",@"删除",@"撤回",@"文件"]];
        NSMutableArray<NSString*> *tempDescArray = [self.delegate longPressExtItemDescArray:_toolbarDescArray];
        if (tempDescArray && [tempDescArray count] > 0) {
            _toolbarDescArray = tempDescArray;
        }
        NSMutableArray<UIImage*> *tempImgArray = [self.delegate longPressExtItemImgArray:_toolbarImgArray];
        if (tempImgArray && [tempImgArray count] > 0) {
            _toolbarImgArray = tempImgArray;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(hideItem:extType:)]) {
            NSArray<NSString*>* hideItems = [self.delegate hideItem:_toolbarDescArray extType:ExtTypeLongPress];
            for (NSString *item in hideItems) {
                NSInteger index = [_toolbarDescArray indexOfObject:item];
                if (index > -1) {
                    [_toolbarDescArray removeObject:item];
                    [_toolbarImgArray removeObjectAtIndex:index];
                }
            }
        }
        _itemImgCount = [_toolbarImgArray count];;
        _itemDescCount = [_toolbarDescArray count];
        _model = [[EMExtModel alloc]initWithType:ExtTypeLongPress itemCount:_itemImgCount];
        [self _setupUI];
    }
    
    return self;
}

- (CGSize)getExtViewSize
{
    return _model.collectionViewSize;
}

- (void)_setupUI {
    //抛出
    //self.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
    self.backgroundColor = [UIColor systemGrayColor];
    
    HorizontalLayout *layout = [[HorizontalLayout alloc] initWithOffset:_model.xOffset yOffset:_model.yOffset];
    layout.itemSize = CGSizeMake(_model.cellLonger, _model.cellLonger + 13.f);
    layout.rowCount = _model.rowCount;
    layout.columCount = _model.columCount;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _model.collectionViewSize.width, _model.collectionViewSize.height) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = YES;
    self.collectionView.pagingEnabled = YES;
    [self addSubview:self.collectionView];
    
    [self.collectionView registerClass:[SessionToolbarCell class] forCellWithReuseIdentifier:@"cell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (_itemImgCount < pageSize) {
        return 1;
    }
    if (_itemImgCount % pageSize == 0) {
        return _itemImgCount / pageSize;
    }
    return _itemImgCount / pageSize + 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (_itemImgCount < pageSize) {
        return _itemImgCount;
    }
    if ((section+1) * pageSize <= _itemImgCount) {
        return pageSize;
    }
    return (_itemImgCount - section * pageSize);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SessionToolbarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    NSInteger index = indexPath.section * pageSize + indexPath.row;
    [cell personalizeToolbar:_toolbarImgArray[index] funcDesc:(index < _itemDescCount) ? _toolbarDescArray[index] : @"" tag:index];
    cell.delegate = self;
    return cell;
}

#pragma mark - SessionToolbarCellDelegate

- (void)toolbarCellDidSelected:(NSInteger)tag itemDesc:(NSString*)itemDesc
{
    //custom
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionAction:itemDesc:extType:)]) {
        [self.delegate chatBarMoreFunctionAction:tag itemDesc:itemDesc extType:_model.type];
    }
    /*
    //default
    if (tag == 5) {
        //群组回执
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionReadReceipt)])
            [self.delegate chatBarMoreFunctionReadReceipt];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(chatBarMoreFunctionAction:)])
        [self.delegate chatBarMoreFunctionAction:tag];*/
}

@end


@interface SessionToolbarCell()
{
    NSInteger _tag;
    CGFloat _cellLonger;
}
@property (nonatomic, strong) UIButton *toolBtn;
@property (nonatomic, strong) UILabel *toolLabel;
@end

@implementation SessionToolbarCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _cellLonger = frame.size.width;
        [self _setupToolbar];
        _tag = -1;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)_setupToolbar {
    self.toolBtn = [[UIButton alloc]init];
    self.toolBtn.layer.cornerRadius = 8;
    self.toolBtn.layer.masksToBounds = YES;
    self.toolBtn.imageEdgeInsets = UIEdgeInsetsMake(2, 10, 2, 10);
    [self.toolBtn addTarget:self action:@selector(cellTapAction) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.toolBtn];
    self.toolBtn.backgroundColor = [UIColor whiteColor];
    [self.toolBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(@(_cellLonger));
        make.height.mas_equalTo(@(_cellLonger));
        make.left.equalTo(self.contentView);
    }];
    
    self.toolLabel = [[UILabel alloc]init];
    self.toolLabel.textColor = [UIColor whiteColor];
    
    [self.toolLabel setFont:[UIFont systemFontOfSize:10.0]];
    self.toolLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.toolLabel];
    [self.toolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toolBtn.mas_bottom).offset(3);
        make.width.mas_equalTo(@(_cellLonger));
        make.height.equalTo(@10);
        make.left.equalTo(self.contentView);
    }];
}

- (void)personalizeToolbar:(UIImage*)itemImg funcDesc:(NSString *)funcDesc tag:(NSInteger)tag
{
    [_toolBtn setImage:itemImg forState:UIControlStateNormal];
    [_toolLabel setText:funcDesc];
    _tag = tag;
}

#pragma mark - Action

- (void)cellTapAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarCellDidSelected:itemDesc:)]) {
        [self.delegate toolbarCellDidSelected:_tag itemDesc:_toolLabel.text];
    }
}

@end
