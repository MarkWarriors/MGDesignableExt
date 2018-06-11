//
//  Extensions.swift
//  TEST
//
//  Created by Marco Guerrieri on 10/03/18.
//  Copyright © 2018 Marco Guerrieri. All rights reserved.
//

import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func notEmpty() -> Bool{
        return self != ""
    }
}

@IBDesignable
extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

@IBDesignable
extension UITextField {
    
    @IBInspectable var placeHolderColor : UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
            setValue(newValue!, forKeyPath: "_placeholderLabel.textColor")
        }
    }
    
    @IBInspectable var placeHolderSize: UIFont? {
        get {
            return self.placeHolderSize
        }
        set {
            self.attributedPlaceholder = NSMutableAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.font:UIFont(name: "", size: 0)!])
        }
    }
}


@IBDesignable
class MGCheckbox: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.setImage(self.checked ? self.onImage : self.offImage, for: UIControlState.normal)
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    
    @IBInspectable var checked: Bool = true {
        didSet{
            self.setImage(self.checked ? self.onImage : self.offImage, for: UIControlState.normal)
        }
    }

    @IBInspectable var onImage: UIImage? {
        didSet{
            if self.checked {
                self.setImage(onImage, for: UIControlState.normal)
            }
        }
    }

    @IBInspectable var offImage: UIImage? {
        didSet{
            if !self.checked {
                self.setImage(offImage, for: UIControlState.normal)
            }
        }
    }

    override var buttonType: UIButtonType {
         return UIButtonType.custom
    }

    var changeValue : ((Bool)->())?

    override func setImage(_ image: UIImage?, for state: UIControlState) {
        super.setImage(image, for: state)
        self.imageView?.contentMode = .scaleAspectFit
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.checked = !self.checked
        self.setImage(self.checked ? self.onImage : self.offImage, for: UIControlState.normal)
        if self.changeValue != nil {
            self.changeValue!(self.checked)
        }
        super.touchesEnded(touches, with: event)
    }
    
    
    
}

@IBDesignable class MGTextField: UITextField {
    private var kAssociationKeyMaxLength: Int = 0
    private var floatLabel : UILabel = UILabel()
    @IBInspectable var focussedBorderColor: UIColor? = UIColor.clear
    var unfocussedBorderColor: UIColor? = UIColor.clear
    @IBInspectable var validBorderColor: UIColor? = UIColor.clear
    @IBInspectable var errorBorderColor: UIColor? = UIColor.clear
    @IBInspectable var floatingPlaceholder : Bool = false {
        didSet{
            
        }
    }
    
    override var text: String?{
        didSet{
            _ = self.resignFirstResponder()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        createFloatingPlaceholder()
        self.addTarget(self, action: #selector(checkMaxLength(textField:)), for: .editingChanged)
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        toggleFloatingPlaceholder(moveTop: text != "")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.toggleFloatingPlaceholder(moveTop: text != "")
    }
    
    func createFloatingPlaceholder(){
        if floatingPlaceholder {
            self.clipsToBounds = false
            let placeholderColor : UIColor = value(forKeyPath: "_placeholderLabel.textColor") as! UIColor
            floatLabel.textColor = placeholderColor.withAlphaComponent(0.5)
            floatLabel.font = self.font
            floatLabel.alpha = 1
            floatLabel.frame = CGRect(x: bounds.origin.x + leftInset, y: bounds.origin.y + topInset, width: bounds.width - rightInset, height: bounds.height - bottomInset)
            floatLabel.text = self.placeholder
            self.addSubview(floatLabel)
            self.placeholder = ""
        }
    }
    
    
    @IBInspectable var leftInset : CGFloat = 0
    @IBInspectable var rightInset : CGFloat = 0
    @IBInspectable var topInset : CGFloat = 0
    @IBInspectable var bottomInset : CGFloat = 0
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    @objc func checkMaxLength(textField: UITextField) {
        guard let prospectiveText = self.text, prospectiveText.count > maxLength
            else {
                return
        }
        
        let selection = selectedTextRange
        let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        text = prospectiveText.substring(to: maxCharIndex)
        selectedTextRange = selection
    }
    



    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + leftInset, y: bounds.origin.y + topInset, width: bounds.width - leftInset - rightInset, height: bounds.height - topInset - bottomInset)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + leftInset, y: bounds.origin.y + topInset, width: bounds.width - leftInset - rightInset, height: bounds.height - topInset - bottomInset)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + leftInset, y: bounds.origin.y + topInset, width: bounds.width - leftInset - rightInset, height: bounds.height - topInset - bottomInset)
    }
    
    open override var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            unfocussedBorderColor = newValue
            layer.borderColor = newValue?.cgColor
        }
    }

    func toggleFloatingPlaceholder(moveTop: Bool, animated: Bool = true){
        if floatingPlaceholder {
            self.floatLabel.alpha = 0

            if moveTop {
                self.floatLabel.font = self.floatLabel.font.withSize((self.font?.pointSize)!-3)
            }
            else{
                self.floatLabel.font = self.floatLabel.font.withSize((self.font?.pointSize)!)
            }
            UIView.animate(withDuration: animated ? 0.2 : 0, delay: 0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                self.floatLabel.alpha = 1
                var newY : CGFloat = 0
                if moveTop {
                    newY = self.frame.size.height/2-self.floatLabel.frame.size.height-8
                    self.floatLabel.textColor = self.floatLabel.textColor.withAlphaComponent(1)
                }
                else{
                    self.floatLabel.textColor = self.floatLabel.textColor.withAlphaComponent(0.5)
                }

                self.floatLabel.frame = CGRect.init(
                    x: self.floatLabel.frame.origin.x,
                    y: newY,
                    width: self.floatLabel.frame.size.width,
                    height: self.floatLabel.frame.size.height)
            }) { (end) in

            }
        }
    }
    
    open override func becomeFirstResponder() -> Bool {
        if floatingPlaceholder && self.text == ""{
            toggleFloatingPlaceholder(moveTop: true)
        }
        if focussedBorderColor != nil {
            layer.borderColor = focussedBorderColor?.cgColor
            self.floatLabel.textColor = focussedBorderColor!.withAlphaComponent(0.5)
        }
        return super.becomeFirstResponder()
    }

    open override func resignFirstResponder() -> Bool {
        if floatingPlaceholder && self.text == ""{
            toggleFloatingPlaceholder(moveTop: false)
        }

        if self.text != ""{
            if focussedBorderColor != nil {
                layer.borderColor = focussedBorderColor?.cgColor
                self.floatLabel.textColor = focussedBorderColor!.withAlphaComponent(0.5)
            }
        }
        else{
            if unfocussedBorderColor != nil {
                layer.borderColor = unfocussedBorderColor?.cgColor
                self.floatLabel.textColor = unfocussedBorderColor!.withAlphaComponent(0.5)
            }
        }
        return super.resignFirstResponder()
    }

    open func contentError() {
        if errorBorderColor != nil {
            layer.borderColor = errorBorderColor!.cgColor
            self.floatLabel.textColor = errorBorderColor!.withAlphaComponent(0.5)
        }
    }

    open func contentValid() {
        if validBorderColor != nil {
            layer.borderColor = validBorderColor?.cgColor
            self.floatLabel.textColor = validBorderColor!.withAlphaComponent(0.5)
        }
    }
}

// TODO
//    //    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
//    //        var textRect = super.leftViewRect(forBounds: bounds)
//    //        textRect.origin.x += leftPadding
//    //        return textRect
//    //    }
//    //
//    //    @IBInspectable var leftImage: UIImage? {
//    //        didSet {
//    //            updateView()
//    //        }
//    //    }
//    //
//
//    //
//    //    @IBInspectable var color: UIColor = UIColor.lightGray {
//    //        didSet {
//    //            updateView()
//    //        }
//    //    }
//    //
//    //    func updateView() {
//    //        if let image = leftImage {
//    //            leftViewMode = UITextFieldViewMode.always
//    //            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
//    //            imageView.image = image
//    //            // Note: In order for your image to use the tint color, you have to select the image in the Assets.xcassets and change the "Render As" property to "Template Image".
//    //            imageView.tintColor = color
//    //            leftView = imageView
//    //        } else {
//    //            leftViewMode = UITextFieldViewMode.never
//    //            leftView = nil
//    //        }
//    //    }
//
//
//

