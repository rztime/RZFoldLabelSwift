//
//  RZFoldLabel.swift
//  iOSUsefulCode
//
//  Created by ruozui on 2020/5/23.
//  Copyright © 2020 rztime. All rights reserved.
//

import UIKit
import RZColorfulSwift
import SnapKit

open class RZFoldLabel: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    open var attributedText: NSAttributedString? {
        didSet {
            setAttributedText()
        }
    }
    open var numberOfLines: UInt = 0
    // 倾向于最大的布局宽度（用于计算文本宽高）与 self.textView的bounds.width 取大 MAX(preferredMaxLayoutWidth, self.textView.bounds.width)
    open var preferredMaxLayoutWidth: CGFloat = 0
    // 条件
    // less: 比numberOfLines小时，将会把showAllText加入到attributedText之后
    // equal: 与numberOfLines相等时，将会把showAllText加入到attributedText之后
    // more: 比numberOfLines大时，将会把showAllText加入到attributedText之后
    open var condition: NSAttributedString.RZCondition = .more
    
    open var textInsetEdge: UIEdgeInsets = .zero {
        didSet {
            self.setTextInsetEdge()
        }
    }
    
    /** 折叠，切换  默认YES
     YES: 折叠
     NO：展开（显示全部）
     */
    open var isFold: Bool = true {
        didSet {
            self.resetAttributedText()
        }
    }
    // “显示全文”的文本，富文本，可实现点击事件
    open var showAllText: NSAttributedString?
    // “收起”的文本 富文本，可实现点击事件
    open var foldText: NSAttributedString?
    
    // 点击 全文、收起时的回调，需要实现在富文本中点击NSLink事件
    open var rzDidTapView:((_ tap: String?, _ view: RZFoldLabel?) -> Void)?
    
    private let textView: UITextView = .init()
    private var edgeLayouts: [NSLayoutConstraint] = []
    private var displayFoldAttr: NSAttributedString?
    private var displayNormalFoldAttr: NSAttributedString?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(textView)
        textView.backgroundColor = .clear
        textView.contentInset = .zero
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.isEditable = false
        textView.textContainer.lineFragmentPadding = 0
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.linkTextAttributes = [:]
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.rzDidTapTextView = { [weak self] (obj, textView) -> Bool in
            self?.rzDidTapView?(obj, self)
            return false
        }
        setTextInsetEdge()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func textDrawRect() -> CGRect {
        return .init(origin: .zero, size: .init(width: max(textView.bounds.size.width, self.preferredMaxLayoutWidth), height: CGFloat(MAXFLOAT)))
    }
    
    open func resetAttributedText() {
        if self.isFold {
            self.textView.attributedText = self.getDisplayFoldAttr()
        } else {
            self.textView.attributedText = self.getDisplayNormalFoldAttr()
        }
    }
    
    private func setTextInsetEdge() {
        //        self.removeConstraints(self.edgeLayouts)
        //        let top = NSLayoutConstraint.init(item: self.textView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: textInsetEdge.top)
        //        let left = NSLayoutConstraint.init(item: self.textView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: textInsetEdge.left)
        //        let right = NSLayoutConstraint.init(item: self.textView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: -textInsetEdge.right)
        //        let bottom = NSLayoutConstraint.init(item: self.textView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -textInsetEdge.bottom)
        //        let centerX = NSLayoutConstraint.init(item: self.textView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0)
        //        let centerY = NSLayoutConstraint.init(item: self.textView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        //        self.edgeLayouts = [top, left, right, bottom, centerX, centerY]
        //        self.addConstraints(self.edgeLayouts)
        
        self.textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(self.textInsetEdge)
        }
    }
    
    open func setAttributedText() {
        self.displayFoldAttr = nil
        self.displayNormalFoldAttr = nil
        self.resetAttributedText()
        self.textView.layoutIfNeeded()
    }
    
    open func getDisplayFoldAttr() -> NSAttributedString? {
        if self.displayFoldAttr == nil {
            self.displayFoldAttr = self.attributedText?.rz_appendAttributedString(attr: self.showAllText, condition: self.condition, line: self.numberOfLines, inRect: self.textDrawRect())
        }
        return self.displayFoldAttr
    }
    open func getDisplayNormalFoldAttr() -> NSAttributedString? {
        if self.displayNormalFoldAttr == nil {
            if self.foldText != nil {
                self.displayNormalFoldAttr = self.attributedText?.attributedStringByAppend(attributedString: self.foldText!)
            } else {
                self.displayNormalFoldAttr = self.attributedText
            }
        }
        return self.displayNormalFoldAttr
    }
}

public extension NSAttributedString {
    enum RZCondition: Int {
        case less = -1
        case equal = 0
        case more = 1
    }
    func rz_appendAttributedString(attr: NSAttributedString?, condition: NSAttributedString.RZCondition, line: UInt, inRect: CGRect) -> NSAttributedString {
        var tempAttr: NSMutableAttributedString = self.mutableCopy() as! NSMutableAttributedString
        let lines: [RZAttributedStringInfo]? = tempAttr.rz_linesIfDrawInRect(inRect)
        let result = NSNumber.init(value: lines?.count ?? 0).compare(NSNumber.init(value: line))
        if result.rawValue == condition.rawValue {
            let ln = min(lines?.count ?? 0, Int(line)) - 1
            for lineNum in stride(from: ln, through: 0, by: -1) {
                var flag = false
                let lastLineInfo: RZAttributedStringInfo? = lines?[lineNum]
                for row in stride(from: lastLineInfo?.range?.length ?? 0, to: 0, by: -1) {
                    let length = (lastLineInfo?.range?.location ?? 0) + row
                    let temp: NSMutableAttributedString = tempAttr.attributedSubstring(from: .init(location: 0, length: length)) as! NSMutableAttributedString
                    temp.append(attr ?? NSAttributedString.init())
                    let tempLines = temp.rz_linesIfDrawInRect(inRect)
                    if tempLines?.count ?? 0 <= line {
                        let tempLast = tempLines?.last
                        let size: CGSize = tempLast?.attributedString?.sizeWithConditionHeight(height: Float(CGFloat.greatestFiniteMagnitude)) ?? CGSize.init(width: inRect.width, height: 0)
                        if size.width <= inRect.size.width {
                            flag = true
                            if temp.string.hasSuffix("\n") {
                                temp.replaceCharacters(in: .init(location: temp.length - 1, length: 1), with: "")
                            }
                            tempAttr = temp.mutableCopy() as! NSMutableAttributedString
                            break
                        }
                    }
                }
                if flag == true {
                    break
                }
            }
        }
        return tempAttr.copy() as! NSAttributedString
    }
    
    func rz_linesIfDrawInRect(_ rect: CGRect) -> [RZAttributedStringInfo]? {
        let frameSetter = CTFramesetterCreateWithAttributedString(self)
        let path: CGMutablePath = CGMutablePath()
        path.addRect(rect)
        let frame = CTFramesetterCreateFrame(frameSetter, CFRange.init(location: 0, length: 0), path, nil)
        let linesNS = CTFrameGetLines(frame)
        let lines: [CTLine] = Array.fromCFArray(records: linesNS) ?? []
        var infos: [RZAttributedStringInfo] = []
        lines.forEach { (lineRef) in
            let lineRange = CTLineGetStringRange(lineRef)
            let range: NSRange = .init(location: lineRange.location, length: lineRange.length)
            let attr: NSMutableAttributedString = self.attributedSubstring(from: range).mutableCopy() as! NSMutableAttributedString
            let info = RZAttributedStringInfo.init(attributedString: attr, range: range)
            infos.append(info)
        }
        return infos
    }
}

public extension Array {
    static func fromCFArray(records: CFArray?) -> [Element]? {
        var result: [Element]?
        if let records = records {
            for i in 0..<CFArrayGetCount(records) {
                let unmanagedObject: UnsafeRawPointer = CFArrayGetValueAtIndex(records, i)
                let rec: Element = unsafeBitCast(unmanagedObject, to: Element.self)
                if (result == nil) {
                    result = [Element]()
                }
                result!.append(rec)
            }
        }
        return result
    }
}

public struct RZAttributedStringInfo {
    var attributedString: NSMutableAttributedString?
    var range: NSRange?
}
