//
//  CardsViewController.swift
//  Basil 442
//
//  Created by Sophie Zhao on 12/1/16.
//  Copyright © 2016 team danko_. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let recipeInstance = Recipes()
    
    var allRecipes: Dictionary<Int, AnyObject> = [:]
    var prepTime: Int = 0
    
    @IBOutlet weak var cardTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allRecipes = recipeInstance.searchRecipes("burger")
        cardTableView.registerNib(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "recipeCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedRow = cardTableView.indexPathForSelectedRow {
            cardTableView.deselectRowAtIndexPath(selectedRow, animated: true)
        }
    }
    
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allRecipes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recipeCell", forIndexPath: indexPath) as! TableViewCell
        
        // Configure cell
        cell.cellRecipeName?.text = allRecipes[indexPath.row]!["title"] as? String
        prepTime = allRecipes[indexPath.row]!["readyInMinutes"] as! Int
        cell.prepTime?.text = String(prepTime)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("toDetailSegue", sender: indexPath)
    }
    
    func detailViewModelForRowAtIndexPath(indexPath: NSIndexPath) -> DetailViewModel {
        let selectedRecipe = getRelevantData(indexPath)
        return DetailViewModel(recipe: selectedRecipe)
    }
    
    func getRelevantData(indexPath: NSIndexPath) -> Recipe {
        let selected = allRecipes[indexPath.row]
        let idInt = selected!["id"] as! Int
        let id = String(idInt)
        let title = selected!["title"] as! String
        let timeInt = selected!["readyInMinutes"] as! Int
        let time = String(timeInt)
        
        // Get details 
        let detailsInfo:Dictionary<String, AnyObject> = recipeInstance.getRecipeDetails(id) as! Dictionary<String, AnyObject>
        let image = detailsInfo["imageURL"] as! String
        let servingsInt = detailsInfo["servings"] as! Int
        let servings = String(servingsInt)
                
        // Get ingredients
        let ingredientInfo:Dictionary<String, AnyObject> = recipeInstance.getIngredients(id) as! Dictionary<String, AnyObject>
        let ingredientsList:Array<String> = (ingredientInfo["ingredients"] as! Array<String>)
        
        // Get directions
        let directionsList:Array<String> = recipeInstance.getDirections(id)
        
        // Create Recipe instance with current recipe
        let selectedRecipe = Recipe(id:id, name:title, imageURL:image, time:time, servings:servings, ingredients:ingredientsList, directions:directionsList)
        
        return selectedRecipe
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailVC = segue.destinationViewController as? DetailViewController,
            indexPath = sender as? NSIndexPath {
            detailVC.viewModel = detailViewModelForRowAtIndexPath(indexPath)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
