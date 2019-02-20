trigger RecipeIngredient on RecipeIngredient__c (before insert, before update) {

		new RecipeIngredientTriggers(trigger.new, trigger.old).run();
}