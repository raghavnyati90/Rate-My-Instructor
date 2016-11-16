//
//  DetailViewController.swift
//  Practice5
//
//  Created by Raghav Nyati on 11/4/16.
//  Copyright © 2016 Raghav Nyati. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{

    var listData: Array<String> = []
    var passedValue: Int!
    var ratingValue: Int!
    var i: Int!
    var isSliderValueChanged: Bool = false
    
    @IBOutlet weak var sliderLabelView: UILabel!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ratingAverage: UILabel!
    @IBOutlet weak var lNameLabelView: UILabel!
    @IBOutlet weak var emailLabelView: UILabel!
    @IBOutlet weak var phoneLabelView: UILabel!
    @IBOutlet weak var officeLabelView: UILabel!
    @IBOutlet weak var fNameView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        let n = passedValue
        i = Int(n!)
        
        commentTextField.delegate = self
        ratingSlider.maximumValue = 5
        ratingSlider.minimumValue = 1
        ratingSlider.setValue(1, animated: true)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailViewController.hideKeyboard))
        view.addGestureRecognizer(tap)
        
        loadInstructorURL()
    }

    func loadInstructorURL(){
        commentTextField.text = nil
        if let url = URL(string: "http://bismarck.sdsu.edu/rateme/instructor/\(i+1)") {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: getDetailsWebPage)
            task.resume()
        }
        else {
            print("Unable to create URL")
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        isSliderValueChanged = true
        ratingSlider.setValue(ratingSlider.value, animated: true)
        sliderLabelView.text = String(Int(ratingSlider.value))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDetailsWebPage(data:Data?, response:URLResponse?, error:Error?) -> Void {
        guard error == nil else {
            print("error: \(error!.localizedDescription)")
            return
        }
        
        let httpResponse = response as? HTTPURLResponse
        let status:Int = httpResponse!.statusCode
        
        if data != nil && status == 200 {
            
            if let webPageContents = String(data: data!, encoding: String.Encoding.utf8) {
                let jsonData:Data? = webPageContents.data(using: String.Encoding.utf8)
                do {
                    let json:Any = try JSONSerialization.jsonObject(with: jsonData!)
                    let jsonDictionary = json as! NSDictionary
                    
                    let id:Int = jsonDictionary["id"] as! Int
                    let office:String = jsonDictionary["office"] as! String
                    let phone:String = jsonDictionary["phone"] as! String
                    let email:String = jsonDictionary["email"] as! String
                    let fName:String = jsonDictionary["firstName"] as! String
                    let lName:String = jsonDictionary["lastName"] as! String
                    let rating = jsonDictionary["rating"] as! NSDictionary
                    let average:Float = rating["average"] as! Float

                    DispatchQueue.global(qos: .userInitiated).async {
                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                    self.fNameView.text = String(fName)
                    self.lNameLabelView.text = String(lName)
                    self.officeLabelView.text = String(office)
                    self.phoneLabelView.text = String(phone)
                    self.emailLabelView.text = String(email)
                    self.ratingAverage.text = String(average)
                        }
                    }
                    showComments(id: id)
                    
                } catch {
                    print("Unable to convert JSON")
                }
            } else {
                print("Unable to convert data to text")
            }
        }
    }
    
    func showComments(id: Int){
        if let url = URL(string: "http://bismarck.sdsu.edu/rateme/comments/\(id)") {
            let session = URLSession.shared
            let task = session.dataTask(with: url, completionHandler: getCommentsWebPage)
            task.resume()
        }
        else {
            print("Unable to create URL")
        }
    }
    
    func getCommentsWebPage(data:Data?, response:URLResponse?, error:Error?) -> Void {
        guard error == nil else {
            print("error: \(error!.localizedDescription)")
            return
        }
        
        let httpResponse = response as? HTTPURLResponse
        let status:Int = httpResponse!.statusCode
        
        if data != nil && status == 200 {
            
            if let webPageContents = String(data: data!, encoding: String.Encoding.utf8) {
                let jsonData:Data? = webPageContents.data(using: String.Encoding.utf8)
                do {
                    let jsonResult = try JSONSerialization.jsonObject(with: jsonData!)
                    
                    var i:Int = 0;
                    for anItem in jsonResult as! [Dictionary<String, AnyObject>] {
                        
                        var comment = ""
                        let text = anItem["text"] as! String
                        let date = anItem["date"] as! String
                        comment = date + ": " + text
                        listData.insert(String(comment), at: i)
                        i=i+1;
                    }
                    DispatchQueue.global(qos: .userInitiated).async {
                        // Bounce back to the main thread to update the UI
                        DispatchQueue.main.async {
                    self.tableView.reloadData()
                        }
                    }
                } catch {
                    print("Unable to convert JSON")
                }
            } else {
                print("unable to convert data to text")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //  return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "TextCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                 for: indexPath)
        cell.textLabel!.text = listData[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        hideKeyboard()
        var isRatingValueChanged: Bool = false
        var isCommentEntered: Bool = false
        if(isSliderValueChanged == true){
        if let url = URL(string: "http://bismarck.sdsu.edu/rateme/rating/\(i+1)/\(ratingSlider.value)") {
            var mutableRequest = URLRequest.init(url: url)
            mutableRequest.httpMethod = "POST"
            mutableRequest.setValue("text/plain",
                                    forHTTPHeaderField: "Content-Type")
            let session = URLSession.shared
            let task = session.uploadTask(with: mutableRequest,
                                          from: String(ratingSlider.value).data(using: .utf8),
                                          completionHandler: uploadRatingResponse)
            task.resume()
            isSliderValueChanged = false
            sliderLabelView.text = String(Int(ratingSlider.minimumValue))
            ratingSlider.setValue(ratingSlider.minimumValue, animated: true)
            isRatingValueChanged = true
        }
        else {
            print("Unable to create URL")
        }
        }
        if(commentTextField.text != nil) && (commentTextField.text != ""){
            if let url = URL(string: "http://bismarck.sdsu.edu/rateme/comment/\(i+1)") {
                var mutableRequest = URLRequest.init(url: url)
                mutableRequest.httpMethod = "POST"
                mutableRequest.setValue("text/plain",
                                        forHTTPHeaderField: "Content-Type")
                let session = URLSession.shared
                mutableRequest.httpBody = String(describing: commentTextField.text!).data(using: .utf8)
                let task = session.uploadTask(with: mutableRequest,
                                              from: String(describing: commentTextField.text!).data(using: .utf8),
                                              completionHandler: uploadCommentResponse)
                task.resume()
                isCommentEntered = true
            }
            else {
                print("Unable to create URL")
            }
        }
        
        var message: String
        if(isCommentEntered || isRatingValueChanged){
            loadInstructorURL()
        }
        if(isCommentEntered && isRatingValueChanged){
            message = "Comment and Rating Submitted Successfully."
        }
        else if(isCommentEntered == true && isRatingValueChanged == false){
            message = "Comment Submitted Successfully."
        }
        else if(isCommentEntered == false && isRatingValueChanged == true){
            message = "Rating Submitted Successfully."
        }
        else{
            message = "Please enter comment or select rating to submit."
        }
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        // change to desired number of seconds (in this case 5 seconds)
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    func uploadRatingResponse(data:Data?, response:URLResponse?, error:Error?) -> Void {
        guard error == nil else {
            return
        }
        let httpResponse = response as? HTTPURLResponse
        let status:Int = httpResponse!.statusCode
        
        if status != 200,
            let error = String(data: data!, encoding: String.Encoding.utf8){
            print(error)
            return
        }
    }
    
    func uploadCommentResponse(data:Data?, response:URLResponse?, error:Error?) -> Void {
        guard error == nil else {
            return
        }
        let httpResponse = response as? HTTPURLResponse
        let status:Int = httpResponse!.statusCode
        if status != 200,
            let error = String(data: data!, encoding: String.Encoding.utf8){
            print(error)
            return
        }
    }
    
    @IBAction func tapInBackground(_ sender: Any) {
            hideKeyboard()
    }
    
    @IBAction func editCommentDone(_ sender: Any) {
        hideKeyboard()
    }
    
    func hideKeyboard() {
        view.endEditing(false)
    }
}
