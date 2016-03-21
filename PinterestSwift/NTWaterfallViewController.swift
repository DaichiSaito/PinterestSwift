//
//  ViewController.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 6/30/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import UIKit

let waterfallViewCellIdentify = "waterfallViewCellIdentify"
// NTWaterfallViewControllerを最初にインスタンス化した時(viewDidLoad)にこのデリゲートも生成される。
// てすと
class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate{
    // ナビゲーションがされる時に呼ばれる。
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        // fromVCに何が入るか
        //
        // タップ時 NTWaterFallViewController
        // Back時 NTHorizontalPageViewController
        let fromVCConfromA = (fromVC as? NTTransitionProtocol)
        let fromVCConfromB = (fromVC as? NTWaterFallViewControllerProtocol)
        let fromVCConfromC = (fromVC as? NTHorizontalPageViewControllerProtocol)
        
        // toVCに何が入るか
        //
        // タップ時 NTWaterFallViewController
        // Back時 NTHorizontalPageViewController
        let toVCConfromA = (toVC as? NTTransitionProtocol)
        let toVCConfromB = (toVC as? NTWaterFallViewControllerProtocol)
        let toVCConfromC = (toVC as? NTHorizontalPageViewControllerProtocol)
        if((fromVCConfromA != nil)&&(toVCConfromA != nil)&&(
            (fromVCConfromB != nil && toVCConfromC != nil)||(fromVCConfromC != nil && toVCConfromB != nil))){
            let transition = NTTransition()
            transition.presenting = operation == .Pop
            return  transition
        }else{
            return nil
        }
        
    }
}

class NTWaterfallViewController:UICollectionViewController,CHTCollectionViewDelegateWaterfallLayout, NTTransitionProtocol, NTWaterFallViewControllerProtocol{
//    class var sharedInstance: NSInteger = 0 Are u kidding me?
    var imageNameList : Array <NSString> = []
    let delegateHolder = NavigationControllerDelegate()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoadは１回だけだよな")
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController!.delegate = delegateHolder
        self.view.backgroundColor = UIColor.yellowColor()
        
        var index = 0
        while(index<14){
            let imageName = NSString(format: "%d.jpg", index)
            imageNameList.append(imageName)
            index++
        }
        
        let collection :UICollectionView = collectionView!;
        collection.frame = screenBounds
        collection.setCollectionViewLayout(CHTCollectionViewWaterfallLayout(), animated: false)
        collection.backgroundColor = UIColor.grayColor()
        // classにはNTWaterFallViewCellを設定
        // identifierには"waterfallViewCellIdentify"を設定
        collection.registerClass(NTWaterfallViewCell.self, forCellWithReuseIdentifier: waterfallViewCellIdentify)
        // なくても良さげ。
        collection.reloadData()

    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        print("画像からセルのサイズ設定")
        // 画像からセルのサイズ設定
        let image:UIImage! = UIImage(named: self.imageNameList[indexPath.row] as String)
        let imageHeight = image.size.height*gridWidth/image.size.width
        return CGSizeMake(gridWidth, imageHeight)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        print("画像の設定")
        // 画像の設定
        // ここの引数でidentifierを使用している。
        let collectionCell: NTWaterfallViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(waterfallViewCellIdentify, forIndexPath: indexPath) as! NTWaterfallViewCell
        collectionCell.imageName = self.imageNameList[indexPath.row] as String
        collectionCell.setNeedsLayout()
        return collectionCell;
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        print("画像の数を返却")
        // 画像の数を返却
        return imageNameList.count;
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        print("pageViewController生成")
        // なぜかここでpageViewController生成。タップしたときかな。→タップした時で正解。didSelectItemAtIndexPathだからそりゃそうか。
        let pageViewController =
        NTHorizontalPageViewController(collectionViewLayout: pageViewControllerLayout(), currentIndexPath:indexPath)
        pageViewController.imageNameList = imageNameList
        // 思うにタップ時のindexPathを保存しておいてる。で、その後左右に動かした時にプラスマイナスしてるんじゃないかな。
        // →正解？不正解？
        collectionView.setToIndexPath(indexPath)
        navigationController!.pushViewController(pageViewController, animated: true)
    }
    
    func pageViewControllerLayout () -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        // navigationBarがあるかないかでレイアウト出し分け
        let itemSize  = self.navigationController!.navigationBarHidden ?
        CGSizeMake(screenWidth, screenHeight+20) : CGSizeMake(screenWidth, screenHeight-navigationHeaderAndStatusbarHeight)
        flowLayout.itemSize = itemSize
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        // これによりcollectionViewが横スクロールになる。
        flowLayout.scrollDirection = .Horizontal
        return flowLayout
    }
    
    func viewWillAppearWithPageIndex(pageIndex : NSInteger) {
        // ウォーターフォールに戻る時に呼ばれる。
        var position : UICollectionViewScrollPosition =
        UICollectionViewScrollPosition.CenteredHorizontally.intersect(.CenteredVertically)
        let image:UIImage! = UIImage(named: self.imageNameList[pageIndex] as String)
        let imageHeight = image.size.height*gridWidth/image.size.width
        if imageHeight > 400 {//whatever you like, it's the max value for height of image
           position = .Top
        }
        let currentIndexPath = NSIndexPath(forRow: pageIndex, inSection: 0)
        let collectionView = self.collectionView!;
        collectionView.setToIndexPath(currentIndexPath)
        if pageIndex<2{
            // 戻る際のtableviewが２番目以前の場合、戻った時の画面位置は最上部にセット
            collectionView.setContentOffset(CGPointZero, animated: false)
        }else{
            // 2番目以降の場合は、戻った時の画面位置はそれまで横スクロールで表示していた画像の位置にセット
            // タップし前後の画像にスクロールした後に戻る際に効果的な処理。
            collectionView.scrollToItemAtIndexPath(currentIndexPath, atScrollPosition: position, animated: false)
        }
    }
    
    func transitionCollectionView() -> UICollectionView!{
        // 画面遷移する時はいつでも？
        print("transitionCollectionView-NTWaterfallViewController.swift")
        return collectionView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

