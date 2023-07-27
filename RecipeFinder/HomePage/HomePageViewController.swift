//
//  HomePageViewController.swift
//  RecipeFinder
//
//  Created by Nazlıcan Çay on 17.07.2023.
//

import UIKit



class HomePageViewController: UIViewController, UISearchResultsUpdating, UICollectionViewDataSource, UICollectionViewDelegate {
   
    
    var searchResultViewController: SearchResultViewController?
    private var collectionView : UICollectionView?
    var CategoriesList: [Category] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Categories"
        let searchResultViewController = storyboard?.instantiateViewController(withIdentifier: "SearchResultViewControllerIdentifier") as? SearchResultViewController
        let searchController = UISearchController(searchResultsController: searchResultViewController)

        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        APIManager.shared.fetchCategories { (result) in
            DispatchQueue.main.async {  // Switch to the main thread to update the UI
                switch result {
                case .success(let categories):
                    self.CategoriesList = categories
                    self.collectionView?.reloadData()
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
        
        let layout = UICollectionViewFlowLayout ()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.itemSize = CGSize(width: (view.frame.size.width/2)-4,
        height: (view.frame.size.width/2)-4)
        
        collectionView = UICollectionView(frame: .zero,
        collectionViewLayout: layout)
        guard let collectionView = collectionView else {
            return

        }
        collectionView.register(CategoriesCollectionViewCell.self, forCellWithReuseIdentifier: CategoriesCollectionViewCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.frame = view.bounds
        
        
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text,
                 let searchResultViewController = searchController.searchResultsController as? SearchResultViewController else {
               return
           }
            searchResultViewController.searchQuery = text
            
        
           
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        CategoriesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoriesCollectionViewCell.identifier, for: indexPath) as! CategoriesCollectionViewCell
            cell.configure(with: CategoriesList[indexPath.row])
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = CategoriesList[indexPath.row]
        // Assuming RecipeViewController is the view controller you want to navigate to
        let listByCategory = ListByCategoryViewController()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)  // replace "Main" with the name of your storyboard if it's different
            guard let listByCategoryVC = storyboard.instantiateViewController(withIdentifier: "ListByCategoryViewController") as? ListByCategoryViewController else {
                fatalError("Failed to instantiate ListByCategoryViewController")
            }
        listByCategory.selectedCategory = category // Pass the selected category to RecipeViewController
        listByCategoryVC.selectedCategory = category
        navigationController?.pushViewController(listByCategoryVC, animated: true)
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
