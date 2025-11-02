/**
 * @description Serviço principal para operações com endereços
 * Implementa padrão Strategy para diferentes estratégias de busca
 * Centraliza lógica de negócios da aplicação
 */
public class AddressService {
    private final IAddressRepository repository;
    private final IExternalAddressService externalService;
    private final AddressServiceFactory.SearchStrategy strategy;
    
    /**
     * @description Construtor com injeção de dependências
     * @param repository Repositório de endereços
     * @param externalService Serviço externo de endereços
     * @param strategy Estratégia de busca
     */
    public AddressService(
        IAddressRepository repository, 
        IExternalAddressService externalService,
        AddressServiceFactory.SearchStrategy strategy
    ) {
        this.repository = repository;
        this.externalService = externalService;
        this.strategy = strategy;
    }
    
    /**
     * @description Busca endereço por CEP usando estratégia configurada
     * @param cep CEP para busca
     * @return AddressDto com dados do endereço ou null se não encontrado
     * @throws IllegalArgumentException se CEP for inválido
     * @throws ExternalServiceException em caso de erro na API externa
     */
    public AddressDto getAddressByCep(String cep) {
        if (!AddressDto.isValidCep(cep)) {
            throw new IllegalArgumentException('CEP inválido: ' + cep);
        }
        
        switch on strategy {
            when CACHE_FIRST {
                return searchCacheFirst(cep);
            }
            when API_FIRST {
                return searchApiFirst(cep);
            }
            when CACHE_ONLY {
                return searchCacheOnly(cep);
            }
            when API_ONLY {
                return searchApiOnly(cep);
            }
            when else {
                return searchCacheFirst(cep); // fallback
            }
        }
    }
    
    /**
     * @description Salva endereço no repositório local
     * @param address Endereço para salvar
     * @return Id do registro criado
     */
    public Id saveAddress(AddressDto address) {
        if (address == null) {
            throw new IllegalArgumentException('Endereço não pode ser null');
        }
        
        return repository.save(address);
    }
    
    /**
     * @description Busca endereços por cidade
     * @param city Nome da cidade
     * @return Lista de endereços da cidade
     */
    public List<AddressDto> getAddressesByCity(String city) {
        if (String.isBlank(city)) {
            throw new IllegalArgumentException('Nome da cidade não pode estar vazio');
        }
        
        return repository.findByCity(city);
    }
    
    /**
     * @description Sincroniza endereço com API externa e salva localmente
     * @param cep CEP para sincronizar
     * @return AddressDto sincronizado ou null se não encontrado
     */
    public AddressDto syncAddressFromApi(String cep) {
        AddressDto address = searchApiOnly(cep);
        
        if (address != null) {
            try {
                saveAddress(address);
            } catch (Exception ex) {
                // Log do erro mas não falha a operação
                System.debug(LoggingLevel.WARN, 'Erro ao salvar endereço sincronizado: ' + ex.getMessage());
            }
        }
        
        return address;
    }
    
    /**
     * @description Verifica se serviço externo está disponível
     * @return true se disponível
     */
    public Boolean isExternalServiceAvailable() {
        try {
            return externalService.isServiceAvailable();
        } catch (Exception ex) {
            System.debug(LoggingLevel.WARN, 'Erro ao verificar disponibilidade do serviço: ' + ex.getMessage());
            return false;
        }
    }
    
    /**
     * @description Estratégia: busca primeiro no cache, depois na API
     * @param cep CEP para busca
     * @return AddressDto encontrado ou null
     */
    @TestVisible
    private AddressDto searchCacheFirst(String cep) {
        // Primeiro tenta buscar no repositório local
        AddressDto address = repository.findByCep(cep);
        
        if (address != null) {
            return address;
        }
        
        // Se não encontrou, busca na API externa
        try {
            address = externalService.getAddressByCep(cep);
            
            // Se encontrou na API, salva no repositório para próximas consultas
            if (address != null) {
                try {
                    saveAddress(address);
                } catch (Exception ex) {
                    // Log do erro mas não falha a operação
                    System.debug(LoggingLevel.WARN, 'Erro ao salvar endereço do cache: ' + ex.getMessage());
                }
            }
            
            return address;
            
        } catch (ExternalServiceException ex) {
            // Em caso de erro na API, retorna null
            System.debug(LoggingLevel.WARN, 'Erro na API externa: ' + ex.getMessage());
            return null;
        }
    }
    
    /**
     * @description Estratégia: busca primeiro na API, depois no cache
     * @param cep CEP para busca
     * @return AddressDto encontrado ou null
     */
    @TestVisible
    private AddressDto searchApiFirst(String cep) {
        try {
            // Primeiro tenta buscar na API externa
            AddressDto address = externalService.getAddressByCep(cep);
            
            if (address != null) {
                // Se encontrou, salva no repositório
                try {
                    saveAddress(address);
                } catch (Exception ex) {
                    System.debug(LoggingLevel.WARN, 'Erro ao salvar endereço da API: ' + ex.getMessage());
                }
                return address;
            }
            
        } catch (ExternalServiceException ex) {
            System.debug(LoggingLevel.WARN, 'Erro na API externa: ' + ex.getMessage());
        }
        
        // Se não encontrou na API ou houve erro, busca no repositório local
        return repository.findByCep(cep);
    }
    
    /**
     * @description Estratégia: busca apenas no cache local
     * @param cep CEP para busca
     * @return AddressDto encontrado ou null
     */
    @TestVisible
    private AddressDto searchCacheOnly(String cep) {
        return repository.findByCep(cep);
    }
    
    /**
     * @description Estratégia: busca apenas na API externa
     * @param cep CEP para busca
     * @return AddressDto encontrado ou null
     */
    @TestVisible
    private AddressDto searchApiOnly(String cep) {
        return externalService.getAddressByCep(cep);
    }
}