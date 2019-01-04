@isTest
public class TriggersHandlerManagerTest {
    @testSetup
	static void setup(){
        User u = MockupFactory.createUser('testuser@test.com', 'testuser@test.com');
    }

    @isTest
    static void bypassTriggerTest(){
        TriggersHandlerManager.byPassTrigger('testTrigger');
        system.assert(TriggersHandlerManager.isByPassTrigger('testTrigger'));
    }

}