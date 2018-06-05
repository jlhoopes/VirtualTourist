//
//  CollectionViewCell.swift
//  VirtualTourist
//
//  Created by Jason on 6/5/18.
//  Copyright © 2018 jlhoopes.com. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.cellImageView.alpha = 0.5
            }
            else {
                self.cellImageView.alpha = 1.0
            }
        }
    }
}
