/**
 * @description Interface para repositório de endereços
 * Define contrato para acesso a dados de endereços
 */
public interface IAddressRepository {
    /**
     * @description Busca endereço por CEP
     * @param cep CEP para busca
     * @return AddressDto com dados do endereço ou null se não encontrado
     */
    AddressDto findByCep(String cep);
    
    /**
     * @description Salva endereço no sistema
     * @param address Dados do endereço para salvar
     * @return Id do registro criado
     */
    Id save(AddressDto address);
    
    /**
     * @description Busca endereços por cidade
     * @param city Nome da cidade
     * @return Lista de endereços da cidade
     */
    List<AddressDto> findByCity(String city);
}