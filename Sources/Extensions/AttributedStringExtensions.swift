//
//  DictionaryExtensions.swift
//  Ello
//
//  Created by Colin Gray on 2/19/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//


extension NSAttributedString {
    func append(str : NSAttributedString) -> NSAttributedString {
        var retval : NSMutableAttributedString = NSMutableAttributedString(attributedString: self)
        retval.appendAttributedString(str)
        return NSAttributedString(attributedString: retval)
    }
}

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    return left.append(right)
}