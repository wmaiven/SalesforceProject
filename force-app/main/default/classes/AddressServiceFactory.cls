/**
 * @description Factory para criação de serviços de endereço
 * Implementa padrão Factory Method
 * Centraliza criação e configuração de dependências
 */
public class AddressServiceFactory {
    
    /**
     * @description Enum para tipos de estratégia de busca
     */
    public enum SearchStrategy {
        CACHE_FIRST,    // Busca primeiro no cache/banco, depois na API
        API_FIRST,      // Busca primeiro na API, depois no cache/banco
        CACHE_ONLY,     // Busca apenas no cache/banco
        API_ONLY        // Busca apenas na API
    }
    
    /**
     * @description Cria instância do serviço de endereços
     * @param strategy Estratégia de busca a ser utilizada
     * @return Instância configurada do AddressService
     */
    public static AddressService createAddressService(SearchStrategy strategy) {
        IAddressRepository repository = createRepository();
        IExternalAddressService externalService = createExternalService();
        
        return new AddressService(repository, externalService, strategy);
    }
    
    /**
     * @description Cria instância padrão do serviço (CACHE_FIRST)
     * @return Instância configurada do AddressService
     */
    public static AddressService createDefaultAddressService() {
        return createAddressService(SearchStrategy.CACHE_FIRST);
    }
    
    /**
     * @description Cria instância do repositório
     * @return Implementação do repositório
     */
    @TestVisible
    private static IAddressRepository createRepository() {
        return new AddressRepository();
    }
    
    /**
     * @description Cria instância do serviço externo
     * @return Implementação do serviço externo
     */
    @TestVisible
    private static IExternalAddressService createExternalService() {
        return new ViaCepService();
    }
}