//
//  SuggestionsCell.swift
//  PreviewSearchFeatureWithCompositionalLayout
//
//  Created by Pawan Sharma on 17/05/21.
//

import UIKit

final class SuggestionsCell: UICollectionViewCell {
  @IBOutlet private weak var wrapperView: UIView!
  @IBOutlet private weak var searchLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    wrapperView.layer.cornerRadius = 17.0
    wrapperView.layer.borderWidth = 2.0
    print(wrapperView.frame.height)
    wrapperView.layer.borderColor = UIColor.lightGray.cgColor
  }

  func setSearch(title: String) {
    self.searchLabel.text = title
  }

  override func layoutSubviews() {
    super.layoutSubviews()
  }

}
