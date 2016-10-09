//
//  GifTableViewCell.swift
//  SpeechSampleApp
//
//  Created by SpotHeroMatt on 9/30/16.
//  Copyright © 2016 Matthew Reed. All rights reserved.
//

import UIKit
import FLAnimatedImage
class GifTableViewCell: UITableViewCell {
    @IBOutlet weak var gifImageView: FLAnimatedImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
