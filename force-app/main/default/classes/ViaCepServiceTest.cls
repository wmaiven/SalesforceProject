/**
 * @description Testes unitários para a classe ViaCepService
 * @author Sistema
 * @since 2024
 */
@IsTest
private class ViaCepServiceTest {
    
    private static final String VALID_CEP = '01310-100';
    private static final String INVALID_CEP = '00000-000';
    private static final String MALFORMED_CEP = '123';
    
    @IsTest
    static void testGetAddressByCepSuccess() {
        // Arrange
        String responseBody = '{"cep":"01310-100","logradouro":"Avenida Paulista","bairro":"Bela Vista","localidade":"São Paulo","uf":"SP"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        ViaCepService service = new ViaCepService();
        
        // Act
        Test.startTest();
        AddressDto result = service.getAddressByCep(VALID_CEP);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.areEqual('01310-100', result.cep, 'CEP deve ser igual ao esperado');
        Assert.areEqual('Avenida Paulista', result.logradouro, 'Logradouro deve ser igual ao esperado');
        Assert.areEqual('Bela Vista', result.bairro, 'Bairro deve ser igual ao esperado');
        Assert.areEqual('São Paulo', result.localidade, 'Localidade deve ser igual ao esperado');
        Assert.areEqual('SP', result.uf, 'UF deve ser igual ao esperado');
    }
    
    @IsTest
    static void testGetAddressByCepWithInvalidCep() {
        // Arrange
        ViaCepService service = new ViaCepService();
        
        // Act & Assert
        Test.startTest();
        try {
            service.getAddressByCep(MALFORMED_CEP);
            Assert.fail('Deveria ter lançado exceção para CEP inválido');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('CEP'), 'Mensagem deve mencionar CEP');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAddressByCepWithNullCep() {
        // Arrange
        ViaCepService service = new ViaCepService();
        
        // Act & Assert
        Test.startTest();
        try {
            service.getAddressByCep(null);
            Assert.fail('Deveria ter lançado exceção para CEP nulo');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('CEP'), 'Mensagem deve mencionar CEP');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAddressByCepNotFound() {
        // Arrange
        String responseBody = '{"erro": true}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        ViaCepService service = new ViaCepService();
        
        // Act
        Test.startTest();
        AddressDto result = service.getAddressByCep(INVALID_CEP);
        Test.stopTest();
        
        // Assert
        Assert.isNull(result, 'Resultado deve ser nulo para CEP não encontrado');
    }
    
    @IsTest
    static void testGetAddressByCepHttpError() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Internal Server Error'));
        
        ViaCepService service = new ViaCepService();
        
        // Act & Assert
        Test.startTest();
        try {
            service.getAddressByCep(VALID_CEP);
            Assert.fail('Deveria ter lançado ExternalServiceException');
        } catch (ExternalServiceException e) {
            Assert.areEqual('ViaCEP', e.serviceName, 'Nome do serviço deve ser ViaCEP');
            Assert.areEqual(500, e.statusCode, 'Status code deve ser 500');
            Assert.isTrue(e.getMessage().contains('ViaCEP'), 'Mensagem deve mencionar ViaCEP');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAddressByCepCalloutException() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionGenerator());
        
        ViaCepService service = new ViaCepService();
        
        // Act & Assert
        Test.startTest();
        try {
            service.getAddressByCep(VALID_CEP);
            Assert.fail('Deveria ter lançado ExternalServiceException');
        } catch (ExternalServiceException e) {
            Assert.areEqual('ViaCEP', e.serviceName, 'Nome do serviço deve ser ViaCEP');
            Assert.isTrue(e.getMessage().contains('timeout'), 'Mensagem deve mencionar timeout');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAddressByCepInvalidJson() {
        // Arrange
        String invalidJson = '{"cep":"01310-100","logradouro":}'; // JSON malformado
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, invalidJson));
        
        ViaCepService service = new ViaCepService();
        
        // Act & Assert
        Test.startTest();
        try {
            service.getAddressByCep(VALID_CEP);
            Assert.fail('Deveria ter lançado ExternalServiceException para JSON inválido');
        } catch (ExternalServiceException e) {
            Assert.areEqual('ViaCEP', e.serviceName, 'Nome do serviço deve ser ViaCEP');
            Assert.isTrue(e.getMessage().contains('JSON'), 'Mensagem deve mencionar erro de JSON');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testIsServiceAvailableSuccess() {
        // Arrange
        String responseBody = '{"cep":"01310-100","logradouro":"Avenida Paulista","localidade":"São Paulo","uf":"SP"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, responseBody));
        
        ViaCepService service = new ViaCepService();
        
        // Act
        Test.startTest();
        Boolean isAvailable = service.isServiceAvailable();
        Test.stopTest();
        
        // Assert
        Assert.isTrue(isAvailable, 'Serviço deve estar disponível');
    }
    
    @IsTest
    static void testIsServiceAvailableFailure() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, 'Internal Server Error'));
        
        ViaCepService service = new ViaCepService();
        
        // Act
        Test.startTest();
        Boolean isAvailable = service.isServiceAvailable();
        Test.stopTest();
        
        // Assert
        Assert.isFalse(isAvailable, 'Serviço deve estar indisponível');
    }
    
    @IsTest
    static void testIsServiceAvailableException() {
        // Arrange
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionGenerator());
        
        ViaCepService service = new ViaCepService();
        
        // Act
        Test.startTest();
        Boolean isAvailable = service.isServiceAvailable();
        Test.stopTest();
        
        // Assert
        Assert.isFalse(isAvailable, 'Serviço deve estar indisponível em caso de exceção');
    }
    
    // Mock classes para simular respostas HTTP
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
    
    private class MockHttpExceptionGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            throw new CalloutException('Connection timeout');
        }
    }
}