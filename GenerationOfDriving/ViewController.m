//
//  ViewController.m
//  GenerationOfDriving
//
//  Created by ZKR on 15/12/31.
//  Copyright © 2015年 ZKR. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <CoreGraphics/CoreGraphics.h>

#define API_KEY  @"5c0bd595963f61124d8ec2d6146b56ab"
@interface ViewController ()<MAMapViewDelegate,UIGestureRecognizerDelegate,AMapSearchDelegate>
{
    MAMapView *_mapView;
    AMapSearchAPI *_searchAPI;
    AMapPOIAroundSearchRequest *_searchRequest;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"代驾";
    [self navLeftRightBtn];
    /*--------------------------------MAMapKit：------------------------------------------*/

    
    [MAMapServices sharedServices].apiKey=API_KEY;
    _mapView=[[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate=self;
    [self.view addSubview:_mapView];
    
    //设置地图类型
    _mapView.mapType = MAMapTypeStandard;
    
//    //设置logo位置
//    _mapView.logoCenter = CGPointMake(50, 50);

    //显示罗盘
    _mapView.showsCompass = YES;
    _mapView.compassOrigin=CGPointMake(self.view.bounds.size.width-42, 70);
    
    
    
    
    // 是否显示用户位置
    _mapView.showsUserLocation=YES;
    // 追踪用户的location更新
    _mapView.userTrackingMode=MAUserTrackingModeFollow;
    //给当前位置进行标注
    [_mapView.userLocation setTitle:@"Jason"];
    [_mapView.userLocation setSubtitle:@"北京欢迎你"];
    
    
    
    //创建大头针对象
    MAPointAnnotation *pointAnnotation=[[MAPointAnnotation alloc] init];
    //插入大头针位置
    CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake(39.91684626, 116.39671326);
    pointAnnotation.coordinate=coordinate; //设置标注的坐标
    pointAnnotation.title=@"北京故宫博物院";//设置标题
    pointAnnotation.subtitle=@"Jason";//设置副标题
    [_mapView selectAnnotation:pointAnnotation animated:YES];
    [_mapView addAnnotation:pointAnnotation];//将标注添加在地图上
    

    
    /*!
     @brief 设置当前地图的缩放级别zoom level
     @param zoomLevel 要设置的zoom level
     @param animated 是否采用动画效果
     从“10”开始测试，逐渐递增
     */
    [_mapView setZoomLevel:11 animated:YES];
    
    
    //添加长按手势－－－－》（暂时响应不了）－－》解决
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.delegate=self;
    _mapView.userInteractionEnabled=YES;
    [_mapView addGestureRecognizer:longPress];
    
    

}
-(void)navLeftRightBtn{
    UIButton* locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    locationBtn.frame = CGRectMake(0, 0, 50, 50);
    [locationBtn setTitle:@"选择" forState:UIControlStateNormal];
    [locationBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    locationBtn.titleLabel.font =[UIFont systemFontOfSize:13];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:locationBtn];
    [locationBtn addTarget:self action:@selector(selectAction:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)selectAction:(UIButton *)sender{
    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:@"选择展现" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    
    UIAlertAction * cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];

    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"显示交通" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        /*!
         @brief 是否显示交通，默认为NO
         */
        _mapView.showTraffic=YES;
    }];
    [alertController addAction:archiveAction];
    
    UIAlertAction *centerAction = [UIAlertAction actionWithTitle:@"家乡坐标" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        /*!
         设置中心点坐标
         纬度和经度
         */
        //创建大头针对象
        MAPointAnnotation *pointAnnotation=[[MAPointAnnotation alloc] init];
        //插入大头针位置
        CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake(35.16837084, 113.88573647);
        pointAnnotation.coordinate=coordinate; //设置标注的坐标
        pointAnnotation.title=@"东荆楼";//设置标题
        pointAnnotation.subtitle=@"我的家";//设置副标题
        [_mapView addAnnotation:pointAnnotation];//将标注添加在地图上
        
        [_mapView setCenterCoordinate:coordinate animated:YES];
        
        
    }];
    [alertController addAction:centerAction];
    
    
    UIAlertAction *searchPOIAction = [UIAlertAction actionWithTitle:@"银行|医院" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

        [self searchPOIAction];
    }];
    [alertController addAction:searchPOIAction];
    
    UIAlertAction *drawPolyLineAction = [UIAlertAction actionWithTitle:@"画折线" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [self drawPolyLine];
    }];
    [alertController addAction:drawPolyLineAction];
    
    
    UIAlertAction *clearDiskAction = [UIAlertAction actionWithTitle:@"清除缓存" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        /*!
         @brief 清除所有磁盘上缓存的地图数据。
         */
        [_mapView clearDisk];
    }];
    [alertController addAction:clearDiskAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

/*!
 @brief 根据anntation生成对应的View
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */
- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"pointReuseIndetifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndetifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
}



- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
    NSArray * array = [NSArray arrayWithArray:_mapView.annotations];
    
    for (int i=0; i<array.count; i++)
        
    {
        
        if (view.annotation.coordinate.latitude ==((MAPointAnnotation*)array[i]).coordinate.latitude)
            
        {
            //获取到当前的大头针  你可以执行一些操作
            NSLog(@"%@",((MAPointAnnotation*)array[i]).title);
            
        }
        
        else
            
        {
            
//            //对其余的大头针进行 删除
//            [_mapView removeAnnotation:array[i]];
            
        }
        
    }
}



#pragma  mark -- 长按手势Action
//解决手势不响应问题
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
-(void)longPress:(UILongPressGestureRecognizer *)longPress {
    
    if (longPress.state != UIGestureRecognizerStateBegan) {
        
        return;
    }

    //获取点位置
    CGPoint point = [longPress locationInView:_mapView];
    
    //将点位置转换成经纬度坐标
    CLLocationCoordinate2D coordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    
    
    //在该点添加一个大头针(标注)
    
    MAPointAnnotation *pointAnn = [[MAPointAnnotation alloc] init];
    pointAnn.coordinate = coordinate;
    pointAnn.title = @"长按的大头针";
    pointAnn.subtitle = @"副标题";
    [_mapView addAnnotation:pointAnn];
}


#pragma mark   searchPOIAction
-(void)searchPOIAction{
    
    /*--------------------------------AMapSearchKit：------------------------------------------*/
    
    //  创建AMapSearchAPI对象，配置APPKEY，同时设置代理对象为self
    /**
     *  AMapSearch的初始化函数。
     *
     *  初始化之前请设置 AMapSearchServices 中的APIKey，否则将无法正常使用搜索服务.
     *  @return AMapSearch类对象实例
     */
    
    [AMapSearchServices sharedServices].apiKey=API_KEY;
    _searchAPI = [[AMapSearchAPI alloc] init];
    _searchAPI.delegate=self;
    
    // 创建搜索周边请求类
    /*
     /// POI周边搜索
     @interface AMapPOIAroundSearchRequest : AMapPOISearchBaseRequest
     
     @property (nonatomic, copy)   NSString     *keywords; //<! 查询关键字，多个关键字用“|”分割
     @property (nonatomic, copy)   AMapGeoPoint *location; //<! 中心点坐标
     @property (nonatomic, assign) NSInteger     radius; //<! 查询半径，范围：0-50000，单位：米 [default = 3000]
     */
    _searchRequest=[[AMapPOIAroundSearchRequest alloc] init];
    _searchRequest.keywords=@"银行|医院";
    _searchRequest.location=[AMapGeoPoint locationWithLatitude:_mapView.userLocation.coordinate.latitude longitude:_mapView.userLocation.coordinate.longitude];
    _searchRequest.radius=1000;
    [_searchAPI AMapPOIAroundSearch:_searchRequest];
}


#pragma  mark  AMapSearchDelegate
/**
 *  当请求发生错误时，会调用代理的此方法.
 *
 *  @param request 发生错误的请求.
 *  @param error   返回的错误.
 */
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    if (request==_searchRequest) {
        NSLog(@"searchError:%@",error);
    }
}

/**
 *  POI查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapPOISearchBaseRequest 及其子类。
 *  @param response 响应结果，具体字段参考 AMapPOISearchResponse 。
 */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    //清空原来的标注（大头针）
    [_mapView removeAnnotations:_mapView.annotations];
    NSLog(@"response:%li",response.count);

    if (response) {
        
        //取出搜索到的POI
        for (AMapPOI *poi in response.pois) {
            
            //poi 的坐标
            CLLocationCoordinate2D coordinate=CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
            //地址
            NSString *address=poi.address;
            
            
            
            [_mapView setCenterCoordinate:coordinate animated:YES];
            //用标注显示
            MAPointAnnotation *pointAnn = [[MAPointAnnotation alloc] init];
            pointAnn.coordinate = coordinate;
            pointAnn.title = poi.name;
            pointAnn.subtitle = address;
            [_mapView addAnnotation:pointAnn];
        }
        
    }else{
        NSLog(@"response:%@",response);
    }
}


#pragma mark 画折线 定制折线视图
-(void)drawPolyLine{
    
    //初始化点
    NSArray *latitudeArray=[NSArray arrayWithObjects:
                             @"39.98264474",
                             
                             @"39.97606774",
                             
                             @"39.97580464",
                             
                             @"39.92342895",
                             
                             @"39.92395554", nil];
    NSArray *longitudeArray = [NSArray arrayWithObjects:
                                
                                @"116.33525848",
                                
                                @"116.340065",
                                
                                @"116.44168854",
                                
                                @"116.46194458",
                                
                                @"116.39705658", nil];
    
    //创建数组
    CLLocationCoordinate2D polyLineCorrds[5];
    
    for (int i=0; i<5; i++) {
        polyLineCorrds[i].latitude=[latitudeArray[i] floatValue];
        polyLineCorrds[i].longitude=[longitudeArray[i] floatValue];
    }
    
    //创建折线对象
    MAPolyline *polyLine=[MAPolyline polylineWithCoordinates:polyLineCorrds count:5];
    //在地图上显示折线
    [_mapView addOverlay:polyLine];
}

/*!
 @brief 根据overlay生成对应的Renderer
 @param mapView 地图View
 @param overlay 指定的overlay
 @return 生成的覆盖物Renderer
 */
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MAPolyline class]]) {
        MAPolylineRenderer *polyLineRenderer=[[MAPolylineRenderer alloc] initWithOverlay:overlay];
        //折线宽度
        polyLineRenderer.lineWidth=3;
        //折线颜色
        polyLineRenderer.strokeColor=[UIColor blackColor];
        //折线连接类型
        polyLineRenderer.lineJoin=kCGLineJoinMiter;
        
        return polyLineRenderer;
    }
    return nil;
}


////要实时获得用户的经纬度:则需要添加下面这个代理方法
//-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
//updatingLocation:(BOOL)updatingLocation
//{
//    if (updatingLocation) {
//        NSLog(@"latitude : %f , longitude : %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
//        
////         //定位后，可设置停止定位(如果停止定位，可能不显示标注)
////         _mapView.showsUserLocation = NO;
//    }
//    
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
