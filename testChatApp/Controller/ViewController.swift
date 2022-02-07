//
//  ViewController.swift
//  testChatApp
//
//  Created by Julian Silvestri on 2022-02-03.
//

import UIKit
import CoreData
import Messages

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var heightOfChatTableView: NSLayoutConstraint!
    @IBOutlet weak var addImageBtn: UIButton!
    @IBOutlet weak var heightOfText: NSLayoutConstraint!
    @IBOutlet weak var heightOfChatbox: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var chatTextBoxView: UIView!
    @IBOutlet weak var chatView: UITableView!
    @IBOutlet weak var customTextView: UITextView!
    
    var localChatHistory: [String:String] = [:]
    var history: [History] = []
    var tapGesture = UITapGestureRecognizer()
    var shouldAdjustForKeyboard: Bool?
    var shouldScrollToBottom: Bool?
    var originalSizedImage: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addImageBtn.setTitle("", for: .normal)
        self.addImageBtn.addTarget(self, action: #selector(didTapOnImageView), for: .touchUpInside)
        self.customTextView.delegate = self
//        self.textInput.delegate = self
        self.chatView.delegate = self
        self.chatView.dataSource = self
        self.tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapToDismiss))
        self.view.addGestureRecognizer(tapGesture)
        self.sendBtn.setTitle("", for: .normal)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//        self.textInput.inputAccessoryView = self.view
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.shouldAdjustForKeyboard = true
        self.chatView.scrollToBottom()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.shouldAdjustForKeyboard = false
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
    @objc func tapToDismiss(){
        if self.customTextView.isFirstResponder == true {
            self.view.endEditing(true)
        } else {
            return
        }
    }
    
     @objc func keyboardWillShow(notification: NSNotification) {
         adjustContentForKeyboard(shown: false, notification: notification)
         if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
             if self.view.frame.origin.y == 0 {
                 self.view.frame.origin.y -= keyboardSize.height - self.heightOfChatbox.constant + self.heightOfChatbox.constant
             }
         }
     }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        adjustContentForKeyboard(shown: false, notification: notification)
        if self.view.frame.origin.y != 0  {
            self.view.frame.origin.y = 0
        }
     }
    

    func saveChatHistory(completionHandler: @escaping(Bool?)->Void){
        guard let context = appDelegate?.persistentContainer.viewContext else {
            return
        }
        let chatHistory = History(context: context)
        chatHistory.history = localChatHistory
        
        do {
            try context.save()
            print("SAVED TO CORE DATA")
            completionHandler(true)
        } catch{
            debugPrint("Could not save to core data = \(error.localizedDescription)")
            completionHandler(false)
        }
        
    }
    //MARK: Send BTN Action
    @IBAction func sendMessageAction(_ sender: Any) {
        print("SENDING MESSAGE")
        self.customTextView.text = ""
        //DO CALL TO SERVER
        
    }
    
    //MARK: Load Chat History
    func loadChatHistory(){
        print("Fetching Data..")
        
        guard let context = appDelegate?.persistentContainer.viewContext else {
            return
        }
        
        let request = NSFetchRequest<History>(entityName: "History")

        do {
            self.history = try context.fetch(request)
        } catch let err{
            print("Fetching data Failed \(err)")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if localChatHistory.count == 0 {
//            return chatHistory.chatHistory.count
//        } else {
//            return localChatHistory.count
//        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.chatView.rowHeight = 74
        if let cell = chatView.dequeueReusableCell(withIdentifier: "chatCell") as? ChatBoxTableCell {
            cell.sentMessageLabel.text = "Value"
            return cell
        }
        return UITableViewCell()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
     
        if shouldScrollToBottom ?? true {
            shouldScrollToBottom = false
            scrollToBottom(animated: false)
        }
    }
    func textViewContentSize() -> CGSize {
        let size = CGSize(width: customTextView.bounds.width,
                          height:self.view.frame.size.height)
     
        let textSize = customTextView.sizeThatFits(size)
        return CGSize(width: textSize.width, height: textSize.height)
    }
     
    func scrollToBottom(animated: Bool) {
        view.layoutIfNeeded()
        self.chatView.setContentOffset(bottomOffset(), animated: animated)
    }
    var intrinsicContentSize: CGSize {
        return textViewContentSize()
    }
     
    func bottomOffset() -> CGPoint {
        return CGPoint(x: 0, y: max(-self.chatView.contentInset.top, chatView.contentSize.height - (self.chatView.bounds.size.height - chatView.contentInset.bottom)))
    }
     
    func adjustContentForKeyboard(shown: Bool, notification: NSNotification) {
        guard shouldAdjustForKeyboard ?? true, let payload = KeyboardInfo(notification as Notification) else { return }
     
        let keyboardHeight = shown ? payload.frameEnd.size.height : chatTextBoxView?.bounds.size.height ?? 0
        if self.chatView.contentInset.bottom == keyboardHeight {
            return
        }
     
        let distanceFromBottom = bottomOffset().y - self.chatView.contentOffset.y
     
        var insets = self.chatView.contentInset
        insets.bottom = keyboardHeight
     
        UIView.animate(withDuration: payload.animationDuration, delay: 0, options: .curveEaseIn, animations: {
     
            self.chatView.contentInset = insets
            self.chatView.scrollIndicatorInsets = insets
     
            if distanceFromBottom < 10 {
                self.chatView.contentOffset = self.bottomOffset()
            }
        }, completion: nil)
    }
    
    
    
}//MARK:- Image Picker
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //This is the tap gesture added on my UIImageView.
    @objc func didTapOnImageView() {
        //call Alert function
        self.showAlert()
    }

    //Show alert to selected the media source type.
    private func showAlert() {

        let alert = UIAlertController(title: "Image Selection", message: "From where you want to pick this image?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    //get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {

        //Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {

            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }

    //MARK:- UIImagePickerViewDelegate.
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        self.dismiss(animated: true) { [weak self] in

            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
            
            let attachment = NSTextAttachment()
            self!.originalSizedImage = attachment.image
            attachment.image = image
            attachment.image = attachment.image?.imageResized(to: CGSize(width: 90, height: 90))
            let imageString = NSAttributedString(attachment: attachment)
            self!.customTextView.textStorage.insert(imageString, at: 0)
            //Setting image to your image view
//            self!.imageThumbnail.image = image
            self!.view.layoutIfNeeded()
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
//    func textViewDidChange(_ textView: UITextView) {
//        custo.isHidden = !textView.text.isEmpty
//        let contentHeight = textViewContentSize().height
//        if textViewHeight.constant != contentHeight {
//            textViewHeight.constant = textViewContentSize().height
//            layoutIfNeeded()
//        }
//    }

}
extension ViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        //placeHolder.isHidden = !textView.text.isEmpty
        let contentHeight = textViewContentSize().height
        if heightOfText.constant != contentHeight {
//            let newHeight = self.heightOfChatTableView.constant + textViewContentSize().height
//            self.heightOfChatTableView.constant = textViewContentSize().height - self.heightOfChatTableView.constant
            view.layoutIfNeeded()
        }
    }
}

extension KeyboardInfo {
    init?(_ notification: Notification) {
        guard notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification else { return nil }
        let u = notification.userInfo!

        animationCurve = UIView.AnimationCurve(rawValue: u[UIWindow.keyboardAnimationCurveUserInfoKey] as! Int)!
        animationDuration = u[UIWindow.keyboardAnimationDurationUserInfoKey] as! Double
        isLocal = u[UIWindow.keyboardIsLocalUserInfoKey] as! Bool
        frameBegin = u[UIWindow.keyboardFrameBeginUserInfoKey] as! CGRect
        frameEnd = u[UIWindow.keyboardFrameEndUserInfoKey] as! CGRect
    }
    
}
extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
extension UITableView {

    func scrollToBottom(isAnimated:Bool = true){

        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .bottom, animated: isAnimated)
            }
        }
    }

    func scrollToTop(isAnimated:Bool = true) {

        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
           }
        }
    }

    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}
