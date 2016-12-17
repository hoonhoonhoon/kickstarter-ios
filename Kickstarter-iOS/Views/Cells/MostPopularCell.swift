import Library
import Prelude
import UIKit

internal final class MostPopularCell: UITableViewCell, ValueCell {
  @IBOutlet private weak var mostPopularLabel: UILabel!

  internal func configureWith(value value: Void) {
  }

  internal override func bindStyles() {
    super.bindStyles()

    self
      |> baseTableViewCellStyle()
      |> MostPopularCell.lens.backgroundColor .~ .clearColor()
      |> MostPopularCell.lens.contentView.layoutMargins %~~ { _, cell in
        cell.traitCollection.isRegularRegular
          ? .init(top: Styles.grid(4), left: Styles.grid(24), bottom: Styles.grid(2), right: Styles.grid(24))
          : .init(topBottom: Styles.grid(2), leftRight: Styles.grid(2))
    }

    self.mostPopularLabel
      |> UILabel.lens.font .~ .ksr_title1(size: 22)
      |> UILabel.lens.textColor .~ .ksr_text_navy_700
      |> UILabel.lens.text %~ { _ in Strings.search_most_popular() }
  }
}
