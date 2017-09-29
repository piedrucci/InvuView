

import Foundation
import UIKit

class CustomCell: UITableViewCell {
    @IBOutlet weak var cellCant: UILabel!
    @IBOutlet weak var cellDescripcion: UILabel!
    @IBOutlet weak var cellAmount: UILabel!
    
    @IBOutlet weak var lblModifier: UILabel!
    
    @IBOutlet weak var discountStack: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        lblModifier.text = ""
    }
}
