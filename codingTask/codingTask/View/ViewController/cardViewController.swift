//
//  cardViewController.swift
//  eliteTask
//
//  Created by Allnet Systems on 7/15/24.
//


import UIKit
import UIView_Shimmer

class CardViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var restaurantLogo: UIImageView!
    @IBOutlet weak var woopView: UIView!
    
    
    private var selectedCategoryIndex: Int = 0
    private var titleCategory: [String] = []
    private var subCategories: [String: [Item]] = [:]
    private var selectedItems: [Item] = []
    private var isLoadingData: Bool = true
    private let viewModel = MainViewModel()
    private var previousSelectedCategoryIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyUIConfigurations()
        setupCollectionView()
        setupTableView()
        applyShimmeringEffect()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        showBottomView()
        collectionView.reloadData()
//        collectionView.gestureRecognizers?.forEach { recognizer in
//            print("Gesture recognizer: \(recognizer)")
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let shadowRect = CGRect(x: 0, y: -bottomView.layer.shadowRadius, width: bottomView.bounds.width, height: bottomView.layer.shadowRadius)
        bottomView.layer.shadowPath = UIBezierPath(rect: shadowRect).cgPath
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            let visibleRows = tableView.indexPathsForVisibleRows
            if let firstVisibleRow = visibleRows?.first {
                let section = firstVisibleRow.section
                selectCategory(at: section, fromScroll: true)
            }
        }
    }

    private func selectCategory(at section: Int, fromScroll: Bool = false) {
        guard section < titleCategory.count else { return }

        if selectedCategoryIndex != section {
            let previousIndexPath = IndexPath(item: selectedCategoryIndex, section: 0)
            selectedCategoryIndex = section
            let indexPath = IndexPath(item: selectedCategoryIndex, section: 0)

            collectionView.performBatchUpdates({
                collectionView.reloadItems(at: [previousIndexPath, indexPath])
            }, completion: nil)

            if !fromScroll {
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                tableView.scrollToRow(at: IndexPath(row: 0, section: section), at: .top, animated: true)
            }
        }
    }
    
    private func applyUIConfigurations() {
        Helper.applyCornerRadius(to: searchButton, radius: searchButton.frame.size.width / 2)
        Helper.applyCornerRadius(to: backButton, radius: backButton.frame.size.width / 2)
        Helper.applyCornerRadius(to: sendButton, radius: sendButton.frame.size.width / 2)
        Helper.applyCornerRadius(to: continueButton, radius: 10)
        Helper.applyCornerRadius(to: restaurantLogo, radius: 10)
        Helper.applyCornerRadius(to: woopView, radius: 10)
        Helper.applyShadow(to: bottomView, color: .black, offset: CGSize(width: 0, height: 2), radius: 5, opacity: 0.5)
    }
    private func applyShimmeringEffect() {
            isLoadingData = true

            let viewsToAnimate: [UIView] = [collectionView, tableView, woopView, bottomView, searchButton, backButton, sendButton, continueButton, restaurantLogo]

            viewsToAnimate.forEach { view in
                view.setTemplateWithSubviews(true, viewBackgroundColor: UIColor.systemOrange)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                viewsToAnimate.forEach { view in
                    view.setTemplateWithSubviews(false)
                }
                self.isLoadingData = false
                self.collectionView.reloadData()
                self.tableView.reloadData()
            }
        }
    func fetchData() {
            viewModel.fetchItems { [weak self] in
                guard let self = self else { return }

                self.titleCategory = self.viewModel.vendorsItems.compactMap { $0.vendorCategoryName }
                self.subCategories = self.viewModel.vendorsItems.reduce(into: [String: [Item]]()) { result, vendorItem in
                    guard let categoryName = vendorItem.vendorCategoryName else { return }
                    result[categoryName] = vendorItem.items ?? []
                }

                self.isLoadingData = false
                self.collectionView.reloadData()
                self.tableView.reloadData()
                self.applyShimmeringEffect()
            }
        }
    
    private func showBottomView() {
        bottomView.isHidden = false
        bottomView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.bottomView.alpha = 1
        }
    }
}

extension CardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 3
            layout.minimumLineSpacing = 3
        }
    }

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//            super.touchesBegan(touches, with: event)
//        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return titleCategory.count
        }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isLoadingData else { return }

         selectCategory(at: indexPath.item)
        //        guard !isLoadingData else { return }
//
//        let previousIndexPath = IndexPath(item: selectedCategoryIndex, section: 0)
//        selectedCategoryIndex = indexPath.item
//        
//        collectionView.performBatchUpdates({
//            collectionView.reloadItems(at: [previousIndexPath, indexPath])
//        }, completion: nil)
//
//        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
//
//        let categoryName = titleCategory[selectedCategoryIndex]
//        selectedItems = subCategories[categoryName] ?? []
//        let sectionIndex = titleCategory.firstIndex(of: categoryName) ?? 0
//        let indexPathForTable = IndexPath(row: 0, section: sectionIndex)
//        tableView.scrollToRow(at: indexPathForTable, at: .top, animated: true)
//        tableView.reloadData()
        selectCategory(at: indexPath.item)

    }



    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        if isLoadingData {
            cell.setTemplateWithSubviews(true, viewBackgroundColor: UIColor(red: 0.95, green: 0.73, blue: 0.37, alpha: 1.00))
        } else {
            let category = titleCategory[indexPath.item]
            let isSelected = indexPath.item == selectedCategoryIndex
            
            cell.configure(isSelected: isSelected)
            cell.titleButton.setTitle(category, for: .normal)
            
            cell.titleButton.isUserInteractionEnabled = false
        }
            return cell
        }



    @objc private func categoryButtonTapped(_ sender: UIButton) {
        let categoryIndex = sender.tag
        let categoryName = titleCategory[categoryIndex]
        selectedItems = subCategories[categoryName] ?? []
        
        let previousIndexPath = IndexPath(item: selectedCategoryIndex, section: 0)
        selectedCategoryIndex = categoryIndex
        let newIndexPath = IndexPath(item: selectedCategoryIndex, section: 0)
        
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: [previousIndexPath, newIndexPath])
        }, completion: nil)
        
        let sectionIndex = titleCategory.firstIndex(of: categoryName) ?? 0
        let indexPath = IndexPath(row: 0, section: sectionIndex)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        
        tableView.reloadData()
    }
}

extension CardViewController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "CatagoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CatagoryTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titleCategory.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleCategory[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let categoryName = titleCategory[section]
        return subCategories[categoryName]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CatagoryTableViewCell", for: indexPath) as? CatagoryTableViewCell else {
            return UITableViewCell()
        }
        
        if isLoadingData {
            cell.setTemplateWithSubviews(true, viewBackgroundColor: UIColor(red: 0.95, green: 0.73, blue: 0.37, alpha: 1.00))
        } else {           let categoryName = titleCategory[indexPath.section]
            if let item = subCategories[categoryName]?[indexPath.row] {
                cell.productNameLabel.text = item.name
                cell.priceLabel.text = "KD. \(item.regularPrice ?? 0)"
                cell.productDescriptionLabel.text = item.description
                if let iconURLString = item.icon, let url = URL(string: iconURLString) {
                    ServiceFile.shared.downloadImage(from: url) { image in
                        DispatchQueue.main.async {
                            cell.foodImageView.image = image ?? UIImage(named: "placeholder")
                        }
                    }
                } else {
                    cell.foodImageView.image = UIImage(named: "placeholder")
                }
            }
        }
            return cell
        }
    }

























