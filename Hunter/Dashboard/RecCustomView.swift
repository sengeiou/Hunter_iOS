//
//  CustomView.swift
//  TinderSwipeView_Example
//
//  Created by Nick on 29/05/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SDWebImage

class RecCustomView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var profImg: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var profNameLab: UILabel!
    @IBOutlet weak var desigNameLab: UILabel!
    @IBOutlet weak var jobDesc: UITextView!
    @IBOutlet weak var coll_industry: UICollectionView!
    @IBOutlet weak var labelCompanyName: UILabel!
    @IBOutlet weak var labelOnTheMarket: UILabel!
    @IBOutlet weak var labelNoOfEmployees: UILabel!
    @IBOutlet weak var labelYear: UILabel!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelPrivate: UILabel!
    
    var userModel : UserModel! {
        didSet{
            self.profNameLab.text = userModel.name
            
//            self.desigNameLab.text = (userModel.job_details["title"] as! String)
            if let desc = userModel.job_details["description"] as? String{
                self.jobDesc.text = desc
            }
            self.profImg.sd_setImage(with: URL(string: userModel.recruiter["banner_image"] as! String), placeholderImage: UIImage(named: "placeholder.png"))
            self.logoImg.sd_setImage(with: URL(string: userModel.recruiter["profile_image"] as! String), placeholderImage: UIImage(named: "iman.png"))
            print(userModel.job_details)
            
            //            self.imageViewBackground.image = UIImage(named:String(Int(1 + arc4random() % (8 - 1))))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(RecCustomView.className, owner: self, options: nil)
        contentView.fixInViewOne(self)
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowOffset = CGSize(width: 0, height: 1.5)
        layer.shadowRadius = 4.0
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
        
        // Corner Radius
        layer.cornerRadius = 10.0;
        //        imageViewProfile.contentMode = .scaleAspectFill
        //        imageViewProfile.layer.cornerRadius = 30
        //        imageViewProfile.clipsToBounds = true
        let alignedFlowLayout = coll_industry?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        alignedFlowLayout?.minimumLineSpacing = 5.0
        alignedFlowLayout?.minimumInteritemSpacing = 5.0
        alignedFlowLayout?.horizontalAlignment = .left
        alignedFlowLayout?.verticalAlignment = .center
        
    }
    
    @IBAction func expandClick(_ sender: Any) {
        
        let candidateDict:[String: Int] = ["candidate_id": userModel.candidate_id!,"job_id" :userModel.job_details["job_id"] as! Int]
        // Post a notification
        NotificationCenter.default.post(name: Notification.Name("expandClick"), object: nil, userInfo: candidateDict)

    }
    
    
}

extension UIView{
    
    func fixInViewOne(_ container: UIView!) -> Void{
        
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}


extension RecCustomView : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userModel.skills.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HunterRegisterDashBoardCollectionCell", for: indexPath) as! HunterRegisterDashBoardCollectionCell
        let skills = userModel.skills[indexPath.row]["skill"] as! String
        cell.titleLabel.text = skills.uppercased()
        return cell
    }
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    //        return 5.0
    //    }
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    //        return 5.0
    //    }
    
}
extension RecCustomView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var label = UILabel(frame: CGRect.zero)
        let skills = userModel.skills[indexPath.row]["skill"] as! String
        label.text = skills.uppercased()
        label.sizeToFit()
        return CGSize(width: label.frame.width, height: 25)
    }
}
extension RecCustomView : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
    
}


    

