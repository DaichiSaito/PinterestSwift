//
//  NTHorizontalPageViewCell.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 7/1/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import Foundation
import UIKit

let cellIdentify = "cellIdentify"

class NTTableViewCell : UITableViewCell{
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.textLabel?.font = UIFont.systemFontOfSize(13)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
    ViewをaddSubviewした時、Viewのframeを変更した時（親ビューのlayoutSubviews経由、画面回転時など）に呼ばれます。
    大抵意識することなく必要な時に呼ばれるますが、任意のタイミングでsetNeedsLayoutを呼べば手動で実行できます。
    */
    override func layoutSubviews() {
        print("layoutSubviews")
        super.layoutSubviews()
        let imageView :UIImageView = self.imageView!;
        imageView.frame = CGRectZero
        if (imageView.image != nil) {
            let imageHeight = imageView.image!.size.height*screenWidth/imageView.image!.size.width
            imageView.frame = CGRectMake(0, 0, screenWidth, imageHeight)
        }
    }
}
// CollectionViewCellとtableView。タップ後の画面。タップ後の画面の一単位だと思う。
// このテーブルビューをコレクションとして扱いたいがためにUICollectionViewCellを継承させてる？
// NTHorizontalPageViewControllerのcollectionViewメソッドの中でcollectionCellの型として使われてる。
class NTHorizontalPageViewCell : UICollectionViewCell, UITableViewDelegate, UITableViewDataSource{
    var imageName : String?
    var pullAction : ((offset : CGPoint) -> Void)?
    var tappedAction : (() -> Void)?
    let tableView = UITableView(frame: screenBounds, style: UITableViewStyle.Plain)
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.lightGrayColor()
        /*Cellに対して addSubView: でUIButtonやLabelといったViewを追加する事ができるが、 UITableViewCellのインスタンスに直接ではなく、cell.contentViewに追加する。
        */
        // スライドして削除ボタンを表示する際に不具合が生ずる、みたいなことが参考書に書いてあった気がする。
        // このcontentViewはcollectionViewCellのもの。
        contentView.addSubview(tableView)
        tableView.registerClass(NTTableViewCell.self, forCellReuseIdentifier: cellIdentify)
        tableView.delegate = self
        tableView.dataSource = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentify) as! NTTableViewCell!
        cell.imageView?.image = nil
        cell.textLabel?.text = nil
        if indexPath.row == 0 {
            // indexPath.rowが0の時は画像を表示する。
            let image = UIImage(named: imageName!)
            cell.imageView?.image = image
        }else{
            // 上記以外の時はテキストを表示する。
            cell.textLabel?.text = "try pull to pop view controller 😃"
        }
        // ちなみにここでいうcellはテーブルのcellであってコレクションビューのcellではないので注意です。
        cell.setNeedsLayout()
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        var cellHeight : CGFloat = navigationHeight
        if indexPath.row == 0{
            let image:UIImage! = UIImage(named: imageName!)
            let imageHeight = image.size.height*screenWidth/image.size.width
            cellHeight = imageHeight
        }
        return cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tappedAction?()
    }
    
    func scrollViewWillBeginDecelerating(scrollView : UIScrollView){
        print("scrollViewWillBeginDecelerating")
        if scrollView.contentOffset.y < navigationHeight{
            print("pullAction?(offset: scrollView.contentOffset")
            pullAction?(offset: scrollView.contentOffset)
        }
    }
}