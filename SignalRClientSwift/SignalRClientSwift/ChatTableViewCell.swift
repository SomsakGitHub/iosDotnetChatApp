//
//  ChatTableViewCell.swift
//  SignalRClientSwift
//
//  Created by Somsak Kaeworasan on 27/6/2564 BE.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var chatLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
