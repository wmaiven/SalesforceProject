/**
 * @description Testes unitários para a classe AddressController
 * @author Sistema
 * @since 2024
 */
@IsTest
private class AddressControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Criar dados de teste
        Address__c testAddress = new Address__c(
            Cep__c = '01310-100',
            Logradouro__c = 'Avenida Paulista',
            Bairro__c = 'Bela Vista',
            Localidade__c = 'São Paulo',
            Uf__c = 'SP'
        );
        insert testAddress;
    }
    
    @IsTest
    static void testSearchAddressByCepSuccess() {
        // Arrange
        String cep = '01310-100';
        
        // Act
        Test.startTest();
        AddressController.AddressSearchResult result = AddressController.searchAddressByCep(cep);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.isTrue(result.success, 'Busca deve ser bem-sucedida');
        Assert.isNotNull(result.address, 'Endereço não deve ser nulo');
        Assert.areEqual('01310-100', result.address.cep, 'CEP deve ser igual ao esperado');
        Assert.areEqual('Avenida Paulista', result.address.logradouro, 'Logradouro deve ser igual ao esperado');
        Assert.areEqual('São Paulo', result.address.localidade, 'Localidade deve ser igual ao esperado');
        Assert.isTrue(result.address.formattedAddress.contains('Avenida Paulista'), 'Endereço formatado deve conter logradouro');
    }
    
    @IsTest
    static void testSearchAddressByCepNotFound() {
        // Arrange
        String cep = '99999-999';
        
        // Act
        Test.startTest();
        AddressController.AddressSearchResult result = AddressController.searchAddressByCep(cep);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.isFalse(result.success, 'Busca deve falhar');
        Assert.isNull(result.address, 'Endereço deve ser nulo');
        Assert.isTrue(result.message.contains('não encontrado'), 'Mensagem deve indicar que não foi encontrado');
    }
    
    @IsTest
    static void testSearchAddressByCepWithInvalidCep() {
        // Arrange
        String invalidCep = '123';
        
        // Act
        Test.startTest();
        AddressController.AddressSearchResult result = AddressController.searchAddressByCep(invalidCep);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.isFalse(result.success, 'Busca deve falhar');
        Assert.isNull(result.address, 'Endereço deve ser nulo');
        Assert.isTrue(result.errorMessage.contains('CEP'), 'Mensagem deve mencionar CEP');
    }
    
    @IsTest
    static void testSearchAddressByCepWithNullCep() {
        // Arrange
        String nullCep = null;
        
        // Act
        Test.startTest();
        AddressController.AddressSearchResult result = AddressController.searchAddressByCep(nullCep);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.isFalse(result.success, 'Busca deve falhar');
        Assert.isNull(result.address, 'Endereço deve ser nulo');
        Assert.isTrue(result.message.contains('CEP'), 'Mensagem deve mencionar CEP');
    }
    
    @IsTest
    static void testSearchAddressByCepWithEmptyCep() {
        // Arrange
        String emptyCep = '';
        
        // Act
        Test.startTest();
        AddressController.AddressSearchResult result = AddressController.searchAddressByCep(emptyCep);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.isFalse(result.success, 'Busca deve falhar');
        Assert.isNull(result.address, 'Endereço deve ser nulo');
        Assert.isTrue(result.message.contains('CEP'), 'Mensagem deve mencionar CEP');
    }
    
    @IsTest
    static void testGetAddressesByCitySuccess() {
        // Arrange
        String city = 'São Paulo';
        
        // Act
        Test.startTest();
        List<AddressController.AddressWrapper> results = AddressController.getAddressesByCity(city);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(results, 'Resultado não deve ser nulo');
        Assert.areEqual(1, results.size(), 'Deve retornar um endereço');
        Assert.areEqual('São Paulo', results[0].localidade, 'Localidade deve ser São Paulo');
        Assert.areEqual('01310-100', results[0].cep, 'CEP deve ser igual ao esperado');
    }
    
    @IsTest
    static void testGetAddressesByCityNotFound() {
        // Arrange
        String city = 'Cidade Inexistente';
        
        // Act
        Test.startTest();
        List<AddressController.AddressWrapper> results = AddressController.getAddressesByCity(city);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(results, 'Resultado não deve ser nulo');
        Assert.areEqual(0, results.size(), 'Deve retornar lista vazia');
    }
    
    @IsTest
    static void testGetAddressesByCityWithInvalidCity() {
        // Act & Assert
        Test.startTest();
        try {
            AddressController.getAddressesByCity(null);
            Assert.fail('Deveria ter lançado AuraHandledException');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage().contains('Localidade'), 'Mensagem deve mencionar Localidade');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSyncAddressFromApiSuccess() {
        // Arrange
        String responseBody = '{"cep":"22071-900","logradouro":"Avenida Atlântica","bairro":"Copacabana","localidade":"Rio de Janeiro","uf":"RJ"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        String cep = '22071-900';
        
        // Act
        Test.startTest();
        AddressController.AddressSearchResult result = AddressController.syncAddressFromApi(cep);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.isTrue(result.success, 'Sincronização deve ser bem-sucedida');
        Assert.isNotNull(result.address, 'Endereço não deve ser nulo');
        Assert.areEqual('22071-900', result.address.cep, 'CEP deve ser igual ao esperado');
        Assert.areEqual('Avenida Atlântica', result.address.logradouro, 'Logradouro deve ser igual ao esperado');
        
        // Verificar se foi salvo no banco
        List<Address__c> savedAddresses = [SELECT Id FROM Address__c WHERE Cep__c = '22071-900'];
        Assert.areEqual(1, savedAddresses.size(), 'Endereço deve ter sido salvo');
    }
    
    @IsTest
    static void testSyncAddressFromApiNotFound() {
        // Arrange
        String responseBody = '{"erro": true}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        String cep = '99999-999';
        
        // Act
        Test.startTest();
        AddressController.AddressSearchResult result = AddressController.syncAddressFromApi(cep);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.isFalse(result.success, 'Sincronização deve falhar');
        Assert.isNull(result.address, 'Endereço deve ser nulo');
        Assert.isTrue(result.message.contains('não encontrado'), 'Mensagem deve indicar que não foi encontrado');
    }
    
    @IsTest
    static void testSyncAddressFromApiWithInvalidCep() {
        // Arrange
        String invalidCep = '123';
        
        // Act
        Test.startTest();
        AddressController.AddressSearchResult result = AddressController.syncAddressFromApi(invalidCep);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.isFalse(result.success, 'Sincronização deve falhar');
        Assert.isNull(result.address, 'Endereço deve ser nulo');
        Assert.isTrue(result.message.contains('CEP'), 'Mensagem deve mencionar CEP');
    }
    
    @IsTest
    static void testSyncAddressFromApiServiceError() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Internal Server Error'));
        
        String cep = '01310-100';
        
        // Act
        Test.startTest();
        AddressController.AddressSearchResult result = AddressController.syncAddressFromApi(cep);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.isFalse(result.success, 'Sincronização deve falhar');
        Assert.isNull(result.address, 'Endereço deve ser nulo');
        Assert.isTrue(result.message.contains('erro'), 'Mensagem deve indicar erro');
    }
    
    @IsTest
    static void testCheckExternalServiceStatusAvailable() {
        // Arrange
        String responseBody = '{"cep":"01310-100","logradouro":"Avenida Paulista","localidade":"São Paulo","uf":"SP"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        // Act
        Test.startTest();
        Boolean isAvailable = AddressController.checkExternalServiceStatus();
        Test.stopTest();
        
        // Assert
        Assert.isTrue(isAvailable, 'Serviço deve estar disponível');
    }
    
    @IsTest
    static void testCheckExternalServiceStatusUnavailable() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Internal Server Error'));
        
        // Act
        Test.startTest();
        Boolean isAvailable = AddressController.checkExternalServiceStatus();
        Test.stopTest();
        
        // Assert
        Assert.isFalse(isAvailable, 'Serviço deve estar indisponível');
    }
    
    @IsTest
    static void testMapToWrapper() {
        // Arrange
        AddressDto addressDto = new AddressDto.Builder()
            .setCep('01310-100')
            .setLogradouro('Avenida Paulista')
            .setBairro('Bela Vista')
            .setLocalidade('São Paulo')
            .setUf('SP')
            .build();
        
        // Act
        Test.startTest();
        AddressController.AddressWrapper result = AddressController.mapToWrapper(addressDto);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.areEqual('01310-100', result.cep, 'CEP deve ser mapeado corretamente');
        Assert.areEqual('Avenida Paulista', result.logradouro, 'Logradouro deve ser mapeado corretamente');
        Assert.areEqual('Bela Vista', result.bairro, 'Bairro deve ser mapeado corretamente');
        Assert.areEqual('São Paulo', result.localidade, 'Localidade deve ser mapeada corretamente');
        Assert.areEqual('SP', result.uf, 'UF deve ser mapeada corretamente');
        Assert.isNotNull(result.formattedAddress, 'Endereço formatado não deve ser nulo');
        Assert.isTrue(result.formattedAddress.contains('Avenida Paulista'), 'Endereço formatado deve conter logradouro');
    }
    
    @IsTest
    static void testBuildFormattedAddress() {
        // Arrange
        AddressDto addressDto = new AddressDto.Builder()
            .setCep('01310-100')
            .setLogradouro('Avenida Paulista')
            .setBairro('Bela Vista')
            .setLocalidade('São Paulo')
            .setUf('SP')
            .build();
        
        // Act
        Test.startTest();
        String result = AddressController.buildFormattedAddress(addressDto);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.isTrue(result.contains('Avenida Paulista'), 'Deve conter logradouro');
        Assert.isTrue(result.contains('Bela Vista'), 'Deve conter bairro');
        Assert.isTrue(result.contains('São Paulo'), 'Deve conter localidade');
        Assert.isTrue(result.contains('SP'), 'Deve conter UF');
        Assert.isTrue(result.contains('01310-100'), 'Deve conter CEP');
    }
    
    @IsTest
    static void testBuildFormattedAddressWithMinimalData() {
        // Arrange
        AddressDto addressDto = new AddressDto.Builder()
            .setCep('01310-100')
            .setLocalidade('São Paulo')
            .setUf('SP')
            .build();
        
        // Act
        Test.startTest();
        String result = AddressController.buildFormattedAddress(addressDto);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.isTrue(result.contains('São Paulo'), 'Deve conter localidade');
        Assert.isTrue(result.contains('SP'), 'Deve conter UF');
        Assert.isTrue(result.contains('01310-100'), 'Deve conter CEP');
    }
    
    // Mock class para simular respostas HTTP
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(this.statusCode);
            res.setBody(this.responseBody);
            res.setHeader('Content-Type', 'application/json');
            return res;
        }
    }
}