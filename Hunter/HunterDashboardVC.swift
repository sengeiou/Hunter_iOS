//
//  ViewController.swift
//  TinderSwipeView
//
//  Created by Nick on 11/05/19.
//  Copyright © 2019 Nick. All rights reserved.
//


import UIKit
import TinderSwipeView
import Alamofire
import SVProgressHUD

var names = [String]()
protocol MyProtocol: class {
    func instantiateNewSecondView(tagged tag : Int)
}
class HunterDashboardVC: UIViewController, UITableViewDelegate, UITableViewDataSource, MyProtocol, UITextViewDelegate {
    @IBOutlet weak var swipe_left: NSLayoutConstraint!
    @IBOutlet weak var swipe_bottom: NSLayoutConstraint!
    @IBOutlet weak var swipe_top: NSLayoutConstraint!
    var baseURL = String()
    var jobList = [String]()
    var jobIDList = [Int]()
    var total_suggestions = [Int]()
    var indx = Int()
    @IBOutlet weak var tbl_jobs: UITableView!
    @IBOutlet weak var noCardLeft: CardView!
    @IBOutlet weak var img_arrow: UIImageView!
    var userModels : [UserModel] = []
    var candidate_Id = 0
    var job_id = 0

    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var txt_msg: UITextView!
    @IBOutlet weak var backMsgView: UIView!
    @IBOutlet weak var messageView: UIView!
    private var swipeView: TinderSwipeView<UserModel>!{
        didSet{
            self.swipeView.delegate = self
        }
    }
    @IBOutlet weak var lab_selectedJob: UILabel!
    @IBOutlet weak var lab_intro: UILabel!
    @IBOutlet weak var lab_introSub: UILabel!

    @IBOutlet weak var viewContainer: UIView!
//    @IBOutlet weak var viewNavigation: UIView!{
//        didSet{
//            self.viewNavigation.alpha = 0.0
//        }
//    }
    var dropDownStatus = false
//    @IBOutlet weak var emojiView: EmojiRateView!
    
//    let userModels : [UserModel] =  {
//        var model : [UserModel] = []
//         for n in 0...names.count-1 {
//            model.append(UserModel(name: names[n], num: "\(n)"))
//        }
//        return model
//    }()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func instantiateNewSecondView(tagged tag : Int){
        
        if (tag == 0) {
            
            swipe_top.constant = 0.0
            swipe_left.constant = 0.0
            swipe_bottom.constant = 0.0
            self.view.layoutIfNeeded()

//            let screenCenter = CGPoint(x:UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
//            let subviewCenter = self.view.convert(self.swipeView.center, to: self.view)
//            let offset = UIOffset(horizontal: screenCenter.x-subviewCenter.x, vertical: screenCenter.y-subviewCenter.y)
//
//            let widthScale = UIScreen.main.bounds.size.width/self.swipeView.frame.size.width
//            let heightScale = UIScreen.main.bounds.size.height/self.swipeView.frame.size.height
//            UIView.animate(withDuration: 1.0, animations: {
//                let scaleTransform = CGAffineTransform(scaleX: widthScale, y: heightScale)
//                let translateTransform = CGAffineTransform(translationX: offset.horizontal, y: offset.vertical)
//                self.swipeView.transform = scaleTransform.concatenating(translateTransform)
//            }, completion: { (finished) in
//
//            })
            
        } else {
            swipe_top.constant = 55.0
            swipe_left.constant = 10.0
            swipe_bottom.constant = 80.0
            self.view.layoutIfNeeded()

//            UIView.animate(withDuration: 1.0, animations: {
//                self.swipeView.transform = CGAffineTransform.identity
//            }, completion: { (finished) in
//
//            })
        }
    }
    @IBAction func dropDownList(_ sender: Any) {
        
        print (dropDownStatus)
        if dropDownStatus == false {
            topSpace.constant = -10
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            dropDownStatus = true
        }
        else if dropDownStatus == true {
            self.img_arrow.transform = CGAffineTransform(scaleX: -1, y: 1)
            topSpace.constant = -210
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            dropDownStatus = false
        }

    }
    
    @IBAction func cancelMsg(_ sender: Any) {
        
        messageView.isHidden = true
        backMsgView.isHidden = true

    }
    @IBAction func sendMsg(_ sender: Any) {
        connectToSendIntroMsgs()
    }
    
    @IBAction func plusClick(_ sender: Any) {
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HunterAllJobsViewController") as! HunterAllJobsViewController
       
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func connectToSendIntroMsgs(){
        let loginType = UserDefaults.standard.object(forKey: "loginType") as? String
        
        if loginType == "candidate" {
            if HunterUtility.isConnectedToInternet(){
                
                
                
                let url = API.candidateBaseURL + API.elevatorPitchURL
                
                print(url)
                HunterUtility.showProgressBar()
                
                
                let headers    = [ "Authorization" : "Bearer " + accessToken]
                print(headers)
                
                
                
                let parameters    = [ "job_id" : job_id ,  "job_message" : txt_msg.text!] as [String : Any]
                print(parameters)
                
                //            job_id
                //            candidate_id
                //            job_message
                
                
                
                Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
                    
                    switch response.result {
                    case .success:
                        if let responseDict = response.result.value as? NSDictionary{
                            print(responseDict)
                            SVProgressHUD.dismiss()
                            if let status = responseDict.value(forKey: "status"){
                                if status as! Int == 1{
                                    self.messageView.isHidden = true
                                    self.backMsgView.isHidden = true
                                }
                                else if status as! Int == 2 {
                                    let alert = UIAlertController(title: "", message: responseDict.value(forKey: "message") as? String, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                    
                                    print("Logout api")
                                    
                                    UserDefaults.standard.removeObject(forKey: "accessToken")
    UserDefaults.standard.removeObject(forKey: "loggedInStat")
                                    accessToken = String()
                                    
                                    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                    let mainRootController = storyBoard.instantiateViewController(withIdentifier: "HunterCreateAccountVC") as! HunterCreateAccountVC
                                    let navigationController:UINavigationController = storyBoard.instantiateInitialViewController() as! UINavigationController
                                    navigationController.viewControllers = [mainRootController]
                                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                    appDelegate.window?.rootViewController = navigationController
                                }
                                else{
                                    let alert = UIAlertController(title: "", message: responseDict.value(forKey: "error") as? String, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                }}
                        }
                        
                        
                        
                        
                    case .failure(let error):
                        SVProgressHUD.dismiss()
                        print(error)
                        let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }else{
                print("no internet")
            }

            
        }
        else {
        if HunterUtility.isConnectedToInternet(){
            
            
            
            let url = API.recruiterBaseURL + API.getSendIntroMsgsURL
            
            print(url)
            HunterUtility.showProgressBar()
            
            
            let headers    = [ "Authorization" : "Bearer " + accessToken]
            print(headers)
            
            
 
            let parameters    = [ "job_id" : job_id , "candidate_id" : candidate_Id , "job_message" : txt_msg.text!] as [String : Any]
            print(parameters)

//            job_id
//            candidate_id
//            job_message
            
            
            
            Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
                
                switch response.result {
                case .success:
                    if let responseDict = response.result.value as? NSDictionary{
                        print(responseDict)
                        SVProgressHUD.dismiss()
                        if let status = responseDict.value(forKey: "status"){
                            if status as! Int == 1{
                                self.messageView.isHidden = true
                                self.backMsgView.isHidden = true
                            }
                        else if status as! Int == 2 {
                            let alert = UIAlertController(title: "", message: responseDict.value(forKey: "message") as? String, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                            print("Logout api")
                            
                            UserDefaults.standard.removeObject(forKey: "accessToken")
    UserDefaults.standard.removeObject(forKey: "loggedInStat")
                            accessToken = String()
                            
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let mainRootController = storyBoard.instantiateViewController(withIdentifier: "HunterCreateAccountVC") as! HunterCreateAccountVC
                            let navigationController:UINavigationController = storyBoard.instantiateInitialViewController() as! UINavigationController
                            navigationController.viewControllers = [mainRootController]
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = navigationController
                        }
                        else{
                            let alert = UIAlertController(title: "", message: responseDict.value(forKey: "error") as? String, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                            }))
                            self.present(alert, animated: true, completion: nil)
                            }}
                    }
                    
                    
                    
                    
                case .failure(let error):
                    SVProgressHUD.dismiss()
                    print(error)
                    let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            print("no internet")
        }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.expandClick(notification:)), name: Notification.Name("expandClick"), object: nil)

    }
    
    @objc func expandClick(notification: Notification) {
        
//         self.tabBarController?.selectedIndex = 0
//         let candidateDataDict:[String: Int] = ["candidate_Id": candidate_Id]
//
//        // Post a notification
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "candidate_Id"), object: nil, userInfo: candidateDataDict)
        var candidate_IdPassed = Int()
        if let candidate_Id = notification.userInfo?["candidate_id"] as? Int {
        // do something with your image
            candidate_IdPassed = candidate_Id
        }
        var job_idPassed = Int()
        if let job_id = notification.userInfo?["job_id"] as? Int {
        // do something with your image
            job_idPassed = job_id
        }
        let vc = UIStoryboard.init(name: "Candidate", bundle: nil).instantiateViewController(withIdentifier: "HunterCandidateProVC") as! HunterCandidateProVC
        vc.candidate_idPassed = candidate_IdPassed
        vc.job_id = job_idPassed
         self.navigationController?.pushViewController(vc, animated: true)
        
        
        
    }

 
    
    
    override func viewWillAppear(_ animated: Bool) {
        UserDefaults.standard.set("loggedIn", forKey: "loggedInStat")
        
        let loginType = UserDefaults.standard.object(forKey: "loginType") as? String
        
        if loginType == "candidate" {
            self.connectToGetJobs()
            self.lab_intro.text = "ELEVATOR PITCH"
            self.lab_introSub.text = "Now's your chance. Tell them what makes you the perfect candidate!"
            
            
        }else {
            
             self.connectToGetCandidates()
            
            
        }
        txt_msg.text = "Type your message here ..."
        messageView.isHidden = true
        backMsgView.isHidden = true
        self.noCardLeft.isHidden = true
        self.navigationController?.navigationBar.isHidden = true

        setNeedsStatusBarAppearanceUpdate()

    }
    override func viewDidAppear(_ animated: Bool) {
         self.navigationController?.navigationBar.isHidden = true

              if userModels.count == 0 {
                self.noCardLeft.isHidden = false

            }
            else {
                self.noCardLeft.isHidden = true

            }
         
    }
    func createCards(){
        
        let loginType = UserDefaults.standard.object(forKey: "loginType") as? String

        if loginType == "candidate" {

        // Dynamically create view for each tinder card
        let contentView: (Int, CGRect, UserModel) -> (UIView) = { (index: Int ,frame: CGRect , userModel: UserModel) -> (UIView) in
            self.indx = index
            // Programitcally creating content view
            //            if index % 2 != 0 {
            //                return self.programticViewForOverlay(frame: frame, userModel: userModel)
            //            }
            //            // loading contentview from nib
            //            else{
            
            
            let customView = CustomView(frame: frame)
            customView.delegate = self

            customView.userModel = userModel
            let nib = UINib(nibName: "MyCollectionViewCell", bundle: nil)
            customView.coll_industry?.register(nib, forCellWithReuseIdentifier: "HunterRegisterDashBoardCollectionCell")
 
            //                customView.buttonAction.addTarget(self, action: #selector(self.customViewButtonSelected), for: UIControl.Event.touchUpInside)
            return customView
            //            }
        }
        
        swipeView = TinderSwipeView<UserModel>(frame: viewContainer.bounds, contentView: contentView)
        viewContainer.addSubview(swipeView)
        swipeView.showTinderCards(with: userModels ,isDummyShow: true)
        }else {
            
            // Dynamically create view for each tinder card
            let contentView: (Int, CGRect, UserModel) -> (UIView) = { (index: Int ,frame: CGRect , userModel: UserModel) -> (UIView) in
                
                // Programitcally creating content view
                //            if index % 2 != 0 {
                //                return self.programticViewForOverlay(frame: frame, userModel: userModel)
                //            }
                //            // loading contentview from nib
                //            else{
                
                
                let customView = RecCustomView(frame: frame)
                customView.userModel = userModel
                let nib = UINib(nibName: "MyCollectionViewCell", bundle: nil)
                customView.coll_industry?.register(nib, forCellWithReuseIdentifier: "HunterRegisterDashBoardCollectionCell")
                
                //                customView.buttonAction.addTarget(self, action: #selector(self.customViewButtonSelected), for: UIControl.Event.touchUpInside)
                return customView
                //            }
            }
            
            swipeView = TinderSwipeView<UserModel>(frame: viewContainer.bounds, contentView: contentView)
            viewContainer.addSubview(swipeView)
            swipeView.showTinderCards(with: userModels ,isDummyShow: true)
        }
    }
    private func programticViewForOverlay(frame:CGRect, userModel:UserModel) -> UIView{
        
        let containerView = UIView(frame: frame)
        
        let backGroundImageView = UIImageView(frame:containerView.bounds)
        backGroundImageView.image = UIImage(named:String(Int(1 + arc4random() % (8 - 1))))
        backGroundImageView.contentMode = .scaleAspectFill
        backGroundImageView.clipsToBounds = true;
        containerView.addSubview(backGroundImageView)
        
        let profileImageView = UIImageView(frame:CGRect(x: 25, y: frame.size.height - 80, width: 60, height: 60))
        profileImageView.image =  #imageLiteral(resourceName: "profileimage")
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 30
        profileImageView.clipsToBounds = true
        containerView.addSubview(profileImageView)
        
        let labelText = UILabel(frame:CGRect(x: 90, y: frame.size.height - 80, width: frame.size.width - 100, height: 60))
        labelText.attributedText = self.attributeStringForModel(userModel: userModel)
        labelText.numberOfLines = 2
        containerView.addSubview(labelText)
        
        return containerView
    }
    
    @objc func customViewButtonSelected(button:UIButton){
        
        if let customView = button.superview(of: CustomView.self) , let userModel = customView.userModel{
            print("button selected for \(userModel.name!)")
        }
        
    }
    
    private func attributeStringForModel(userModel:UserModel) -> NSAttributedString{
        
        let attributedText = NSMutableAttributedString(string: userModel.name, attributes: [.foregroundColor: UIColor.white,.font:UIFont.boldSystemFont(ofSize: 25)])
        attributedText.append(NSAttributedString(string: "\nnums :\( userModel.num!) (programitically)", attributes: [.foregroundColor: UIColor.white,.font:UIFont.systemFont(ofSize: 18)]))
        return attributedText
    }
    
    
    @IBAction func leftSwipeAction(_ sender: Any) {
        if let swipeView = swipeView{
            swipeView.makeLeftSwipeAction()
        }
    }
    
    @IBAction func rightSwipeAction(_ sender: Any) {
        if let swipeView = swipeView{
            swipeView.makeRightSwipeAction()
        }
    }
    
    @IBAction func undoButtonPressed(_ sender: Any) {
        if let swipeView = swipeView{
            swipeView.undoCurrentTinderCard()
        }
    }
    //MARK:- Textview delegates
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Type your message here ..." {
            textView.text = nil
            txt_msg.textColor = UIColor.darkGray
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            txt_msg.text = "Type your message here ..."
            txt_msg.textColor = UIColor.lightGray
        }
    }
    //MARK:- Webservice
    func connectToGetJobs(){
        if HunterUtility.isConnectedToInternet(){
             let url = API.candidateBaseURL + API.getJobsURL
            print(url)
            HunterUtility.showProgressBar()
            
            
            let headers    = [ "Authorization" : "Bearer " + accessToken]
            print(headers)

            Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
                
                switch response.result {
                case .success:
                    if let responseDict = response.result.value as? NSDictionary{
                        print(responseDict)
                        SVProgressHUD.dismiss()
                        if let status = responseDict.value(forKey: "status"){
                            
                                if status as! Int == 1 {
                                if let data = responseDict.value(forKey: "data") as? NSDictionary {
                                print (data)
                                var n = 0
                                    
                                    if data.allKeys.count == 0 {
                                        self.noCardLeft.isHidden = false
                                        
                                    }
                                    else  {
                                        self.noCardLeft.isHidden = true
                                        
                                    }
                                for key in data.allKeys {
                                    
                                    let mainDic = data[key] as! NSDictionary
                                    let recruiterDict = mainDic["recruiter"] as! NSDictionary
                                    let companyName =  recruiterDict["company_name"] as! String
                                    let job_detailsDict = mainDic["job_details"] as! NSDictionary
                                    let skillsArrDict = mainDic["skills"] as! [NSDictionary]
                                    let candidate_Id = recruiterDict["candidate_id"] as! Int

                                    self.userModels.append(UserModel(name: companyName, recruiter: recruiterDict, job_details: job_detailsDict, skills: skillsArrDict, num: "\(n)",candidate_id:candidate_Id))
                                    n = n + 1
                                    
                                }
                                
                                
  //                                self.jobsDict = data
                                self.createCards()
                                
                                
                                }
                                else {
                                        self.noCardLeft.isHidden = false
                                        
                                    
                                    }
                            }
                            else if status as! Int == 2 {
                                let alert = UIAlertController(title: "", message: responseDict.value(forKey: "message") as? String, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                                }))
                                self.present(alert, animated: true, completion: nil)
                                
                                print("Logout api")
                                
                                UserDefaults.standard.removeObject(forKey: "accessToken")
    UserDefaults.standard.removeObject(forKey: "loggedInStat")
                                accessToken = String()
                                
                                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                let mainRootController = storyBoard.instantiateViewController(withIdentifier: "HunterCreateAccountVC") as! HunterCreateAccountVC
                                let navigationController:UINavigationController = storyBoard.instantiateInitialViewController() as! UINavigationController
                                navigationController.viewControllers = [mainRootController]
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.window?.rootViewController = navigationController
                            }
                            else{
                                let alert = UIAlertController(title: "", message: responseDict.value(forKey: "error") as? String, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }else{
                            let alert = UIAlertController(title: "", message: responseDict.value(forKey: "message") as? String, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    
                    
                    
                    
                case .failure(let error):
                    SVProgressHUD.dismiss()
                    print(error)
                    let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            print("no internet")
        }
    }
    
    func connectToGetCandidates(){
        if HunterUtility.isConnectedToInternet(){
            
 
//            let url = API.recruiterBaseURL + API.getCandidateSuggsURL
            let url = API.recruiterBaseURL + API.candidateSuggestionsURL

            print(url)
            HunterUtility.showProgressBar()
            
            
            let headers    = [ "Authorization" : "Bearer " + accessToken]
            print(headers)
            
            let parameters = [ "job_id" : job_id]
            Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
                
                switch response.result {
                case .success:
                    if let responseDict = response.result.value as? NSDictionary{
                        print(responseDict)
                        SVProgressHUD.dismiss()
                        if let status = responseDict.value(forKey: "status"){
                            if status as! Int == 1{
                                let data = responseDict.value(forKey: "data") as! NSDictionary
                                print (data)
                                var n = 0
                                let candidate_cards = data.value(forKey: "candidate_cards") as! NSDictionary
                                let candidates = candidate_cards.value(forKey: "cards") as! [NSDictionary]
                                if candidates.count == 0 {
                                      self.noCardLeft.isHidden = false
                                        
                                    
                                    
                                        
                                    
                                }
                                else {
                                    
                                    self.noCardLeft.isHidden = true
                                for mainDic in candidates{
                                    print(mainDic)
                                    let recruiterDict = mainDic
                                    let companyName =  recruiterDict["first_name"] as! String
                                    let job_detailsDict = mainDic
                                    let skillsArrDict = mainDic["skills"] as! [NSDictionary]
                                    let candidate_Id = recruiterDict["candidate_id"] as! Int
                                    

                                    self.userModels.append(UserModel(name: companyName, recruiter: recruiterDict, job_details: job_detailsDict, skills: skillsArrDict, num: "\(n)", candidate_id:candidate_Id ))
                                    n = n + 1
                                }
                                self.createCards()
                                }
                                self.jobList = []
                                self.jobIDList = []
                                self.total_suggestions = []
                                
                                 let jobs = candidate_cards.value(forKey: "jobs") as! [NSDictionary]

                                    for dic in jobs {
                                    self.jobList.append(dic["title"] as! String)
                                    self.jobIDList.append(dic["id"] as! Int)
                                    self.total_suggestions.append(dic["total_matched_candidate"] as! Int)

                                    self.lab_selectedJob.text = self.jobList[0]
                                    self.job_id = self.jobIDList[0]
                                    self.tbl_jobs.reloadData()
                                    }
                                
                            }
                            else if status as! Int == 2 {
                                let alert = UIAlertController(title: "", message: responseDict.value(forKey: "message") as? String, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                                }))
                                self.present(alert, animated: true, completion: nil)
                                
                                print("Logout api")
                                
                                UserDefaults.standard.removeObject(forKey: "accessToken")
    UserDefaults.standard.removeObject(forKey: "loggedInStat")
                                accessToken = String()
                                
                                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                                let mainRootController = storyBoard.instantiateViewController(withIdentifier: "HunterCreateAccountVC") as! HunterCreateAccountVC
                                let navigationController:UINavigationController = storyBoard.instantiateInitialViewController() as! UINavigationController
                                navigationController.viewControllers = [mainRootController]
                                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                appDelegate.window?.rootViewController = navigationController
                            }
                            else{
                                let alert = UIAlertController(title: "", message: responseDict.value(forKey: "error") as? String, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }else{
                            let alert = UIAlertController(title: "", message: responseDict.value(forKey: "message") as? String, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    
                    
                    
                    
                case .failure(let error):
                    SVProgressHUD.dismiss()
                    print(error)
                    let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            print("no internet")
        }
    }
    
    
    // MARK:- Tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobList.count + 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HunterJobListTableViewCell", for: indexPath) as! HunterJobListTableViewCell
        cell.selectionStyle = .none
        if indexPath.row == 0
        {
        cell.labelTitle.text = ""
        cell.labelSubTitle.text = "Edit/Post a Job"
    }
        else {
            cell.labelTitle.text = jobList[indexPath.row-1]
            cell.labelSubTitle.text = "\(total_suggestions[indexPath.row-1]) MATCHES"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HunterAllJobsViewController") as! HunterAllJobsViewController
           
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
        self.lab_selectedJob.text = jobList[indexPath.row-1]
        self.job_id = jobIDList[indexPath.row-1]
        self.connectToGetCandidates()
        self.img_arrow.transform = CGAffineTransform(scaleX: -1, y: 1)
        topSpace.constant = -210
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        dropDownStatus = false
        }
    }
    
}

extension HunterDashboardVC : TinderSwipeViewDelegate{
    
    func dummyAnimationDone() {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveLinear, animations: {
//            self.viewNavigation.alpha = 1.0
        }, completion: nil)
        print("Watch out shake action")
    }
    
    func didSelectCard(model: Any) {
        print("Selected card")
    }
    
    func fallbackCard(model: Any) {
        //        emojiView.rateValue =  2.5
        let userModel = model as! UserModel
        print("Cancelling \(userModel.name!)")
    }
    
    func cardGoesLeft(model: Any) {
        //        emojiView.rateValue =  2.5
        let userModel = model as! UserModel
        print("Watchout Left \(userModel.name!)")
        let loginType = UserDefaults.standard.object(forKey: "loginType") as? String

        if loginType == "candidate" {
            connectToSwipeCandidates(0, 1, userModel.job_details["id"] as! Int)

        }
        else {
        connectToSwipeCandidates(userModel.candidate_id!, 1 , self.job_id)
        candidate_Id = userModel.candidate_id!
        }
    }
    
    func cardGoesRight(model : Any) {
        //        emojiView.rateValue =  2.5
        let userModel = model as! UserModel
        print("Watchout Right \(userModel.name!)")
        let loginType = UserDefaults.standard.object(forKey: "loginType") as? String
        
        if loginType == "candidate" {
            connectToSwipeCandidates(0, 0,userModel.job_details["id"] as! Int)
         }
        else {
        connectToSwipeCandidates(userModel.candidate_id!, 0 , self.job_id)
        candidate_Id = userModel.candidate_id!
        }
    }
    
    func undoCardsDone(model: Any) {
        //        emojiView.rateValue =  2.5
        let userModel = model as! UserModel
        print("Reverting done \(userModel.name!)")
    }
    
    func endOfCardsReached() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveLinear, animations: {
//            self.viewNavigation.alpha = 0.0
            
             
        }, completion: nil)
        print("End of all cards")
        self.noCardLeft.isHidden = false

    }
    
    func currentCardStatus(card object: Any, distance: CGFloat) {
        if distance == 0 {
            //            emojiView.rateValue =  2.5
        }else{
            let value = Float(min(abs(distance/100), 1.0) * 5)
            //            let sorted = distance > 0  ? 2.5 + (value * 5) / 10  : 2.5 - (value * 5) / 10
            //            emojiView.rateValue =  sorted
        }
     }


    func connectToSwipeCandidates(_ candidate_ID : Int , _ decision : Int, _ job_id : Int){
        if HunterUtility.isConnectedToInternet(){
            
            let loginType = UserDefaults.standard.object(forKey: "loginType") as? String
            var parameters =  [String : Any]()
            if loginType == "candidate" {
                baseURL = API.candidateBaseURL  + API.jobsSwipesURL
                parameters = [ "decision" : decision , "job_id" : job_id] as [String : Any]

            }else{
                baseURL = API.recruiterBaseURL  + API.getCandidateSwipeURL
                parameters = [ "decision" : decision , "candidate_id" : candidate_ID, "job_id" : job_id] as [String : Any]
            }
            let url = baseURL
            
            print(url)
            HunterUtility.showProgressBar()
            
            
            let headers    = [ "Authorization" : "Bearer " + accessToken]
            print(headers)

            Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
                
                switch response.result {
                case .success:
                    if let responseDict = response.result.value as? NSDictionary{
                        print(responseDict)
                        SVProgressHUD.dismiss()
                        if let status = responseDict.value(forKey: "status"){
                            if status as! Int == 1{
                                if decision == 0 {
                                    if loginType == "candidate" {
                                        let data = responseDict.value(forKey: "data") as! NSDictionary
                                        
                                        
                                        self.job_id = Int(data["job_id"] as! String)!
                                        self.txt_msg.text = "Type your message here ..."
                                        self.messageView.isHidden = false
                                        self.backMsgView.isHidden = false
                                    }
                                    else {
                                        
                                        let data = responseDict.value(forKey: "data") as! NSDictionary
                                        
                                        
                                        self.candidate_Id = Int(data["candidate_id"] as! String)!
                                        self.txt_msg.text = "Type your message here ..."
                                        self.messageView.isHidden = false
                                        self.backMsgView.isHidden = false
                                    }
                                }
                                
                             }
                        else if status as! Int == 2 {
                            let alert = UIAlertController(title: "", message: responseDict.value(forKey: "message") as? String, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                            }))
                            self.present(alert, animated: true, completion: nil)
                            
                            print("Logout api")
                            
                            UserDefaults.standard.removeObject(forKey: "accessToken")
    UserDefaults.standard.removeObject(forKey: "loggedInStat")
                            accessToken = String()
                            
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let mainRootController = storyBoard.instantiateViewController(withIdentifier: "HunterCreateAccountVC") as! HunterCreateAccountVC
                            let navigationController:UINavigationController = storyBoard.instantiateInitialViewController() as! UINavigationController
                            navigationController.viewControllers = [mainRootController]
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.window?.rootViewController = navigationController
                        }
                        else{
                            let alert = UIAlertController(title: "", message: responseDict.value(forKey: "error") as? String, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                        }
                    }
                    
                    
                    
                    
                case .failure(let error):
                    SVProgressHUD.dismiss()
                    print(error)
                    let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }else{
            print("no internet")
        }
    }
}

extension UIView {
    
    func superview<T>(of type: T.Type) -> T? {
        return superview as? T ?? superview.map { $0.superview(of: type)! }
    }
    
    func subview<T>(of type: T.Type) -> T? {
        return subviews.compactMap { $0 as? T ?? $0.subview(of: type) }.first
    }
}
