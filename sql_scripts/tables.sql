-- create blank userbase 
DROP DATABASE IF EXISTS MyNutrition;

CREATE DATABASE MyNutrition;

USE MyNutrition;

-- CREATE DATABASE
CREATE TABLE ingredient (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    servings FLOAT NOT NULL,
    cost DECIMAL(5, 2) NOT NULL,
    fat FLOAT DEFAULT 0.0,
    protein FLOAT DEFAULT 0.0,
    carbohydrates FLOAT DEFAULT 0.0,
    sodium FLOAT DEFAULT 0.0,
    weblink VARCHAR(255)
);

CREATE TABLE recipe (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    servings SMALLINT DEFAULT 1
);

CREATE TABLE recipeNutrition (
    recipeID INT,
    totalFat FLOAT DEFAULT 0.0,
    totalProtein FLOAT DEFAULT 0.0,
    totalCarbs FLOAT DEFAULT 0.0,
    totalSodium FLOAT DEFAULT 0.0,
    totalCalories FLOAT DEFAULT 0.0,
    CONSTRAINT FK_recipe_recipeNutrition FOREIGN KEY (recipeID) REFERENCES recipe(id)
);

delimiter //
CREATE TRIGGER newRecipe 
	AFTER INSERT
	ON recipe
	FOR EACH ROW
	BEGIN
        SET @lastRecipeID = 0;
		SELECT id 
        FROM recipe
        ORDER BY id DESC
        LIMIT 1
        INTO @lastRecipeID;
		INSERT INTO recipeNutrition (recipeID)
					VALUES (@lastRecipeID);
	END;
    //
delimiter ;

CREATE TABLE recipeIngredient(
    recipeID INT,
    ingredientID INT,
    ingredientQty FLOAT DEFAULT 0.0,
    CONSTRAINT PK_recipeIngredient PRIMARY KEY (recipeID, ingredientID),
    CONSTRAINT FK_recipe_recipeIngredient FOREIGN KEY (recipeID) REFERENCES recipe(id),
    CONSTRAINT FK_ingredient_recipeIngredient FOREIGN KEY (ingredientID) REFERENCES ingredient(id)
);

delimiter //
CREATE TRIGGER updateRecipeNutrition 
	AFTER INSERT 
    ON recipeIngredient 
    FOR EACH ROW
    BEGIN
		SELECT *
        FROM recipeIngredient
        ORDER BY recipeID DESC
        LIMIT 1
        INTO @recipeID, @ingredientID, @ingredientQty;
        -- fat content
        SELECT fat, protein, carbohydrates, sodium
        FROM ingredient
        WHERE id = @ingredientID
        INTO @fatPerServing, @proteinPerServing, @carbsPerServing, @naPerServing;
		UPDATE recipeNutrition
        SET recipeNutrition.totalFat = recipeNutrition.totalFat + (@fatPerServing * @ingredientQty), 
			recipeNutrition.totalProtein = recipeNutrition.totalProtein + (@proteinPerServing * @ingredientQty),
			recipeNutrition.totalCarbs = recipeNutrition.totalCarbs + (@carbsPerServing * @ingredientQty),
            recipeNutrition.totalSodium = recipeNutrition.totalSodium + (@naPerServing * @ingredientQty),
			recipeNutrition.totalCalories = (recipeNutrition.totalFat * 8) + 4 * (
				recipeNutrition.totalProtein + recipeNutrition.totalCarbs)
        WHERE recipeNutrition.recipeID = @recipeID;
        END;
//
delimiter ;

CREATE TABLE recipeCost (
    recipeID INT,
    costPerServing DECIMAL(5, 2),
    CONSTRAINT FK_recipe_recipeCost FOREIGN KEY (recipeID) REFERENCES recipe(id)
);

-- TEST DB 
INSERT INTO
    ingredient (
        name,
        servings,
        cost,
        fat,
        carbohydrates,
        protein,
        sodium,
        weblink
    )
VALUES
    (
        'Crunchy Peanut Butter',
        35,
        3.98,
        15,
        8,
        7,
        135,
        'https://www.walmart.com/ip/Great-Value-Crunchy-Peanut-Butter-40-oz/10315478'
    ),
    (
        'Multi Grain Bread',
        15,
        2.38,
        2,
        23,
        5,
        170,
        'https://www.walmart.com/ip/Great-Value-Multi-Grain-Bread-24-oz/46491799'
    ),
    (
        'Nutella Hazelnut Spread',
        20,
        7.62,
        11,
        22,
        2,
        15,
        'https://www.walmart.com/ip/Nutella-Hazelnut-Spread-with-Cocoa-for-Breakfast-Great-for-Holiday-Baking-26-5-oz-Jar/14574564'
    );

INSERT INTO
    recipe (name)
VALUES
    ('Peanut Butter-Nutella Sandwich');

SELECT
    *
FROM
    ingredient;

SELECT
    *
FROM
    recipe;

INSERT INTO
    recipeIngredient
VALUES
    (1, 1, 2),
    (1, 2, 3),
    (1, 3, 1);

SELECT
    *
FROM
    recipeIngredient;

SELECT
    *
FROM
    recipeNutrition;