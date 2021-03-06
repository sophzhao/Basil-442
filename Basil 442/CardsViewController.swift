//
//  CardsViewController.swift
//  Basil 442
//
//  Created by Sophie Zhao on 12/1/16.
//  Copyright © 2016 team danko_. All rights reserved.
//

import UIKit

class CardsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: Properties & Outlets
    var cardsViewModel: CardsViewModel?
    
    let recipeInstance = Recipes()
    
    var allRecipes: Dictionary<Int, AnyObject> = [:]
    var prepTime: Int = 0
    
    @IBOutlet weak var cardTableView: UITableView!
    @IBOutlet weak var searchQuery: UILabel!
    
    // MARK: Std View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // register the nib
        searchQuery.text = cardsViewModel!.query()
        allRecipes = recipeInstance.searchRecipes(cardsViewModel!.query())
        if allRecipes.count == 0 {
            alertNoResults(cardsViewModel!.query())
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedRow = cardTableView.indexPathForSelectedRow {
            cardTableView.deselectRowAtIndexPath(selectedRow, animated: true)
        }
    }
    
    // MARK: - General Methods 
    func alertNoResults(query: String) {
        let title = "No results found!"
        let message = "Spoonacular Food API does not have any results for \(query). Please search for another recipe!"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: {
            action in self.performSegueWithIdentifier("unwindToSearch", sender: self)
        })
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    func alertNoInstructions(name: String) {
        let title = "API did not store instructions!"
        let message = "Spoonacular Food API does not have complete instructions. Please try again & select a different recipe!"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default,handler:nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func ingredientsViewModelForRowAtIndexPath(indexPath: NSIndexPath) -> IngredientsViewModel {
        let selectedRecipe = getRelevantData(indexPath)
        return IngredientsViewModel(recipe: selectedRecipe, source: "cards")
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

    
    // MARK: - Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allRecipes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("recipeCell", forIndexPath: indexPath) as! TableViewCell
        
        // Configure cell
        // Get image URL
        if let img = allRecipes[indexPath.row]!["image"] as? String{
            let endString:String = img
            let imgString:String = "https://spoonacular.com/recipeImages/" + endString
            if !imgString.containsString("{") || !imgString.containsString("}") {
                let url:NSURL? = NSURL(string: imgString)
                let data:NSData? = NSData(contentsOfURL : url!)
                let image = UIImage(data : data!)
                cell.recipeImage.image = image
            }
        }
        else {
            let imgString:String = "https://spoonacular.com/recipeImages/beef-burgundy-2-101141.jpg"
            let url:NSURL? = NSURL(string: imgString)
            let data:NSData? = NSData(contentsOfURL : url!)
            let image = UIImage(data : data!)
            cell.recipeImage.image = image
        }
        
        cell.cellRecipeName?.text = allRecipes[indexPath.row]!["title"] as? String
        prepTime = allRecipes[indexPath.row]!["readyInMinutes"] as! Int
        cell.prepTime?.text = String(prepTime)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // if recipe indexed has empty instructions array, ALERT, do not segue
        let selected = allRecipes[indexPath.row]
        let idInt = selected!["id"] as! Int
        let id = String(idInt)
        let details:Dictionary<String, AnyObject> = recipeInstance.getRecipeDetails(id) as! Dictionary<String, AnyObject>
        if let ins = details["instructions"] as? String {
            performSegueWithIdentifier("cardToIngredientsSegue", sender: indexPath)
        } else {
            alertNoInstructions(selected!["title"] as! String)
        }
    }
    
    // MARK: - Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ingVC = segue.destinationViewController as? IngredientsViewController,
            indexPath = sender as? NSIndexPath {
            ingVC.ingViewModel = ingredientsViewModelForRowAtIndexPath(indexPath)
        }
    }
    
    @IBAction func unwindToCard(segue: UIStoryboardSegue) {}
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
