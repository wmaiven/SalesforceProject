/**
 * @description Implementação do repositório de endereços
 * Implementa IAddressRepository
 */
public class AddressRepository implements IAddressRepository {
    
    /**
     * @description Busca endereço por CEP
     * @param cep CEP para busca
     * @return AddressDto com dados do endereço ou null se não encontrado
     */
    public AddressDto findByCep(String cep) {
        if (!AddressDto.isValidCep(cep)) {
            throw new IllegalArgumentException('CEP inválido: ' + cep);
        }
        
        String formattedCep = AddressDto.formatCep(cep);
        
        List<Address__c> addresses = [
            SELECT Id, Cep__c, Logradouro__c, Bairro__c, Localidade__c, Uf__c
            FROM Address__c 
            WHERE Cep__c = :formattedCep 
            LIMIT 1
        ];
        
        if (addresses.isEmpty()) {
            return null;
        }
        
        return mapToDto(addresses[0]);
    }
    
    /**
     * @description Salva endereço no sistema
     * @param address Dados do endereço para salvar
     * @return Id do registro criado
     */
    public Id save(AddressDto address) {
        if (address == null) {
            throw new IllegalArgumentException('AddressDto não pode ser null');
        }
        
        Address__c addressRecord = mapToSObject(address);
        
        try {
            // Verifica se já existe um endereço com o mesmo CEP
            AddressDto existingAddress = findByCep(address.cep);
            if (existingAddress != null) {
                // Atualiza o registro existente
                List<Address__c> existingRecords = [
                    SELECT Id FROM Address__c WHERE Cep__c = :address.cep LIMIT 1
                ];
                if (!existingRecords.isEmpty()) {
                    addressRecord.Id = existingRecords[0].Id;
                    update addressRecord;
                    return addressRecord.Id;
                }
            }
            
            // Cria novo registro
            insert addressRecord;
            return addressRecord.Id;
            
        } catch (DmlException ex) {
            throw new DataException('Erro ao salvar endereço: ' + ex.getMessage());
        }
    }
    
    /**
     * @description Busca endereços por cidade
     * @param city Nome da cidade
     * @return Lista de endereços da cidade
     */
    public List<AddressDto> findByCity(String city) {
        if (String.isBlank(city)) {
            throw new IllegalArgumentException('Nome da cidade não pode estar vazio');
        }
        
        List<Address__c> addresses = [
            SELECT Id, Cep__c, Logradouro__c, Bairro__c, Localidade__c, Uf__c
            FROM Address__c 
            WHERE Localidade__c = :city
            ORDER BY Cep__c
        ];
        
        List<AddressDto> result = new List<AddressDto>();
        for (Address__c address : addresses) {
            result.add(mapToDto(address));
        }
        
        return result;
    }
    
    /**
     * @description Converte SObject para DTO
     * @param address Registro do Salesforce
     * @return AddressDto correspondente
     */
    @TestVisible
    private AddressDto mapToDto(Address__c address) {
        return AddressDto.newBuilder()
            .setCep(address.Cep__c)
            .setLogradouro(address.Logradouro__c)
            .setBairro(address.Bairro__c)
            .setLocalidade(address.Localidade__c)
            .setUf(address.Uf__c)
            .build();
    }
    
    /**
     * @description Converte DTO para SObject
     * @param address DTO do endereço
     * @return Address__c correspondente
     */
    @TestVisible
    private Address__c mapToSObject(AddressDto address) {
        return new Address__c(
            Cep__c = address.cep,
            Logradouro__c = address.logradouro,
            Bairro__c = address.bairro,
            Localidade__c = address.localidade,
            Uf__c = address.uf
        );
    }
    
    /**
     * @description Exceção para erros de dados
     */
    public class DataException extends Exception {}
}