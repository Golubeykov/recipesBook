//
//  ContentView.swift
//  recipesBook
//
//  Created by Антон Голубейков on 10.05.2022.
//

import SwiftUI

struct RecipesListView: View {

    @EnvironmentObject var recipeData: RecipeData
    let viewStyle: ViewStyle

    @State private var isPresenting = false
    @State private var newRecipe = Recipe()
    
    @AppStorage("listBackgroundColor") private var listBackgroundColor = AppColor.background
    @AppStorage("listTextColor") private var listTextColor = AppColor.foreground
    
    var body: some View {
        List {
            ForEach(recipes) {
                recipe in
                NavigationLink(destination: {
                    RecipeDetailView(recipe: binding(for: recipe))
                }, label: {
                    Text(recipe.mainInformation.name)
                })
            }
            .listRowBackground(listBackgroundColor)
            .foregroundColor(listTextColor)
        }
        .navigationTitle(navigationTitle)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing, content: {
                Button(action: {
                    newRecipe = Recipe()
                    newRecipe.mainInformation.category = recipes.first?.mainInformation.category ?? .breakfast
                    isPresenting = true
                }, label: {
                    Image(systemName: "plus")
                })
            })
        })
        .sheet(isPresented: $isPresenting, content: {
            NavigationView {
                ModifyRecipeView(recipe: $newRecipe)
                    .toolbar(content: {
                        ToolbarItem(placement: .navigationBarLeading, content: {
                            Button("Dismiss") {
                                isPresenting = false
                            }
                        })
                        ToolbarItem(placement: .navigationBarTrailing, content: {
                            if newRecipe.isValid {
                            Button("Add") {
                                if case .favorites = viewStyle {
                                    newRecipe.isFavorite = true
                                }
                                recipeData.add(recipe: newRecipe)
                                isPresenting = false
                            }
                        }
                        })
                    })
            }
            .navigationTitle("Add a New Recipe")
        })
    }
}

extension RecipesListView {
    enum ViewStyle {
        case favorites
        case singleCategory(MainInformation.Category)
    }
    private var recipes: [Recipe] {
        switch viewStyle {
        case let .singleCategory(category):
            return recipeData.recipes(for: category)
        case .favorites:
            return recipeData.favoritesRecipes
        }
    }
    var navigationTitle: String {
        switch viewStyle {
        case let .singleCategory(category):
            return "\(category.rawValue) recipes"
        case .favorites:
            return "Favorite recipes"
        }
    }
    func binding(for recipe: Recipe) -> Binding<Recipe> {
        guard let index = recipeData.index(of: recipe) else { fatalError("Recipe not found") }
        return $recipeData.recipes[index]
    }
    
}

struct RecipesListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecipesListView(viewStyle: .singleCategory(.breakfast))
                .environmentObject(RecipeData())
        }
    }
}
 
