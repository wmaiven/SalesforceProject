/**
 * @description Controller para operações de endereço na UI
 * Camada de apresentação que expõe métodos para Lightning Web Components
 */
public with sharing class AddressController {
    
    /**
     * @description Busca endereço por CEP
     * @param cep CEP para busca
     * @return Wrapper com resultado da busca
     */
    @AuraEnabled(cacheable=false)
    public static AddressSearchResult searchAddressByCep(String cep) {
        AddressSearchResult result = new AddressSearchResult();
        
        try {
            if (String.isBlank(cep)) {
                result.success = false;
                result.errorMessage = 'CEP é obrigatório';
                return result;
            }
            
            if (!AddressDto.isValidCep(cep)) {
                result.success = false;
                result.errorMessage = 'CEP deve ter 8 dígitos numéricos';
                return result;
            }
            
            AddressService service = AddressServiceFactory.createDefaultAddressService();
            AddressDto address = service.getAddressByCep(cep);
            
            if (address != null) {
                result.success = true;
                result.address = mapToWrapper(address);
                result.message = 'Endereço encontrado com sucesso';
            } else {
                result.success = false;
                result.errorMessage = 'CEP não encontrado';
            }
            
        } catch (IllegalArgumentException ex) {
            result.success = false;
            result.errorMessage = ex.getMessage();
        } catch (ExternalServiceException ex) {
            result.success = false;
            result.errorMessage = 'Erro no serviço externo: ' + ex.getMessage();
        } catch (Exception ex) {
            result.success = false;
            result.errorMessage = 'Erro inesperado: ' + ex.getMessage();
            System.debug(LoggingLevel.ERROR, 'Erro em searchAddressByCep: ' + ex.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Busca endereços por cidade
     * @param city Nome da cidade
     * @return Lista de endereços da cidade
     */
    @AuraEnabled(cacheable=true)
    public static List<AddressWrapper> getAddressesByCity(String city) {
        try {
            if (String.isBlank(city)) {
                throw new IllegalArgumentException('Nome da cidade é obrigatório');
            }
            
            AddressService service = AddressServiceFactory.createDefaultAddressService();
            List<AddressDto> addresses = service.getAddressesByCity(city);
            
            List<AddressWrapper> result = new List<AddressWrapper>();
            for (AddressDto address : addresses) {
                result.add(mapToWrapper(address));
            }
            
            return result;
            
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Erro em getAddressesByCity: ' + ex.getMessage());
            throw new AuraHandledException('Erro ao buscar endereços: ' + ex.getMessage());
        }
    }
    
    /**
     * @description Sincroniza endereço com API externa
     * @param cep CEP para sincronizar
     * @return Resultado da sincronização
     */
    @AuraEnabled(cacheable=false)
    public static AddressSearchResult syncAddressFromApi(String cep) {
        AddressSearchResult result = new AddressSearchResult();
        
        try {
            if (!AddressDto.isValidCep(cep)) {
                result.success = false;
                result.errorMessage = 'CEP inválido';
                return result;
            }
            
            AddressService service = AddressServiceFactory.createDefaultAddressService();
            AddressDto address = service.syncAddressFromApi(cep);
            
            if (address != null) {
                result.success = true;
                result.address = mapToWrapper(address);
                result.message = 'Endereço sincronizado com sucesso';
            } else {
                result.success = false;
                result.errorMessage = 'CEP não encontrado na API externa';
            }
            
        } catch (Exception ex) {
            result.success = false;
            result.errorMessage = 'Erro na sincronização: ' + ex.getMessage();
            System.debug(LoggingLevel.ERROR, 'Erro em syncAddressFromApi: ' + ex.getMessage());
        }
        
        return result;
    }
    
    /**
     * @description Verifica status do serviço externo
     * @return true se serviço está disponível
     */
    @AuraEnabled(cacheable=false)
    public static Boolean checkExternalServiceStatus() {
        try {
            AddressService service = AddressServiceFactory.createDefaultAddressService();
            return service.isExternalServiceAvailable();
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Erro em checkExternalServiceStatus: ' + ex.getMessage());
            return false;
        }
    }
    
    /**
     * @description Converte AddressDto para AddressWrapper
     * @param address DTO do endereço
     * @return Wrapper para UI
     */
    @TestVisible
    private static AddressWrapper mapToWrapper(AddressDto address) {
        AddressWrapper wrapper = new AddressWrapper();
        wrapper.cep = address.cep;
        wrapper.logradouro = address.logradouro;
        wrapper.bairro = address.bairro;
        wrapper.localidade = address.localidade;
        wrapper.uf = address.uf;
        wrapper.formattedAddress = buildFormattedAddress(address);
        return wrapper;
    }
    
    /**
     * @description Constrói endereço formatado para exibição
     * @param address DTO do endereço
     * @return String com endereço formatado
     */
    @TestVisible
    private static String buildFormattedAddress(AddressDto address) {
        List<String> parts = new List<String>();
        
        if (String.isNotBlank(address.logradouro)) {
            parts.add(address.logradouro);
        }
        
        if (String.isNotBlank(address.bairro)) {
            parts.add(address.bairro);
        }
        
        if (String.isNotBlank(address.localidade)) {
            parts.add(address.localidade);
        }
        
        if (String.isNotBlank(address.uf)) {
            parts.add(address.uf);
        }
        
        if (String.isNotBlank(address.cep)) {
            parts.add('CEP: ' + address.cep);
        }
        
        return String.join(parts, ', ');
    }
    
    /**
     * @description Wrapper para resultado de busca de endereço
     */
    public class AddressSearchResult {
        @AuraEnabled public Boolean success { get; set; }
        @AuraEnabled public String message { get; set; }
        @AuraEnabled public String errorMessage { get; set; }
        @AuraEnabled public AddressWrapper address { get; set; }
        
        public AddressSearchResult() {
            this.success = false;
        }
    }
    
    /**
     * @description Wrapper para endereço na UI
     */
    public class AddressWrapper {
        @AuraEnabled public String cep { get; set; }
        @AuraEnabled public String logradouro { get; set; }
        @AuraEnabled public String bairro { get; set; }
        @AuraEnabled public String localidade { get; set; }
        @AuraEnabled public String uf { get; set; }
        @AuraEnabled public String formattedAddress { get; set; }
    }
}