//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit


open class DayCell: UICollectionViewCell {

    @IBOutlet public weak var dateLabel: UILabel!
    @IBOutlet public weak var weekDayLabel: UILabel!
    @IBOutlet public weak var monthLabel: UILabel!
    @IBOutlet public weak var selectorView: UIView!

    static var ClassName: String {
        return String(describing: self)
    }


    // MARK: - Setup

    func setup(date: Date, style: DayStyleConfiguration) {
        let formatter = DateFormatter()

        formatter.dateFormat = "dd" ///01 - 31
        dateLabel.text = formatter.string(from: date)
        dateLabel.font = style.dateTextFont ?? dateLabel.font
        dateLabel.textColor = style.dateTextColor ?? dateLabel.textColor

        formatter.dateFormat = "EEE"///星期的英文缩写
        weekDayLabel.text = NSLocalizedString(formatter.string(from: date).uppercased(), comment: "")
        weekDayLabel.font = style.weekDayTextFont ?? weekDayLabel.font
        weekDayLabel.textColor = style.weekDayTextColor ?? weekDayLabel.textColor

        formatter.dateFormat = "MMMM"///英文月份的缩写
        monthLabel.text = NSLocalizedString(formatter.string(from: date).uppercased(), comment: "")
        monthLabel.font = style.monthTextFont ?? monthLabel.font
        monthLabel.textColor = style.monthTextColor ?? monthLabel.textColor

        selectorView.backgroundColor = style.selectorColor ?? UIColor.clear
        backgroundColor = style.backgroundColor ?? backgroundColor
    }

}
