/**
 * @description Testes unitários para a classe AddressRepository
 * @author Sistema
 * @since 2024
 */
@IsTest
private class AddressRepositoryTest {
    
    @TestSetup
    static void setupTestData() {
        // Criar dados de teste
        List<Address__c> testAddresses = new List<Address__c>();
        
        testAddresses.add(new Address__c(
            Cep__c = '01310-100',
            Logradouro__c = 'Avenida Paulista',
            Bairro__c = 'Bela Vista',
            Localidade__c = 'São Paulo',
            Uf__c = 'SP'
        ));
        
        testAddresses.add(new Address__c(
            Cep__c = '22071-900',
            Logradouro__c = 'Avenida Atlântica',
            Bairro__c = 'Copacabana',
            Localidade__c = 'Rio de Janeiro',
            Uf__c = 'RJ'
        ));
        
        testAddresses.add(new Address__c(
            Cep__c = '30112-000',
            Logradouro__c = 'Avenida Afonso Pena',
            Bairro__c = 'Centro',
            Localidade__c = 'Belo Horizonte',
            Uf__c = 'MG'
        ));
        
        insert testAddresses;
    }
    
    @IsTest
    static void testFindByCepSuccess() {
        // Arrange
        AddressRepository repository = new AddressRepository();
        String cep = '01310-100';
        
        // Act
        Test.startTest();
        AddressDto result = repository.findByCep(cep);
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
    static void testFindByCepNotFound() {
        // Arrange
        AddressRepository repository = new AddressRepository();
        String cep = '99999-999';
        
        // Act
        Test.startTest();
        AddressDto result = repository.findByCep(cep);
        Test.stopTest();
        
        // Assert
        Assert.isNull(result, 'Resultado deve ser nulo para CEP não encontrado');
    }
    
    @IsTest
    static void testFindByCepWithInvalidCep() {
        // Arrange
        AddressRepository repository = new AddressRepository();
        String invalidCep = '123';
        
        // Act & Assert
        Test.startTest();
        try {
            repository.findByCep(invalidCep);
            Assert.fail('Deveria ter lançado exceção para CEP inválido');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('CEP'), 'Mensagem deve mencionar CEP');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testFindByCepWithNullCep() {
        // Arrange
        AddressRepository repository = new AddressRepository();
        
        // Act & Assert
        Test.startTest();
        try {
            repository.findByCep(null);
            Assert.fail('Deveria ter lançado exceção para CEP nulo');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('CEP'), 'Mensagem deve mencionar CEP');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSaveNewAddress() {
        // Arrange
        AddressRepository repository = new AddressRepository();
        AddressDto newAddress = new AddressDto.Builder()
            .setCep('12345-678')
            .setLogradouro('Rua Nova')
            .setBairro('Bairro Novo')
            .setLocalidade('Cidade Nova')
            .setUf('SP')
            .build();
        
        // Act
        Test.startTest();
        Id result = repository.save(newAddress);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        
        // Verificar se foi salvo no banco
        List<Address__c> savedAddresses = [SELECT Id, Cep__c FROM Address__c WHERE Cep__c = '12345-678'];
        Assert.areEqual(1, savedAddresses.size(), 'Deve ter sido salvo um endereço');
    }
    
    @IsTest
    static void testSaveUpdateExistingAddress() {
        // Arrange
        AddressRepository repository = new AddressRepository();
        AddressDto updatedAddress = new AddressDto.Builder()
            .setCep('01310-100')
            .setLogradouro('Avenida Paulista - Atualizada')
            .setBairro('Bela Vista - Atualizada')
            .setLocalidade('São Paulo')
            .setUf('SP')
            .build();
        
        // Act
        Test.startTest();
        Id result = repository.save(updatedAddress);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        
        // Verificar se foi atualizado no banco
        List<Address__c> addresses = [SELECT Id, Logradouro__c FROM Address__c WHERE Cep__c = '01310-100'];
        Assert.areEqual(1, addresses.size(), 'Deve existir apenas um endereço com este CEP');
        Assert.areEqual('Avenida Paulista - Atualizada', addresses[0].Logradouro__c, 'Logradouro deve ter sido atualizado');
    }
    
    @IsTest
    static void testSaveWithNullAddress() {
        // Arrange
        AddressRepository repository = new AddressRepository();
        
        // Act & Assert
        Test.startTest();
        try {
            repository.save(null);
            Assert.fail('Deveria ter lançado exceção para endereço nulo');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('AddressDto'), 'Mensagem deve mencionar AddressDto');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testFindByCitySuccess() {
        // Arrange
        AddressRepository repository = new AddressRepository();
        String city = 'São Paulo';
        
        // Act
        Test.startTest();
        List<AddressDto> results = repository.findByCity(city);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(results, 'Resultado não deve ser nulo');
        Assert.areEqual(1, results.size(), 'Deve retornar um endereço para São Paulo');
        Assert.areEqual('São Paulo', results[0].localidade, 'Localidade deve ser São Paulo');
    }
    
    @IsTest
    static void testFindByCityNotFound() {
        // Arrange
        AddressRepository repository = new AddressRepository();
        String city = 'Cidade Inexistente';
        
        // Act
        Test.startTest();
        List<AddressDto> results = repository.findByCity(city);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(results, 'Resultado não deve ser nulo');
        Assert.areEqual(0, results.size(), 'Deve retornar lista vazia para cidade inexistente');
    }
    
    @IsTest
    static void testFindByCityWithNullCity() {
        // Arrange
        AddressRepository repository = new AddressRepository();
        
        // Act & Assert
        Test.startTest();
        try {
            repository.findByCity(null);
            Assert.fail('Deveria ter lançado exceção para cidade nula');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Localidade'), 'Mensagem deve mencionar Localidade');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testFindByCityWithEmptyCity() {
        // Arrange
        AddressRepository repository = new AddressRepository();
        
        // Act & Assert
        Test.startTest();
        try {
            repository.findByCity('');
            Assert.fail('Deveria ter lançado exceção para cidade vazia');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Localidade'), 'Mensagem deve mencionar Localidade');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testMapToDto() {
        // Arrange
        Address__c addressRecord = new Address__c(
            Cep__c = '01310-100',
            Logradouro__c = 'Avenida Paulista',
            Bairro__c = 'Bela Vista',
            Localidade__c = 'São Paulo',
            Uf__c = 'SP'
        );
        
        AddressRepository repository = new AddressRepository();
        
        // Act
        Test.startTest();
        AddressDto result = repository.mapToDto(addressRecord);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.areEqual('01310-100', result.cep, 'CEP deve ser mapeado corretamente');
        Assert.areEqual('Avenida Paulista', result.logradouro, 'Logradouro deve ser mapeado corretamente');
        Assert.areEqual('Bela Vista', result.bairro, 'Bairro deve ser mapeado corretamente');
        Assert.areEqual('São Paulo', result.localidade, 'Localidade deve ser mapeada corretamente');
        Assert.areEqual('SP', result.uf, 'UF deve ser mapeada corretamente');
    }
    
    @IsTest
    static void testMapToSObject() {
        // Arrange
        AddressDto addressDto = new AddressDto.Builder()
            .setCep('01310-100')
            .setLogradouro('Avenida Paulista')
            .setBairro('Bela Vista')
            .setLocalidade('São Paulo')
            .setUf('SP')
            .build();
        
        AddressRepository repository = new AddressRepository();
        
        // Act
        Test.startTest();
        Address__c result = repository.mapToSObject(addressDto);
        Test.stopTest();
        
        // Assert
        Assert.isNotNull(result, 'Resultado não deve ser nulo');
        Assert.areEqual('01310-100', result.Cep__c, 'CEP deve ser mapeado corretamente');
        Assert.areEqual('Avenida Paulista', result.Logradouro__c, 'Logradouro deve ser mapeado corretamente');
        Assert.areEqual('Bela Vista', result.Bairro__c, 'Bairro deve ser mapeado corretamente');
        Assert.areEqual('São Paulo', result.Localidade__c, 'Localidade deve ser mapeada corretamente');
        Assert.areEqual('SP', result.Uf__c, 'UF deve ser mapeada corretamente');
    }
}