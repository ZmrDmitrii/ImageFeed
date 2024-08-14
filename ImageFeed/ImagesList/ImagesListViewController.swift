//
//  ViewController.swift
//  ImageFeed
//
//  Created by Дмитрий Замараев on 4/8/24.
//
import UIKit

class ImagesListViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet private var tableView: UITableView!
    
    //MARK: - Private properties
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    //MARK: - Date formetter
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    //MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 4, right: 0)
        //от себя - убрал вертикальный ползунок
        tableView.showsVerticalScrollIndicator = false
    }
}

// MARK: UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            print("Error: failed to cast the cell to the required type")
            return UITableViewCell()
        }
        
        func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
            let name = photosName[indexPath.row]
            
            if UIImage(named: name) != nil {
                imagesListCell.cellImageView.image = UIImage(named: name)
            } else {
                return
            }
            
            imagesListCell.cellDateLable.text = dateFormatter.string(from: Date())
            let likeImage = (indexPath.row + 1) % 2 == 0 ? UIImage(named: "Active") : UIImage(named: "No Active")
            imagesListCell.cellLikeButton.setImage(likeImage, for: .normal)
        }
        imagesListCell.cellLikeButton.setTitle("", for: .normal)
        configCell(for: imagesListCell, with: indexPath)
        
        return imagesListCell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let imageWidth = CGFloat(UIImage(named: photosName[indexPath.row])?.size.width ?? 0)
        let imageViewWidth = CGFloat(tableView.contentSize.width)
        let imageHeight = CGFloat(UIImage(named: photosName[indexPath.row])?.size.height ?? 0)
        return imageHeight * (imageViewWidth / imageWidth)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
}
