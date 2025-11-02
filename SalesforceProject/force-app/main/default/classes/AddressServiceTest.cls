/**
 * @description Testes unitários para a classe AddressService
 * @author Sistema
 * @since 2024
 */
@IsTest
private class AddressServiceTest {
    
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
    static void testGetAddressByCepCacheFirst() {
        // Arrange
        String responseBody = '{"cep":"22071-900","logradouro":"Avenida Atlântica","bairro":"Copacabana","localidade":"Rio de Janeiro","uf":"RJ"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_FIRST);
        
        // Act - Buscar endereço que existe no cache
        Test.startTest();
        AddressDto result1 = service.getAddressByCep('01310-100');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result1, 'Resultado não deve ser nulo');
        Assert.areEqual('01310-100', result1.cep, 'CEP deve ser igual ao esperado');
        Assert.areEqual('Avenida Paulista', result1.logradouro, 'Deve retornar dados do cache');
    }
    
    @IsTest
    static void testGetAddressByCepApiFirst() {
        // Arrange
        String responseBody = '{"cep":"22071-900","logradouro":"Avenida Atlântica","bairro":"Copacabana","localidade":"Rio de Janeiro","uf":"RJ"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.API_FIRST);
        
        // Act
        Test.startTest();
        AddressDto result = service.getAddressByCep('22071-900');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.areEqual('22071-900', result.cep, 'CEP deve ser igual ao esperado');
        Assert.areEqual('Avenida Atlântica', result.logradouro, 'Deve retornar dados da API');
    }
    
    @IsTest
    static void testGetAddressByCepCacheOnly() {
        // Arrange
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_ONLY);
        
        // Act
        Test.startTest();
        AddressDto result1 = service.getAddressByCep('01310-100'); // Existe no cache
        AddressDto result2 = service.getAddressByCep('99999-999'); // Não existe no cache
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result1, 'Resultado deve retornar dados do cache');
        Assert.areEqual('01310-100', result1.cep, 'CEP deve ser igual ao esperado');
        Assert.isNull(result2, 'Resultado deve ser nulo para CEP não encontrado no cache');
    }
    
    @IsTest
    static void testGetAddressByCepApiOnly() {
        // Arrange
        String responseBody = '{"cep":"22071-900","logradouro":"Avenida Atlântica","bairro":"Copacabana","localidade":"Rio de Janeiro","uf":"RJ"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.API_ONLY);
        
        // Act
        Test.startTest();
        AddressDto result = service.getAddressByCep('22071-900');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.areEqual('22071-900', result.cep, 'CEP deve ser igual ao esperado');
        Assert.areEqual('Avenida Atlântica', result.logradouro, 'Deve retornar dados da API');
    }
    
    @IsTest
    static void testGetAddressByCepWithInvalidCep() {
        // Arrange
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_FIRST);
        
        // Act & Assert
        Test.startTest();
        try {
            service.getAddressByCep('123');
            Assert.fail('Deveria ter lançado exceção para CEP inválido');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('CEP'), 'Mensagem deve mencionar CEP');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSaveAddress() {
        // Arrange
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_FIRST);
        AddressDto newAddress = new AddressDto.Builder()
            .setCep('12345-678')
            .setLogradouro('Rua Nova')
            .setBairro('Bairro Novo')
            .setLocalidade('Cidade Nova')
            .setUf('SP')
            .build();
        
        // Act
        Test.startTest();
        Id result = service.saveAddress(newAddress);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        
        // Verificar se foi salvo
        List<Address__c> savedAddresses = [SELECT Id FROM Address__c WHERE Cep__c = '12345-678'];
        Assert.areEqual(1, savedAddresses.size(), 'Endereço deve ter sido salvo');
    }
    
    @IsTest
    static void testSaveAddressWithNull() {
        // Arrange
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_FIRST);
        
        // Act & Assert
        Test.startTest();
        try {
            service.saveAddress(null);
            Assert.fail('Deveria ter lançado exceção para endereço nulo');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('AddressDto'), 'Mensagem deve mencionar AddressDto');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAddressesByCity() {
        // Arrange
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_FIRST);
        
        // Act
        Test.startTest();
        List<AddressDto> results = service.getAddressesByCity('São Paulo');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(results, 'Resultados não devem ser nulos');
        Assert.areEqual(1, results.size(), 'Deve retornar 1 endereço');
        Assert.areEqual('São Paulo', results[0].localidade, 'Localidade deve ser São Paulo');
    }
    
    @IsTest
    static void testGetAddressesByCityWithInvalidCity() {
        // Arrange
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_FIRST);
        
        // Act & Assert
        Test.startTest();
        try {
            service.getAddressesByCity(null);
            Assert.fail('Deveria ter lançado exceção para cidade nula');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Localidade'), 'Mensagem deve mencionar Localidade');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSyncAddressFromApi() {
        // Arrange
        String responseBody = '{"cep":"22071-900","logradouro":"Avenida Atlântica","bairro":"Copacabana","localidade":"Rio de Janeiro","uf":"RJ"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_FIRST);
        
        // Act
        Test.startTest();
        AddressDto result = service.syncAddressFromApi('22071-900');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.areEqual('22071-900', result.cep, 'CEP deve ser igual ao esperado');
        
        // Verificar se foi salvo no cache
        List<Address__c> savedAddresses = [SELECT Id FROM Address__c WHERE Cep__c = '22071-900'];
        Assert.areEqual(1, savedAddresses.size(), 'Endereço deve ter sido salvo no cache');
    }
    
    @IsTest
    static void testSyncAddressFromApiNotFound() {
        // Arrange
        String responseBody = '{"erro": true}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_FIRST);
        
        // Act
        Test.startTest();
        AddressDto result = service.syncAddressFromApi('99999-999');
        Test.stopTest();
        
        // Assert
        Assert.isNull(result, 'Resultado deve ser nulo para CEP não encontrado');
    }
    
    @IsTest
    static void testSyncAddressFromApiWithInvalidCep() {
        // Arrange
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_FIRST);
        
        // Act & Assert
        Test.startTest();
        try {
            service.syncAddressFromApi('123');
            Assert.fail('Deveria ter lançado exceção para CEP inválido');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('CEP'), 'Mensagem deve mencionar CEP');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testIsExternalServiceAvailable() {
        // Arrange
        String responseBody = '{"cep":"01310-100","logradouro":"Avenida Paulista","localidade":"São Paulo","uf":"SP"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_FIRST);
        
        // Act
        Test.startTest();
        Boolean isAvailable = service.isExternalServiceAvailable();
        Test.stopTest();
        
        // Assert
        Assert.isTrue(isAvailable, 'Serviço externo deve estar disponível');
    }
    
    @IsTest
    static void testIsExternalServiceUnavailable() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Internal Server Error'));
        
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_FIRST);
        
        // Act
        Test.startTest();
        Boolean isAvailable = service.isExternalServiceAvailable();
        Test.stopTest();
        
        // Assert
        Assert.isFalse(isAvailable, 'Serviço externo deve estar indisponível');
    }
    
    @IsTest
    static void testSearchCacheFirstFallbackToApi() {
        // Arrange
        String responseBody = '{"cep":"99999-999","logradouro":"Rua Teste","bairro":"Bairro Teste","localidade":"Cidade Teste","uf":"SP"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.CACHE_FIRST);
        
        // Act - Buscar CEP que não existe no cache
        Test.startTest();
        AddressDto result = service.getAddressByCep('99999-999');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.areEqual('99999-999', result.cep, 'CEP deve ser igual ao esperado');
        Assert.areEqual('Rua Teste', result.logradouro, 'Deve retornar dados da API');
    }
    
    @IsTest
    static void testSearchApiFirstFallbackToCache() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Internal Server Error'));
        
        AddressService service = AddressServiceFactory.createAddressService(AddressServiceFactory.SearchStrategy.API_FIRST);
        
        // Act - Buscar CEP que existe no cache mas API está indisponível
        Test.startTest();
        AddressDto result = service.getAddressByCep('01310-100');
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.areEqual('01310-100', result.cep, 'CEP deve ser igual ao esperado');
        Assert.areEqual('Avenida Paulista', result.logradouro, 'Deve retornar dados do cache como fallback');
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