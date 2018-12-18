@isTest
private class GeneralUtilsTest {
	
	@isTest static void test_method_one() {
		/* Comment: Comprueba que dado un String, el metodo generateExternalId de la clase General Utils,
		retorne el valor del String recibido como parámetro, sin espacios, y con los carácteres especiales
		cambiados por guiones bajos. Y que dado el caso de que el contenido tenga el Cluster como parámetro
		tambien, entonces retorne un valor con formato: "Cluster_Nombre" */

		//Given
		String name1 = 'FrancoFolatelli';
		String name2 = 'Special°**° Characters';
		String name3 = 'Number123 space';
		String name4 = 'Number123 space';
		String cluster = 'AR';
		String name5 = 'Cachaça';
		String cluster2 = 'BR';
		String res1 = 'FrancoFolatelli';
		String res2 = 'Special____Characters';
		String res3 = 'Number123space';
		String res4 = 'AR_Number123space';
		String res5 = 'BR_Cacha_a';

		// When
		Test.startTest();
		String test1 = GeneralUtils.generateExternalId(name1);
		String test2 = GeneralUtils.generateExternalId(name2);
		String test3 = GeneralUtils.generateExternalId(name3);
		String test4 = GeneralUtils.generateExternalId(name4, cluster);
		String test5 = GeneralUtils.generateExternalId(name5, cluster2);
		Test.stopTest();

		//Then
		System.assertEquals(test1, res1);
		System.assertEquals(test2, res2);
		System.assertEquals(test3, res3);
		System.assertEquals(test4, res4);
		System.assertEquals(test5, res5);
	}
	
	
}