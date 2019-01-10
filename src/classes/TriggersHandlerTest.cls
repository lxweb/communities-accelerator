@isTest
public class TriggersHandlerTest {
	
	@testSetup
	static void testSetup(){
		TriggersHandler.isTriggersHandlerTest = true;
	}

	@isTest 
	static void simulationDataPreparingDMLsAndFinish(){
		//Comment: Checks execution of "satellite" methods ("dataPreparing", "executeDMLs" and "triggerFinish")

		//Given
		User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
		List<SObject> triggerNew = new List<SObject>{u};
	    List<SObject> triggerOld;
	    map<Id, SObject> triggerOldMap;
	    
		//When
		Test.startTest();
	    TriggersHandler th = new TriggersHandler(triggerNew, triggerOld, false);
	    th.triggerIsBefore = true;
	    th.triggerIsAfter = false;
	    th.triggerIsInsert = true;
	    th.triggerIsUpdate = false;
	    th.triggerIsUndelete = false;
	    th.triggerIsDelete = false;
	    th.triggerOldMap = triggerOldMap;

	    th.allow_masterLoop_BeforeInsert = true;
	    th.allow_dataPreparing = true;
	    th.allow_executeDMLs = true;
	    th.allow_finalLoop_BeforeInsert = true;
	    th.allow_triggerFinish = true;
	    th.allow_selfUpdate = true;

	    th.run();
		Test.stopTest();

		//Then
		System.assert(th.mapExecution_forTest.containsKey('dataPreparing'));
		System.assert(th.mapExecution_forTest.containsKey('executeDMLs'));
		System.assert(th.mapExecution_forTest.containsKey('triggerFinish'));
	}

	@isTest 
	static void simulationBeforeInsert(){
		//Comment: Checks execution of Before Insert event

		//Given
		User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
		List<SObject> triggerNew = new List<SObject>{u};
	    List<SObject> triggerOld;
	    map<Id, SObject> triggerOldMap;
	    
		//When
		Test.startTest();
	    TriggersHandler th = new TriggersHandler(triggerNew, triggerOld, false);
	    th.triggerIsBefore = true;
	    th.triggerIsAfter = false;
	    th.triggerIsInsert = true;
	    th.triggerIsUpdate = false;
	    th.triggerIsUndelete = false;
	    th.triggerIsDelete = false;
	    th.triggerOldMap = triggerOldMap;

	    th.allow_masterLoop_BeforeInsert = true;
	    th.allow_dataPreparing = true;
	    th.allow_executeDMLs = true;
	    th.allow_finalLoop_BeforeInsert = true;
	    th.allow_triggerFinish = true;
	    th.allow_selfUpdate = true;

	    th.run();
		Test.stopTest();

		//Then
		System.assert(th.mapExecution_forTest.containsKey('masterLoop_BeforeInsert'));
		System.assert(th.mapExecution_forTest.get('masterLoop_BeforeInsert').contains(u.Id));
		System.assert(th.mapExecution_forTest.containsKey('finalLoop_BeforeInsert'));
		System.assert(th.mapExecution_forTest.get('finalLoop_BeforeInsert').contains(u.Id));
	}

	@isTest 
	static void simulationAfterInsert(){
		//Comment: Checks execution of After Insert event

		//Given
		User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
		List<SObject> triggerNew = new List<SObject>{u};
	    List<SObject> triggerOld;
	    map<Id, SObject> triggerOldMap;
	    
		//When
		Test.startTest();
	    TriggersHandler th = new TriggersHandler(triggerNew, triggerOld, false);
	    th.triggerIsBefore = false;
	    th.triggerIsAfter = true;
	    th.triggerIsInsert = true;
	    th.triggerIsUpdate = false;
	    th.triggerIsUndelete = false;
	    th.triggerIsDelete = false;
	    th.triggerOldMap = triggerOldMap;

	    th.allow_masterLoop_AfterInsert = true;
	    th.allow_dataPreparing = true;
	    th.allow_executeDMLs = true;
	    th.allow_finalLoop_AfterInsert = true;
	    th.allow_triggerFinish = true;
	    th.allow_selfUpdate = true;

	    th.run();
		Test.stopTest();

		//Then
		System.assert(th.mapExecution_forTest.containsKey('masterLoop_AfterInsert'));
		System.assert(th.mapExecution_forTest.get('masterLoop_AfterInsert').contains(u.Id));
		System.assert(th.mapExecution_forTest.containsKey('finalLoop_AfterInsert'));
		System.assert(th.mapExecution_forTest.get('finalLoop_AfterInsert').contains(u.Id));
	}

	@isTest 
	static void simulationBeforeUpdate(){
		//Comment: Checks execution of Before Update event

		//Given
		User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
		List<SObject> triggerNew = new List<SObject>{u};
	    List<SObject> triggerOld = new List<SObject>{u};
	    map<Id, SObject> triggerOldMap = new map<Id, SObject>{u.Id => u};
	    
		//When
		Test.startTest();
	    TriggersHandler th = new TriggersHandler(triggerNew, triggerOld, false);
	    th.triggerIsBefore = true;
	    th.triggerIsAfter = false;
	    th.triggerIsInsert = false;
	    th.triggerIsUpdate = true;
	    th.triggerIsUndelete = false;
	    th.triggerIsDelete = false;
	    th.triggerOldMap = triggerOldMap;

	    th.allow_masterLoop_BeforeUpdate = true;
	    th.allow_dataPreparing = true;
	    th.allow_executeDMLs = true;
	    th.allow_finalLoop_BeforeUpdate = true;
	    th.allow_triggerFinish = true;
	    th.allow_selfUpdate = true;

	    th.run();
		Test.stopTest();

		//Then
		System.assert(th.mapExecution_forTest.containsKey('masterLoop_BeforeUpdate'));
		System.assert(th.mapExecution_forTest.get('masterLoop_BeforeUpdate').contains(u.Id));
		System.assert(th.mapExecution_forTest.containsKey('finalLoop_BeforeUpdate'));
		System.assert(th.mapExecution_forTest.get('finalLoop_BeforeUpdate').contains(u.Id));
	}

	@isTest 
	static void simulationAfterUpdate(){
		//Comment: Checks execution of After Update event

		//Given
		User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
		List<SObject> triggerNew = new List<SObject>{u};
	    List<SObject> triggerOld = new List<SObject>{u};
	    map<Id, SObject> triggerOldMap = new map<Id, SObject>{u.Id => u};
	    
		//When
		Test.startTest();
	    TriggersHandler th = new TriggersHandler(triggerNew, triggerOld, false);
	    th.triggerIsBefore = false;
	    th.triggerIsAfter = true;
	    th.triggerIsInsert = false;
	    th.triggerIsUpdate = true;
	    th.triggerIsUndelete = false;
	    th.triggerIsDelete = false;
	    th.triggerOldMap = triggerOldMap;

	    th.allow_masterLoop_AfterUpdate = true;
	    th.allow_dataPreparing = true;
	    th.allow_executeDMLs = true;
	    th.allow_finalLoop_AfterUpdate = true;
	    th.allow_triggerFinish = true;
	    th.allow_selfUpdate = true;

	    th.run();
		Test.stopTest();

		//Then
		System.assert(th.mapExecution_forTest.containsKey('masterLoop_AfterUpdate'));
		System.assert(th.mapExecution_forTest.get('masterLoop_AfterUpdate').contains(u.Id));
		System.assert(th.mapExecution_forTest.containsKey('finalLoop_AfterUpdate'));
		System.assert(th.mapExecution_forTest.get('finalLoop_AfterUpdate').contains(u.Id));
	}

	@isTest 
	static void simulationBeforeDelete(){
		//Comment: Checks execution of Before Delete event

		//Given
		User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
		List<SObject> triggerNew;
	    List<SObject> triggerOld = new List<SObject>{u};
	    map<Id, SObject> triggerOldMap = new map<Id, SObject>{u.Id => u};
	    
		//When
		Test.startTest();
	    TriggersHandler th = new TriggersHandler(triggerNew, triggerOld, false);
	    th.triggerIsBefore = true;
	    th.triggerIsAfter = false;
	    th.triggerIsInsert = false;
	    th.triggerIsUpdate = false;
	    th.triggerIsUndelete = false;
	    th.triggerIsDelete = true;
	    th.triggerOldMap = triggerOldMap;

	    th.allow_masterLoop_BeforeDelete = true;
	    th.allow_dataPreparing = true;
	    th.allow_executeDMLs = true;
	    th.allow_finalLoop_BeforeDelete = true;
	    th.allow_triggerFinish = true;
	    th.allow_selfUpdate = true;

	    th.run();
		Test.stopTest();

		//Then
		System.assert(th.mapExecution_forTest.containsKey('masterLoop_BeforeDelete'));
		System.assert(th.mapExecution_forTest.get('masterLoop_BeforeDelete').contains(u.Id));
		System.assert(th.mapExecution_forTest.containsKey('finalLoop_BeforeDelete'));
		System.assert(th.mapExecution_forTest.get('finalLoop_BeforeDelete').contains(u.Id));
	}

	@isTest 
	static void simulationAfterDelete(){
		//Comment: Checks execution of After Delete event

		//Given
		User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
		List<SObject> triggerNew;
	    List<SObject> triggerOld = new List<SObject>{u};
	    map<Id, SObject> triggerOldMap = new map<Id, SObject>{u.Id => u};
	    
		//When
		Test.startTest();
	    TriggersHandler th = new TriggersHandler(triggerNew, triggerOld, false);
	    th.triggerIsBefore = false;
	    th.triggerIsAfter = true;
	    th.triggerIsInsert = false;
	    th.triggerIsUpdate = false;
	    th.triggerIsUndelete = false;
	    th.triggerIsDelete = true;
	    th.triggerOldMap = triggerOldMap;

	    th.allow_masterLoop_AfterDelete = true;
	    th.allow_dataPreparing = true;
	    th.allow_executeDMLs = true;
	    th.allow_finalLoop_AfterDelete = true;
	    th.allow_triggerFinish = true;
	    th.allow_selfUpdate = true;

	    th.run();
		Test.stopTest();

		//Then
		System.assert(th.mapExecution_forTest.containsKey('masterLoop_AfterDelete'));
		System.assert(th.mapExecution_forTest.get('masterLoop_AfterDelete').contains(u.Id));
		System.assert(th.mapExecution_forTest.containsKey('finalLoop_AfterDelete'));
		System.assert(th.mapExecution_forTest.get('finalLoop_AfterDelete').contains(u.Id));
	}

	@isTest 
	static void simulationAfterUndelete(){
		//Comment: Checks execution of After Undelete event

		//Given
		User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
		List<SObject> triggerNew = new List<SObject>{u};
	    List<SObject> triggerOld;
	    map<Id, SObject> triggerOldMap;
	    
		//When
		Test.startTest();
	    TriggersHandler th = new TriggersHandler(triggerNew, triggerOld, false);
	    th.triggerIsBefore = false;
	    th.triggerIsAfter = true;
	    th.triggerIsInsert = false;
	    th.triggerIsUpdate = false;
	    th.triggerIsUndelete = true;
	    th.triggerIsDelete = false;
	    th.triggerOldMap = triggerOldMap;

	    th.allow_masterLoop_AfterUndelete = true;
	    th.allow_dataPreparing = true;
	    th.allow_executeDMLs = true;
	    th.allow_finalLoop_AfterUndelete = true;
	    th.allow_triggerFinish = true;
	    th.allow_selfUpdate = true;

	    th.run();
		Test.stopTest();

		//Then
		System.assert(th.mapExecution_forTest.containsKey('masterLoop_AfterUndelete'));
		System.assert(th.mapExecution_forTest.get('masterLoop_AfterUndelete').contains(u.Id));
		System.assert(th.mapExecution_forTest.containsKey('finalLoop_AfterUndelete'));
		System.assert(th.mapExecution_forTest.get('finalLoop_AfterUndelete').contains(u.Id));
	}

	@isTest
	static void testSelfUpdate(){
		//Comment: Checks execution of "Self Update" method

		//Given
		User u = [SELECT Id, Name, FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];
		List<SObject> triggerNew = new List<SObject>{u};
	    List<SObject> triggerOld = new List<SObject>{u};
	    map<Id, SObject> triggerOldMap = new map<Id, SObject>{u.Id => u};
	    
		//When
		Test.startTest();
	    TriggersHandler th = new TriggersHandler(triggerNew, triggerOld);
	    th.triggerIsBefore = false;
	    th.triggerIsAfter = true;
	    th.triggerIsInsert = false;
	    th.triggerIsUpdate = true;
	    th.triggerIsUndelete = false;
	    th.triggerIsDelete = false;
	    th.triggerOldMap = triggerOldMap;

	    th.allow_masterLoop_AfterUpdate = true;
	    th.allow_dataPreparing = true;
	    th.allow_executeDMLs = true;
	    th.allow_finalLoop_AfterUpdate = true;
	    th.allow_triggerFinish = true;
	    th.allow_selfUpdate = true;

	    th.recordSelfUpdate(u.Id, 'FirstName', 'New First Name');
	    th.recordSelfUpdate(u.Id, 'LastName', 'New Last Name');

	    th.run();
		Test.stopTest();

		//Then
		u = [SELECT Id, Name, FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];
		System.assertEquals(u.FirstName, 'New First Name');
		System.assertEquals(u.LastName, 'New Last Name');
	}

	@isTest
	static void testCanMethod(){
		//Comment: Checks execution of "CanMethod" method

		//Given
		User u = [SELECT Id, Name, FirstName, LastName FROM User WHERE Id =: UserInfo.getUserId()];
		List<SObject> triggerNew = new List<SObject>{u};
	    List<SObject> triggerOld = new List<SObject>{u};
	    map<Id, SObject> triggerOldMap = new map<Id, SObject>{u.Id => u};

		//When
		Test.startTest();
	    TriggersHandler th = new TriggersHandler(triggerNew, triggerOld);
	    th.triggerIsBefore = false;
	    th.triggerIsAfter = true;
	    th.triggerIsInsert = false;
	    th.triggerIsUpdate = true;
	    th.triggerIsUndelete = false;
	    th.triggerIsDelete = false;
	    th.triggerOldMap = triggerOldMap;

	    th.allow_masterLoop_AfterUpdate = true;
	    th.allow_dataPreparing = true;
	    th.allow_executeDMLs = true;
	    th.allow_finalLoop_AfterUpdate = true;
	    th.allow_triggerFinish = true;
	    th.allow_selfUpdate = true;
		th.run();

	    Boolean executed = th.canMethod('TriggersHandler.testMethod');

	    TriggersHandlerManager.byPassTrigger('TriggersHandler.testMethod2');
	    Boolean notExecuted = th.canMethod('testMethod2');
		Test.stopTest();

		//Then
		System.assertEquals(executed, true);
		System.assertEquals(notExecuted, false);
	}

}