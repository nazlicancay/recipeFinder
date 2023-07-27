//
//  ApiManager.swift
//  RecipeFinder
//
//  Created by Nazlıcan Çay on 18.07.2023.
//

import Foundation
import UIKit

class APIManager {
    static let shared = APIManager()
    let baseURL = "https://www.themealdb.com/api/json/v1/1/search.php?s="
    var ingredients: [String] = []

 // MARK: - Function to get the recipe by name
    
    func fetchMeals(query: String, completion: @escaping (Result<MealData, Error>) -> Void) {
        let urlString = "\(baseURL)\(query)"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let mealData = try JSONDecoder().decode(MealData.self, from: data)
                   
                    if let meal = mealData.meals.first {
                                      let mealMirror = Mirror(reflecting: meal)

                                      for child in mealMirror.children {
                                          if child.label?.contains("strIngredient") == true, let ingredient = child.value as? String, !ingredient.isEmpty {
                                              self.ingredients.append(ingredient)
                                          } 
                                      }
                                  }
                    completion(.success(mealData))
                } catch(let error) {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Getting the categories
    func fetchCategories(completion: @escaping (Result<[Category], Error>) -> Void) {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/categories.php")!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Data was not retrieved from request"])
                completion(.failure(error))
                return
            }

            do {
                let decoder = JSONDecoder()
                let categoriesResponse = try decoder.decode(CategoriesResponse.self, from: data)
                completion(.success(categoriesResponse.categories))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
    
    // MARK: - GEtting The Meals in Choosen Category
    
    func fetchMealsByCategory(for category: String, completion: @escaping (Result<[Meal], Error>) -> Void) {
        let urlString = "https://www.themealdb.com/api/json/v1/1/filter.php?c=\(category)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let mealResponse = try decoder.decode(MealData.self, from: data!)
                DispatchQueue.main.async {
                    completion(.success(mealResponse.meals))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task.resume()
    }

    
    // MARK: - function to load the meal pictures 
    func loadImage(from url: URL, into imageView: UIImageView) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    imageView.image = UIImage(data: data)
                }
            }
        }.resume()
    }
}
