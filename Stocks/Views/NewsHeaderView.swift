//
//  NewsHeaderView.swift
//  Stocks
//
//  Created by Abhijnan Maji on 13/10/21.
//

import UIKit

protocol NewsHeaderViewDelegate: AnyObject{
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView)
}

class NewsHeaderView: UITableViewHeaderFooterView {
    static let identifier = "NewsHeaderView"
    static let prefferredHeight: CGFloat = 70
    
    weak var delegate: NewsHeaderViewDelegate?
    
    struct ViewMdel {
        let title: String
        let shouldShowAddButton: Bool
    }
    
    private let label: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 32)
        return lbl
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("+ Watchlist", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
// MARK:- Init
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubviews(label, button)
        contentView.backgroundColor = .secondarySystemBackground
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc private func didTapButton(){
        //Call delegate
        delegate?.newsHeaderViewDidTapAddButton(self)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = CGRect(x: 0, y: 0, width: contentView.width - 28, height: contentView.height)
        button.sizeToFit()
        button.frame = CGRect(
            x: contentView.width - button.width - 16,
            y: (contentView.height - button.height)/2,
            width: button.width + 8,
            height: button.height
        )
    }
    
    override func prepareForReuse(){
        super.prepareForReuse()
        label.text = nil
    }
    
    public func configure(with viewModel: ViewMdel){
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAddButton
    }
}
