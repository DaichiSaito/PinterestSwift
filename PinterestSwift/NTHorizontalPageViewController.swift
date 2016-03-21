//
//  NTHorizontalPageViewController.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 7/1/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import Foundation
import UIKit

let horizontalPageViewCellIdentify = "horizontalPageViewCellIdentify"

// pageViewControllerなのになぜUICollectionViewControllerを継承しているのか。
// collectionViewをpageViewのように横スクロールさせるため、とみた。
class NTHorizontalPageViewController : UICollectionViewController, NTTransitionProtocol ,NTHorizontalPageViewControllerProtocol{
    
    var imageNameList : Array <NSString> = []
    var pullOffset = CGPointZero
    
    // initの引数には、layoutとタップ時のインデックス。ここのlayoutには.Horizontalの情報が含まれている。
    init(collectionViewLayout layout: UICollectionViewLayout!, currentIndexPath indexPath: NSIndexPath){
        super.init(collectionViewLayout:layout)
        // self.collectionViewを格納する。self.collectionViewはどこでもインスタンス化していないが、おそらくこのクラスがUICollectionViewContorllerを継承しているからそのまま利用できると思われる。
        let collectionView :UICollectionView = self.collectionView!;
        // falseにすると画像がスラスラ流れてしまう。１ページごとに画面を止めるためにtrueにしてると思われる。
        collectionView.pagingEnabled = true
        // collectionViewのクラスにはNTHorizontalPageViewCellを設定。カスタムセルっぽい。
        // identifierも設定。この二つはregisterClassのお作法。
        collectionView.registerClass(NTHorizontalPageViewCell.self, forCellWithReuseIdentifier: horizontalPageViewCellIdentify)
        // 謎。indexPathをどっかに保存しておくんだろうか。
        collectionView.setToIndexPath(indexPath)
        /*
        重要なのは、まずデータ源を更新し、その後でコレクションビューに変更を通知することです。コレ
        クションビュー側のメソッドは、データ源が最新のデータを保持していると想定しているからです。
        この想定が正しくなければ、データ源から誤った項目を受け取り、あるいは存在しない項目を渡すよ
        う要求する結果、アプリケーションがクラッシュする虞があります。
        単一の項目をプログラム上で追加、削除、移動すると、コレクションビュー側のメソッドは自動的
        に、この操作に応じたアニメーションを表示します。しかし、複数の項目を操作（挿入、削除、移
        動）する場合、アニメーション表示はまとめて一度で行う必要があるでしょう。これは、操作をすべ
        てブロック内に記述し、このブロックをperformBatchUpdates:completion:メソッドに渡すことに
        より実現します。このバッチ更新処理では、複数の操作をまとめてひとつと看做してアニメーション
        表示を行うほか、同じブロック内で操作の順序を入れ替えるなど工夫することも可能です。
        */
        // たぶんcollectionViewのリロードが完了したら中のメソッドが呼ばれるんだと思う。
        collectionView.performBatchUpdates({collectionView.reloadData()}, completion: { finished in
            if finished {
                // 画面遷移した時点でUICollectionViewの指定したCellを表示する
                // これをコメントアウトすると、タップ後の次画面遷移時に上部が一瞬黒くなる。けどそれ以外はうまく動いてそう。
                collectionView.scrollToItemAtIndexPath(indexPath,atScrollPosition:.CenteredHorizontally, animated: false)
            }});
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        // cellのインスタンスを作成する。cellのインスタンスはtableViewらしい。NTHorizontalPageViewCell参照。
        // 横にスクロールした時に呼ばれるらしい。
        print("collectionCellの生成")
        let collectionCell: NTHorizontalPageViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(horizontalPageViewCellIdentify, forIndexPath: indexPath) as! NTHorizontalPageViewCell
        collectionCell.imageName = self.imageNameList[indexPath.row] as String
        collectionCell.tappedAction = {}
        collectionCell.pullAction = { offset in
            self.pullOffset = offset
            self.navigationController!.popViewControllerAnimated(true)
        }
        collectionCell.setNeedsLayout()
        return collectionCell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        print("imageNameList.count")
        // タップした時に3回呼ばれる。
        //0,0,14の順で返却される。
        print(imageNameList.count)
        return imageNameList.count;
    }
    
    func transitionCollectionView() -> UICollectionView!{
        // 画像をタップしたときやBack押下時の画面遷移時に呼ばれる。
        // git
        print("transitionCollectionView")
        return collectionView
    }
    
    func pageViewCellScrollViewContentOffset() -> CGPoint{
        // Back押下時にやプルした時に呼ばれる。
        print("self.pullOffset")
        print(self.pullOffset)
        return self.pullOffset
    }
}