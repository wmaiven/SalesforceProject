/**
 * @description Interface para serviços externos de endereços
 * Define contrato para integração com APIs externas
 */
public interface IExternalAddressService {
    /**
     * @description Busca endereço em serviço externo por CEP
     * @param cep CEP para busca
     * @return AddressDto com dados do endereço ou null se não encontrado
     * @throws ExternalServiceException em caso de erro na integração
     */
    AddressDto getAddressByCep(String cep);
    
    /**
     * @description Verifica se o serviço está disponível
     * @return true se o serviço está disponível
     */
    Boolean isServiceAvailable();
}