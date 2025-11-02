/**
 * @description Testes unitários para a classe AddressDto
 * @author Sistema
 * @since 2024
 */
@IsTest
private class AddressDtoTest {
    
    @IsTest
    static void testBuilderWithValidData() {
        // Arrange
        String cep = '01310-100';
        String logradouro = 'Avenida Paulista';
        String bairro = 'Bela Vista';
        String localidade = 'São Paulo';
        String uf = 'SP';
        
        // Act
        Test.startTest();
        AddressDto address = new AddressDto.Builder()
            .setCep(cep)
            .setLogradouro(logradouro)
            .setBairro(bairro)
            .setLocalidade(localidade)
            .setUf(uf)
            .build();
        Test.stopTest();
        
        // Assert
        Assert.areEqual(cep, address.cep, 'CEP deve ser igual ao valor definido');
        Assert.areEqual(logradouro, address.logradouro, 'Logradouro deve ser igual ao valor definido');
        Assert.areEqual(bairro, address.bairro, 'Bairro deve ser igual ao valor definido');
        Assert.areEqual(localidade, address.localidade, 'Localidade deve ser igual ao valor definido');
        Assert.areEqual(uf, address.uf, 'UF deve ser igual ao valor definido');
    }
    
    @IsTest
    static void testBuilderWithMinimalRequiredData() {
        // Arrange
        String cep = '01310100';
        String localidade = 'São Paulo';
        String uf = 'SP';
        
        // Act
        Test.startTest();
        AddressDto address = new AddressDto.Builder()
            .setCep(cep)
            .setLocalidade(localidade)
            .setUf(uf)
            .build();
        Test.stopTest();
        
        // Assert
        Assert.areEqual('01310-100', address.cep, 'CEP deve ser formatado corretamente');
        Assert.areEqual(localidade, address.localidade, 'Localidade deve ser igual ao valor definido');
        Assert.areEqual(uf, address.uf, 'UF deve ser igual ao valor definido');
        Assert.isNull(address.logradouro, 'Logradouro deve ser nulo quando não informado');
        Assert.isNull(address.bairro, 'Bairro deve ser nulo quando não informado');
    }
    
    @IsTest
    static void testBuilderWithInvalidCep() {
        // Arrange
        String invalidCep = '123';
        String localidade = 'São Paulo';
        String uf = 'SP';
        
        // Act & Assert
        Test.startTest();
        try {
            new AddressDto.Builder()
                .setCep(invalidCep)
                .setLocalidade(localidade)
                .setUf(uf)
                .build();
            Assert.fail('Deveria ter lançado exceção para CEP inválido');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('CEP'), 'Mensagem de erro deve mencionar CEP');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBuilderWithNullCep() {
        // Arrange
        String localidade = 'São Paulo';
        String uf = 'SP';
        
        // Act & Assert
        Test.startTest();
        try {
            new AddressDto.Builder()
                .setCep(null)
                .setLocalidade(localidade)
                .setUf(uf)
                .build();
            Assert.fail('Deveria ter lançado exceção para CEP nulo');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('CEP'), 'Mensagem de erro deve mencionar CEP');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBuilderWithEmptyLocalidade() {
        // Arrange
        String cep = '01310-100';
        String uf = 'SP';
        
        // Act & Assert
        Test.startTest();
        try {
            new AddressDto.Builder()
                .setCep(cep)
                .setLocalidade('')
                .setUf(uf)
                .build();
            Assert.fail('Deveria ter lançado exceção para localidade vazia');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('Localidade'), 'Mensagem de erro deve mencionar Localidade');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testBuilderWithNullUf() {
        // Arrange
        String cep = '01310-100';
        String localidade = 'São Paulo';
        
        // Act & Assert
        Test.startTest();
        try {
            new AddressDto.Builder()
                .setCep(cep)
                .setLocalidade(localidade)
                .setUf(null)
                .build();
            Assert.fail('Deveria ter lançado exceção para UF nula');
        } catch (IllegalArgumentException e) {
            Assert.isTrue(e.getMessage().contains('UF'), 'Mensagem de erro deve mencionar UF');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testIsValidCepWithValidFormats() {
        // Act & Assert
        Test.startTest();
        Assert.isTrue(AddressDto.isValidCep('01310-100'), 'CEP com hífen deve ser válido');
        Assert.isTrue(AddressDto.isValidCep('01310100'), 'CEP sem hífen deve ser válido');
        Assert.isTrue(AddressDto.isValidCep('12345-678'), 'CEP com formato padrão deve ser válido');
        Test.stopTest();
    }
    
    @IsTest
    static void testIsValidCepWithInvalidFormats() {
        // Act & Assert
        Test.startTest();
        Assert.isFalse(AddressDto.isValidCep('123'), 'CEP muito curto deve ser inválido');
        Assert.isFalse(AddressDto.isValidCep('123456789'), 'CEP muito longo deve ser inválido');
        Assert.isFalse(AddressDto.isValidCep('abcde-fgh'), 'CEP com letras deve ser inválido');
        Assert.isFalse(AddressDto.isValidCep(''), 'CEP vazio deve ser inválido');
        Assert.isFalse(AddressDto.isValidCep(null), 'CEP nulo deve ser inválido');
        Test.stopTest();
    }
    
    @IsTest
    static void testFormatCep() {
        // Act & Assert
        Test.startTest();
        Assert.areEqual('01310-100', AddressDto.formatCep('01310100'), 'CEP deve ser formatado com hífen');
        Assert.areEqual('01310-100', AddressDto.formatCep('01310-100'), 'CEP já formatado deve permanecer igual');
        Assert.areEqual('12345-678', AddressDto.formatCep('12345678'), 'CEP deve ser formatado corretamente');
        Test.stopTest();
    }
    
    @IsTest
    static void testToString() {
        // Arrange
        AddressDto address = new AddressDto.Builder()
            .setCep('01310-100')
            .setLogradouro('Avenida Paulista')
            .setBairro('Bela Vista')
            .setLocalidade('São Paulo')
            .setUf('SP')
            .build();
        
        // Act
        Test.startTest();
        String result = address.toString();
        Test.stopTest();
        
        // Assert
        Assert.isTrue(result.contains('01310-100'), 'ToString deve conter o CEP');
        Assert.isTrue(result.contains('Avenida Paulista'), 'ToString deve conter o logradouro');
        Assert.isTrue(result.contains('São Paulo'), 'ToString deve conter a localidade');
        Assert.isTrue(result.contains('SP'), 'ToString deve conter a UF');
    }
    
    @IsTest
    static void testEqualsAndHashCode() {
        // Arrange
        AddressDto address1 = new AddressDto.Builder()
            .setCep('01310-100')
            .setLogradouro('Avenida Paulista')
            .setLocalidade('São Paulo')
            .setUf('SP')
            .build();
            
        AddressDto address2 = new AddressDto.Builder()
            .setCep('01310-100')
            .setLogradouro('Avenida Paulista')
            .setLocalidade('São Paulo')
            .setUf('SP')
            .build();
            
        AddressDto address3 = new AddressDto.Builder()
            .setCep('12345-678')
            .setLocalidade('Rio de Janeiro')
            .setUf('RJ')
            .build();
        
        // Act & Assert
        Test.startTest();
        Assert.areEqual(address1, address2, 'Endereços com mesmos dados devem ser iguais');
        Assert.areNotEqual(address1, address3, 'Endereços com dados diferentes devem ser diferentes');
        Assert.areEqual(address1.hashCode(), address2.hashCode(), 'HashCodes de objetos iguais devem ser iguais');
        Test.stopTest();
    }
}