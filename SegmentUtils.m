//
//  SegmentUtils.m
//  CloudMonitor
//
//  Created by 黄梓伦 on 29/12/2017.
//  Copyright © 2017 STS. All rights reserved.
//
#define ButtonTag 100 //按钮的Tag
#define DefaultColor [UIColor colorWithRed:0.4 green:0.3 blue:0.7 alpha:1] //默认颜色
#define ButtonY 22 //按钮在Segment中的Y坐标
#define FixMargin 20 //固定边距

#import "SegmentUtils.h"
#import "UIView+Util.h"

/**
 CGXYHeightFrameMake的Make方法实现

 @param x 传入的X坐标
 @param y 传入的Y坐标
 @param height 传入的高度
 @return XYHeightFrame
 */
XYHeightFrame CGXYHeightFrameMake(CGFloat x, CGFloat y, CGFloat height)
{
    XYHeightFrame rect;
    rect.originX = x;
    rect.originY = y;
    rect.SizeHeight = height;
    return rect;
}


@interface SegmentUtils()

/**
 按钮标题总长度
 */
@property (nonatomic, strong) NSMutableArray *titleLengthArray;

/**
 按钮宽度数组，存放每个按钮的宽度
 */
@property (nonatomic, strong) NSMutableArray *btnArray;

/**
 Segment触发事件的Target
 */
@property (nonatomic, strong) id target;

/**
 Segment触发事件的方法编号 SEL
 */
@property (nonatomic, assign) SEL action;

@end

@implementation SegmentUtils{
    
    UIView *_slider; //标题下的滑条
    CGFloat _totalWidth; //总宽度
    CGFloat _buttonMargin; //Segment上按钮的边距
    CGFloat _buttonWidth; //按钮宽度
    NSInteger _selectedIndex; //当前选中的按钮Index
    BOOL _isFlexibleWidth; //是否自适应宽度
    BOOL _isFirstLayoutSubView; //是否是首次LayoutSubView，防止子视图frame改变多次调用[self layoutSubView]造成控件重叠
   
   
}
#pragma mark ---懒加载---

/**
 标题数组
 */
- (NSMutableArray *)btnArray{
    if (!_btnArray) {
        
        _btnArray = [[NSMutableArray alloc] init];
    }
    return _btnArray;
}

/**
 按钮宽度数组，存放每个按钮的宽度
 */
- (NSMutableArray *)titleLengthArray{
    if (!_titleLengthArray) {
        
        _titleLengthArray = [[NSMutableArray alloc] init];
    }
    return _titleLengthArray;
    
}
#pragma mark ---实例化方法---

/**
 根据Segment总标题文字长度及字体自适应宽度 字体固定为15号
 
 @param frame 需要生成的Segment的原点及高度，类型为XYHeightFrame结构体
 @param items Segement的标题数组，数组元素为字符串类型
 @return 根据Segment总标题文字长度及字体自适应宽度
 */
- (instancetype)initWithFlexibleWidthFrame:(XYHeightFrame)frame items:(NSArray *)items{
    
    return [self initWithFlexibleWidthFrame:frame items:items fontSize:15];;
    
}

/**
 根据Segment总标题文字长度及字体自适应宽度
 
 @param frame 需要生成的Segment的原点及高度，类型为XYHeightFrame结构体
 @param items Segement的标题数组，数组元素为字符串类型
 @param fontSize 字体大小
 @return 根据Segment总标题文字长度及字体自适应宽度
 */
- (instancetype)initWithFlexibleWidthFrame:(XYHeightFrame)frame items:(NSArray *)items fontSize:(CGFloat)fontSize{
    CGRect newFrame = CGRectMake(frame.originX, frame.originY, 20, frame.SizeHeight);
    
    if (self = [super initWithFrame:newFrame]) {
        
        
        _items = items;
        _isFlexibleWidth = YES;
        _fontSize = fontSize;
        _selectedColor = DefaultColor;
        _titleColor = [UIColor grayColor];
        /**
         *  根据items的各个按钮标题长度自适应HZLSegment的宽度
         */
        [self addUpTitleLength]; //计算按钮标题总长度
        [self setNewFrame]; //更新Frame
        _isFirstLayoutSubView = YES;
        _sliderLengthRatio = 0;
        _sliderHeight = 4;
    }
    
    return self;
}

/**
 传入按钮标题字符串生成Segment
 
 @param frame Segment的Frame
 @param items 标题数组
 @return 生成的Segment
 */
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray *)items{
    
    if (self = [super initWithFrame:frame]) {
        
        
        _items = items;
        _fontSize = 15;
        _selectedColor = DefaultColor;
        _titleColor = [UIColor grayColor];
        _isFlexibleWidth = NO;
        _isFirstLayoutSubView = YES;
        _sliderLengthRatio = 0;
        _sliderHeight = 4;
        //此串行队列永远按钮和底部滑块的创建
       
    }
    return self;
}

/**
 重写父类方法,当调用此方法时会抛出异常
 */
- (instancetype)initWithFrame:(CGRect)frame{
  
    NSException *exception = [NSException exceptionWithName:@"SegmentUtils不能使用initWithFrame方法" reason:@"必须传入按钮标题" userInfo:nil];
    
    @throw exception;
}
#pragma mark ---子视图布局---
/**
 子视图布局
 */
- (void)layoutSubviews{
    if (_isFirstLayoutSubView) {
     
        if (!_isFlexibleWidth) {
            
            [self addUpTitleLength];
        }
        [self creatButton];
       
    }
}

/**
 创建按钮底部滑块
 */
- (void)creatSlider{
   
    UIButton *btn = (UIButton *)[self viewWithTag:ButtonTag + _selectedIndex];

    if (_sliderLengthRatio > 0 ) {
        
        _slider = [[UIView alloc] initWithFrame:CGRectMake(btn.x, self.bounds.size.height - 4,btn.width * _sliderLengthRatio, _sliderHeight)];
    }else{
        
        _slider = [[UIView alloc] initWithFrame:CGRectMake(btn.x, self.bounds.size.height - 4,[_titleLengthArray[_selectedIndex] floatValue], _sliderHeight)];
    }
    _slider.backgroundColor =  _selectedColor;
    _slider.centerX = btn.centerX;
    
    [self addSubview:_slider];
}

/**
 创建按钮
 */
- (void)creatButton{
   
    NSMutableArray *originXArray = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0;i < _items.count;i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setTitle:_items[i] forState:UIControlStateNormal];
        
        [btn setTitleColor:_titleColor forState:UIControlStateNormal];
        
        [btn setTitleColor: _selectedColor forState:UIControlStateSelected];
        
        btn.titleLabel.font = [UIFont systemFontOfSize:_fontSize];
        
        btn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        
        btn.tag = ButtonTag + i;
        
        [btn addTarget:self action:@selector(onClickedButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if (i == 0) {
            
            [btn setFrame:CGRectMake(FixMargin, ButtonY, [_titleLengthArray[i] doubleValue], self.bounds.size.height - ButtonY)];
            btn.selected = YES;
            btn.userInteractionEnabled = NO;
            [originXArray addObject:[NSNumber numberWithDouble:FixMargin]];
        }else{
            
            CGFloat originX = [originXArray[i -1] doubleValue] + [_titleLengthArray[i-1] doubleValue] + FixMargin;
            [originXArray addObject:[NSNumber numberWithDouble:originX]];
            [btn setFrame:CGRectMake(originX, ButtonY, [_titleLengthArray[i] doubleValue], self.bounds.size.height - ButtonY)];
        }
        [btn.titleLabel sizeToFit];
        [self addSubview:btn];
        [self.btnArray addObject:btn];
    }

        //更新按钮布局
        [self updateButtonFrame];

}
#pragma mark ---辅助方法---

/**
 设置Segment的新Frame,并更新按钮布局
 */
- (void)setNewFrame{
    
    _buttonMargin = FixMargin;
    CGFloat newWidth = FixMargin * (_items.count +1) + _totalWidth;
    
    self.width = newWidth;
}

/**
 计算完Segment长度后，更新按钮布局
 */
- (void)updateButtonFrame{
    
    //按钮个数的浮点数，这样做防止_btnArray.count(NSUInteger型）强转浮点数可能带来的问题（比如出现负数）
    __block CGFloat btnArrayCount = 0;
    
    [_btnArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        btnArrayCount++;
    }];
    _buttonWidth = self.width / btnArrayCount;
   
    for (NSUInteger i = 0; i < _btnArray.count; i++) {
        
        UIButton *btn = (UIButton *)[self viewWithTag:ButtonTag + i];
        
        btn.width = self.width / btnArrayCount;

        btn.x = i * btn.width;
        
    }
    
    //创建滑块
    [self creatSlider];
}

/**
 设置当前选中的按钮的Index，更新按钮状态

 @param selectedIndex 选中的按钮的Index
 */
- (void)setSelectedIndex:(NSInteger)selectedIndex{
    
    [self layoutSubviews];
    UIButton *currentBtn = _btnArray[_selectedIndex];
    currentBtn.selected = NO;
    currentBtn.userInteractionEnabled = YES;
    UIButton *choosedBtn = _btnArray[selectedIndex];
    
    [self onClickedButton:choosedBtn];
    _selectedIndex = selectedIndex;
}

/**
 改变滑块的宽度

 @param sliderLengthRatio 滑块宽度与按钮宽度的比
 */
- (void)setSliderLengthRatio:(CGFloat)sliderLengthRatio{
    
    if (sliderLengthRatio < 0 || sliderLengthRatio > 1) {
        
        return;
    }
    _sliderLengthRatio = sliderLengthRatio;
}
- (void)setSliderHeight:(CGFloat)sliderHeight{
    
    //浮点数不能精确等于0
    if (sliderHeight > 4 || sliderHeight < 0.01) {
        
        return;
    }
    _sliderHeight  = sliderHeight;
    _slider.height = sliderHeight;
    
}

/**
 按钮点击事件

 @param button 被点击的按钮
 */
- (void)onClickedButton:(UIButton *)button{
    
    _isFirstLayoutSubView = NO;
    UIButton *currentBtn = (UIButton *)[self viewWithTag:ButtonTag + _selectedIndex];
    currentBtn.selected = NO;
    currentBtn.userInteractionEnabled = YES;
    
    button.selected = YES;
    button.userInteractionEnabled = NO;

    _selectedIndex = button.tag - ButtonTag;
    
    self.currentXOffset = button.center.x;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        //当未设置滑块宽度时，滑块宽度根据标题文字宽度而变化,对应浮点数而言，不能用等于进行判断
        if (_sliderLengthRatio < 0) {
        
            _slider.width = [_titleLengthArray[_selectedIndex] doubleValue];
        }
        _slider.center = CGPointMake(button.center.x, _slider.center.y);
        
    }];
    
    if ([self.target respondsToSelector:self.action]) {
#if 1
        //以下代码，避免系统提示及ARC下可能出现的循环引用，实现self.target调用self.action方法编号SEL对应的方法
        //返回self.target中self.action的IMP(方法地址，本质是函数指针)
        IMP imp = [self.target methodForSelector:self.action];
        //将上面方法返回的IMP传递给一函数指针，包含ARC需要的细节（两个隐藏参数,self,_cmd及参数）
        void (*func)(id, SEL,id) = (void *)imp;
        //调用函数
        func(self.target, self.action,self);
        
#elif 0
        //用系统自带的方法，因为self.action不是静态编译，会提示可能出现内存泄露，主要是因为在ARC环境下可能出现循环引用
        [self.target performSelector:self.action withObject:self];
#endif
        
    };
    
}

/**
 为Segment添加响应事件

 @param target 响应事件Target
 @param action 响应事件方法编号 SEL
 */
- (void)addTarget:(id)target withAction:(SEL)action{
    
    self.target = target;
    self.action = action;
}

/**
 计算标题总长图
 */
- (void)addUpTitleLength
{
    _totalWidth = 0;
    [self.titleLengthArray removeAllObjects];
    for (NSUInteger i = 0;i < _items.count;i++) {
        CGSize titleSize ;
        titleSize = [_items[i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:_fontSize]}];
        _totalWidth += titleSize.width;
        [self.titleLengthArray addObject:[NSNumber numberWithDouble:titleSize.width]];
        
    }
}

/**
 Fontsize的Setter方法，可实现Segment字体大小的更改

 @param fontSize 字体大小
 */
- (void)setFontSize:(CGFloat)fontSize
{
    
    if (_isFlexibleWidth) {
        
        [self addUpTitleLength];
        [self setNewFrame];
    }
    
    _fontSize = fontSize;
    
}
@end


