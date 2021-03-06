//
//  HunterSelectionViewController.swift
//  Hunter
//
//  Created by Zubin Manak on 31/07/20.
//  Copyright © 2020 Zubin Manak. All rights reserved.
//

import UIKit

class HunterSelectionViewController: UIViewController, UITableViewDelegate , UITableViewDataSource {
    
    
    @IBOutlet weak var lblSelectedCount: UILabel!
    
    @IBOutlet weak var lblHeader: UILabel!
    var delegate: hunterDelegate!
    @IBOutlet weak var tbl_view: UITableView!
    var passedDict = NSDictionary()
    var selectedIDArray = [String]()
     
    struct Section {
        let letter : String
        let names : [String]
    }
    var selectedData = [NSDictionary]()

      var sections = [Section]()
      var isMultiSelect = Bool()
      var isFrom = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHeadertTitle()

        let username : [String] = passedDict.map { ($0.value as? String ?? "Null") }
        
        let groupedDictionary = Dictionary(grouping:username , by: {String($0.prefix(1))})
        // get the keys and sort them
        let keys = groupedDictionary.keys.sorted()
        // map the sorted keys to a struct
        sections = keys.map{ Section(letter: $0, names: groupedDictionary[$0]!.sorted()) }
        
        print(sections)
        self.tbl_view.reloadData()
    }

    func setHeadertTitle(){
        switch  isFrom{
        case "JobFunction":
            self.lblHeader.text = "Select your job function"
            self.lblSelectedCount.text = "\(selectedIDArray.count)/5"
        case "Skills":
            self.lblHeader.text = "Select your Skill Sets"
            self.lblSelectedCount.text = "\(selectedIDArray.count)/5"
        case "FieldOfEdu":
            self.lblHeader.text = "Search Level of Study"
            self.lblSelectedCount.text = "\(selectedIDArray.count)/5"
        default:
            self.lblHeader.text = "Select your industry"
            self.lblSelectedCount.text = "\(selectedIDArray.count)/1"
        }
    }
    @IBAction func dismissAction(_ sender: Any) {
        let myDict:NSDictionary =
        ["selectedData": selectedData]
        
        self.dismiss(animated: true) {
            self.delegate?.selectedData(selectedDict: myDict, isFrom: self.isFrom)
        }
    }
    
      

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return sections[section].names.count
     }

     func numberOfSections(in tableView: UITableView) -> Int {
         return sections.count
     }

     func sectionIndexTitles(for tableView: UITableView) -> [String]? {
         return sections.map{$0.letter}
     }

     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         return sections[section].letter
     }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).contentView.backgroundColor = UIColor.clear
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.init(red: 93.0/255.0, green: 26.0/255.0, blue: 147.0/255.0, alpha: 1.0)
    }
    // MARK: - Table view data source
    
     

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HunterSelectionTableCell", for: indexPath) as! HunterSelectionTableCell
        cell.selectionStyle = .none
        let section = sections[indexPath.section]
        let username = section.names[indexPath.row]
        cell.titleLabel?.text = username
        
        
        if(isMultiSelect){
            
            let usernames : [String] = passedDict.map { ($0.value as? String ?? "Null") }
            
            let indexOfA = usernames.firstIndex(of: username) // 0
            let dict = NSMutableDictionary()
            dict["name"] = username
            dict["id"] = passedDict.allKeys[indexOfA!] as! String
            
            let myDict:NSDictionary =
                ["name": username, "id": passedDict.allKeys[indexOfA!] as! String]
            
            if selectedIDArray.contains(myDict["id"] as! String){
                cell.imgSelection?.backgroundColor = UIColor.init(hexString: "5D1A93")
            }else{
                cell.imgSelection?.backgroundColor = UIColor.init(hexString: "E9E4F2")
            }
            
            
        }
        
        return cell
        
    }
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isMultiSelect == false {
            let section = sections[indexPath.section]
            let username = section.names[indexPath.row]
            let usernames : [String] = passedDict.map { ($0.value as? String ?? "Null") }
            
            let indexOfA = usernames.firstIndex(of: username) // 0
            
            
            let dict = NSMutableDictionary()
            dict["name"] = username
            dict["id"] = passedDict.allKeys[indexOfA!] as! String
            
            let myDict:NSDictionary =
                ["name": username, "id": passedDict.allKeys[indexOfA!] as! String]
            
            print(myDict)
            
            self.dismiss(animated: true) {
                
                self.delegate?.selectedData(selectedDict: myDict, isFrom: self.isFrom)
            }
        }else{
            let section = sections[indexPath.section]
            let username = section.names[indexPath.row]
            let usernames : [String] = passedDict.map { ($0.value as? String ?? "Null") }
            let indexOfA = usernames.firstIndex(of: username) // 0
            
            let myDict:NSDictionary =
            ["name": username, "id": passedDict.allKeys[indexOfA!] as! String]
            
            if selectedData.contains(myDict){
                let index = selectedData.firstIndex(of: myDict)!
                selectedData.remove(at: index)
                selectedIDArray.remove(at: index)
            }else{
                if selectedIDArray.count < 5{
                    selectedIDArray.append(myDict["id"] as! String)
                    selectedData.append(myDict)
                }
            }
            print(selectedData)
            setHeadertTitle()
            tbl_view.reloadData()
     
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
class HunterSelectionTableCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imgSelection: UIImageView!
    



}
