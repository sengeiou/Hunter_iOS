//
//  HunterRegisterCompOneVC.swift
//  Hunter
//
//  Created by Zubin Manak on 9/24/19.
//  Copyright © 2019 Zubin Manak. All rights reserved.
//

import UIKit
import iOSDropDown
import Alamofire
import SVProgressHUD
extension DateFormatter {
    func years<R: RandomAccessCollection>(_ range: R) -> [String] where R.Iterator.Element == Int {
        setLocalizedDateFormatFromTemplate("yyyy")
        var comps = DateComponents(month: 1, day: 1)
        var res = [String]()
        for y in range {
            comps.year = y
            if let date = calendar.date(from: comps) {
                res.append(string(from: date))
            }
        }
        
        return res
    }
}
class HunterRegisterCompOneVC: UIViewController, UITextViewDelegate, UITextFieldDelegate,hunterDelegate {
    func selectedData(selectedDict: NSDictionary, isFrom: String) {
        if isFrom == "businessType" {
            print(selectedDict["name"] as! String)
            self.txt_businessType.text = (selectedDict["name"] as! String)
            selectedBusinessType = selectedDict["name"] as! String
            selectedBusinessTypeID = selectedDict["id"] as! String
        }
        else {
            print(selectedDict["name"] as! String)
            self.txt_companySize.text = (selectedDict["name"] as! String)
            selectedCompanySize = selectedDict["name"] as! String
            selectedCompanySizeID = selectedDict["id"] as! String
        }
    }
    

    @IBOutlet weak var txt_desc: UITextView!
 
    @IBOutlet weak var txt_companySize: HunterTextField!
    @IBOutlet weak var txt_businessType: HunterTextField!
    @IBOutlet weak var contButton: UIButton!
    var businessTypeArr = [String]()
    var businessTypeIDArr = [String]()
    
    var company_sizeArr = [String]()
    var company_sizeIDArr = [String]()
    
    var selectedBusinessType = String()
    var selectedCompanySize = String()
    
    var selectedBusinessTypeID = String()
    var selectedCompanySizeID = String()
    
    var businessTypeDict = NSDictionary()
    var company_sizeDict = NSDictionary()

     
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.hideKeyboardWhenTappedAround()
        
         
        
        connectToGetCompanyDataStep3()
        // Do any additional setup after loading the view.
        self.txt_desc.delegate = self
        txt_desc.text = "Description..."
        txt_desc.textColor = UIColor.officialApplePlaceholderGray

    }
    @IBAction func companySizeClick(_ sender: Any) {
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let HunterPickerViewController = storyboard.instantiateViewController(withIdentifier: "HunterPickerViewController") as! HunterPickerViewController
            HunterPickerViewController.isFrom = "companySize"
        HunterPickerViewController.passedDict = company_sizeDict

            HunterPickerViewController.delegate = self
            HunterPickerViewController.modalPresentationStyle = .overFullScreen
            self.present(HunterPickerViewController, animated: true, completion: nil)
        
    }
    // businessType
    @IBAction func businessTypeClick(_ sender: Any) {
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let HunterPickerViewController = storyboard.instantiateViewController(withIdentifier: "HunterPickerViewController") as! HunterPickerViewController
            HunterPickerViewController.isFrom = "businessType"
        HunterPickerViewController.passedDict = businessTypeDict
            HunterPickerViewController.delegate = self
            HunterPickerViewController.modalPresentationStyle = .overFullScreen
            self.present(HunterPickerViewController, animated: true, completion: nil)
        
    }
    //MARK:- Textfield delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
         
            if textField.text == ""{
                self.contButton.setTitleColor(UIColor.init(hexString:"300471" ), for: UIControl.State.normal)
                self.contButton.backgroundColor = UIColor.init(hexString:"E9E4F2" )
            }else{
                if self.txt_companySize.text != "" && self.txt_businessType.text != "" && self.txt_desc.text != "" && self.txt_desc.text != "Description..."{
                    self.contButton.setTitleColor(UIColor.init(hexString:"E9E4F2" ), for: UIControl.State.normal)
                    self.contButton.backgroundColor = UIColor.init(hexString:"6B3E99" )
                }
            }
        
    }
    //MARK:- Textview delegates
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Description..."{
            textView.text = ""
            textView.textColor = Color.darkVioletColor
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == ""{
            textView.text = "Description..."
            textView.textColor = UIColor.officialApplePlaceholderGray
            
            self.contButton.setTitleColor(UIColor.init(hexString:"300471" ), for: UIControl.State.normal)
            self.contButton.backgroundColor = UIColor.init(hexString:"E9E4F2" )
        }else{
            if self.txt_companySize.text != "" && self.txt_businessType.text != "" && self.txt_desc.text != "" && self.txt_desc.text != "Description..."{
                self.contButton.setTitleColor(UIColor.init(hexString:"E9E4F2" ), for: UIControl.State.normal)
                self.contButton.backgroundColor = UIColor.init(hexString:"6B3E99" )
            }else{
                self.contButton.setTitleColor(UIColor.init(hexString:"300471" ), for: UIControl.State.normal)
                self.contButton.backgroundColor = UIColor.init(hexString:"E9E4F2" )
            }
        }
    }
    //MARK:- Webservice
    func connectToGetCompanyDataStep3(){
        if HunterUtility.isConnectedToInternet(){
//            https://huntrapp.chkdemo.com/api/recruiter/registration/get-company-data-step-3
            let url = API.recruiterBaseURL + API.registerGetCompanyDataStep3URL
            print(url)
            HunterUtility.showProgressBar()
            
            
            let headers    = [ "Authorization" : "Bearer " + accessToken]
            
            Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
                
                switch response.result {
                case .success:
                    if let responseDict = response.result.value as? NSDictionary{
                        print(responseDict)
                        SVProgressHUD.dismiss()
                        if let status = responseDict.value(forKey: "status"){
                            if status as! Int == 1{
                               let data = responseDict.value(forKey: "data") as! NSDictionary
                               let company_registration = data.value(forKey:"company_registration") as! NSDictionary
                               self.businessTypeDict = company_registration.value(forKey: "businessType") as! NSDictionary
                               self.company_sizeDict = company_registration.value(forKey: "companySize") as! NSDictionary

                                

                                
                                self.businessTypeArr = self.businessTypeDict.allValues as! [String]
                                self.businessTypeIDArr = self.businessTypeDict.allKeys as! [String]
                                
                                self.company_sizeArr = self.company_sizeDict.allValues as! [String]
                                self.company_sizeIDArr = self.company_sizeDict.allKeys as! [String]
                                
                                  
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
    func connectToRegisterSavePreferedLocations(){
        if HunterUtility.isConnectedToInternet(){
            
            let url = API.recruiterBaseURL + API.registerSaveCompanyBioStep3URL
            print(url)
            HunterUtility.showProgressBar()
            
//company_size_id
//business_type
//company_bio
            let paramsDict = ["company_size_id": Int(selectedCompanySizeID)! , "business_type" : Int(selectedBusinessTypeID)! ,  "company_bio" : txt_desc.text! ] as   [String : Any]
            
            let headers    = [ "Authorization" : "Bearer " + accessToken]
            
            Alamofire.request(url, method: .post, parameters: paramsDict, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
                
                switch response.result {
                case .success:
                    if let responseDict = response.result.value as? NSDictionary{
                        print(responseDict)
                        SVProgressHUD.dismiss()
                        if let status = responseDict.value(forKey: "status"){
                            if status as! Int == 1   {
                                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HunterRegisterCompTwoVC") as! HunterRegisterCompTwoVC
                                self.navigationController?.pushViewController(vc, animated: true)
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
                        else{
                            let alert = UIAlertController(title: "", message: responseDict.value(forKey: "error") as? String, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }else{
                        SVProgressHUD.dismiss()
                        //                        let alert = UIAlertController(title: "", message: (response.result.value as! NSDictionary).value(forKey: "msg") as? String, preferredStyle: .alert)
                        //                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .cancel, handler: nil))
                        //                        self.present(alert, animated: true, completion: nil)
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btn_continue(_ sender: Any) {
        if txt_companySize.text == ""{
            let alert = UIAlertController(title: "", message:
                "Please select company size.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            self.present(alert, animated: true, completion: nil)
        }else if txt_businessType.text == ""{
            let alert = UIAlertController(title: "", message:
                "Please select business type.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            self.present(alert, animated: true, completion: nil)
        }else if txt_desc.text == ""{
            let alert = UIAlertController(title: "", message:
                "Please enter a description", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            self.present(alert, animated: true, completion: nil)
        }else{
            connectToRegisterSavePreferedLocations()
        }
    }
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
