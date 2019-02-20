trigger RecipeStep on RecipeStep__c (before insert, before update) {

		new RecipeStepTriggers(trigger.new, trigger.old).run();
}