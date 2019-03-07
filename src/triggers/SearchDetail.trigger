trigger SearchDetail on SearchDetail__c (before insert, before update) {
  new SearchDetailTriggers(trigger.new, trigger.old).run();
}